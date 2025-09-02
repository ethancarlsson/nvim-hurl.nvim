local mocks = {}

function mocks.get_vim()
	return {
		bo = {
			filetype = 'hurl'
		},
		api = {
			nvim_buf_get_name = function()
				return 'test_file_name'
			end,
			nvim_create_buf = function()
				return 1
			end,
			nvim_buf_set_option = function()
			end,
			nvim_buf_set_text = function()
			end,
		},
		fn = { setreg = function()

		end
		}
	}
end

function mocks.get_file()
	local mock_file = {};
	--luacheck: push no unused args
	function mock_file:read()
		return 'test_file_contents'
	end
	--luacheck: pop

	--luacheck: push no unused args
	function mock_file:close()
	end
	--luacheck: pop

	return mock_file
end

function mocks.get_io()
	local io = {
		open = function()
			return mocks.get_file()
		end,
		popen = function()
		end,
	}

	--luacheck: push no unused args
	function io:read()
		return 'test_result'
	end
	--luacheck: pop

	return io
end

return mocks
