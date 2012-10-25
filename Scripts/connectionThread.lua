thisThread = love.thread.getThread()
require("Scripts/mapUtils")
require("Scripts/TSerial")
require("socket")
require("Scripts/misc")

ip = thisThread:demand("ip")
port = thisThread:demand("port")

sendMsgNumber = 0

printLineNumber = 0
print = function(...)
	str = ""
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
	thisThread:set("packet" .. packetNumber, text)
	packetNumber = incrementID(packetNumber)
end

print("Hello from inside the connection thread!")

print("Attempting to connect to:", ip .. ":" .. port)
ok, client = pcall(socket.connect, ip, port)
if not ok or not client then
	print("Could not connect!", client)
	return
else
	print("Connected.")
end

startTime = os.time()
while true do
	msg = thisThread:get("sendMsg" .. sendMsgNumber)
	if msg then
		ok, msg = client:send(msg .. "\n")
		sendMsgNumber = incrementID(sendMsgNumber)
	end
	
	data, msg = client:receive()
	if not msg then
		print("received: " .. data)
		if data:find("MAP:") == 1 then
			thisThread:set("newMap", data:sub(5,#data))
		elseif data:find("U:") == 1 then
			newPacket(data:sub(3,#data))
		end
	else
		print("error: " .. msg)
		return
	end
end
