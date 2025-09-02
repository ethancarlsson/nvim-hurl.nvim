local asserts = require('nvim-hurl.tests.asserts')
local url = require('nvim-hurl.hurl_run.utilities.url')

return {
	['test: get_from_string with url an exact match to a url'] = function()
		return asserts
		    .assert_equals(
		            'https://example.com',
		            url.get_from_string('https://example.com'),
		            nil
		    )
	end,
	['test: get_from_string with url in json'] = function()
		return asserts
		    .assert_equals(
		            'https://example.com',
		            url.get_from_string('"https://example.com",'),
		            nil
		    )
	end,
	['test: get_from_string with url in html(href)'] = function()
		return asserts
		    .assert_equals(
		            'https://example.com',
		            url.get_from_string('href="https://example.com">'),
		            nil
		    )
	end,
	['test: get_from_string with swapi url'] = function()
		return asserts
		    .assert_equals(
		            'https://swapi.dev/api/people/?page=2',
		            url.get_from_string('https://swapi.dev/api/people/?page=2'),
		            nil
		    )
	end,
}
