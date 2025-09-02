local asserts = require("nvim-hurl.tests.asserts")
local service = require("nvim-hurl.hurl_run.utilities.hurl_run_service")

return {
	["test: get_file_type_of_response no content type header returns nothing"] = function()
		local actual = service.get_file_type_of_response({ "< no-content-type: nothing", "somethingelse: test" })

		return asserts.assert_equals(actual, nil, nil)
	end,
	["test: get_file_type_of_response with json returns json"] = function()
		local actual = service.get_file_type_of_response({ "< content-type: json", "somethingelse: test" })

		return asserts.assert_equals(actual, "json", nil)
	end,
	["test: get_file_type_of_response with html returns html"] = function()
		local actual = service.get_file_type_of_response({ "< content-type: html", "somethingelse: test" })

		return asserts.assert_equals(actual, "html", nil)
	end,
	["test: get_file_type_of_response with unknown filetype returns nothing"] = function()
		local actual = service.get_file_type_of_response({ "< content-type: not a thing", "somethingelse: test" })

		return asserts.assert_equals(actual, nil, nil)
	end,
	["test: get_file_type_of_response with content_type on first line without header-name gets content type"] = function()
		local actual = service.get_file_type_of_response({
			": application/json; charset=UTF-8",
			"< somethingelse: test",
		})

		return asserts.assert_equals(actual, "json", nil)
	end,
	["test: get_file_type_of_response with next line nil doesnt crash"] = function()
		local actual = service.get_file_type_of_response({
			"< content-type: json",
		})

		return asserts.assert_equals(actual, "json", nil)
	end,
	["test: get_file_type_of_response with unrelated content-types"] = function()
		local actual = service.get_file_type_of_response({
			"*",
			"* content-type: html",
			"< content-type: json",
			"> content-type: xml",
		})

		return asserts.assert_equals(actual, "json", nil)
	end,
	["test: get_file_type_of_response first line is content-type"] = function()
		local actual = service.get_file_type_of_response({
			"content-type: application/json",
		})

		return asserts.assert_equals(actual, "json", nil)
	end,
}
