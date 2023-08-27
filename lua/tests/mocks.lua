local mock_file = {};
function mock_file:read()
	return 'test_file_contents'
end

return {
	file = mock_file
}
