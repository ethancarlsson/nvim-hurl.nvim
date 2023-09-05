local string_utilities = require('commands.hurl_run.utilities.strings')

---@param line string
local function is_header(line)
	return not (
	    string_utilities.starts_with(line, '*') or string_utilities.starts_with(line, '<')
	    )
	    and line:find('[%a%d]+%s*:%s*[%a%d{}:"/*%[%]()@%%+*%- _%.;,\\\'?!<>=#$&`|~^%%]+$')
end

local headers = {}

---@param verbose_lines table<string>
---@return table<string>
function headers.get_request_headers_from_verbose_lines(verbose_lines)
	local h = {}

	for _, line in ipairs(verbose_lines) do
		if string_utilities.starts_with(line, '<') then
			return h
		end

		if is_header(line) then
			local clean_header = string.gsub(line, '> ', '', 1)
			table.insert(h, clean_header)
		end
	end

	return h
end

return headers
