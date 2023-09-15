# autopairs
a simple neovim autopair plugin 
# installation
vim-plug
```lua
  Plug 'Sam-Programs/autopairs.nvim'
```
packer
```lua
use({"Sam-programs/autopairs.nvim"})
```
# setup
``` lua 
require("autopairs.nvim").setup({})
```
this is the default setup
```lua
require("autopairs.nvim").setup({
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
# features
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
