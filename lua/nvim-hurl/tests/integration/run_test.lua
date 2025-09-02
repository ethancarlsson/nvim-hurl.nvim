local asserts  = require('nvim-hurl.tests.asserts')
local hurl_run = require('nvim-hurl.hurl_run.run')
local split    = require('nvim-hurl.windows.split')
local window   = require('nvim-hurl.windows.window')

return {
	['integration: test :HurlRun'] = function()
		vim.bo.filetype = 'hurl'
		local buf, job = hurl_run.run(io)

		if job <= 0 or buf == -1 then
			print('failed asserting that :HurlRun doesn\t fail')
			return false
		end

		split.split_to_buf(buf)

		vim.fn.jobwait({ job })

		local result_win = window.get_window(window.TEMP_RESULT_WINDOW)
		local result_buf = vim.api.nvim_win_get_buf(result_win)

		local lines = vim.api.nvim_buf_get_lines(result_buf, 0, -1, false)

		return asserts.assert_equals('hello hurl.nvim', table.concat(lines))
	end,
	['integration: test :HurlRunVerbose'] = function()
		vim.bo.filetype = 'hurl'
		local buf, v_buf, job = hurl_run.verbose(io)

		if job <= 0 or buf == -1 or v_buf == -1 then
			print('failed asserting that :HurlRunVerbose doesn\t fail')
			return false
		end

		split.split_to_buf_and_verbose(buf, v_buf)

		vim.fn.jobwait({ job })

		local result_win = window.get_window(window.TEMP_RESULT_WINDOW)
		local result_buf = vim.api.nvim_win_get_buf(result_win)
		local lines = vim.api.nvim_buf_get_lines(result_buf, 0, -1, false)

		local v_result_win = window.get_window(window.VERBOSE_RESULT_WINDOW)
		local v_result_buf = vim.api.nvim_win_get_buf(v_result_win)

		local v_lines = vim.api.nvim_buf_get_lines(v_result_buf, 0, -1, false)

		return asserts.assert_equals('hello hurl.nvim', table.concat(lines))
		    and asserts.assert_string_contains('HTTP/1.0 200 OK', table.concat(v_lines))
	end
}
