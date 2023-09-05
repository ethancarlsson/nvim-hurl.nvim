local s = {}

---@param str string
---@param start string
---@return boolean
function s.starts_with(str, start)
	return str:sub(1, #start) == start
end

return s
