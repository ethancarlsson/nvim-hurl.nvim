
local function clean_json(json_string)
	-- Remove any trailing commas and ensure the string is a valid JSON object

	local trimmed = vim.trim(json_string)
	local without_trailing_comma = trimmed:gsub(",$", "")
	return "{" .. without_trailing_comma .. "}"
end

--- Transforms a string of JSON into a string of CLI variables to be passed to
--- the hurl run command.
---
--- It will work with some partially valid JSON objects, for example: `"key": "value",`
--- is interpreted as `{"key": "value"}`. This is to improve ergonomics when selecting
--- variables from data.
---
---@param json_string string The JSON string to convert.
---@param include_non_scalar boolean Default false. Set to true to be able to set json arrays and objects as well
---@return table A table of variables that can be used to fill temporary variables
local function parse(json_string, include_non_scalar)
	if include_non_scalar == nil then
		include_non_scalar = false
	end

	local success, tbl = pcall(vim.json.decode, json_string)

	if not success then
		success, tbl = pcall(vim.json.decode, clean_json(json_string))
		if not success then
			return {}
		end
	end

	if type(tbl) ~= "table" then
		return {}
	end

	local res = {}

	for k, v in pairs(tbl) do
		if type(k) ~= "string" then
			return {}
		end

		if not include_non_scalar and type(v) == "table" then
			goto continue
		end

		if type(v) == "string" then
			res[k] = string.format([["%s"]], v)
			goto continue
		end

		if type(v) ~= "string" then
			res[k] = vim.json.encode(v)
		end

		::continue::
	end

	return res
end

return {
	parse = parse,
}
