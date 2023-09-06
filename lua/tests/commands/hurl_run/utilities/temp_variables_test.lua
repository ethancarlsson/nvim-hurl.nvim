local asserts = require('tests.asserts')
local temp_variables = require('commands.hurl_run.utilities.temp_variables')

return {
	['test: get_variables_as_command_options with no variables, returns empty string'] = function()
		temp_variables.clear_variables()

		return asserts
		    .assert_equals(
		            '',
		            temp_variables.get_variables_as_command_options(),
		            nil
		    )
	end,
	['test: get_variables_as_command_options with one variables, returns --variable name=value'] = function()
		temp_variables.clear_variables()

		temp_variables.set_variable('name', 'value')

		return asserts
		    .assert_equals(
		            '--variable name=value',
		            temp_variables.get_variables_as_command_options(),
		            nil
		    )
	end,
	['test: get_variables_as_command_options with mutiple variables, returns --variable name=value for each'] = function()
		temp_variables.clear_variables()

		temp_variables.set_variable('name', 'value')
		temp_variables.set_variable('name2', 'value2')
		temp_variables.set_variable('name3', 'value3')

		return asserts
		    .assert_equals(
		            '--variable name=value',
		            string.match(temp_variables.get_variables_as_command_options(), '--variable name=value'),
		            'failed asserting variables string contains --variable name=value'
		    ) and asserts
		    .assert_equals(
		            '--variable name2=value2',
		            string.match(temp_variables.get_variables_as_command_options(), '--variable name2=value2'),
		            'failed asserting variables string contains --variable name2=value2'
		    ) and asserts
		    .assert_equals(
		            '--variable name3=value3',
		            string.match(temp_variables.get_variables_as_command_options(), '--variable name3=value3'),
		            'failed asserting variables string contains --variable name3=value3'
		    )


	end,
	['test: get_variables_as_command_options with duplicated names, returns last variable'] = function()
		temp_variables.clear_variables()

		temp_variables.set_variable('name', 'value')
		temp_variables.set_variable('name', 'value2')
		temp_variables.set_variable('name', 'value3')

		return asserts
		    .assert_equals(
		            '--variable name=value3',
		            temp_variables.get_variables_as_command_options(),
		            nil
		    )
	end,
}
