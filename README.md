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
this is the default setup
```lua
require("autopairs").setup({
   wrapForwardKey = '<C-e>',
   wrapBackwradKey = '<C-a>',
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
{}-> {}
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
word wrap + inverse wrap
```
|foo    -> (foo)
|foo.bar -> (foo).bar

<C-e>
(|foo).bar -> (|foo.bar)
<C-a>
(|foo.bar) -> (|foo).bar
```
Insert new indented line after Return (only for {})
```
{|} -> {
           |
       }
```
Skip ' when inside a word

Ignore auto pair when the previous character is \

this is a personal project for c and c++
as of right now it seems complete without any issue for c and c++
i will not be working on it anymore (unless there is a serious issue)
