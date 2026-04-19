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

## Setup
Setup must be called for keymaps to be set and completions to be registerred

```lua
require("nvim-hurl").setup({
	log = false,
	lsp = {
		init_options = {},
	},
	keymaps = {
		run = "<localleader>hr", -- run the file
		verbose = "<localleader>hv", -- run the file in verbose mode
		cursor_go = "<localleader>hh", -- go to the URL location under the cursor
		clear_vars = "<localleader>hc", -- clear variables (excluding file variables)
		yank_var = "<localleader>yh" -- yank json line under cursor into variables, e.g. `"key": "value"` becomes `--variable key=variable`
	},
})
```

### Lsp
LSP registration is provided for [hurl-lsp](https://github.com/ethancarlsson/hurl-lsp).
The LSP can be installed with `go install github.com/ethancarlsson/hurl-lsp`.

```lua
require("nvim-hurl").setup({
	lsp = {
		init_options = {},
	},
})
```

## Commands

### :HurlRun

Run a hurl file and view the results in a split window scratch file. This will
set the file type of the result based on content type in the response header.


### :HurlVerbose

Run a hurl file and view the result and the results of the hurl `--verbose` option
in two seperate scratch files.

### :CurlGo

Make a simple GET request, reusing the headers of the previous request. To
prevent reuse of previous headers, use `:CurlGo {url} noreuse`.

### :CurlGoFromCursor

Run `CurlGo` running the but using the url directly under the cursor.

NOTE: Will reuse headers unless `noreuse` option is passed to it.

### :Hurlsvf {variable_file_location}

Hurl [s]et [v]ariables [f]iles. This command will set the variables file for a
project.

### :Hurlsv {name} {value}

Hurl [s]et [v]ariable. Sets a temporary variable, it is the equivelant to the
command line `--variable` option. It accepts exactly two arguments, the name
of the variable and the variable. `:Hurlsv name value` is equivelant to
`--variable name=value` from the command line.

NOTE: These values will not persist after your session ends.

### :Hurlsvr {register}

Hurl [s]et [v]ariable from [register]. Sets a temporary variable from the register.
It accepts the register as an argument and parses the contents of the register to
find the key and value.

The contents must be in json format or a partial json format, for example: {"key": "value"}
will set the hurl variable to `--variable key=variable`. If the contents are only
partial for example "key": "value" it will add the curly braces to make it valid json.

NOTE: only scalar values are supported, so nested objects or arrays will not be parsed.
If no key value pairs are found or if the JSON is not valid no values will be set.

## Completions

This plugin includes completions for the variables it adds in the background.
Just add the following to your cmp setup.

```lua
require("cmp").setup {
	sources = {
		{ name = "nvim_hurl" },
		-- other sources
	},
}
```
