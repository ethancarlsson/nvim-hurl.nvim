local M = {}

---@param str string
---@param start string
---@return boolean
function M.starts_with(str, start)
	return str:sub(1, #start) == start
end

---@param str string
---@return string
function M.trim6(str)
   return str:match'^()%s*$' and '' or str:match'^%s*(.*%S)'
end

return M
