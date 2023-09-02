local hurl_run_command = require('commands.hurl_run.utilities.command')
local hurl_run_service = require('commands.hurl_run.utilities.hurl_run_service')
local windowsplit = require('commands.windows.split')

local hurl_run = {}

local function write_verbose_on_stderr(verbose_buf, buf, data)
	local line_count = vim.api.nvim_buf_line_count(verbose_buf)
	vim.api.nvim_buf_set_lines(verbose_buf, line_count, line_count, false, data)

	local response_filetype = hurl_run_service
	    .get_file_type_of_response(data)

	if response_filetype ~= nil then
		vim.api.nvim_buf_set_option(buf, 'filetype', response_filetype)
		windowsplit.reset_window()
	end

	vim.api.nvim_buf_set_option(verbose_buf, 'filetype', 'sh')
end

local function read_verbose_on_stderr(buf, data)
	local response_filetype = hurl_run_service
	    .get_file_type_of_response(data)

	if response_filetype ~= nil then
		vim.api.nvim_buf_set_option(buf, 'filetype', response_filetype)
		windowsplit.reset_window()
	end
end

local function run_on_stdout(buf, data)
	local line_count = vim.api.nvim_buf_line_count(buf)
	vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, data)
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

	local buf = vim.api.nvim_create_buf(false, false)
	vim.api.nvim_buf_set_option(buf, "readonly", false)

	local filename = vim.api.nvim_buf_get_name(0)

	vim.schedule(function()
		local command = hurl_run_command.get_command(filename, '--verbose', io)
		vim.fn.jobstart(command, {
			on_stderr = function(_, data) read_verbose_on_stderr(buf, data) end,
			on_stdout = function(_, data) run_on_stdout(buf, data)
			end,
		})
	end)

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

	local buf = vim.api.nvim_create_buf(false, false)
	local verbose_buf = vim.api.nvim_create_buf(false, false)

	vim.api.nvim_buf_set_option(buf, "readonly", false)
	vim.api.nvim_buf_set_option(verbose_buf, "readonly", false)

	local filename = vim.api.nvim_buf_get_name(0)

	vim.schedule(function()
		local command = hurl_run_command.get_command(filename, '--verbose', io)
		vim.fn.jobstart(command, {
			on_stderr = function(_, data) write_verbose_on_stderr(verbose_buf, buf, data) end,
			on_stdout = function(_, data) run_on_stdout(buf, data)
			end,
		})
	end)

	return buf, verbose_buf
end

function hurl_run.yank(vim, io)
	local filetype = vim.bo.filetype
	if filetype ~= 'hurl' then
		print('cannot run hurl command in non-hurl file')
		return -1
	end

	local buf = vim.api.nvim_create_buf(false, false)
	vim.api.nvim_buf_set_option(buf, "readonly", false)

	local filename = vim.api.nvim_buf_get_name(0)

	local result = ''
	vim.schedule(function()
		local command = hurl_run_command.get_command(filename, '', io)
		vim.fn.jobstart(command, {
			on_stdout = function(_, data)
				for _, v in ipairs(data) do
					result = result .. v
				end

				vim.fn.setreg('*', result)
			end,
		})
	end)

	return buf
end

return hurl_run
