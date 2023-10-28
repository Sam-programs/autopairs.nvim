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

local bracketList     = {
   { '{',  '}' },
   { '(',  ')' },
   { '[',  ']' },
   { '\"', '\"' },
   { '\'', '\'' },
}

local wrapForwardKey  = '<C-e>'
local wrapBackwradKey = '<C-a>'
local cmdline         = true
local wordRegex       = '%w'
--plugin code


local function init()
   local api = vim.api
   local OPENING = 1
   local CLOSING = 2
   local function distanceToNextWord(i, line)
      local distance = 1
      while distance < #line - i do
         if string.match(stri(line, i + distance), wordRegex) == nil then
            distance = distance - 1
            break;
         end
         distance = distance + 1
      end
      return distance
   end

   local function distanceToEndOfPrevWord(i, line)
      local distance = 0
      while distance < i do
         if string.match(stri(line, i - distance), wordRegex) == nil then
            distance = distance + 1
            break;
         end
         distance = distance + 1
      end
      return distance
   end

   local function saveUndo()
      local ctrlg = api.nvim_replace_termcodes("<C-g>", true, false, true)
      api.nvim_feedkeys(ctrlg .. "u", "n", false);
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
      local cursorRow, cursorCol = unpack(api.nvim_win_get_cursor(0));
      cursorRow                  = cursorRow - 1;
      local line                 = api.nvim_buf_get_lines(0, cursorRow, cursorRow + 1, false)[1];
      local prev                 = stri(line, cursorCol - 1);
      local dataBeforeCursor     = strsub(line, 0, cursorCol - 1);
      local dataAfterCursor      = strsub(line, cursorCol);
      local filteredOpenBrackets
      local filteredClosedBrackets
      -- not willing to rewrite this :>
      if open ~= close then
         filteredOpenBrackets   = strcontains(dataBeforeCursor, open) -
             strcontains(dataBeforeCursor, close)
         filteredClosedBrackets = strcontains(dataAfterCursor, close) - strcontains(dataAfterCursor, open);
      else
         filteredClosedBrackets = strcontains(dataBeforeCursor, close) % 2
         filteredOpenBrackets   = strcontains(dataAfterCursor, open) % 2
         --avoid the check for less than
         if filteredClosedBrackets ~= filteredOpenBrackets then
            filteredOpenBrackets = 0
            filteredClosedBrackets = 1
         end
      end
      line = insertChar(line, cursorCol - 1, open);
      if filteredClosedBrackets <= filteredOpenBrackets and
          prev ~= '\\'
      then
         line = insertChar(line, cursorCol, close);
      end
      api.nvim_buf_set_lines(0, cursorRow, cursorRow + 1, false, { line })
      saveUndo()
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
         vim.keymap.set("c", "<bs>", function()
            local line = vim.fn.getcmdline()
            local c = vim.fn.getcmdpos()
            local prev = line:sub(c - 1, c - 1)
            local cur = line:sub(c, c)
            for _, cmd_bracket in pairs(bracketList) do
               if prev == cmd_bracket[OPENING] then
                  if cur == cmd_bracket[CLOSING] then
                     return '<del><bs>'
                  end
               end
            end
            return '<bs>'
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
      saveUndo()
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
      saveUndo()
   end)
   -- ' gets a speical function
   -- because i can't write can't properly without this function
   vim.keymap.set("i", "\'", function()
      local r, c = unpack(api.nvim_win_get_cursor(0));
      r = r - 1;
      local line = api.nvim_buf_get_lines(0, r, r + 1, false)[1];
      local prev = stri(line, c - 1)
      if string.match(prev, wordRegex) or
          prev == '\\'
      then
         api.nvim_feedkeys('\'', "n", false);
      else
         brackets('\'', '\'');
      end
      saveUndo()
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
               return '<BS><DEL>';
            end
         end
      end
      return '<BS>';
   end, { expr = true, noremap = true })

   local function formated_on_cr()
      OLD_cinkeys = vim.o.cinkeys
      OLD_indentkeys = vim.o.indentkeys
      OLD_cindent = vim.o.cindent
      OLD_indentexpr = vim.o.indentexpr
      if vim.o.filetype == 'lisp' then
         vim.cmd(
            'if !exists("*GetLispIndent")\n' ..
            'function GetLispIndent() \n' ..
            'return lispindent(v:lnum) \n' ..
            'endfunction\n' ..
            'endif \n')
         vim.o.indentexpr = 'GetLispIndent()'
      end
      if vim.o.indentexpr ~= '' then
         vim.o.indentkeys = '!^F'
      else
         vim.o.cinkeys = '!^F'
         vim.o.cindent = true
      end
      return
          '<cr><cr><end><C-f><Up><C-f><c-g>u' ..
          -- restore the user's configuration
          '<cmd>lua ' ..
          ' vim.o.cindent    = OLD_cindent' ..
          ' vim.o.cinkeys    = OLD_cinkeys' ..
          ' vim.o.indentkeys = OLD_indentkeys' ..
          ' vim.o.indentexpr = OLD_indentexpr<cr>'
   end


   --this works better than <ESC>O because it only draws the cursor once
   --it would have been easier to make this perfect make if i had learnt to not skim documentation
   vim.keymap.set("i", "<cr>", function()
      local cursorRow, cursorCol = unpack(api.nvim_win_get_cursor(0));
      cursorRow = cursorRow - 1
      local line = api.nvim_buf_get_lines(0, cursorRow, cursorRow + 1, false)[1]
      local prev = stri(line, cursorCol - 1)
      local cur = stri(line, cursorCol)
      for _, bracket in pairs(bracketList) do
         if prev == bracket[OPENING] then
            if cur == bracket[CLOSING] then
               return formated_on_cr()
            end
         end
      end

      return '<CR>'
   end, { expr = true, noremap = true })
end

M.setup = function(config)
   if config then
      if config.bracketList then
         bracketList = config.bracketList
      end
      if config.wrapForwardKey then
         wrapForwardKey = config.wrapForwardKey
      end
      if config.wrapBackwradKey then
         wrapBackwradKey = config.wrapBackwradKey
      end
      if config.cmdline then
         cmdline = config.cmdline
      end
      if config.wordRegex then
         wordRegex = config.wordRegex
      end
   end
   init()
end
return M
