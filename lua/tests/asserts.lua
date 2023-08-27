---@param expected any
---@param actual any
---@param message string?
local function assert_equals(expected, actual, message)
	if expected == actual then
		return true
	end

	if message ~= nil then
		print(message)
	end

	print(string.format('failed asserting %s = %s', expected, actual))
	return false
end

return {
	assert_equals = assert_equals
}
