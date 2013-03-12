thisThread = love.thread.getThread()

--package.path = "Scripts/?.lua;" .. package.path
require("love.filesystem")

pcall(require,"mapUtils")
pcall(require,"Scripts/mapUtils")
pcall(require,"TSerial")
pcall(require,"Scripts/TSerial")
pcall(require,"misc")
pcall(require,"socket")

require("Scripts/misc")


ip = thisThread:demand("ip")
port = thisThread:demand("port")

sendMsgNumber = 0
function incrementID( num )
	if num == 99999 then
		num = 0
	else
		num = num + 1
	end
	return num
end

printLineNumber = 0
print = function( ... )
	str = ""
	local arg = { ... }
	for i=1,#arg do
		if arg[i] then
			str = str .. arg[i] .. "\t"
		else
			str = str .. "nil\t"
		end
	end
	thisThread:set("print" .. printLineNumber, str)
	
	printLineNumber = incrementID(printLineNumber)
end





packetNumber = 0
function newPacket(text)
	--print("thread-packet", packetNumber, text)
	thisThread:set("packet" .. packetNumber, text)
	packetNumber = incrementID(packetNumber)
end


print("Attempting to connect to:", ip .. ":" .. port)
ok, client = pcall(socket.connect, ip, port)
if not ok or not client then
	thisThread:set("statusErr", "Could not connect to server. Either your internet connection is not active or the server is down for maintainance.")
	error("Could not connect!")
	return
else
	thisThread:set("statusMsg", "Connected to server.")
	print("Connected.")
end

startTime = os.time()
while true do
	msg = thisThread:get("sendMsg" .. sendMsgNumber)
	if msg then
		ok, msg = client:send(msg .. "\n")
		sendMsgNumber = incrementID(sendMsgNumber)
	end
	
	if thisThread:get("closeConnection") then
		return
	end
	
	data, msg = client:receive()
	if not msg then
		
		--print("RECEIVED: " .. data)
	
		if data:find("MAP:") == 1 then
			thisThread:set("newMap", data:sub(5,#data))
		elseif data:find("U:") == 1 then
			newPacket(data:sub(3,#data))
		elseif data:find("NEXT_MATCH:") == 1 then
			timeUntilNextMatch = tonumber(data:sub(12, #data))
			thisThread:set("nextMatch", timeUntilNextMatch)
		elseif data:find("T:") == 1 then
			serverTime = tonumber(data:sub(3, #data))
			thisThread:set("serverTime", serverTime)
		end
	else
		print("error: " .. msg)
		return
	end
end
