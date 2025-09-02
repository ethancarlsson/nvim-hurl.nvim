local string_utilities = require('nvim-hurl.hurl_run.utilities.strings')

local headers = {}

-- Match based on format described here:
-- https://developers.cloudflare.com/rules/transform/request-header-modification/reference/header-format/
local header_pattern = '--header \'[%a%d_%-]+%s*:%s*[%a%d{}:"/*%[%]()@%%+*%- _%.;,\\?!<>=#$&`|~^%%]+\''

---@param verbose_lines table<string>
---@return table<string>
function headers.get_request_headers_from_verbose_lines(verbose_lines)
	for _, line in ipairs(verbose_lines) do
		if string_utilities.starts_with(line, '* curl') then
			local s, _ = string.gsub(line, '* curl', '')

			local curl_headers = string.gmatch(s, header_pattern)

			local h = {}
			for header in curl_headers do
				table.insert(h, header)
			end


			return h
		end
	end

	return {}
end

return headers
