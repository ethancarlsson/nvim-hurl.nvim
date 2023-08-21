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

	return ''
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

local function hurl_run()
	local filetype = vim.bo.filetype
	if filetype ~= 'hurl' then return end

	local filename = vim.api.nvim_buf_get_name(0)

	local command = '!hurl --verbose ' .. filename
	---@diagnostic disable-next-line: undefined-field - it is defined.
	local result = vim.api.nvim_command_output(command)

	local buf = vim.api.nvim_create_buf(false, false)
	vim.api.nvim_buf_set_option(buf, "readonly", false)

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

	return buf
end

function HurlRun()
	local buf = hurl_run()
	split_to_buf(buf)
end
