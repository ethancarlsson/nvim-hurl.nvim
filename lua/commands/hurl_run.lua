local windows = require('commands.windows.window')
local hurl_run = require('commands.hurl_run.run')

local function split_to_buf(buf)
	local current_window = vim.api.nvim_get_current_win()
	local win = windows.get_window(windows.TEMP_RESULT_WINDOW)
	if win == nil or not vim.api.nvim_win_is_valid(win) then

		vim.cmd('vsplit')
		win = windows.set_window(windows.TEMP_RESULT_WINDOW, vim.api.nvim_get_current_win())
	end

	vim.api.nvim_buf_set_option(buf, "modified", false)
	vim.api.nvim_win_set_buf(win, buf)
	vim.bo[buf].buftype = 'nofile'
	vim.bo[buf].bufhidden = 'hide'
	vim.bo[buf].swapfile = false

	vim.api.nvim_set_current_win(current_window)
end

local function split_to_buf_and_verbose(buf, verbose_buf)
	local current_window = vim.api.nvim_get_current_win()

	local result_win = windows.get_window(windows.TEMP_RESULT_WINDOW)
	local verbose_win = windows.get_window(windows.VERBOSE_RESULT_WINDOW)

	if result_win == nil or not vim.api.nvim_win_is_valid(result_win) then

		vim.cmd('vsplit')
		result_win = windows.set_window(windows.TEMP_RESULT_WINDOW, vim.api.nvim_get_current_win())
	end

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
		local buf, verbose_buf = hurl_run.verbose(vim, io)

		if buf == -1 then
			return
		end

		split_to_buf_and_verbose(buf, verbose_buf)
	end,
	run = function()
		local buf = hurl_run.run(vim, io)

		if buf == -1 then
			return
		end

		split_to_buf(buf)
	end,
	---@param expected_file_type string?
	full = function(expected_file_type)
		local buf = hurl_run.full(vim, io)

		if buf == -1 then
			return
		end

		if expected_file_type ~= nil then
			vim.api.nvim_buf_set_option(buf, 'filetype', expected_file_type)
		end

		split_to_buf(buf)
	end
}
