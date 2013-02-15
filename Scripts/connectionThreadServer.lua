thisThread = love.thread.getThread()

PORT = thisThread:demand("PORT")

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

local timeUntilNextMatch = 0

local connection = {}

local server, client

clientList = {}

print = function(...)
	sendStr = ""
	local arg = { ... }
	for i = 1, #arg do
		if arg[i] then
			sendStr = sendStr .. arg[i] .. "\t"
		end
	end
	thisThread:set("msg" .. msgNumber, sendStr)
	msgNumber = incrementID(msgNumber)
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
		client:send("MAP: " .. curMapStr .. "\n")
		for i = 1, #sendPacketsList do
			--print(client[1], "SENT:","U:" .. sendPacketsList[i].ID .. "|".. sendPacketsList[i].time .. "|" .. sendPacketsList[i].event)
			client:send("U:" .. sendPacketsList[i].ID .. "|" .. sendPacketsList[i].time .. "|" .. sendPacketsList[i].event .. "\n")		-- send all events to client that have already happened (in the right order)
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
			print("new client!")
			clientSynchronize(newClient)	-- send everything to the client that has been sent before
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
					print("client left.")
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

while true do
	dt = os.time()-curTime
	curTime = os.time()

	input = thisThread:get("input")
	if input == "close" then
		return
	end
	connection.handleServer()

	reset = thisThread:get("reset")
	if reset then
		sendPackets.init()			-- important! if there's a new map, reset everything you did last round!
	end

	newMap = thisThread:get("curMap")
	if newMap then
		curMapStr = newMap		-- careful: in this thread, it's only in string form, not in a table!
		
		for k, cl in pairs(clientList) do
			ok, msg = cl:send("MAP:" .. curMapStr .. "\n")
			ok, err = cl:send("T:" .. 0 .. "\n")		-- send update to clients.
			--print(cl[1], "SENT:","MAP:" .. curMapStr)
		end
		
	end
	
	str = thisThread:get("nextMatch")
	if str then
		timeUntilNextMatch = tonumber(str)
	end
	timeUntilNextMatch = timeUntilNextMatch - dt
	
	msg = thisThread:get("packet" .. packetNumber)
	if msg then
	
		newPacketID = sendPackets.getPacketNum() + 1
	
		for k, cl in pairs(clientList) do
			ok, err = cl:send("U:" .. newPacketID .. "|" .. msg .. "\n")		-- send update to clients.
			print(cl[1], "SENT:","U:" .. newPacketID .. "|" .. msg)
		end
		packetNumber = incrementID(packetNumber)
		
		s, e = msg:find("|")
		if not s then
			print("ERROR: no timestamp found in packet! Aborting.")
			return
		end
		time = tonumber(msg:sub(1, s-1))
		msg = msg:sub(e+1, #msg)
		sendPackets.add(newPacketID,msg, time)
		
	end
	
	t = thisThread:get("time")		-- tell the clients at what time they should currently be.
	if t then
		serverTime = t
		for k, cl in pairs(clientList) do
			ok, err = cl:send("T:" .. serverTime .. "\n")		-- send update to clients.
		end
	end
	
end
