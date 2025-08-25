local v = {
}

local variables = {}

function v.clear_variables()
	variables = {}
end

---@param name string
---@param value string
function v.set_variable(name, value)
	variables[name] = value
end

---@return string
function v.get_variables_as_command_options()

	local vars = {}

	for name, value in pairs(variables) do
		table.insert(vars, name .. '=' .. value)
	end

	if #vars == 0 then
		return ''
	end

	return '--variable ' .. table.concat(vars, ' --variable ')
end

---@return table
function v.get_all()
	return variables
end

return v
