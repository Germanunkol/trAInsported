--thisThread = love.thread.getThread()

local args = { ... }
local channelIn = args[1]
local channelOut = args[2]

local PORT = args[3]
local timeUntilNextMatch = args[4]

local socket = require("socket")

pcall(require, "TSerial")
pcall(require, "Scripts/TSerial")
pcall(require, "misc")
pcall(require, "Scripts/misc")

ok, sendPackets = pcall(require, "sendPackets")
if not ok then
	ok, sendPackets = pcall(require, "Scripts/sendPackets")
end

local msgNumber = 0
local statusNumber = 0
local packetNumber = 0


local connection = {}

local server, client

clientList = {}

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

-- Sends a string fully. If a timeout is reached, it will try again until there's
-- no more timeout.
function sendReliable( client, msg )
	local num, err, lastByte = client:send( msg )
	while num == nil and err == 'timeout' do
		msg = msg:sub( lastByte + 1 )
		num, err, lastByte = client:send( msg )
	end
end

function connection.startServer()
	ok, server = pcall(socket.bind, "*", PORT)
	if not ok then
		error("Error establishing server: " .. server)
		return false
	else
		print("Started server at: " .. PORT)
	end
	
	ok, err = pcall(function()
		-- set a timeout for accepting client connections
		server:settimeout(.0001)
		sendPackets.init()
	end)
	
	if not ok then error("Failed to set up server. Maybe a connection is already running on this port?\n" .. err) end
	
	return true
end


function clientSynchronize(client)		-- called on new clients. Will get them up to date
	if curMapStr then
		sendReliable( client, "MAP: " .. curMapStr .. "\n")
		for i = 1, #sendPacketsList do
			--print(client[1], "SENT:","U:" .. sendPacketsList[i].ID .. "|".. sendPacketsList[i].time .. "|" .. sendPacketsList[i].event)
			sendReliable( client, "U:" .. sendPacketsList[i].ID .. "|" .. sendPacketsList[i].time .. "|" .. sendPacketsList[i].event .. "\n")		-- send all events to client that have already happened (in the right order)
		end
		
		if serverTime then
			client:send("T: " .. serverTime .. "\n")
		end
	else
		--print(client[1], "SENT:","NEXT_MATCH:" .. timeUntilNextMatch)
		client:send("NEXT_MATCH:" .. timeUntilNextMatch .. "\n")
	end
end

function connection.handleServer()
	if server then
		newClient = server:accept()
		if newClient then
			table.insert(clientList, newClient)
			newClient:settimeout(.0001)
			print("New client!")
			-- send everything to the new client that has been sent to others already
			clientSynchronize(newClient)
		end
		
		for k, cl in pairs(clientList) do
			data, msg = cl:receive()
			--print(data, msg)
			if not msg then
				cl:send("echo: " .. data .. "\n")
			else
				--print("error: " .. msg)
				if msg == "closed" then
					cl:shutdown()
					clientList[k] = nil
					print("Client left.")
				end
			end
		end
	end
end

ok = connection.startServer()
if not ok then
	return
end
print("Connection started.")

curTime = os.time()

local packet

while true do
	dt = os.time()-curTime
	curTime = os.time()

	connection.handleServer()

	--input = thisThread:get("input")
	packet = channelIn:pop()
	if packet then
		if packet.key == "close" then
			return
		end

		if packet.key == "reset" then
			sendPackets.init()			-- important! if there's a new map, reset everything you did last round!
		end

		if packet.key == "curMap" then
			curMapStr = packet[1]		-- careful: in this thread, it's only in string form, not in a table!
			serverTime = 0
			for k, cl in pairs(clientList) do
				ok, msg = cl:send("MAP:" .. curMapStr .. "\n")
				ok, err = cl:send("T:" .. serverTime .. "\n")		-- send update to clients.
				--print(cl[1], "SENT:","MAP:" .. curMapStr)
			end

		end

		if packet.key == "nextMatch" then
			timeUntilNextMatch = tonumber(packet[1])
		end

		if packet.key == "packet" then
			local msg = packet[1]

			newPacketID = sendPackets.getPacketNum() + 1

			if msg:find("U:") then
				print("PANIC!!", msg)
			end

			for k, cl in pairs(clientList) do
				ok, err = cl:send("U:" .. newPacketID .. "|" .. msg .. "\n")		-- send update to clients.
				--print(cl[1], "SENT:","U:" .. newPacketID .. "|" .. msg)
			end
			packetNumber = incrementID(packetNumber)

			s, e = msg:find("|")
			if not s then
				print("ERROR: no timestamp found in packet! Aborting.")
				return
			end
			time = tonumber(msg:sub(1, s-1))
			msg = msg:sub(e+1, #msg)
			sendPackets.add(newPacketID, msg, time)
		end

		-- tell the clients at what time they should currently be:
		if packet.key == "time" then
			serverTime = packet[1]
			for k, cl in pairs(clientList) do
				ok, err = cl:send("T:" .. serverTime .. "\n")		-- send update to clients.
			end
		end

	end
	timeUntilNextMatch = timeUntilNextMatch - dt
end
