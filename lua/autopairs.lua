---@diagnostic disable: deprecated
--
-- my first neovim plugin
-- it isn't really too custimizable
--

-- i am done with this projects base
-- what i learnt while making this project is 2 things
-- 1. don't do math and logic without pen and paper
-- 2. making a project open source results in me being pressured (by my self) to finish it
-- and make something actually useful
-- by pressuring myself i actually made an autopairs that integrates better with status lines (than nvim-autopairs and vim autopairs they are still wonderful plugins tho)
-- i made it all work in insert mode it also moves the cursor a lot less

local M = {};

M.state = {
   disabled = false,
   rules = {},
   buf_ts = {},
}
-- string utils

-- str:sub but with 0 indexing
local function strsub(str, b, e)
   if e then
      return str:sub(b + 1, e + 1)
   end
   return str:sub(b + 1)
end
-- get an element by index in a string
-- 0 indexing
local function stri(str, i)
   return strsub(str, i, i)
end
-- insert an element to a string
-- 0 indexing
local function insertChar(str, i, c)
   return strsub(str, 0, i) .. c .. strsub(str, i + 1, #str)
end
local function rmChar(str, i)
   return strsub(str, 0, i - 1) .. strsub(str, i + 1, #str)
end
-- returns the number of occurences of c in str
-- c is a character
local function strcontains(str, c)
   local i = 0
   local count = 0;
   while i < #str do
      if stri(str, i) == c then
         count = count + 1
      end
      i = i + 1
   end
   return count
end

local function strrepeat(str, n)
   local i = 0
   local result = '';
   while i < n do
      result = result .. str
      i = i + 1
   end
   return result
end

local bracketList     = {
   { '{',  '}' },
   { '(',  ')' },
   { '[',  ']' },
   { '\"', '\"' },
   { '\'', '\'' },
}

--  don't get confused you are not a compiler
-- (;) -> ();
-- {;} -> {};
local semiOutPair     = {
   {
      ['{'] = true,
      ['('] = true,
   },
   {
      [')'] = true,
      ['}'] = true,
   }
}

local wrapForwardKey  = '<C-e>'
local wrapBackwradKey = '<C-a>'
local cmdline         = true
--plugin code


local function init()
   --i could use a string contains
   --but this is cooler
   --letters to wrap when pressing () over one of them
   -- |foo_    -> (foo_)
   -- |foo.bar -> (foo).bar
   local letters = {
      ['a'] = true,
      ['b'] = true,
      ['c'] = true,
      ['d'] = true,
      ['e'] = true,
      ['f'] = true,
      ['g'] = true,
      ['h'] = true,
      ['i'] = true,
      ['j'] = true,
      ['k'] = true,
      ['l'] = true,
      ['m'] = true,
      ['n'] = true,
      ['o'] = true,
      ['p'] = true,
      ['q'] = true,
      ['r'] = true,
      ['s'] = true,
      ['t'] = true,
      ['u'] = true,
      ['v'] = true,
      ['w'] = true,
      ['x'] = true,
      ['y'] = true,
      ['z'] = true,
      ['A'] = true,
      ['B'] = true,
      ['C'] = true,
      ['D'] = true,
      ['E'] = true,
      ['F'] = true,
      ['G'] = true,
      ['H'] = true,
      ['I'] = true,
      ['J'] = true,
      ['K'] = true,
      ['L'] = true,
      ['M'] = true,
      ['N'] = true,
      ['O'] = true,
      ['P'] = true,
      ['Q'] = true,
      ['R'] = true,
      ['S'] = true,
      ['T'] = true,
      ['U'] = true,
      ['V'] = true,
      ['W'] = true,
      ['X'] = true,
      ['Y'] = true,
      ['Z'] = true,
      ['0'] = true,
      ['1'] = true,
      ['2'] = true,
      ['3'] = true,
      ['4'] = true,
      ['5'] = true,
      ['6'] = true,
      ['7'] = true,
      ['8'] = true,
      ['9'] = true,
   }
   local api = vim.api
   local OPENING = 1
   local CLOSING = 2
   -- hybird between lisp indent and c indent
   local function hyindent(lnum)
      local lispindent = vim.fn.lispindent(lnum + 1)
      if lispindent == 0 then
         return vim.fn.cindent(lnum + 1)
      end
      return lispindent
   end
   vim.keymap.set("i", ";", function()
      local cursorRow, cursorCol = unpack(api.nvim_win_get_cursor(0));
      cursorRow = cursorRow - 1
      local line = api.nvim_buf_get_lines(0, cursorRow, cursorRow + 1, false)[1]
      local current = stri(line, cursorCol)
      local next = stri(line, cursorCol + 1)
      if next == ';' then
         return ''
      end
      if semiOutPair[OPENING][current] ~= nil then
         return '<right><right>;<left><left>'
      end
      if semiOutPair[CLOSING][current] ~= nil then
         return '<right>;<left><left>'
      end
      return ';'
   end, { expr = true, noremap = true })
   vim.keymap.set("n", ";", function()
      local cursorRow, cursorCol = unpack(api.nvim_win_get_cursor(0));
      cursorRow = cursorRow - 1
      local line = api.nvim_buf_get_lines(0, cursorRow, cursorRow + 1, false)[1]
      local finalChar = stri(line,#line - 1)
      if finalChar ~= ';' then
         line = strsub(line,0,#line - 1) .. ';'
      end
      api.nvim_buf_set_lines(0, cursorRow, cursorRow + 1, false, { line })
   end)
   local function distanceToNextWord(i, line)
      local distance = 1
      while distance < #line - i do
         if letters[stri(line, i + distance)] == nil then
            distance = distance - 1
            break;
         end
         distance = distance + 1
      end
      return distance
   end

   local function distanceToEndOfPrevWord(i, line)
      local distance = 1
      while distance < i do
         if letters[stri(line, i - distance)] == nil then
            distance = distance + 1
            break;
         end
         distance = distance + 1
      end
      return distance
   end

   local function distanceToNextChar(i, line, c)
      local distance = 1
      while distance < #line - i do
         if stri(line, i + distance) == c then
            break;
         end
         distance = distance + 1
      end
      return distance
   end
   local function brackets(open, close)
      local cursorRow, cursorCol              = unpack(api.nvim_win_get_cursor(0));
      cursorRow                               = cursorRow - 1;
      local line                              = api.nvim_buf_get_lines(0, cursorRow, cursorRow + 1, false)[1];
      local prev                              = stri(line, cursorCol - 1);
      local dataBeforeCursor                  = strsub(line, 0, cursorCol - 1);
      local dataAfterCursor                   = strsub(line, cursorCol);
      local filteredOpenBracketsBeforeCursor  = strcontains(dataBeforeCursor, open) -
          strcontains(dataBeforeCursor, close);
      local filteredClosedBracketsAfterCursor = strcontains(dataAfterCursor, close) - strcontains(dataAfterCursor, open);
      line                                    = insertChar(line, cursorCol - 1, open);
      --this might not be the best way to check if there are missing end brackets
      --but its good enough
      if filteredClosedBracketsAfterCursor <= filteredOpenBracketsBeforeCursor and
          prev ~= '\\'
      then
         -- word wrapping
         local distance = distanceToNextWord(cursorCol, line)
         line = insertChar(line, cursorCol + distance, close);
      end
      api.nvim_buf_set_lines(0, cursorRow, cursorRow + 1, false, { line })
      api.nvim_win_set_cursor(0, { cursorRow + 1, cursorCol + 1 })
   end
   for _, bracket in pairs(bracketList) do
      vim.keymap.set("i", bracket[OPENING], function()
         brackets(bracket[OPENING], bracket[CLOSING])
      end)
      if cmdline then
         vim.keymap.set("c", bracket[OPENING], function()
            return bracket[OPENING] .. bracket[CLOSING] .. '<left>'
         end, { expr = true, noremap = true })
      end
   end

   vim.keymap.set("i", wrapForwardKey, function()
      local cursorRow, cursorCol = unpack(api.nvim_win_get_cursor(0));
      cursorRow = cursorRow - 1;
      local line = api.nvim_buf_get_lines(0, cursorRow, cursorRow + 1, false)[1];
      local prev = stri(line, cursorCol - 1)
      local closing = ''
      for _, bracket in pairs(bracketList) do
         if prev == bracket[OPENING] then
            closing = bracket[CLOSING]
            break;
         end
      end
      if closing == '' then
         return
      end
      local distance = cursorCol - 1 + distanceToNextChar(cursorCol - 1, line, closing)
      line = rmChar(line, distance)
      distance = distance + distanceToNextWord(distance, line)
      line = insertChar(line, distance, closing)
      api.nvim_buf_set_lines(0, cursorRow, cursorRow + 1, false, { line })
   end)
   vim.keymap.set("i", wrapBackwradKey, function()
      local cursorRow, cursorCol = unpack(api.nvim_win_get_cursor(0));
      cursorRow = cursorRow - 1;
      local line = api.nvim_buf_get_lines(0, cursorRow, cursorRow + 1, false)[1];
      local prev = stri(line, cursorCol - 1)
      local closing = ''
      for _, bracket in pairs(bracketList) do
         if prev == bracket[OPENING] then
            closing = bracket[CLOSING]
            break;
         end
      end
      if closing == '' then
         return
      end
      local distance = cursorCol - 1 + distanceToNextChar(cursorCol - 1, line, closing)
      line = rmChar(line, distance)
      distance = distance - 1
      distance = distance - distanceToEndOfPrevWord(distance, line)
      if distance >= cursorCol then
         line = insertChar(line, distance, closing)
      else
         line = insertChar(line, cursorCol - 1, closing)
      end
      api.nvim_buf_set_lines(0, cursorRow, cursorRow + 1, false, { line })
   end)
   -- ' gets a speical function
   -- because i can't write can't properly without this function
   vim.keymap.set("i", "\'", function()
      local r, c = unpack(api.nvim_win_get_cursor(0));
      r = r - 1;
      local line = api.nvim_buf_get_lines(0, r, r + 1, false)[1];
      local prev = stri(line, c - 1)
      if letters[prev] or
          prev == '\\'
      then
         api.nvim_feedkeys('\'',"n",false);
      end
      brackets('\'', '\'');
   end)

   vim.keymap.set("i", "<BS>", function()
      local r, c = unpack(api.nvim_win_get_cursor(0));
      r = r - 1;
      local line = api.nvim_buf_get_lines(0, r, r + 1, false)[1];
      local prev = stri(line, c - 1)
      local next = stri(line, c)
      for _, bracket in pairs(bracketList) do
         if prev == bracket[OPENING] then
            if next == bracket[CLOSING] then
               return '<right><BS><BS>';
            end
         end
      end
      return '<BS>';
   end, { expr = true, noremap = true })

   --this works better than <ESC>O because it only draws the cursor once
   --this took hours of trying to perfect it all thanks to feedkeys
   vim.keymap.set("i", "<CR>", function()
      local cursorRow, cursorCol = unpack(api.nvim_win_get_cursor(0));
      cursorRow = cursorRow - 1
      local line = api.nvim_buf_get_lines(0, cursorRow, cursorRow + 1, false)[1]
      local prev = stri(line, cursorCol - 1)
      local cur = stri(line, cursorCol)
      if prev == '{' and cur == '}' then
         local dataBeforeCursor = strsub(line, 0, cursorCol - 1)
         api.nvim_buf_set_lines(0, cursorRow, cursorRow + 1, false, { dataBeforeCursor })

         local dataAfterCursor = strsub(line, cursorCol, #line)
         api.nvim_buf_set_lines(0, cursorRow + 1, cursorRow + 1, false, { dataAfterCursor })

         local indentLevel = hyindent(cursorRow + 1)
         dataAfterCursor = strrepeat(" ", indentLevel) .. dataAfterCursor
         api.nvim_buf_set_lines(0, cursorRow + 1, cursorRow + 2, false, { dataAfterCursor })
      end
      -- i have no clue why i need to move the cursor back and forwards to make the indetation update for enter
      local right = api.nvim_replace_termcodes("<right>", true, false, true)
      local left = api.nvim_replace_termcodes("<left>", true, false, true)
      api.nvim_feedkeys(left .. right, "t", false)
      local enter = api.nvim_replace_termcodes("<CR>", true, false, true)
      api.nvim_feedkeys(enter, "n", false)
   end);
end

M.setup = function(config)
   if config.bracketList then
      bracketList = config.bracketList
   end
   if config.semiOutPair then
      semiOutPair = config.semiOutPair
   end
   if config.wrapForwardKey then
      wrapForwardKey = config.wrapForwardKey
   end
   if config.wrapBackwradKey then
      wrapBackwradKey = config.wrapBackwradKey
   end
   if config.cmdline then
      wrapBackwradKey = config.cmdline
   end
   init()
end
return M
