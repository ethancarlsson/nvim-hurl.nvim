local asserts  = require('nvim-hurl.tests.asserts')
local hurl_run = require('nvim-hurl.hurl_run.run')
local window   = require('nvim-hurl.windows.window')

return {
	['e2e: test :CurlGo'] = function()
		local job = hurl_run.go('http://localhost:9122', 'noreuse')

		if job <= 0 then
			print('failed asserting that :CurlGo doesn\t fail')
			return false
		end

		vim.fn.jobwait({ job })

		local result_win = window.get_window(window.TEMP_RESULT_WINDOW)
		local result_buf = vim.api.nvim_win_get_buf(result_win)

		local lines = vim.api.nvim_buf_get_lines(result_buf, 0, -1, false)

		return asserts.assert_equals('hello hurl.nvim', table.concat(lines))
	end
}
