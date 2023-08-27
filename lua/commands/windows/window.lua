TEMP_RESULT_WINDOW = 'result_win'
VERBOSE_RESULT_WINDOW = 'verbose_win'

local state = {
}

---@param name string
---@param win integer
---@return integer
function SetWindow(name, win)
	state[name] = win
	return win
end

--
---@param name string
---@return integer?
function GetWindow(name)
	return state[name]
end
