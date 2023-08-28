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
			nvim_command_output = function()
				return 'test_result'
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
	function mock_file:read()
		return 'test_file_contents'
	end

	function mock_file:close()
	end

	return mock_file
end

function mocks.get_io()
	return {
		open = function()
			return mocks.get_file()
		end
	}
end

return mocks
