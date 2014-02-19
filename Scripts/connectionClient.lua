local connection = {}

local connectionsRunning = 0

connectionThread = nil
connectionThreadChannelIn = love.thread.newChannel()
connectionThreadChannelOut = love.thread.newChannel()

local printLineNumber = 0

local packetNumber = 0

--local rememberPort = 0

function connection.startClient(ip, port)

	--[[th = love.thread.getThreads()
	i = 0
	for k, t in pairs(th) do
		i = i + 1
	end

	print("Threads: ", i)]]

	--[[if ip and port then
		rememberPort = port
	elseif rememberPort then
		port = rememberPort
		ip = FALLBACK_SERVER_IP
		rememberPort = nil
	else return end]]--
	if not port then port = PORT end
	if not ip then return end

	if connectionThread then
		connectionThreadChannelIn:push({key="command", "quit"})

		connectionThreadChannelIn = love.thread.newChannel()
		connectionThreadChannelOut = love.thread.newChannel()
	end
	
	serverTime = 0
	
	connectionThread = love.thread.newThread("Scripts/connectionThreadClient.lua")
	connectionThread:start( connectionThreadChannelIn, connectionThreadChannelOut, ip, port )
	connectionsRunning = connectionsRunning + 1 
	if connectionThread then
		--connectionThreadChannelIn:push({key="ip",ip})
		--connectionThreadChannelIn:push({key="port",port})
		
		connection.serverVersionMatch = false
		connection.mapReceived = false
	end
end


local lineFound = true

function connection.handleConnection()
	if not connectionThread then return end
	
	local packet = connectionThreadChannelOut:pop()

	if packet then
		if packet.key == "print" then
			print("CONNECTION:", packet[1])
			if packet[1]:find("closed") then
				lostConnection = true
			end
		end

		if packet.key == "newMap" then
			if not curMap and not map.startupProcess() then
				mapImage = nil
			end
			roundEnded = true
			simulationMap = TSerial.unpack(packet[1])
			map.print("New map", simulationMap)
			connection.mapReceived = true
			simulation.init()
		end

		if packet.key == "packet" then
			if packet[1]:find(".U:") then
				print("Error: Received bad packet", packet[1])
				statusMsg.new("Error in connection. Received a bad packet content. Will automatically retry when current match is over.", true)
			else
				simulation.addUpdate(packet[1])
			end
		end
		-- addUpdate MIGHT have stopped the connection (if version does not match server's version). Make sure to handle this here:
		if not connectionThread then
			return
		end

		if packet.key == "serverTime" then
			serverTime = packet[1]
			print("Received new server time: " .. serverTime)
			if simulationMap then
				print("My time: " .. simulationMap.time, "Delta:", serverTime - simulationMap.time .. " seconds" )
			end
		end

		if packet.key == "statusErr" then
			statusMsg.new(packet[1], true)

			--try again, with fallback IP:
			connection.startClient()
		end
		if packet.key == "statusMsg" then
			statusMsg.new(str, false)
		end
		if packet.key == "nextMatch" then
			timeUntilNextMatch = packet[1]
			print("timeUntilNextMatch", timeUntilNextMatch)
			simulation.displayTimeUntilNextMatch(timeUntilNextMatch)
		end
	end
	err = connectionThread:getError()
	if err then
		print("CONNECTION ERROR:", err)
		if err:find("Could not connect!") then
			print("could not connect error")
			if menuButtons.buttonSimulationExit then		-- change button to go to "back".
				x = defaultMenuX
				y = defaultMenuY + 45
				menuButtons.buttonAbortSimulation = button:new(x, y, "Return", menu.init, nil, nil, nil, nil, "Return to main menu")
			end
			loadingScreen.addSubSection(LNG.load_connecting, LNG.load_failed)
		end
		connection.closeConnection()
	end

	if connection.serverVersionMatch and connection.mapReceived then
		if not curMap then --and map.startupProcess() then
			--map.render(simulationMap)
			map.render(simulationMap)
			newMapStarting = true
			menu.exitOnly()
			simulation.runMap()
		end
		connection.serverVersionMatch = false
		connection.mapReceived = false
	end
end

function connection.closeConnection()
	if connectionThread then
		print("Closing connection!")
		connectionThreadChannelIn:push({key="closeConnection", true})
	 	--connectionThread:wait()
	 	connectionThread = nil
	end
end

return connection
