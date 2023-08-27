local asserts = require('tests.asserts')
local mocks = require('tests.mocks')
local command = require('commands.hurl_run.command')

return {
	['test: get_command with nil file returns command without variables file'] = function()
		local mock_io_object = {
			open = function()
				return nil
			end
		}

		return asserts
		    .assert_equals(
		            command.get_command('test.hurl', '--verbose', mock_io_object),
		            'hurl --verbose test.hurl',
		            nil
		    )
	end,
	['test: get_command with variables file returns command with variables file located'] = function()

		local mock_io_object = {
			open = function()
				return mocks.file
			end
		}

		return asserts
		    .assert_equals(
		            command.get_command('test.hurl', '--verbose', mock_io_object),
		            'hurl --variables-file=test_file_contents --verbose test.hurl',
		            nil
		    )
	end,
}
