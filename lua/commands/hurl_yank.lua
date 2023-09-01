return {
	yank = function()
		local filetype = vim.bo.filetype

		if filetype ~= 'hurl' then
			print('can not run HurlYank inside a non hurl file')
			return
		end

		local filename = vim.api.nvim_buf_get_name(0)

		local command = require('commands.hurl_run.utilities.command')
		    .get_command(filename, '', io)

		local handle, err = io.popen(command)

		if err ~= nil then
			print('something went wrong while running hurl file')
			return
		end

		if handle == nil then
			print('something went wrong while running hurl file')
			return
		end

		local result = handle:read('*all')

		handle:close()

		vim.fn.setreg('*', result)
	end
}
