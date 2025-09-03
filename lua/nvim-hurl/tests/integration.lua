-- luacheck: globals no package
package.path = 'lua/?.lua;' .. package.path

local runner = require('nvim-hurl.tests.test_runner.runner')

runner.run_tests({
	['tests.integration.yank_test'] = require('nvim-hurl.tests.integration.yank_test'),
	['tests.integration.run_test'] = require('nvim-hurl.tests.integration.run_test'),
	['tests.integration.go_test'] = require('nvim-hurl.tests.integration.go_test'),
})
