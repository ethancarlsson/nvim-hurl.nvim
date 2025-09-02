local conf = require("nvim-hurl.lib.conf")
local M = {}

function M.setup(config)
	if type(config) ~= "table" then
		return
	end

	if type(config["log"]) == "boolean" then
		conf.log = config["log"]
	end
end

return M
