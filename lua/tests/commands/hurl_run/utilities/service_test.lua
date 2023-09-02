local asserts = require('tests.asserts')
local service = require('commands.hurl_run.utilities.hurl_run_service')

return {
	['test: get_file_type_of_response no content type header returns nothing'] = function()
		local actual = service.get_file_type_of_response({ '< no-content-type: nothing', 'somethingelse: test' })

		return asserts.assert_equals(
			actual,
			nil,
			nil
		)
	end,
	['test: get_file_type_of_response with json returns json'] = function()
		local actual = service.get_file_type_of_response({ '< content-type: json', 'somethingelse: test' })

		return asserts.assert_equals(
			actual,
			'json',
			nil
		)
	end,
	['test: get_file_type_of_response with html returns html'] = function()
		local actual = service.get_file_type_of_response({ '< content-type: html', 'somethingelse: test' })

		return asserts.assert_equals(
			actual,
			'html',
			nil
		)
	end,
	['test: get_file_type_of_response with unknown filetype returns nothing'] = function()
		local actual = service.get_file_type_of_response({ '< content-type: not a thing', 'somethingelse: test' })

		return asserts.assert_equals(
			actual,
			nil,
			nil
		)
	end,
}
