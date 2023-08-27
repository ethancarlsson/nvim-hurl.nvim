local constants = require('commands.constants.files')

---@param variables_location string
local function hurl_set_vars_file(variables_location)
	local f = io.open(constants.VARS_FILE, "w+")

	if f == nil then
		return
	end

	f:write(os.getenv('PWD') .. '/' .. variables_location)
	f:close()
end

return {
	hurl_set_vars_file = hurl_set_vars_file
}
