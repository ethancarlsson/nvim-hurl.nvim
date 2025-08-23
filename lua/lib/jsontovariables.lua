
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
---@return table A table of variables that can be used to fill temporary variables
local function parse(json_string)
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

		if type(v) == "table" then
			goto continue
		end

		if type(v) == "string" then
			res[k] = string.format([["%s"]], v)
			goto continue
		end

		-- There's probably a better way to check for this
		if string.format("%s", v) == "vim.NIL" then
			res[k] = "null"
			goto continue
		end

		if type(v) ~= "string" then
			res[k] = v
		end

		::continue::
	end

	return res
end

return {
	parse = parse,
}
