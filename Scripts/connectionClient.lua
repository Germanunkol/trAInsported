local connection = {}

local connectionsRunning = 0

local connectionThread

local printLineNumber = 0

function connection.startClient(ip, port)

	if connectionThread then
		connectionThread:set("quit", true)
	end
	connectionThread = love.thread.newThread("connectionThread" .. connectionsRunning, "Scripts/connectionThread.lua")
	connectionThread:start()
	connectionsRunning = connectionsRunning + 1 
	if connectionThread then
		connectionThread:set("ip", ip)
		connectionThread:set("port", port)
		printLineNumber = 0
	end
end


local lineFound = true

function connection.handleConnection()
	if not connectionThread then return end
	err = connectionThread:get("error")
	if err then print("CONNECTION ERROR:", err) end
	
	lineFound = true
	while lineFound do
		str = connectionThread:get("print" .. printLineNumber)
		if str then
			printLineNumber = printLineNumber + 1
			if printLineNumber == 99999 then
				printLineNumber = 0
			end
			print("CONNECTION:", str)
		else
			lineFound = false
		end
	end
end

return connection
