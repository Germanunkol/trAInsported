thisThread = love.thread.getThread()

PORT = thisThread:demand("PORT")

local socket = require("socket")
require("Scripts/TSerial")
require("Scripts/misc")

sendPackets = require("Scripts/sendPackets")

local msgNumber = 0
local statusNumber = 0
local packetNumber = 0

local connection = {}

local server, client

clientList = {}

print = function(...)
	sendStr = ""
	for i = 1, #arg do
		sendStr = sendStr .. arg[i] .. "\t"
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
	
	-- set a timeout for accepting client connections
	server:settimeout(.0001)
	sendPackets.init()
	
	return true
end


function clientSynchronize(client)		-- called on new clients. Will get them up to date
	if curMapStr then
		print("sending map:")
		client:send("MAP: " .. curMapStr .. "\n")
		print("Sendung updates:", #sendPacketsList)
		for i = 1, #sendPacketsList do
			client:send("U:" .. sendPacketsList[i].time .. "|" .. sendPacketsList[i].event .. "\n")		-- send all events to client that have already happened (in the right order)
			print("SENT: " .. "U:" .. sendPacketsList[i].time .. "|" .. sendPacketsList[i].event)
		end
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
				print("received: " .. data)
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

while true do
	input = thisThread:get("input")
	if input == "close" then
		return
	end
	connection.handleServer()

	newMap = thisThread:get("curMap")
	if newMap then
		curMapStr = newMap		-- careful: in this thread, it's only in string form, not in a table!
		
		for k, cl in pairs(clientList) do
			ok, msg = sl:send("MAP:" .. curMapStr .. "\n")
		end
	end
	
	msg = thisThread:get("packet" .. packetNumber)
	if msg then
		for k, cl in pairs(clientList) do
			ok, msg = sl:send("U:" .. msg .. "\n")		-- send update to clients.
		end
		packetNumber = incrementID(packetNumber)
		
		s, e = msg:find("|")
		if not s then
			print("ERROR: no timestamp found for packet! Aborting.")
			return
		end
		time = tonumber(msg:sub(1, s-1))
		msg = msg:sub(e+1, #msg)
		sendPackets.add(msg, time)
	end
	
end
