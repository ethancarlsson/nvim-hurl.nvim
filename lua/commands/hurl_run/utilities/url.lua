local url = {}

---@param s string
---@return string
function url.get_from_string(s)
	return string.match(s, '[a-z]*://[^ >,;"]*')
end

return url
