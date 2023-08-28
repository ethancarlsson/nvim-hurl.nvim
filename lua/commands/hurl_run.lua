local windows = require('commands.windows.window')
local hurl_run_command = require('commands.hurl_run.utilities.command')
local hurl_run_service = require('commands.hurl_run.utilities.hurl_run_service')
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

---@return integer, integer
local function hurl_run_verbose()
	local filetype = vim.bo.filetype
	if filetype ~= 'hurl' then
		print('cannot run hurl command in non-hurl file')
		return -1, -1
	end

	local filename = vim.api.nvim_buf_get_name(0)

	local command = '!' .. hurl_run_command.get_command(filename, '--verbose', io)
	---@diagnostic disable-next-line: undefined-field - it is defined.
	local result = vim.api.nvim_command_output(command)

	local buf = vim.api.nvim_create_buf(false, false)
	local verbose_buf = vim.api.nvim_create_buf(false, false)

	hurl_run_service.set_lines_and_verbose_from_result(result, buf, verbose_buf, command)
	vim.api.nvim_buf_set_option(buf, "readonly", false)
	vim.api.nvim_buf_set_option(verbose_buf, "readonly", false)

	return buf, verbose_buf
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
		local buf, verbose_buf = hurl_run_verbose()

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
	full = function()
		local buf = hurl_run.full(vim, io)

		if buf == -1 then
			return
		end

		split_to_buf(buf)
	end
}
