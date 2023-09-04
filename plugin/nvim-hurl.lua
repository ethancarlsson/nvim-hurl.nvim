vim.cmd [[ au BufRead,BufNewFile *.hurl                setfiletype hurl ]]

vim.cmd([[ command! HurlYank lua require('commands.hurl_yank').yank() ]])

require('commands.hurl_run')
vim.cmd([[ command! HurlRun lua require('commands.hurl_run').run() ]])
vim.cmd([[ command! HurlRunVerbose lua require('commands.hurl_run').verbose() ]])
vim.cmd(
	[[ command! -nargs=1 Hurlsvf lua require('commands.hurl_set_vars_file').hurl_set_vars_file(<f-args>)]]
)
vim.cmd(
	[[ command! -nargs=* HurlGo lua require('commands.hurl_run').go(<f-args>)]]
)
vim.cmd(
	[[ command! -nargs=* HurlGoFromCursor lua require('commands.hurl_run').go_from_cursor(<f-args>)]]
)
