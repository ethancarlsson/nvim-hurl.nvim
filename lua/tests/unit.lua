-- luacheck: globals no package
package.path = 'lua/?.lua;' .. package.path

local runner = require('tests.test_runner.runner')

runner.run_tests({
	['tests.commands.hurl_run.utilities.command_test'] = require('tests.commands.hurl_run.utilities.command_test'),
	['tests.commands.hurl_run.utilities.service_test'] = require('tests.commands.hurl_run.utilities.service_test'),
	['tests.commands.hurl_run.utilities.headers'] = require('tests.commands.hurl_run.utilities.headers_test'),
	['tests.commands.hurl_run.utilities.url'] = require('tests.commands.hurl_run.utilities.url_test'),
	['tests.commands.hurl_run.utilities.temp_variables_test'] = require(
		'tests.commands.hurl_run.utilities.temp_variables_test'
	),
})
