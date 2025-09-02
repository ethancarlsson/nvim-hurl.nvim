local hurl_run = require('nvim-hurl.hurl_run.run')

return {
	-- Do not add any logic here, it's too annoying to test
	yank = function(l1, l2)
		hurl_run.yank(io, l1, l2)
	end
}
