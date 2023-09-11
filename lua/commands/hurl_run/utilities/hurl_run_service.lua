local string_utilities = require('commands.hurl_run.utilities.strings')

local service = {}

---@param content_type string
---@return string?
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

	return nil
end

---@param line string
---@param i integer
---@return string?
local function get_file_type(line, i)
	-- Have to check the first line explicitly in case the headers get split
	-- accross multiple lines. This usually happens when the response
	-- is large and can't be returned to stdout/stderr in one go.
	if i == 1 and (
	    string_utilities.starts_with(line, 'content-type:', nil, true) ~= nil
	        or string_utilities.starts_with(line, ': application')
	    )
	then
		return get_file_type_from_content_type(line)
	end


	if not string_utilities.starts_with(line, '<') then
		return nil
	end

	local lowered_line = line:lower()

	if string_utilities.starts_with(lowered_line, '< content-type') then
		return get_file_type_from_content_type(lowered_line)
	end
	return nil

end

---@param verbose_lines string[]
---@return string?
function service.get_file_type_of_response(verbose_lines)
	for i, s in ipairs(verbose_lines) do
		local file_type = get_file_type(s, i)

		if file_type ~= nil then
			return file_type
		end
	end

	return nil
end

return service
