local constants = require("nvim-hurl.constants.files")
local state = require("nvim-hurl.hurl_run.utilities.state")
local temp_variables = require("nvim-hurl.hurl_run.utilities.temp_variables")

local c = {}

---@param options string
---@param io iolib
function c.get_command(options, io)
	local vars_file = io.open(constants.VARS_FILE, "r")

	if vars_file ~= nil then
		local variable_file_location = vars_file:read("*a")

		vars_file:close()
		return string.format(
			"hurl %s --variables-file=%s %s",
			temp_variables.get_variables_as_command_options(),
			variable_file_location,
			options
		)
	end

	return string.format(
		"hurl %s %s",
		temp_variables.get_variables_as_command_options(),
		options
	)
end

---@param url string
---@return string
function c.get_curl_go_to(url)
	local curl = "curl -sS " .. url:gsub("?", "\\?"):gsub("=", "\\="):gsub("&", "\\&"):gsub("%^", "\\^")

	local headers = state:get_headers()

	if #headers == 0 then
		return curl
	end

	return curl .. " " .. table.concat(headers, " ")
end

return c
