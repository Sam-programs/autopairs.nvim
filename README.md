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
the killer feature for this plugin is it never leaves insert mode
so diagnostics and mode in lualine  won't change
Insert pair
```
{;}-> {};
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
-- |foo    -> (foo)
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
