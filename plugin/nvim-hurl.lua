vim.cmd [[ au BufRead,BufNewFile *.hurl                setfiletype hurl ]]

function HurlYank()
	local filetype = vim.bo.filetype
	if filetype ~= 'hurl' then return end

	local filename = vim.api.nvim_buf_get_name(0)

	local handle, err = io.popen('hurl ' .. filename)

	if handle == nil then
		print('something went wrong while running hurl file')
		return
	end

	if not err == nil then
		vim.fn.setreg('*', err)
		return
	end

	local result = handle:read('*all')

	handle:close()

	vim.fn.setreg('*', result)
end

vim.cmd([[ command! HurlYank lua HurlYank() ]])

require('commands.hurl_run')
vim.cmd([[ command! HurlRun lua HurlRun() ]])
vim.cmd([[ command! HurlRunFull lua HurlRunFull() ]])
