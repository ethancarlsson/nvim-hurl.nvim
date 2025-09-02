local asserts = require('nvim-hurl.tests.asserts')
local headers = require('nvim-hurl.hurl_run.utilities.headers')

return {
	['test: get_request_headers_from_verbose_lines with no lines, returns empty table'] = function()
		local actual = headers.get_request_headers_from_verbose_lines(
			{}
		)

		return asserts.assert_equals(
			actual,
			{},
			nil
		)
	end,
	['test: get_request_headers_from_verbose_lines with headers, returns headers'] = function()
		local actual = headers.get_request_headers_from_verbose_lines(
			{
				string.format(
					"* curl %s %s %s %s %s %s %s %s %s %s %s %s 'https://api.example.com'",
					"--header 'authorization: Bearer some_token'",
					"--header 'testing: something'",
					"--header 'testing_two: something_two'",
					"--header 'user-agent: hurl/4.0.0'",
					"--header 'user-agent-2: hurl/4.0.0'",
					"--header 'with_json: {\"testing\": [\"testing\"]}'",
					"--header 'lisp: (+ 2 2)'",
					"--header 'email: @example.com'",
					"--header 'percentage: %percentage'",
					"--header 'naked_lisp: + 2 2'",
					"--header 'naked_lisp_minus: - 2 2'",
					"--header 'naked_lisp_multiply: * 2 2'"
				),
			}

		)

		return asserts.assert_equals(
			{
				"--header 'authorization: Bearer some_token'",
				"--header 'testing: something'",
				"--header 'testing_two: something_two'",
				"--header 'user-agent: hurl/4.0.0'",
				"--header 'user-agent-2: hurl/4.0.0'",
				"--header 'with_json: {\"testing\": [\"testing\"]}'",
				"--header 'lisp: (+ 2 2)'",
				"--header 'email: @example.com'",
				"--header 'percentage: %percentage'",
				"--header 'naked_lisp: + 2 2'",
				"--header 'naked_lisp_minus: - 2 2'",
				"--header 'naked_lisp_multiply: * 2 2'"
			},
			actual,
			nil
		)
	end,
}



