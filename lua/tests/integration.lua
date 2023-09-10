-- luacheck: globals no package
package.path = 'lua/?.lua;' .. package.path

local runner = require('tests.test_runner.runner')

runner.run_tests({
	['tests.integration.yank_test'] = require('tests.integration.yank_test'),
	['tests.integration.run_test'] = require('tests.integration.run_test'),
	['tests.integration.go_test'] = require('tests.integration.go_test'),
})
