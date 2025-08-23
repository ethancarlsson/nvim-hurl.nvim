vim.cmd([[ au BufRead,BufNewFile *.hurl                setfiletype hurl ]])

vim.cmd([[ command! -range=% HurlYank lua require('commands.hurl_yank').yank(<line1>, <line2>) ]])
vim.cmd([[ command! -range=% HurlRun lua require('commands.hurl_run').run(<line1>, <line2>) ]])
vim.cmd([[ command! -range=% HurlRunVerbose lua require('commands.hurl_run').verbose(<line1>, <line2>) ]])
vim.cmd([[ command! Hurlvc lua require('commands.hurl_set_vars_file').hurl_clear_vars()]])
vim.cmd([[ command! -nargs=* CurlGo lua require('commands.hurl_run').go(<f-args>)]])
vim.cmd([[ command! -nargs=* CurlGoFromCursor lua require('commands.hurl_run').go_from_cursor(<f-args>)]])

vim.cmd([[ command! -nargs=+ Hurlsv lua require('commands.hurl_set_vars_file').hurl_set_var(<f-args>)]])
vim.cmd([[ command! -nargs=1 Hurlsvr lua require('commands.hurl_set_vars_file').hurl_set_vars_register_json(<f-args>)]])
vim.cmd([[ command! -nargs=1 Hurlsvf lua require('commands.hurl_set_vars_file').hurl_set_vars_file(<f-args>)]])
