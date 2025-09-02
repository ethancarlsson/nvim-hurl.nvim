local hurl_run = require('nvim-hurl.hurl_run.run')
local splitwindows = require('nvim-hurl.windows.split')

-- Do not add any more logic here, it's too annoying to test
return {
	verbose = function(l1, l2)
		local buf, verbose_buf = hurl_run.verbose(io, l1, l2)

		if buf == -1 then
			return
		end

		splitwindows.split_to_buf_and_verbose(buf, verbose_buf)
	end,
	run = function(l1, l2)
		local buf = hurl_run.run(io, l1, l2)

		if buf == -1 then
			return
		end

		splitwindows.split_to_buf(buf)
	end,
	---@param url string
	---@param noreuse string?
	go = function(url, noreuse)
		if url == nil then
			print('CurlGo cannot run without a url as the first argument')

			return
		end

		hurl_run.go(url, noreuse)
	end,
	---@param noreuse string
	go_from_cursor = function(noreuse)
		hurl_run.go_from_cursor(noreuse)
	end
}
