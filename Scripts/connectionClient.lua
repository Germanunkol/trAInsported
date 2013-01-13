local connection = {}

local connectionsRunning = 0

local connectionThread

local printLineNumber = 0

local packetNumber = 0

local rememberPort = 0

function connection.startClient(ip, port)

	if ip and port then
		rememberPort = port
	elseif rememberPort then
		port = rememberPort
		ip = FALLBACK_SERVER_IP
		rememberPort = nil
	else return end

	if connectionThread then
		connectionThread:set("quit", true)
	end
	connectionThread = love.thread.newThread("connectionThread" .. connectionsRunning, "Scripts/connectionThreadClient.lua")
	connectionThread:start()
	connectionsRunning = connectionsRunning + 1 
	if connectionThread then
		connectionThread:set("ip", ip)
		connectionThread:set("port", port)
		printLineNumber = 0
		packetNumber = 0
	end
end


local lineFound = true

function connection.handleConnection()
	if not connectionThread then return end
	
	lineFound = true
	while lineFound do
		str = connectionThread:get("print" .. printLineNumber)
		if str then
			printLineNumber = incrementID(printLineNumber)
			print("CONNECTION:", str)
		else
			lineFound = false
		end
	end
	
	str = connectionThread:get("newMap")
	if str then
		if not curMap and not map.startupProcess() then
			mapImage = nil
		end
		map.print("new map", simulationMap)
		roundEnded = true
		simulationMap = TSerial.unpack(str)
		simulation.init()
	end
	
	str = connectionThread:get("packet" .. packetNumber)
	if str then
		simulation.addUpdate(str)
		packetNumber = incrementID(packetNumber)
	end
	
	
	str = connectionThread:get("serverTime")
	if str then
		serverTime = tonumber(str)
		print("Received new server time: " .. serverTime)
		if simulationMap then
			print("My time: " .. simulationMap.time)
		end
	end
	
	-- if versions don't match, addUpdate might have stopped the connection, so make sure it's still up:
	
	if not connectionThread then return end
	
	str = connectionThread:get("statusErr")
	if str then
		statusMsg.new(str, true)
		
		--try again, with fallback IP:
		connection.startClient()
	end
	str = connectionThread:get("statusMsg")
	if str then
		statusMsg.new(str, false)
	end
	str = connectionThread:get("nextMatch")
	if str then
		timeUntilNextMatch = str
		print("timeUntilNextMatch", timeUntilNextMatch)
		simulation.displayTimeUntilNextMatch(timeUntilNextMatch)
	end
	
	err = connectionThread:get("error")
	if err then
		print("CONNECTION ERROR:", err)
	end
end

function connection.closeConnection()
	if connectionThread then
	 	connectionThread:set("closeConnection", true)
	 	connectionThread = nil
	end
end

return connection
