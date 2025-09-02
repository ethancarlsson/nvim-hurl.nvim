vim.cmd([[ au BufRead,BufNewFile *.hurl                setfiletype hurl ]])

vim.cmd([[ command! -range=% HurlYank lua require('nvim-hurl.hurl_yank').yank(<line1>, <line2>) ]])
vim.cmd([[ command! -range=% HurlRun lua require('nvim-hurl.hurl_run').run(<line1>, <line2>) ]])
vim.cmd([[ command! -range=% HurlRunVerbose lua require('nvim-hurl.hurl_run').verbose(<line1>, <line2>) ]])
vim.cmd([[ command! Hurlvc lua require('nvim-hurl.hurl_set_vars_file').hurl_clear_vars()]])
vim.cmd([[ command! -nargs=* CurlGo lua require('nvim-hurl.hurl_run').go(<f-args>)]])
vim.cmd([[ command! -nargs=* CurlGoFromCursor lua require('nvim-hurl.hurl_run').go_from_cursor(<f-args>)]])

vim.cmd([[ command! -nargs=+ Hurlsv lua require('nvim-hurl.hurl_set_vars_file').hurl_set_var(<f-args>)]])
vim.cmd(
	[[ command! -nargs=1 Hurlsvr lua require('nvim-hurl.hurl_set_vars_file').hurl_set_vars_register_json(<f-args>)]]
)
vim.cmd([[ command! -nargs=1 Hurlsvf lua require('nvim-hurl.hurl_set_vars_file').hurl_set_vars_file(<f-args>)]])
