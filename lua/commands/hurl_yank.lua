local hurl_run = require('commands.hurl_run.run')

return {
	yank = function()
		hurl_run.yank(vim, io)
	end
}
