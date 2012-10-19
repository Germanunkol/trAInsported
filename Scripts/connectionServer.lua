
PORT = 5556

local socket = require("socket")

local connection = {}

local server, client

clientList = {}

function connection.startServer()
	ok, server = pcall(socket.bind, "*", 5556)
	if not ok then
		print("Error establishing server: " .. server)
		return false
	else
		print("Started server at: " .. PORT)
	end
	
	-- set a timeout for accepting client connections
	server:settimeout(.0001)
	
	return true
end

function connection.handleServer()
	if server then
		newClient = server:accept()
		if newClient then
			table.insert(clientList, newClient)
			newClient:settimeout(.0001)
			print("new client!")
		end
		
		for k, cl in pairs(clientList) do
			data, msg = cl:receive()
			--print(data, msg)
			if not msg then
				print("received: " .. data)
			else
				--print("error: " .. msg)
				if msg == "closed" then
					cl:shutdown()
					clientList[k] = nil
				end
			end
		end
	end
end

return connection
