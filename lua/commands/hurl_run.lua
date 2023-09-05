local windows = require('commands.windows.window')
local hurl_run = require('commands.hurl_run.run')
local splitwindows = require('commands.windows.split')


---@param buf integer
---@param verbose_buf integer
local function split_to_buf_and_verbose(buf, verbose_buf)
	local current_window = vim.api.nvim_get_current_win()

	local result_win = windows.get_window(windows.TEMP_RESULT_WINDOW)
	local verbose_win = windows.get_window(windows.VERBOSE_RESULT_WINDOW)

	if result_win == nil or not vim.api.nvim_win_is_valid(result_win) then

		vim.cmd('vsplit')
		result_win = windows.set_window(windows.TEMP_RESULT_WINDOW, vim.api.nvim_get_current_win())
	end

	vim.api.nvim_set_current_win(result_win)

	if verbose_win == nil or not vim.api.nvim_win_is_valid(verbose_win) then

		vim.cmd('split')
		verbose_win = windows.set_window(windows.VERBOSE_RESULT_WINDOW, vim.api.nvim_get_current_win())
	end

	vim.api.nvim_buf_set_option(buf, "modified", false)
	vim.api.nvim_win_set_buf(result_win, buf)

	vim.bo[buf].buftype = 'nofile'
	vim.bo[buf].bufhidden = 'hide'
	vim.bo[buf].swapfile = false

	vim.api.nvim_buf_set_option(verbose_buf, "modified", false)
	vim.api.nvim_win_set_buf(verbose_win, verbose_buf)

	vim.bo[verbose_buf].buftype = 'nofile'
	vim.bo[verbose_buf].bufhidden = 'hide'
	vim.bo[verbose_buf].swapfile = false

	vim.api.nvim_set_current_win(current_window)
end

return {
	verbose = function()
		local buf, verbose_buf = hurl_run.verbose(io)

		if buf == -1 then
			return
		end

		split_to_buf_and_verbose(buf, verbose_buf)
	end,
	run = function()
		local buf = hurl_run.run(io)

		if buf == -1 then
			return
		end

		splitwindows.split_to_buf(buf)
	end,
	---@param url string
	---@param noreuse string?
	go = function(url, noreuse)
		if url == nil then
			print('HurlGo cannot run without a url as the first argument')

			return
		end

		hurl_run.go(url, noreuse)
	end,
	---@param noreuse string
	go_from_cursor = function(noreuse)
		hurl_run.go_from_cursor(noreuse)
	end
}
