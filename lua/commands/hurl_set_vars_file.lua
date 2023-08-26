require('commands.constants.files')

---@param variables_location string
local function hurl_set_vars_file(variables_location)
	local f = io.open(VARS_FILE, "w+")

	if f == nil then
		return
	end

	f:write(os.getenv('PWD') .. '/' .. variables_location)
	f:close()
end

---@param variables_location string
function HurlSetVarsFile(variables_location)
	hurl_set_vars_file(variables_location)
end
