thisThread = love.thread.getThread()
require("Scripts/mapUtils")
require("Scripts/TSerial")
require("socket")

ip = thisThread:demand("ip")
port = thisThread:demand("port")

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
	printLineNumber = printLineNumber + 1
	if printLineNumber == 99999 then
		printLineNumber = 0
	end
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
	if os.time()-startTime > 2 then
		print("sending...")
		ok, msg = client:send("Test" .. os.time() .. "\n")
		if not ok then
			print(msg)
			if msg == "closed" then return end
		end
		startTime = os.time()
	end
end
