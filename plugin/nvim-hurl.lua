vim.cmd [[ au BufRead,BufNewFile *.hurl                setfiletype hurl ]]

vim.cmd([[ command! HurlYank lua require('commands.hurl_yank').yank() ]])

require('commands.hurl_run')
vim.cmd([[ command! HurlRun lua require('commands.hurl_run').run() ]])
vim.cmd([[ command! -nargs=* HurlRunFull lua require('commands.hurl_run').full(<f-args>) ]])
vim.cmd([[ command! HurlRunVerbose lua require('commands.hurl_run').verbose() ]])
vim.cmd(
	[[ command! -nargs=1 Hurlsvf lua require('commands.hurl_set_vars_file').hurl_set_vars_file(<f-args>)]]
)
