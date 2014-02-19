--thisThread = love.thread.getThread()

--package.path = "Scripts/?.lua;" .. package.path
require("love.filesystem")

pcall(require,"mapUtils")
pcall(require,"Scripts/mapUtils")
pcall(require,"TSerial")
pcall(require,"Scripts/TSerial")
pcall(require,"misc")
pcall(require,"socket")

require("Scripts/misc")

local args = { ... }

local channelIn = args[1]
local channelOut = args[2]

local ip = args[3]
local port = args[4]

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
	channelOut:push({key="print", str})
end

function newPacket(text)
	channelOut:push({key="packet", text})
end

print("Attempting to connect to:", ip .. ":" .. port)
ok, client = pcall(socket.connect, ip, port)
if not ok or not client then
	channelOu:push({key="statusErr", "Could not connect to server. Either your internet connection is not active or the server is down for maintainance."})
	error("Could not connect!")
	return
else
	channelOut:push({key="statusMsg", "Connected to server."})
	print("Connected.")
end

local packet

startTime = os.time()
while true do
	packet = channelIn:pop()
	if packet then
		if packet.key == "msg" then
			ok, msg = client:send(packet[1] .. "\n")
		end

		if packet.key == "closeConnection" then
			return
		end
	end

	data, msg = client:receive()
	if data and not msg then

		if data:find(".U:") and not data:find("MAP:") == 1 then
			print("RECEIVED: faulty packet")
		end

		if data:find("MAP:") == 1 then
			--thisThread:set("newMap", data:sub(5,#data))
			channelOut:push({key="newMap", data:sub(5,#data)})
		elseif data:find("U:") == 1 then
			channelOut:push({key="packet", data:sub(3,#data)})
		elseif data:find("NEXT_MATCH:") == 1 then
			timeUntilNextMatch = tonumber(data:sub(12, #data))
			--thisThread:set("nextMatch", timeUntilNextMatch)
			channelOut:push({key="nextMatch", timeUntilNextMatch})
		elseif data:find("T:") == 1 then
			serverTime = tonumber(data:sub(3, #data))
			--thisThread:set("serverTime", serverTime)
			channelOut:push({key="serverTime", serverTime})
		end
	else
		print("error: " .. msg)
		return
	end
end
