
function initServer()
	if connection.thread then
		connection.thread:set("input", "close")	-- tell the current thread to close
	end
	print("Initialising Server")
	
	connection.thread = love.thread.newThread("connectionThread" .. connectionThreadNum, "Scripts/connectionThreadServer.lua")
	connectionThreadNum = connectionThreadNum + 1
	connection.thread:start()
	connection.thread:set("PORT", PORT)
	connection.msgNumber = 0
	connection.packetNum = 0
	
	connection.thread:set("nextMatch", timeUntilNextMatch)
end

function stopServer()
	if connection.thread then
		connection.thread:set("input", "close")	-- tell the current thread to close
		connection.thread = nil
		curMap = nil
	end
end

function sendMapUpdate(event)
	local t = 0
	if curMap then
		t = curMap.time
	end
	connection.thread:set("packet" .. connection.packetNum, t .. "|" .. event)
	connection.packetNum = incrementID(connection.packetNum)
end

function sendMap()
	if connection.thread then
		connection.thread:set("curMap", TSerial.pack(curMap))
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
		str = container.thread:get("msg" .. container.msgNumber)
		while str do
			print(str)
			container.msgNumber = incrementID(container.msgNumber)
			str = container.thread:get("msg" .. container.msgNumber)
		end
		
		-- then, check if there was an error:
		err = container.thread:get("error")
		if err then
			print("THREAD error: " .. err)
			love.event.quit()
		end
	end
end
