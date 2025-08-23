test_unit:
	nvim -l lua/tests/unit.lua

test_integration:
	lua scripts/init_test_e2e_server.lua &
	nvim --headless --noplugin -u scripts/minimal_init.vim -c "luafile ./lua/tests/integration.lua" -c 'qa' lua/tests/test.hurl
