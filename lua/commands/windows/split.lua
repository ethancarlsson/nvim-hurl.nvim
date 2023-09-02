local windows = require('commands.windows.window')

---@param buf integer
local function split_to_buf(buf)
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

local function reset_window()
	local win = windows.get_window(windows.TEMP_RESULT_WINDOW)
	-- TODO: Find a way to reset the window so we don't depend on this command
	if vim.fn.exists(':LspStart') == 2 and win ~= nil then
		local current_window = vim.api.nvim_get_current_win()
		vim.api.nvim_set_current_win(win)
		vim.cmd('LspStart')
		vim.api.nvim_set_current_win(current_window)
	end
end

return {
	split_to_buf = split_to_buf,
	reset_window = reset_window,
}
