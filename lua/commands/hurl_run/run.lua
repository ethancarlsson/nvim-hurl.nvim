local hurl_run_command = require('commands.hurl_run.utilities.command')
local hurl_run_service = require('commands.hurl_run.utilities.hurl_run_service')
local headers = require('commands.hurl_run.utilities.headers')
local windowsplit = require('commands.windows.split')
local window = require('commands.windows.window')
local state = require('commands.hurl_run.utilities.state')
local url_service = require('commands.hurl_run.utilities.url')

local hurl_run = {}

---@param verbose_buf integer
---@param buf integer
---@param data table<string>
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
	state:set_current_headers(headers.get_request_headers_from_verbose_lines(data))
end

---@param buf integer
---@param data table<string>
local function read_verbose_on_stderr(buf, data)
	local response_filetype = hurl_run_service
	    .get_file_type_of_response(data)

	if response_filetype ~= nil then
		vim.api.nvim_buf_set_option(buf, 'filetype', response_filetype)
		windowsplit.reset_window()
	end

	state:set_current_headers(headers.get_request_headers_from_verbose_lines(data))
end

---@param buf integer
---@param data table<string>
local function run_on_stdout(buf, data)
	local line_count = vim.api.nvim_buf_line_count(buf)
	vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, data)
end

---@param io iolib
---@return integer, integer
function hurl_run.run(io)
	local filetype = vim.bo.filetype
	if filetype ~= 'hurl' then
		print('cannot run hurl command in non-hurl file')
		return -1, -1
	end

	local buf = vim.api.nvim_create_buf(false, false)
	vim.api.nvim_buf_set_option(buf, "readonly", false)

	local filename = vim.api.nvim_buf_get_name(0)

	-- Clear here to make sure we don't have to think about async with headers
	state:clear_current_headers()
	local command = hurl_run_command.get_command(filename, '--verbose', io)
	print(command)

	return buf, vim.fn.jobstart(command, {
		on_stderr = function(_, data) read_verbose_on_stderr(buf, data) end,
		on_stdout = function(_, data) run_on_stdout(buf, data)
		end,
	})
end

---@param io iolib
---@return integer, integer, integer
function hurl_run.verbose(io)
	local filetype = vim.bo.filetype

	if filetype ~= 'hurl' then
		print('cannot run hurl command in non-hurl file')
		return -1, -1, -1
	end

	local buf = vim.api.nvim_create_buf(false, false)
	local verbose_buf = vim.api.nvim_create_buf(false, false)

	vim.api.nvim_buf_set_option(buf, 'readonly', false)
	vim.api.nvim_buf_set_option(verbose_buf, 'readonly', false)

	local filename = vim.api.nvim_buf_get_name(0)
	-- Clear here to make sure we don't have to think about async with headers
	state:clear_current_headers()

	local command = hurl_run_command.get_command(filename, '--verbose', io)
	print(command)

	return buf, verbose_buf, vim.fn.jobstart(command, {
		on_stderr = function(_, data) write_verbose_on_stderr(verbose_buf, buf, data) end,
		on_stdout = function(_, data) run_on_stdout(buf, data)
		end,
	})
end

---@param io iolib
---@return integer job
function hurl_run.yank(io)
	local filetype = vim.bo.filetype
	if filetype ~= 'hurl' then
		print('cannot run hurl command in non-hurl file')
		return -1
	end

	local filename = vim.api.nvim_buf_get_name(0)

	local result = ''
	local command = hurl_run_command.get_command(filename, '', io)

	print(command)
	return vim.fn.jobstart(command, {
		on_stdout = function(_, data)
			for _, v in ipairs(data) do
				result = result .. v
			end

			vim.fn.setreg('*', result)
		end,
	})

end

---@param noreuse string?
---@param url string
---@return integer job
function hurl_run.go(url, noreuse)

	local result = {}

	local function go_on_stdout(_, data)
		-- We only want to create/update the buffer when we
		-- get the response. That way the user can keep interacting with
		-- the previous response.
		local buf = window.get_buf_of_window(window.TEMP_RESULT_WINDOW)

		if buf == nil then
			buf = vim.api.nvim_create_buf(false, false)
		end

		vim.api.nvim_buf_set_option(buf, 'readonly', false)

		for _, line in ipairs(data) do
			table.insert(result, line)
		end

		local line_count = vim.api.nvim_buf_line_count(buf)
		vim.api.nvim_buf_set_lines(buf, 0, line_count, false, result)

		windowsplit.split_to_buf(buf)
	end

	local curl_command = 'curl -sS ' .. url

	if noreuse ~= 'noreuse' then
		curl_command = hurl_run_command.get_curl_go_to(url)
	end
	print(curl_command)

	local buf = window.get_buf_of_window(window.TEMP_RESULT_WINDOW)

	if buf == nil then
		buf = vim.api.nvim_create_buf(false, true)
	end

	local line_count = vim.api.nvim_buf_line_count(buf)
	vim.api.nvim_buf_set_lines(buf, 0, line_count, false, { '' })

	return vim.fn.jobstart(curl_command, {
		on_stdout = go_on_stdout,
		on_stderr = go_on_stdout, -- Not a mistake, just realised
		-- That it's the same
	})
end

---@param noreuse string
function hurl_run.go_from_cursor(noreuse)
	local url = url_service.get_from_string(vim.fn.expand('<cWORD>'))
	if url == nil then
		print('cant go to a non-url resource')
		return
	end

	hurl_run.go(url, noreuse)
end

return hurl_run
