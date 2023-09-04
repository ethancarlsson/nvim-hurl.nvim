local function starts_with(str, start)
	return str:sub(1, #start) == start
end

---@param line string
local function is_header(line)
	return not (
	    starts_with(line, '*') or starts_with(line, '<')
	    )
	    and line:find('[%a%d]+%s*:%s*[%a%d{}:"/*%[%]()@%%+*%- _%.;,\\\'?!<>=#$&`|~^%%]+$')
end

local headers = {}

---@param verbose_lines table<string>
---@return table<string>
function headers.get_request_headers_from_verbose_lines(verbose_lines)
	local h = {}

	for _, line in ipairs(verbose_lines) do
		if starts_with(line, '<') then
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
