---@diagnostic disable: deprecated
--
-- my first neovim plugin
-- it isn't really too custimizable
-- features request are welcome

local M = {}

M.state = {
   disabled = false,
   rules = {},
   buf_ts = {},
}

-- string utils

-- get an element by index in a string
-- 0 indexing
local function stri(str, i)
   return str:sub(i + 1, i + 1)
end

-- str:sub but with 0 indexing
local function strsub(str, b, e)
   if e then
      return str:sub(b + 1, e + 1)
   end
   return str:sub(b + 1)
end
-- insert an element to a string
-- 0 indexing
local function insertChar(str, i, c)
   return str:sub(1, i + 1) .. c .. str:sub(i + 2, #str)
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

local bracketList = {
   { '{',  '}' },
   { '(',  ')' },
   { '[',  ']' },
   { '\"', '\"' },
   { '\'', '\'' },
}

--  don't get confused you are not a compiler
-- (;) -> ();
-- {;} -> {};
local semiOutPair = {
   {
      ['{'] = true,
      ['('] = true,
   },
   {
      [')'] = true,
      ['}'] = true,
   }
}

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
      ['_'] = true,
      ['\"'] = true,
      ['\''] = true,
   }
   local api = vim.api
   local OPENING = 1
   local CLOSING = 2

   local function semicolon_handler()
      local r, c = unpack(api.nvim_win_get_cursor(0));
      r = r - 1
      local line = api.nvim_buf_get_lines(0, r, r + 1, false)[1];
      local current = stri(line, c)
      local next = stri(line, c + 1)
      local afterNext = stri(line, c + 2)
      if next == ';' then
         return ''
      end
      if afterNext == ';' then
         return ''
      end
      if semiOutPair[OPENING][current] ~= nil then
         return '<right><right>;<left><left>'
      end
      if semiOutPair[CLOSING][current] ~= nil then
         return '<right>;<left><left>'
      end
      return ';'
   end

   vim.keymap.set("i", ";", function()
      return semicolon_handler();
   end, { expr = true, noremap = true })

   vim.keymap.set("n", ";", function()
      local ret = semicolon_handler();
      if ret == ';' then
         return ';'
      end
      return 'i' .. ret .. '<ESC>'
   end, { expr = true, noremap = true })

   local function brackets(open, close)
      local r, c = unpack(api.nvim_win_get_cursor(0));
      r = r - 1;
      local line = api.nvim_buf_get_lines(0, r, r + 1, false)[1];
      local next = stri(line, c);
      local prev = stri(line, c - 1);
      local dataBeforeCursor = strsub(line, 0, c - 1);
      local dataAfterCursor = strsub(line, c);
      local openBracketsBeforeCursor = strcontains(dataBeforeCursor, open) - strcontains(dataBeforeCursor, close);
      local closedBracketsAfterCursor = strcontains(dataAfterCursor, close) - strcontains(dataAfterCursor, open);
      line = insertChar(line, c - 1, open);
      --this might not be the best way to check if there are missing end brackets
      --but its good enough
      if closedBracketsAfterCursor <= openBracketsBeforeCursor and
          prev ~= '\\'
      then
         -- word wrapping
         if letters[next] then
            while letters[next] do
               c = c + 1;
               next = stri(line, c);
            end
            c = c - 1
         end
         line = insertChar(line, c, close);
      end
      api.nvim_buf_set_lines(0, r, r + 1, false, { line });
      local right = api.nvim_replace_termcodes("<right>", true, false, true);
      vim.cmd('normal ==f' .. open)
      api.nvim_feedkeys(right, 'n', false);
   end
   for i, bracket in pairs(bracketList) do
      vim.keymap.set("i", bracket[OPENING], function()
         brackets(bracket[OPENING], bracket[CLOSING])
      end)
   end
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
         return "\'"
      end
      return "\'\'<left>"
   end, { expr = true, noremap = true })

   vim.keymap.set("i", "<BS>", function()
      local r, c = unpack(api.nvim_win_get_cursor(0));
      r = r - 1;
      local line = api.nvim_buf_get_lines(0, r, r + 1, false)[1];
      local prev = stri(line, c - 1)
      local next = stri(line, c)
      for i, bracket in pairs(bracketList) do
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
      local line = api.nvim_buf_get_lines(0, cursorRow - 1, cursorRow, false)[1]
      local prev = stri(line, cursorCol - 1)
      if prev == '{' then
         --had a weird indentation thats why ==
         return '<CR><CMD>normal ==k$<CR><right><CR>';
         -- {|<CR>
         -- }
      end
      return '<CR>'
   end, { expr = true, noremap = true })
end

M.setup = function(config)
   if config.bracketList then
      bracketList = config.bracketList
   end
   if config.semiOutPair then
      semiOutPair = config.semiOutPair
   end
   init()
end
return M
