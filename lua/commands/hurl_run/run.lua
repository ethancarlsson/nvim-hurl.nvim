local hurl_run_command = require('commands.hurl_run.utilities.command')
local hurl_run_service = require('commands.hurl_run.utilities.hurl_run_service')

local hurl_run = {}

---@param vim object
---@param io object
---@return integer
function hurl_run.run(vim, io)
	local filetype = vim.bo.filetype
	if filetype ~= 'hurl' then
		print('cannot run hurl command in non-hurl file')
		return -1
	end

	local filename = vim.api.nvim_buf_get_name(0)

	local command = '!' .. hurl_run_command.get_command(filename, '--verbose', io)
	---@diagnostic disable-next-line: undefined-field - it is defined.
	local result = vim.api.nvim_command_output(command)

	local buf = vim.api.nvim_create_buf(false, false)
	hurl_run_service.set_lines_and_filetype_from_result(result, buf, command, vim)
	vim.api.nvim_buf_set_option(buf, "readonly", false)

	return buf
end


return hurl_run
