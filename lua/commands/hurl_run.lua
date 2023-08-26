require('commands.constants.files')

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

---@param filename string
---@param options string
local function get_command(filename, options)
	local command = 'hurl'

	local f = io.open(VARS_FILE, 'r')

	if f ~= nil then
		local variable_file_location = f:read('*a')

		return string.format('%s --variables-file=%s %s %s', command, variable_file_location, options, filename)
	end

	return string.format('%s %s %s', command, options, filename)
end

local temp_win = nil
local function split_to_buf(buf)
	local current_window = vim.api.nvim_get_current_win()
	if temp_win == nil or not vim.api.nvim_win_is_valid(temp_win) then

		vim.cmd('vsplit')
		local win = vim.api.nvim_get_current_win()
		temp_win = win

	end

	vim.api.nvim_buf_set_option(buf, "modified", false)
	vim.api.nvim_win_set_buf(temp_win, buf)
	vim.bo[buf].buftype = 'nofile'
	vim.bo[buf].bufhidden = 'hide'
	vim.bo[buf].swapfile = false

	vim.api.nvim_set_current_win(current_window)
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
		        not (is_debug(s)
		            or is_response_header
		            or is_http_request_header(s)
		            or s == ':' .. command)
		    ) then
			is_in_body = true -- in case we match inside the body
			table.insert(lines, s)
		end

		if is_response_header and string_starts_with(s, '< content-type:') then
			buf_file_type = get_file_type_from_content_type(s)
		end
	end

	vim.api.nvim_buf_set_text(buf, 0, 0, 0, 0, lines)

	vim.api.nvim_buf_set_option(buf, 'filetype', buf_file_type)

end

local function hurl_run()
	local filetype = vim.bo.filetype
	if filetype ~= 'hurl' then return end

	local filename = vim.api.nvim_buf_get_name(0)

	local command = '!' .. get_command(filename, '--verbose')
	---@diagnostic disable-next-line: undefined-field - it is defined.
	local result = vim.api.nvim_command_output(command)

	local buf = vim.api.nvim_create_buf(false, false)
	set_lines_and_filetype_from_result(result, buf, command)
	vim.api.nvim_buf_set_option(buf, "readonly", false)

	return buf
end

function HurlRun()
	local buf = hurl_run()
	split_to_buf(buf)
end

local function hurl_run_full()
	local filetype = vim.bo.filetype
	if filetype ~= 'hurl' then return end

	local filename = vim.api.nvim_buf_get_name(0)
	local command = get_command(filename, '')
	local handle, err = io.popen(command, 'r')

	if handle == nil then
		print('something went wrong while running hurl file')
		return
	end

	if not err == nil then
		vim.fn.setreg('*', err)
		return
	end

	local result = handle:read('*all')

	local buf = vim.api.nvim_create_buf(false, false)
	set_lines_and_filetype_from_result(result, buf, command)
	vim.api.nvim_buf_set_option(buf, "readonly", false)

	handle:close()

	return buf
end

--- This function is used for larger responses HurlRun() will cut off the result
--- by default.
function HurlRunFull()
	local buf = hurl_run_full()
	split_to_buf(buf)
end
