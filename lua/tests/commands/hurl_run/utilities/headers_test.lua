local asserts = require('tests.asserts')
local headers = require('commands.hurl_run.utilities.headers')

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
				'* Executing entry 1',
				'*',
				'* Cookie store:',
				'*',
				'* Request:',
				'* GET https://api.example.com',
				'*',
				'* Request can be run with the following curl command:',
				'* curl \'https://api.example.com\'',
				'*',
				'> GET /api/people/6 HTTP/2',
				'> GET /products/1 HTTP/2',
				'> Host: api.example.com',
				'> accept: */*',
				'> ',
				'authorization: Bearer some_token',
				'> testing: something',
				'> testing_two: something_two',
				'> user-agent: hurl/4.0.0',
				'> user-agent-2: hurl/4.0.0',
				'> no-value:',
				'> with_json: {"testing": ["testing"]}',
				'> lisp: (+ 2 2)',
				'> email: @example.com',
				'> percentage: %percentage',
				'> naked_lisp: + 2 2',
				'> naked_lisp_minus: - 2 2',
				'> naked_lisp_multiply: * 2 2',
				'>',
				'*',
				'< HTTP/2 200',
				'< server: nginx/1.16.1',
				'<',
				'edge-case: sometimes response response headers are on the next line',

			}

		)

		return asserts.assert_equals(
			actual,
			{
				'Host: api.example.com',
				'accept: */*',
				'authorization: Bearer some_token',
				'testing: something',
				'testing_two: something_two',
				'user-agent: hurl/4.0.0',
				'user-agent-2: hurl/4.0.0',
				'with_json: {"testing": ["testing"]}',
				'lisp: (+ 2 2)',
				'email: @example.com',
				'percentage: %percentage',
				'naked_lisp: + 2 2',
				'naked_lisp_minus: - 2 2',
				'naked_lisp_multiply: * 2 2',
			},
			nil
		)
	end,
}
