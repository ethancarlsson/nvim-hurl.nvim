local asserts  = require('tests.asserts')
local mocks    = require('tests.mocks')
local hurl_run = require('commands.hurl_run.run')

return {
	['integration_test: hurl_yank without hurl file'] = function()
		local io_mock = mocks.get_io();
		vim.bo.filetype = 'not_hurl'
		local buf = hurl_run.yank(io_mock)

		return asserts.assert_equals(
			-1,
			buf,
			nil

		)
	end,
	['integration: test :HurlYank'] = function()
		vim.bo.filetype = 'hurl'
		local job = hurl_run.yank(io)

		if job <= 0 then
			print('failed asserting that :HurlYank doesn\t fail')
			return false
		end

		vim.fn.jobwait({ job })

		return asserts.assert_equals('hello hurl.nvim', vim.fn.getreg('*'))
	end
}
