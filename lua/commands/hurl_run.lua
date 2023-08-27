local windows = require('commands.windows.window')
local hurl_run_command = require('commands.hurl_run.command')

-- http://lua-users.org/wiki/StringRecipes
local function string_starts_with(str, start)
	return str:sub(1, #start) == start
end

-- http://lua-users.org/wiki/StringRecipes
local function string_ends_with(str, ending)
	return ending == "" or str:sub(- #ending) == ending
end

---@param s string
---@return boolean
local function is_http_request_header(s)
	return string_starts_with(s, '>')
end

---@param s string
---@return boolean
local function is_http_response_header(s)
	return string_starts_with(s, '<') and not string_ends_with(s, '>')
end

---@param s string
---@return boolean
local function is_debug(s)
	return string_starts_with(s, '*')
end

---@param content_type string
---@return string
local function get_file_type_from_content_type(content_type)
	if string.match(content_type, 'json') then
		return 'json'
	end

	if string.match(content_type, 'html') then
		return 'html'
	end

	if string.match(content_type, 'xml') then
		return 'xml'
	end

	return ''
end


local function split_to_buf(buf)
	local current_window = vim.api.nvim_get_current_win()
	local win = windows.get_window(windows.TEMP_RESULT_WINDOW)
	if win == nil or not vim.api.nvim_win_is_valid(win) then

		vim.cmd('vsplit')
		win = windows.set_window(windows.TEMP_RESULT_WINDOW, vim.api.nvim_get_current_win())
	end

	vim.api.nvim_buf_set_option(buf, "modified", false)
	vim.api.nvim_win_set_buf(win, buf)
	vim.bo[buf].buftype = 'nofile'
	vim.bo[buf].bufhidden = 'hide'
	vim.bo[buf].swapfile = false

	vim.api.nvim_set_current_win(current_window)
end

---@param line string
---@param command string
---@return boolean
local function is_verbose_info(line, command)
	return (is_debug(line)
	    or is_http_response_header(line)
	    or is_http_request_header(line)
	    or line == ':' .. command)
end

---@param result string
---@param buf integer
---@param command string
local function set_lines_and_filetype_from_result(result, buf, command)
	local buf_file_type = ''
	local lines = {}
	local is_in_body = false
	for s in result:gmatch("[^\r\n]+") do
		local is_response_header = is_http_response_header(s)
		if (
		    (is_in_body)
		        or
		        not is_verbose_info(s, command)) then
			is_in_body = true -- in case we match inside the body
			table.insert(lines, s)
		end

		if is_response_header and string_starts_with(s:lower(), '< content-type:') then
			buf_file_type = get_file_type_from_content_type(s)
		end
	end

	vim.api.nvim_buf_set_text(buf, 0, 0, 0, 0, lines)

	vim.api.nvim_buf_set_option(buf, 'filetype', buf_file_type)
end

---@return integer
local function hurl_run()
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
	set_lines_and_filetype_from_result(result, buf, command)
	vim.api.nvim_buf_set_option(buf, "readonly", false)

	return buf
end

---@return integer
local function hurl_run_full()
	local filetype = vim.bo.filetype
	if filetype ~= 'hurl' then
		print('cannot run hurl command in non-hurl file')
		return -1
	end

	local filename = vim.api.nvim_buf_get_name(0)
	local command = hurl_run_command.get_command(filename, '', io)
	local handle, err = io.popen(command, 'r')

	if handle == nil then
		print('something went wrong while running hurl file')
		return -1
	end

	if err ~= nil then
		vim.fn.setreg('*', err)
		print('something went wrong while running hurl file')
		return -1
	end

	local result = handle:read('*all')

	local buf = vim.api.nvim_create_buf(false, false)
	set_lines_and_filetype_from_result(result, buf, command)
	vim.api.nvim_buf_set_option(buf, "readonly", false)

	handle:close()

	return buf
end

---@param result string
---@param buf integer
---@param command string
local function set_lines_and_verbose_from_result(result, buf, verbose_buf, command)
	local buf_file_type = ''
	local body_lines = {}
	local verbose_lines = {}
	local is_in_body = false

	for s in result:gmatch("[^\r\n]+") do
		local is_response_header = is_http_response_header(s)
		if (
		    (is_in_body)
		        or
		        not is_verbose_info(s, command)) then
			is_in_body = true -- in case we match inside the body
			table.insert(body_lines, s)
		else
			table.insert(verbose_lines, s)
		end

		if is_response_header and string_starts_with(s:lower(), '< content-type:') then
			buf_file_type = get_file_type_from_content_type(s)
		end
	end

	vim.api.nvim_buf_set_text(buf, 0, 0, 0, 0, body_lines)
	vim.api.nvim_buf_set_option(buf, 'filetype', buf_file_type)

	vim.api.nvim_buf_set_text(verbose_buf, 0, 0, 0, 0, verbose_lines)
	vim.api.nvim_buf_set_option(verbose_buf, 'filetype', 'sh')
end

---@return integer, integer
local function hurl_run_verbose()
	local filetype = vim.bo.filetype
	if filetype ~= 'hurl' then
		print('cannot run hurl command in non-hurl file')
		return -1, -1
	end

	local filename = vim.api.nvim_buf_get_name(0)

	local command = '!' .. hurl_run_command.get_command(filename, '--verbose', io)
	---@diagnostic disable-next-line: undefined-field - it is defined.
	local result = vim.api.nvim_command_output(command)

	local buf = vim.api.nvim_create_buf(false, false)
	local verbose_buf = vim.api.nvim_create_buf(false, false)

	set_lines_and_verbose_from_result(result, buf, verbose_buf, command)
	vim.api.nvim_buf_set_option(buf, "readonly", false)
	vim.api.nvim_buf_set_option(verbose_buf, "readonly", false)

	return buf, verbose_buf
end

local function split_to_buf_and_verbose(buf, verbose_buf)
	local current_window = vim.api.nvim_get_current_win()

	local result_win = windows.get_window(windows.TEMP_RESULT_WINDOW)
	local verbose_win = windows.get_window(windows.VERBOSE_RESULT_WINDOW)

	if result_win == nil or not vim.api.nvim_win_is_valid(result_win) then

		vim.cmd('vsplit')
		result_win = windows.set_window(windows.TEMP_RESULT_WINDOW, vim.api.nvim_get_current_win())
	end

	if verbose_win == nil or not vim.api.nvim_win_is_valid(verbose_win) then

		vim.cmd('split')
		verbose_win = windows.set_window(windows.VERBOSE_RESULT_WINDOW, vim.api.nvim_get_current_win())
	end


	vim.api.nvim_buf_set_option(buf, "modified", false)
	vim.api.nvim_win_set_buf(result_win, buf)

	vim.bo[buf].buftype = 'nofile'
	vim.bo[buf].bufhidden = 'hide'
	vim.bo[buf].swapfile = false

	vim.api.nvim_buf_set_option(verbose_buf, "modified", false)
	vim.api.nvim_win_set_buf(verbose_win, verbose_buf)

	vim.bo[verbose_buf].buftype = 'nofile'
	vim.bo[verbose_buf].bufhidden = 'hide'
	vim.bo[verbose_buf].swapfile = false

	vim.api.nvim_set_current_win(current_window)
end

return {
	verbose = function()
		local buf, verbose_buf = hurl_run_verbose()

		if buf == -1 then
			return
		end

		split_to_buf_and_verbose(buf, verbose_buf)
	end,
	run = function()
		local buf = hurl_run()

		if buf == -1 then
			return
		end

		split_to_buf(buf)
	end,
	full = function()
		local buf = hurl_run_full()

		if buf == -1 then
			return
		end

		split_to_buf(buf)
	end
}
