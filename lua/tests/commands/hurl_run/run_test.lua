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

	local actual = hurl_run.run(vim, mocks.get_io())
	return asserts.assert_equals(actual, -1)
end

local function test_hurl_run_full__with_command_no_return_from_command__returns_negative1()
	local io = mocks.get_io()
	io.popen = function()
		return nil, nil
	end

	local actual = hurl_run.full(mocks.get_vim(), io)

	return asserts.assert_equals(actual, -1)
end

local function test_hurl_run_full__with_err__returns_negative1()
	local io = mocks.get_io()
	local error_message = 'some kind of error happend'
	io.popen = function()
		return mocks.get_file(), 'some kind of error happend'
	end

	local vim = mocks.get_vim()
	local actual_error_message = ''
	vim.fn.setreg = function(_, value, _)
		actual_error_message = value
	end

	local actual = hurl_run.full(vim, io)

	return asserts.assert_equals(actual, -1)
	    and asserts.assert_equals(actual_error_message, error_message)
end

return {
	['test_hurl_run_run__returns_buf'] = test_hurl_run_run__returns_buf,
	['test_hurl_run_run__with_non_hurl_file__returns_negative_1'] = test_hurl_run_run__with_non_hurl_file__returns_negative_1,
	['test_hurl_run_full__with_command_no_return_from_command__returns_negative1'] = test_hurl_run_full__with_command_no_return_from_command__returns_negative1,
	['test_hurl_run_full__with_err__returns_negative1'] = test_hurl_run_full__with_err__returns_negative1,
}
