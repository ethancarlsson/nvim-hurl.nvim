local constants = require('commands.constants.files')

---@param filename string
---@param options string
local function get_command(filename, options)
	local command = 'hurl'

	local f = io.open(constants.VARS_FILE, 'r')

	if f ~= nil then
		local variable_file_location = f:read('*a')

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

return {
	get_command = get_command
}
