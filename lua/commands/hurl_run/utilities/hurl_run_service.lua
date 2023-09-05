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

---@param verbose_lines string[]
---@return string?
function service.get_file_type_of_response(verbose_lines)
	for _, s in pairs(verbose_lines) do
		if string_utilities.starts_with(s:lower(), '< content-type:') then
			return get_file_type_from_content_type(s)
		end
	end

	return nil
end

return service
