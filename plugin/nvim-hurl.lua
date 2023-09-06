vim.cmd [[ au BufRead,BufNewFile *.hurl                setfiletype hurl ]]

vim.cmd([[ command! HurlYank lua require('commands.hurl_yank').yank() ]])
vim.cmd([[ command! HurlRun lua require('commands.hurl_run').run() ]])
vim.cmd([[ command! HurlRunVerbose lua require('commands.hurl_run').verbose() ]])
vim.cmd(
	[[ command! -nargs=1 Hurlsvf lua require('commands.hurl_set_vars_file').hurl_set_vars_file(<f-args>)]]
)
vim.cmd(
	[[ command! -nargs=+ Hurlsv lua require('commands.hurl_set_vars_file').hurl_set_var(<f-args>)]]
)
vim.cmd(
	[[ command! Hurlvc lua require('commands.hurl_set_vars_file').hurl_clear_vars()]]
)
vim.cmd(
	[[ command! -nargs=* CurlGo lua require('commands.hurl_run').go(<f-args>)]]
)
vim.cmd(
	[[ command! -nargs=* CurlGoFromCursor lua require('commands.hurl_run').go_from_cursor(<f-args>)]]
)
