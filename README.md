# nvim-hurl
`nvim-hurl` is a simple set of utitities to help you explore APIs using 
`hurl` and `neovim`. 

![gif showing how nvim-hurl can be used](https://raw.githubusercontent.com/ethancarlsson/nvim-hurl-images/master/example_gifs/nvimhurl.gif) 

NOTE: This is an unofficial plugin, visit https://hurl.dev for more information
about the project.

Also, note there is another project here: https://github.com/pfeiferj/nvim-hurl
that does something very similar to this. Check it out in case it serves your
needs better than this plugin.

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
vim.keymap.set('n', '<leader>hv', '<cmd>HurlRunVerbose<CR>',
    { desc = 'Run hurl file and get additional meta info along with it' })
vim.keymap.set('n', '<leader>hh', '<cmd>CurlGoFromCursor<CR>',
    { desc = 'Run a curl request from the url under the cursor' })
```

## Commands
### :HurlYank
Run a hurl file and yank the results into the `"*` register.

### :HurlRun
Run a hurl file and view the results in a split window scratch file. This will
set the file type of the result based on content type in the response header.

### :Hurlsvf {variable_file_location}
Hurl [s]et [v]ariables [f]iles. This command will set the variables file for a
project.

### :HurlVerbose
Run a hurl file and view the result and the results of the hurl `--verbose` option
in two seperate scratch files.
