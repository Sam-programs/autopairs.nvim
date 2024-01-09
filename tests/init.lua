-- init.lua
-- if u are using lazy
local lazypath = vim.fn.stdpath('data') .. '/lazy/'
vim.o.rtp = 
lazypath .. 'keymap-tester.nvim' .. ',' ..
lazypath .. 'autopairs.nvim' .. ','

-- if u don't turn off indenting you'ill have to add the extra spaces to the tests
vim.o.indentexpr = '0'
require('autopairs').setup{}
local ok,Test = pcall(require,'keymap-tester')
if not ok then
   print('keymap-tester.nvim is required for testing expand.nvim')
   print('https://github.com/Sam-programs/keymap-tester.nvim')
   vim.cmd('q!')
end

Test("{", "{}", "{} pair", "")
Test("(", "()", "() pair", "")
Test("[", "[]", "[] pair", "")

Test("{<bs>", "", "{} pair delete", "")
Test("(<bs>", "", "() pair delete", "")
Test("[<bs>", "", "[] pair delete", "")
Test("a", "", "should fail", "")



vim.cmd('q!')
