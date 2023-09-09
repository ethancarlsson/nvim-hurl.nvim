local hurl_run = require('commands.hurl_run.run')

return {
	-- Do not add any logic here, it's too annoying to test
	yank = function()
		hurl_run.yank(io)
	end
}
