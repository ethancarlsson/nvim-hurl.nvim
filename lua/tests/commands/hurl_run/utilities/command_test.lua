local asserts = require('tests.asserts')
local mocks = require('tests.mocks')
local command = require('commands.hurl_run.utilities.command')
local state = require('commands.hurl_run.utilities.state')
local temp_variables = require('commands.hurl_run.utilities.temp_variables')


return {
	['test: get_command with nil file returns command without variables file'] = function()
		temp_variables.clear_variables()

		local mock_io_object = mocks:get_io()
		mock_io_object.open = function()
			return nil
		end

		return asserts
		    .assert_equals(
		            'hurl  --verbose test.hurl',
		            command.get_command('test.hurl', '--verbose', mock_io_object),
		            nil
		    )
	end,
	['test: get_command with variables file returns command with variables file located'] = function()
		temp_variables.clear_variables()

		local mock_io_object = mocks:get_io()
		mock_io_object.open = function()
			return mocks.get_file()
		end

		return asserts
		    .assert_equals(
		            'hurl  --variables-file=test_file_contents --verbose test.hurl',
		            command.get_command('test.hurl', '--verbose', mock_io_object),
		            nil
		    )
	end,
	['test: with variables returns variables in the command'] = function()
		temp_variables.clear_variables()

		local mock_io_object = mocks:get_io()
		mock_io_object.open = function()
			return mocks.get_file()
		end

		temp_variables.set_variable('name', 'value')

		return asserts
		    .assert_equals(
		            'hurl --variable name=value --variables-file=test_file_contents --verbose test.hurl',
		            command.get_command('test.hurl', '--verbose', mock_io_object),
		            nil
		    )
	end,
	['test: get_curl_go_to with no headers returns curl with just url'] = function()
		temp_variables.clear_variables()
		state:clear_current_headers()

		local expected_curl = 'curl -sS https://api.example.com'

		return asserts
		    .assert_equals(
		            expected_curl,
		            command.get_curl_go_to('https://api.example.com'),
		            nil
		    )
	end,
	['test: get_curl_go_to with headers returns curl with headers'] = function()
		temp_variables.clear_variables()
		state:clear_current_headers()

		local expected_curl = 'curl -sS https://api.example.com --header "testname: testval"'

		state:set_current_headers({
			'testname: testval'
		})


		return asserts
		    .assert_equals(
		            expected_curl,
		            command.get_curl_go_to('https://api.example.com'),
		            nil
		    )
	end,
	['test: get_curl_go_to with empty headers returns curl with no headers'] = function()
		temp_variables.clear_variables()
		state:clear_current_headers()

		local expected_curl = 'curl -sS https://api.example.com'

		state:set_current_headers({
			''
		})


		return asserts
		    .assert_equals(
		            expected_curl,
		            command.get_curl_go_to('https://api.example.com'),
		            nil
		    )
	end,
	['test: get_curl_go_to with characters needing escape, escapes them'] = function()
		temp_variables.clear_variables()
		state:clear_current_headers()

		local expected_curl = 'curl -sS https://swapi.dev/api/people/\\?page\\=2'

		state:set_current_headers({
			''
		})


		return asserts
		    .assert_equals(
		            expected_curl,
		            command.get_curl_go_to('https://swapi.dev/api/people/?page=2'),
		            nil
		    )
	end
}
