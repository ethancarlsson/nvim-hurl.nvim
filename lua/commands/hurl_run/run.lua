local hurl_run_command = require('commands.hurl_run.utilities.command')
local hurl_run_service = require('commands.hurl_run.utilities.hurl_run_service')

local hurl_run = {}

---@param command string
---@param io object
---@return string
local function get_hurl_result(command, io)
	local handle, err = io.popen(command .. ' 2>&1', 'r')

	if err ~= nil then
		return err
	end

	if handle == nil then
		return 'something went wrong while running hurl file'
	end

	local result = handle:read('*all')

	handle:close()

	return result
end

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
	local command = hurl_run_command.get_command(filename, '--verbose', io)
	local result = get_hurl_result(command, io)

	local buf = vim.api.nvim_create_buf(false, false)
	hurl_run_service.set_lines_and_filetype_from_result(result, buf, command, vim)
	vim.api.nvim_buf_set_option(buf, "readonly", false)

	return buf
end


---@param vim object
---@param io object
---@return integer, integer
function hurl_run.verbose(vim, io)
	local filetype = vim.bo.filetype
	if filetype ~= 'hurl' then
		print('cannot run hurl command in non-hurl file')
		return -1, -1
	end

	local filename = vim.api.nvim_buf_get_name(0)
	local command = hurl_run_command.get_command(filename, '--verbose', io)
	local result = get_hurl_result(command, io)

	local buf = vim.api.nvim_create_buf(false, false)
	local verbose_buf = vim.api.nvim_create_buf(false, false)

	hurl_run_service.set_lines_and_verbose_from_result(result, buf, verbose_buf, command, vim)
	vim.api.nvim_buf_set_option(buf, "readonly", false)
	vim.api.nvim_buf_set_option(verbose_buf, "readonly", false)

	return buf, verbose_buf
end

return hurl_run
