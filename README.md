# autopairs.nvim
a simple neovim autopair plugin 
## installation
vim-plug
```vim
  Plug 'Sam-Programs/autopairs.nvim'
  lua << EOF
  require("autopairs").setup {}
  EOF
```
packer
```lua
use {
    "Sam-programs/autopairs.nvim",
    config = function() require("autopairs").setup {} end
}
```
## setup
``` lua 
require("autopairs").setup({})
```
this is the default setup
```lua
require("autopairs").setup({
   semiOutPair = {
      {
         ['{'] = true,
         ['('] = true,
      },
      {
         [')'] = true,
         ['}'] = true,
      }
   },
   bracketList = {
      { '{',  '}' },
      { '(',  ')' },
      { '[',  ']' },
      { '\"', '\"' },
      { '\'', '\'' },
   },
})
```
## features
a lot of the features were inspired by jiangmiao/auto-pairs (accidentally)  
Insert pair
```
{ -> {}
```
Delete pair
```
{|} -> |
```
Semiclon out of pair
```
{;} -> {};
(;) -> ();
```
Word wrap
```
-- |foo_    -> (foo_)
-- |foo.bar -> (foo).bar
```
Insert new indented line after Return (only for {})
```
{|} -> {
           |
       }
```
Skip ' when inside a word

Ignore auto pair when previous character is \

planning to add jump to next and previous pair soon™ 
