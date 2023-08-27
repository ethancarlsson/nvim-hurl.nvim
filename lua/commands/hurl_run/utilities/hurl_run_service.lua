local service = {}

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
---@param vim object
function service.set_lines_and_filetype_from_result(result, buf, command, vim)
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

return service
