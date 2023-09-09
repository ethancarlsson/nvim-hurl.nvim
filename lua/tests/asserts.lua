local M = {}

---@param old string
---@param new string
---@return string
local function get_string_diff(old, new)
	local prv = {}
	for o = 0, #old do
		prv[o] = ""
	end
	for n = 1, #new do
		local nxt = { [0] = new:sub(1, n) }
		local nn = new:sub(n, n)
		for o = 1, #old do
			local result
			if nn == old:sub(o, o) then
				result = prv[o - 1]
			else
				result = prv[o] .. nn
				if #nxt[o - 1] <= #result then
					result = nxt[o - 1]
				end
			end
			nxt[o] = result
		end
		prv = nxt
	end
	return prv[#old]
end

---@param expected table
---@param actual table
---@param message string?
local function assert_equals_ordered_tables(expected, actual, message)
	local expected_concat = table.concat(expected, ', ')
	local actual_concat = table.concat(actual, ', ')

	if expected_concat == actual_concat then
		return true
	end

	if message ~= nil then
		print(message)
	end

	print(string.format(
		'failed asserting expected %s = %s\ndiff: %s',
		actual_concat,
		expected_concat,
		get_string_diff(actual_concat, expected_concat))
	)

	return false
end

---@param expected any
---@param actual any
---@param message string?
---@return boolean
local function assert_equals(expected, actual, message)
	if expected == actual then
		return true
	end

	if message ~= nil then
		print(message)
	end

	print(string.format('failed asserting expected %s = %s', expected, actual))
	return false
end

---@param expected any
---@param actual any
---@param message string?
function M.assert_equals(expected, actual, message)
	if type(expected) == 'table' and type(actual) == 'table' then
		return assert_equals_ordered_tables(expected, actual, message)
	else
		return assert_equals(expected, actual, message)
	end
end

---@param expected_contains string
---@param str string
---@param message string?
---@return boolean
function M.assert_string_contains(expected_contains, str, message)
	if str:find(expected_contains) then
		return true
	end

	if message ~= nil then
		print(message)
	end

	print(string.format('failed asserting that %s contains the string %s'))

	return false
end

return M
