local constants = require('commands.constants.files')
local temp_variables = require('commands.hurl_run.utilities.temp_variables')
local jsontovariables = require('lib.jsontovariables')

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

--- Sets variables from JSON in the given register
---@param register string?
function M.hurl_set_vars_register_json(register)
	if register == nil then
		print('Variable not set. :Hurlsvr requires one argument with the form `:Hurlsvr {register}`')
		return;
	end

	local contents = vim.fn.getreg(register)
	local variable_tbl = jsontovariables.parse(contents)

	for name, variable in pairs(variable_tbl) do
		temp_variables.set_variable(name, variable)
	end
end

function M.hurl_clear_vars()
	temp_variables.clear_variables()
end

return M
