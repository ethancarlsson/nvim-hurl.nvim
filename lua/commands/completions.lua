local cmp = require("cmp")

local source = {}

-- Create a new instance of the source
source.new = function()
	-- luacheck: globals setmetatable
	return setmetatable({}, { __index = source })
end

-- Check if the source is available
source.is_available = function()
	return vim.bo.filetype == "hurl"
end

source.get_trigger_characters = function()
	return { "{" }
end

-- Define the keyword pattern for triggering completion
source.get_keyword_pattern = function()
	return [[\%(\k\|\.\)\+]]
end

---This function is just to ensure that {{ is treated the same as { when adding
---the completion item.
---
---@param prefix string
---@return integer
local function braces_to_remove(prefix)
	if #prefix < 2 then
		return 1
	end

	local reversed = string.reverse(prefix)
	local firstBraceFromBack = string.find(reversed, "{")
	if not firstBraceFromBack then
		return 0
	end

	if string.sub(reversed, firstBraceFromBack + 1, firstBraceFromBack + 1) == "{" then
		return 2
	else
		return 1
	end
end

local function strsplit(inputstr, sep)
  if sep == nil then
    sep = "%s"
  end
  local t = {}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    table.insert(t, str)
  end
  return t
end

local function vars_from_file()
	local tbl = {}
	local constants = require("commands.constants.files")

	local vars_file_location = io.open(constants.VARS_FILE, "r")
	if vars_file_location == nil then
		return tbl
	end

	local variable_file_location = vars_file_location:read("*a")
	vars_file_location:close()

	local vars_file = io.open(variable_file_location, "r")
	if vars_file == nil then
		return tbl
	end

	local variables = vars_file:read("*a")
	vars_file:close()

	for _, value in ipairs(strsplit(variables, "\n")) do
		local kv = strsplit(value, "=")
		tbl[kv[1]] = kv[2] or ""
	end


	return tbl
end

-- Provide completion items
source.complete = function(_, params, callback)
	local tmp_vars = require("commands.hurl_run.utilities.temp_variables")

	local items = {}
	local prefix = string.sub(params.context.cursor_before_line, 1, params.offset - 1)

	local filevars = vars_from_file()
	local variables = tmp_vars.get_all()

	for key, value in pairs(filevars) do
		variables[key] = value
	end

	for key, value in pairs(variables) do
		local newText = "{{" .. key .. "}}"

		table.insert(items, {
			label = key,
			kind = cmp.lsp.CompletionItemKind.Variable,
			detail = "Variable",
			documentation = {
				kind = "hurl variable",
				value = "variable where " .. key .. "=" .. value,
			},
			textEdit = {
				newText = newText,
				range = {
					start = {
						line = params.context.cursor.row - 1,
						character = params.context.cursor.col - 1 - braces_to_remove(prefix),
					},
					["end"] = {
						line = params.context.cursor.row - 1,
						character = params.context.cursor.col - 1,
					},
				},
			},
			insertTextFormat = cmp.lsp.InsertTextFormat.Variable,
		})
	end

	callback(items)
end

-- Resolve additional information for a completion item (optional)
source.resolve = function(_, completion_item, callback)
	callback(completion_item)
end

return source
