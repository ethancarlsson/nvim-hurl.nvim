local hurl_run_command = require("nvim-hurl.hurl_run.utilities.command")
local hurl_run_service = require("nvim-hurl.hurl_run.utilities.hurl_run_service")
local headers = require("nvim-hurl.hurl_run.utilities.headers")
local windowsplit = require("nvim-hurl.windows.split")
local window = require("nvim-hurl.windows.window")
local state = require("nvim-hurl.hurl_run.utilities.state")
local url_service = require("nvim-hurl.hurl_run.utilities.url")
local conf = require("nvim-hurl.lib.conf")

local hurl_run = {}

---@param verbose_buf integer
---@param buf integer
---@param data table<string>
local function write_verbose(verbose_buf, buf, data)
	local line_count = vim.api.nvim_buf_line_count(verbose_buf)
	vim.api.nvim_buf_set_lines(verbose_buf, line_count, line_count, false, data)

	local response_filetype = hurl_run_service.get_file_type_of_response(data)

	if response_filetype ~= nil then
		vim.api.nvim_set_option_value("filetype", response_filetype, { buf = buf })
		windowsplit.reset_window()
	end

	vim.api.nvim_set_option_value("filetype", "sh", { buf = verbose_buf })
	state:set_current_headers(headers.get_request_headers_from_verbose_lines(data))
end

---@param buf integer
---@param data table<string>
local function read_verbose_on_stderr(buf, data)
	local response_filetype = hurl_run_service.get_file_type_of_response(data)

	if response_filetype ~= nil then
		vim.api.nvim_set_option_value("filetype", response_filetype, { buf = buf })
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

---@param on_stderr function
---@param on_stdout function
---@param write_cmd function|nil
local function run(io, l1, l2, on_stderr, on_stdout, write_cmd)
	local command = hurl_run_command.get_command("--verbose", io)
	local curr_buff = vim.api.nvim_get_current_buf()

	if conf.log then
		print(command)
	end

	-- Clear here to make sure we don't have to think about async with headers
	state:clear_current_headers()

	-- vim.api.nvim_buf_line_count(curr_buff) - 1 -1 to account for first line being 1 not 0
	local is_whole_file = l2 - l1 == vim.api.nvim_buf_line_count(curr_buff) - 1
	-- Read whole file where possible (pipes don't always work well with hurl on large files)
	if is_whole_file then
		local filepath = vim.fn.expand("%")

		local cmd = command .. " " .. filepath
		if write_cmd ~= nil then
			write_cmd({cmd})
		end

		return vim.fn.jobstart(command .. " " .. filepath, {
			on_stderr = on_stderr,
			on_stdout = on_stdout,
		})
	end

	local request_content = vim.api.nvim_buf_get_lines(curr_buff, l1 - 1, l2, false)
	local request_string = table.concat(request_content, "\n")

	local cmd = "echo '" .. request_string .. "' | " .. command
	if write_cmd ~= nil then
		write_cmd(vim.split(cmd, "\n"))
	end

	return vim.fn.jobstart(cmd, {
		on_stderr = on_stderr,
		on_stdout = on_stdout,
	})
end

---@param io iolib
---@return integer, integer
function hurl_run.run(io, l1, l2)
	local filetype = vim.bo.filetype
	if filetype ~= "hurl" then
		print("cannot run hurl command in non-hurl file")
		return -1, -1
	end

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_set_option_value("readonly", false, { buf = buf })

	return buf,
		run(io, l1, l2, function(_, data)
			read_verbose_on_stderr(buf, data)
		end, function(_, data)
			run_on_stdout(buf, data)
		end)
end

---@param io iolib
---@return integer, integer, integer
function hurl_run.verbose(io, l1, l2)
	local filetype = vim.bo.filetype

	if filetype ~= "hurl" then
		print("cannot run hurl command in non-hurl file")
		return -1, -1, -1
	end

	local buf = vim.api.nvim_create_buf(false, false)
	local verbose_buf = vim.api.nvim_create_buf(false, false)

	vim.api.nvim_set_option_value("readonly", false, { buf = buf })
	vim.api.nvim_set_option_value("readonly", false, { buf = verbose_buf })

	local chan_id = run(io, l1, l2, function(_, data)
		write_verbose(verbose_buf, buf, data)
	end, function(_, data)
		run_on_stdout(buf, data)
	end, function(cmd)
		write_verbose(verbose_buf, buf, cmd)
	end)

	return buf, verbose_buf, chan_id
end

---@param io iolib
---@return integer job
function hurl_run.yank(io, l1, l2)
	local filetype = vim.bo.filetype
	if filetype ~= "hurl" then
		print("cannot run hurl command in non-hurl file")
		return -1
	end

	local request_content = vim.api.nvim_buf_get_lines(vim.api.nvim_get_current_buf(), l1 - 1, l2, false)
	local request_string = table.concat(request_content, "")

	local result = ""
	local command = hurl_run_command.get_command("", io)

	if conf.log then
		print(command)
	end

	return vim.fn.jobstart("echo '" .. request_string .. "' | " .. command, {
		on_stdout = function(_, data)
			for _, v in ipairs(data) do
				result = result .. v
			end

			vim.fn.setreg("*", result)
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

		vim.api.nvim_set_option_value("readonly", false, { buf = buf })

		for _, line in ipairs(data) do
			table.insert(result, line)
		end

		local line_count = vim.api.nvim_buf_line_count(buf)
		vim.api.nvim_buf_set_lines(buf, 0, line_count, false, result)

		windowsplit.split_to_buf(buf)
	end

	local curl_command = "curl -sS " .. url

	if noreuse ~= "noreuse" then
		curl_command = hurl_run_command.get_curl_go_to(url)
	end
	if conf.log then
		print(curl_command)
	end

	local buf = window.get_buf_of_window(window.TEMP_RESULT_WINDOW)

	if buf == nil then
		buf = vim.api.nvim_create_buf(false, true)
	end

	local line_count = vim.api.nvim_buf_line_count(buf)
	vim.api.nvim_buf_set_lines(buf, 0, line_count, false, { "" })

	return vim.fn.jobstart(curl_command, {
		on_stdout = go_on_stdout,
		on_stderr = go_on_stdout, -- Not a mistake, just realised
		-- That it's the same
	})
end

---@param noreuse string
function hurl_run.go_from_cursor(noreuse)
	local url = url_service.get_from_string(vim.fn.expand("<cWORD>"))
	if url == nil then
		print("cant go to a non-url resource")
		return
	end

	hurl_run.go(url, noreuse)
end

return hurl_run
