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

this plugin doesn't have  builtin cmp support because it's not that hard to impelement
and i want you to create it your own customized autopairs for cmp
```lua
local kind = cmp.lsp.CompletionItemKind
-- auto add pairs
local function pair_on_confirm(event)
   local entry = event.entry
   local item = entry:get_completion_item()
   local keys = "()"
   local functionsig = item.label
   if item.kind == kind.Function or item.kind == kind.Method then
      -- auto skip empty functions
      if functionsig:sub(#functionsig - 1,#functionsig) ~= '()' then
         keys = keys .. '<left>'
         keys = vim.api.nvim_replace_termcodes(keys, true, false, true)
      end
      vim.api.nvim_feedkeys(keys, "n", false)
   end
end
cmp.event:on('confirm_done',pair_on_confirm) 
```
if u want to learn more about cmp read the types in its lua/cmp/types
