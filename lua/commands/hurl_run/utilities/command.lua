local constants = require('commands.constants.files')

---@param filename string
---@param options string
---@param io_object object?
local function get_command(filename, options, io_object)
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

return {
	get_command = get_command
}
