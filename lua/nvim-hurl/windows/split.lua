local windows = require('nvim-hurl.windows.window')

local W = {}

---@param buf integer
function W.split_to_buf(buf)
	local current_window = vim.api.nvim_get_current_win()
	local win = windows.get_window(windows.TEMP_RESULT_WINDOW)

	if win == nil or not vim.api.nvim_win_is_valid(win) then

		vim.cmd('vsplit')
		win = windows.set_window(windows.TEMP_RESULT_WINDOW, vim.api.nvim_get_current_win())
	end

	vim.api.nvim_win_set_buf(win, buf)

	vim.bo[buf].buftype = 'nofile'
	vim.bo[buf].bufhidden = 'hide'
	vim.bo[buf].swapfile = false

	vim.api.nvim_set_current_win(current_window)
end

---@param buf integer
---@param verbose_buf integer
function W.split_to_buf_and_verbose(buf, verbose_buf)
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

	vim.api.nvim_set_option_value("modified", false, { buf = buf })
	vim.api.nvim_win_set_buf(result_win, buf)

	vim.bo[buf].buftype = 'nofile'
	vim.bo[buf].bufhidden = 'hide'
	vim.bo[buf].swapfile = false

	vim.api.nvim_set_option_value("modified", false, { buf = verbose_buf })
	vim.api.nvim_win_set_buf(verbose_win, verbose_buf)

	vim.bo[verbose_buf].buftype = 'nofile'
	vim.bo[verbose_buf].bufhidden = 'hide'
	vim.bo[verbose_buf].swapfile = false

	vim.api.nvim_set_current_win(current_window)
end

function W.reset_window()
	local win = windows.get_window(windows.TEMP_RESULT_WINDOW)
	-- TODO: Find a way to reset the window so we don't depend on this command
	if vim.fn.exists(':LspStart') == 2 and win ~= nil then
		local current_window = vim.api.nvim_get_current_win()
		vim.api.nvim_set_current_win(win)
		vim.cmd('LspStart')
		vim.api.nvim_set_current_win(current_window)
	end
end

return W
