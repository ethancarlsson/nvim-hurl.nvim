
local state = {
}

---@param name string
---@param win integer
---@return integer
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


return {
	TEMP_RESULT_WINDOW = 'result_win',
	VERBOSE_RESULT_WINDOW = 'verbose_win',
	set_window = set_window,
	get_window = get_window,
}
