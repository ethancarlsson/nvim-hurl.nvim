local constants = require('commands.constants.files')
local state = require('commands.hurl_run.utilities.state')

local c = {}

---@param filename string
---@param options string
---@param io_object object?
function c.get_command(filename, options, io_object)
	local command = 'hurl'

	local file = io_object.open(constants.VARS_FILE, 'r')

	if file ~= nil then
		local variable_file_location = file:read('*a')

		file:close()
		return string
		    .format(
		            '%s --variables-file=%s %s %s',
		            command,
		            variable_file_location,
		            options,
		            filename
		    )
	end

	return string.format('%s %s %s', command, options, filename)
end

function c.get_curl_go_to(url)
	local curl = 'curl -sS ' .. url
	local headers = state:get_headers()

	if #headers == 0 then
		return curl
	end

	return curl .. ' --header "' .. table.concat(headers, '" --header "') .. '"'
end


return c
