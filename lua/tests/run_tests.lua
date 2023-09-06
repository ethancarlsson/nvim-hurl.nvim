package.path = 'lua/?.lua;' .. package.path

local tests = {
	['tests.commands.hurl_run.utilities.command_test'] = require('tests.commands.hurl_run.utilities.command_test'),
	['tests.commands.hurl_run.utilities.service_test'] = require('tests.commands.hurl_run.utilities.service_test'),
	['tests.commands.hurl_run.utilities.headers'] = require('tests.commands.hurl_run.utilities.headers_test'),
	['tests.commands.hurl_run.utilities.url'] = require('tests.commands.hurl_run.utilities.url_test'),
	['tests.commands.hurl_run.utilities.temp_variables_test'] = require('tests.commands.hurl_run.utilities.temp_variables_test'),
}

local tests_passed = true
for suite_name, test_suite in pairs(tests) do
	print(string.format('== %s ==', suite_name))
	for test_name, test in pairs(test_suite) do
		if test() == false then
			tests_passed = false
			print(string.format('%s %s', '❌', test_name))
		else
			print(string.format('%s %s', '✅', test_name))
		end
	end
end


if tests_passed then
	print('tests passed')
else
	error('tests failed', 0)
end
