local state = {
}

---@param name string
---@param win integer?
---@return integer?
local function set_window(name, win)
	state[name] = win
	return win
end

--
---@param name string
---@return integer?
local function get_window(name)
	return state[name]
end

---@param window_name string
---@return integer?
local function get_buf_of_window(window_name)
	local window = get_window(window_name)

	if window == nil then
		return nil
	end

	local is_win_valid, buf = pcall(function() return vim.api.nvim_win_get_buf(window) end)

	if is_win_valid then
		return buf
	else
		return set_window(window_name, nil)
	end
end

return {
	TEMP_RESULT_WINDOW = 'result_win',
	VERBOSE_RESULT_WINDOW = 'verbose_win',
	set_window = set_window,
	get_window = get_window,
	get_buf_of_window = get_buf_of_window,
}
