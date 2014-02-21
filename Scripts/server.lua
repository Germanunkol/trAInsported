
function initServer()
	if connection.thread then
		connection.channelIn:push({key="input", "close"})	-- tell the current thread to close
	end
	print("Initialising Server")
	
	connection.thread = love.thread.newThread("Scripts/connectionThreadServer.lua")
	--connectionThreadNum = connectionThreadNum + 1
	connection.channelIn = love.thread.newChannel()
	connection.channelOut = love.thread.newChannel()
	connection.thread:start( connection.channelIn, connection.channelOut, PORT, timeUntilNextMatch )
	connection.msgNumber = 0
	connection.packetNum = 0
	
end

function stopServer()
	if connection.thread then
		connection.channelIn:push({key="input", "close"})	-- tell the current thread to close
		connection.thread = nil
		curMap = nil
	end
end

function sendMapUpdate(event)
	local t = 0
	if curMap then
		t = curMap.time
	end
	connection.channelIn:push({key="packet", t .. "|" .. event})
	--connection.packetNum = incrementID(connection.packetNum)
end

function sendMap()
	if connection.thread then
		--connection.thread:set("curMap", TSerial.pack(curMap))
		connection.channelIn:push({key="curMap", TSerial.pack(curMap)})
	end
end

function sendRoundInfo()
	sendStr = "ROUND_DETAILS:"
	sendStr = sendStr .. VERSION .. ","
	sendStr = sendStr .. GAME_TYPE .. ","
	if GAME_TYPE == GAME_TYPE_TIME then
		sendStr = sendStr .. ROUND_TIME .. ","
	elseif GAME_TYPE == GAME_TYPE_MAX_PASSENGERS then
		sendStr = sendStr .. MAX_NUM_PASSENGERS .. ","
	end
	
	sendMapUpdate(sendStr)
end

function handleThreadMessages( container )
	if container.thread then
	
		-- first, look for new messages:
		--str = container.thread:get("msg" .. container.msgNumber)
		local packet = container.channelOut:pop()
		while packet do
			print(packet[1])
			packet = container.channelOut:pop()
		end
		
		-- then, check if there was an error:
		err = container.thread:getError()
		if err then
			print("Server thread error:", err)
			love.event.quit()
		end
	end
end
