local constants = require('commands.constants.files')
local state = require('commands.hurl_run.utilities.state')
local temp_variables = require('commands.hurl_run.utilities.temp_variables')

local c = {}

---@param filename string
---@param options string
---@param io iolib
function c.get_command(filename, options, io)
	local command = 'hurl'

	local file = io.open(constants.VARS_FILE, 'r')

	if file ~= nil then
		local variable_file_location = file:read('*a')

		file:close()
		return string
		    .format(
		            '%s %s --variables-file=%s %s %s',
		            command,
		            temp_variables.get_variables_as_command_options(),
		            variable_file_location,
		            options,
		            filename
		    )
	end

	return string.format(
		'%s %s %s %s',
		command,
		temp_variables.get_variables_as_command_options(),
		options,
		filename
	)
end

---@param url string
---@return string
function c.get_curl_go_to(url)
	local curl = 'curl -sS ' .. url
	    :gsub('?', '\\?')
	    :gsub('=', '\\=')
	    :gsub('&', '\\&')
	    :gsub('%^', '\\^')

	local headers = state:get_headers()

	if #headers == 0 then
		return curl
	end

	return curl .. ' ' .. table.concat(headers, ' ')
end

return c
