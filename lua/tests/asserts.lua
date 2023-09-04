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

local asserts = {}

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
function asserts.assert_equals(expected, actual, message)
	if type(expected) == 'table' and type(actual) == 'table' then
		return assert_equals_ordered_tables(expected, actual, message)
	else
		return assert_equals(expected, actual, message)
	end
end

return asserts
