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
   wordRegex = '%w',
   cmdline = true
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
word wrap + inverse wrap
```
<C-e>
(|)foo.bar -> (|foo).bar
(|foo).bar -> (|foo.bar)

<C-a>
(|foo.bar) -> (|foo).bar
(|)foo.bar -> (|foo).bar

```
Insert new indented line after Return 
```
{|} -> {
           |
       }
```
Skip ' when the previous character is a letter

Ignore auto pair when the previous character is \

Very simple command line support

i didn't make a jump out of pair function becaues this does the job for me
```lua
vim.keymap.set("i", "<C-j>", "<down><end><cr>")

{
     |   C-j here
}
| and you go here
```

the formmating for Return uses cindenting if indentexpr is empty
which should be fine for most cases
am not so sure about lisp but it seems fine to me (not a lisp expert)
