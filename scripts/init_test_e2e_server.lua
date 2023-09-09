-- This whole file was virtually copied and pasted from here:
-- https://luacode.wordpress.com/2011/08/18/the-simplest-http-server-in-lua/
-- All credit goes to that author

local socket = require("socket")

--{{Options
---The port number for the HTTP server. Default is 80
local PORT = 9122
---The parameter backlog specifies the number of client connections
-- that can be queued waiting for service. If the queue is full and
-- another client attempts connection, the connection is refused.
local BACKLOG = 5
--}}Options

-- create a TCP socket and bind it to the local host, at any port
local server = assert(socket.tcp(), 'couldn\t create server')

local binding, bind_err = server:bind("*", PORT)
if binding == nil then
	print(bind_err)
	print('server already bound to ' .. PORT)
	return
end
server:listen(BACKLOG)

-- Print IP and port
local ip, port = server:getsockname()
print("Listening on IP=" .. ip .. ", PORT=" .. port .. "...")

-- loop forever waiting for clients
while 1 do
	-- wait for a connection from any client
	local client, err = server:accept()

	if client then
		local _, client_err = client:receive()
		-- if there was no error, send it back to the client
		if not client_err then
			client:send("HTTP/1.0 200 OK\n\n\nhello hurl.nvim")
		else
			print('error from client:receive: ' .. client_err)
		end
	else
		print("Error happened while getting the connection.nError: " .. err)
	end

	-- done with client, close the object
	client:close()
	print("Terminated")
end
