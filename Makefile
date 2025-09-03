test_unit:
	nvim -l lua/nvim-hurl/tests/unit.lua

test_integration:
	lua scripts/init_test_e2e_server.lua &
	nvim --headless --noplugin -u scripts/minimal_init.vim -c "luafile ./lua/nvim-hurl/tests/integration.lua" -c 'qa' lua/nvim-hurl/tests/test.hurl
