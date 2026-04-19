local conf = require("nvim-hurl.lib.conf")
local M = {}

local function strOrDefault(val, default)
	if type(val) == "string" then
		return val
	end

	return default
end

function M.setup(config)
	if type(config) ~= "table" then
		config = {}
	end

	-- logging
	if type(config["log"]) == "boolean" then
		conf.log = config["log"]
	end

	-- completions
	local has_cmp, cmp = pcall(require, "cmp")

	if has_cmp then
		cmp.register_source("nvim_hurl", require("nvim-hurl.completions").new())
	end

	-- lsp
	if config["lsp"] == nil then
		config["lsp"] = false
	end

	if type(config["lsp"]) == "table" or (type(config["lsp"]) == "boolean" and config["lsp"]) then
		local init_opts = {}
		if type(config["lsp"]) == "table" then
			init_opts = config["lsp"]["init_options"]
		end

		if type(config["init_opts"]) ~= "table" then
			init_opts = {}
		end

		vim.lsp.config["hurl_ls"] = {
			cmd = { "hurl-lsp" },
			filetypes = {"hurl"},
			init_options = init_opts
		}

		vim.lsp.enable("hurl_ls")
	end

	-- keymaps
	local keymaps = config["keymaps"]
	if type(keymaps) ~= "table" then
		keymaps = {}
	end

	vim.api.nvim_create_autocmd("FileType", {
		pattern = "hurl",
		callback = function()
			vim.keymap.set(
				"n",
				strOrDefault(keymaps["run"], "<localleader>hr"),
				"<cmd>HurlRun<CR>",
				{ desc = "Run hurl file in buffer and paste it's content into a split window" }
			)

			vim.keymap.set(
				"v",
				strOrDefault(keymaps["run"], "<localleader>hr"),
				"<cmd>'<,'>HurlRun<CR>",
				{ desc = "Run hurl file in buffer and paste it's content into a split window" }
			)

			vim.keymap.set(
				"n",
				strOrDefault(keymaps["verbose"], "<localleader>hv"),
				"<cmd>HurlRunVerbose<CR>",
				{ desc = "Run hurl file and get additional meta info along with it" }
			)

			vim.keymap.set(
				"v",
				strOrDefault(keymaps["verbose"], "<localleader>hv"),
				"<cmd>'<,'>HurlRunVerbose<CR>",
				{ desc = "Run hurl file and get additional meta info along with it" }
			)

			vim.keymap.set(
				"n",
				strOrDefault(keymaps["cursor_go"], "<localleader>hh"),
				"<cmd>CurlGoFromCursor<CR>",
				{ desc = "Run a curl request from the url under the cursor" }
			)

			vim.keymap.set(
				"n",
				strOrDefault(keymaps["clear_vars"], "<localleader>hc"),
				"<cmd>Hurlvc<CR>",
				{ desc = "Clear all --variable options from your next Hurl command" }
			)

			vim.keymap.set(
				"n",
				strOrDefault(keymaps["yank_var"],"<localleader>yh"),
				[["8yy<cmd>Hurlsvr "8<CR>]],
				{ desc = "Yank line to register and then to hurl variables" }
			)
		end,
	})

end

return M
