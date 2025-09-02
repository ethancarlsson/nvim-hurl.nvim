local s = {
	['headers'] = {}
}

---@param headers table<string>
function s:set_current_headers(headers)
	if #headers > 0 and headers[1] ~= '' then
		self['headers'] = headers
	end
end

function s:clear_current_headers()
	self['headers'] = {}
end

---@return table<string>
function s:get_headers()
	return self['headers']
end

return s
