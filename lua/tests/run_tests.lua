package.path = 'lua/?.lua;' .. package.path

local tests = {
	['tests.commands.hurl_run.command_test'] = require('tests.commands.hurl_run.command_test')
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
