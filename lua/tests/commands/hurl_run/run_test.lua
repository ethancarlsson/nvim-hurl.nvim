local hurl_run = require('commands.hurl_run.run')
local asserts = require('tests.asserts')
local mocks = require('tests.mocks')

local function test_hurl_run_run__returns_buf()
	local vim = mocks.get_vim()
	local new_buf_name = 11

	vim.api.nvim_create_buf = function()
		return new_buf_name
	end

	local actual = hurl_run.run(vim, mocks.get_io())
	return asserts.assert_equals(actual, new_buf_name)
end

local function test_hurl_run_run__with_non_hurl_file__returns_negative_1()
	local vim = mocks.get_vim()
	local new_buf_name = 11

	vim.bo.filetype = 'not_hurl'
	vim.api.nvim_create_buf = function()
		return new_buf_name
	end

	local actual = hurl_run.run(vim, mocks.io)
	return asserts.assert_equals(actual, -1)
end

return {
	['test_hurl_run_run__returns_buf'] = test_hurl_run_run__returns_buf,
	['test_hurl_run_run__with_non_hurl_file__returns_negative_1'] = test_hurl_run_run__with_non_hurl_file__returns_negative_1,
}
