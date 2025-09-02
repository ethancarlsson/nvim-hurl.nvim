local asserts = require("nvim-hurl.tests.asserts")
local jsontovariables = require("nvim-hurl.lib.jsontovariables")

return {
	["test: parse with empty json returns empty table"] = function()
		local result = jsontovariables.parse("{}", false)

		return asserts.assert_equals({}, result)
	end,

	["test: parse with example variables returns variables"] = function()
		local result = jsontovariables.parse([[{"example": "value", "key": 2}]], false)

		return asserts.assert_equals([["value"]], result.example) and asserts.assert_equals("2", result.key)
	end,

	["test: parse non scalar values returns only scalar"] = function()
		local result = jsontovariables.parse([[{
			"example": "value", "arr": [], "obj": {}
			}]], false)

		return asserts.assert_equals([["value"]], result.example)
			and asserts.assert_equals(nil, result.arr)
			and asserts.assert_equals(nil, result.obj)
	end,

	["test: parse non scalar values returns only scalar but include_non_scalar used"] = function()
		local result = jsontovariables.parse([[{
			"example": "value", "arr": [], "obj": {}
			}]], true)

		return asserts.assert_equals([["value"]], result.example)
			and asserts.assert_equals("[]", result.arr)
			and asserts.assert_equals("{}", result.obj)
	end,

	["test: parse with scalar values"] = function()
		local result = jsontovariables.parse([[{
			"int": 2, "null": null, "float": 2.2,
			"true": true, "false": false, "string": "value"
			}]], false)

		return asserts.assert_equals([["value"]], result.string)
			and asserts.assert_equals("2", result.int)
			and asserts.assert_equals("2.2", result.float)
			and asserts.assert_equals("true", result["true"])
			and asserts.assert_equals("false", result["false"])
			and asserts.assert_equals("null", result["null"])
	end,

	["test: with invalid json returns empty table"] = function()
		local result = jsontovariables.parse("{]", false)

		return asserts.assert_equals({}, result)
	end,

	["test: with partially valid json object makes it valid and builds table"] = function()
		local result = jsontovariables.parse([["key": "value",]], false)

		return asserts.assert_equals([["value"]], result.key)
	end,

	["test: with multiple partially valid JSON properties"] = function()
		local result = jsontovariables.parse([[

		"key": "value", "key2": "value2",
		"key3": "value3",

		]], false)

		return asserts.assert_equals([["value"]], result.key)
			and asserts.assert_equals([["value2"]], result.key2)
			and asserts.assert_equals([["value3"]], result.key3)
	end,
}
