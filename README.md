# nvim-hurl
`nvim-hurl` is a simple set of utitities to help you explore APIs using 
`hurl` and `neovim`. 

![gif showing how nvim-hurl can be used](https://raw.githubusercontent.com/ethancarlsson/nvim-hurl-images/master/example_gifs/nvimhurl.gif) 

## Installation
Using [packer.nvim](https://github.com/wbthomason/packer.nvim)
```lua
use 'ethancarlsson/nvim-hurl.nvim'
```

Using [lazy.nvim](https://github.com/folke/lazy.nvim)
```lua
-- init.lua
{
	{ 'ethancarlsson/nvim-hurl.nvim' }
}
-- plugins/hurl.lua
return {
	{ 'ethancarlsson/nvim-hurl.nvim' }
}
```

## Usage 
The plugin will automatically install some commands but it's usually more
comfortable to run those commands through a keymap.
```lua
vim.keymap.set('n', '<leader>hy', '<cmd>HurlYank<CR>',
    { desc = 'Run hurl file in buffer and yank contents to the register "*"' })
vim.keymap.set('n', '<leader>hr', '<cmd>HurlRun<CR>',
    { desc = 'Run hurl file in buffer and paste it\'s content into a split window' })
vim.keymap.set('n', '<leader>hf', '<cmd>HurlRunFull<CR>',
    { desc = 'Run hurl file with full output even on large files' })
vim.keymap.set('n', '<leader>hj', '<cmd>HurlRunFull json<CR>',
    { desc = 'Run hurl file with and set the scratch file to json' })
vim.keymap.set('n', '<leader>hv', '<cmd>HurlRunVerbose<CR>',
    { desc = 'Run hurl file and get additional meta info along with it' })
```

## Commands
### :HurlYank
Run a hurl file and yank the results into the `"*` register.

### :HurlRun
Run a hurl file and view the results in a split window scratch file. This will
set the file type of the result based on content type in the response header.
It will not give the full response if it is too large.

### :HurlRunFull
Run a hurl file and view the results in a split window scratch file. The same as
HurlRun but without setting the file type, useful for when the response is too
large for `HurlRun`.

### :Hurlsvf {variable_file_location}
Hurl [s]et [v]ariables [f]iles. This command will set the variables file for a
project.

### :HurlVerbose
Run a hurl file and view the result and the results of the hurl `--verbose` option
in two seperate scratch files.
