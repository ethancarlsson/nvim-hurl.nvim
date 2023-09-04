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
				'> user-agent: hurl/4.0.0',
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
				'user-agent: hurl/4.0.0',
			},
			nil
		)
	end,
}
