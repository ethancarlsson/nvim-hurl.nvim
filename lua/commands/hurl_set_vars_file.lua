local constants = require('commands.constants.files')
local temp_variables = require('commands.hurl_run.utilities.temp_variables')

local M = {}

---@param variables_location string
function M.hurl_set_vars_file(variables_location)
	local f = io.open(constants.VARS_FILE, "w+")

	if f == nil then
		return
	end

	f:write(os.getenv('PWD') .. '/' .. variables_location)
	f:close()
end

---@param variable string?
---@param name string?
function M.hurl_set_var(name, variable)
	if variable == nil or name == nil then
		print('Variable not set. :Hurlsv requires two arguments with the form `:Hurlsv {name} {variable}`')
		return;
	end

	temp_variables.set_variable(name, variable)
end

function M.hurl_clear_vars()
	temp_variables.clear_variables()
end

return M
