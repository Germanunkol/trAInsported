thisThread = love.thread.getThread()

require("Scripts/misc")

local menu = {}

local menuOptions = {}

local details = {}

local clientList = {}

local msgNumber = 0
local statusNumber = 0
local clientNumber = 0

local eventNumReceived = 0


print = function(...)
	sendStr = ""
	for i = 1, #arg do
		sendStr = sendStr .. arg[i] .. "\t"
	end
	thisThread:set("msg" .. msgNumber, sendStr)
	msgNumber = incrementID(msgNumber)
end

function status(sendStr)
	print("setting status to", sendStr, statusNumber)
	thisThread:set("status" .. statusNumber, sendStr)
	statusNumber = incrementID(statusNumber)
end

function menu.display()
	print("____________________")
	if showClients then
		if #clientList > 0 then
			print("Clients:")
		end
		for i = 1, #clientList do
			print("\t" .. clientList[i])
		end
	end
	--[[print("Status:")
	for k, v in pairs(details) do
		print("\t", k, v)
	end]]--
	print("Options:")
	for i = 1, #menuOptions do
		print(" ", "(" .. i .. ")", menuOptions[i].title)
	end
	status("input")
end

function menu.addOption( title, event, arguments )
	menuOptions[#menuOptions+1] = {title = title, event = event, arguments = arguments}
end

function menu.removeOptions( title )
	for i = 1, #menuOptions do			-- look for the given menu entry
		if title == menuOptions[i].title then	-- found the menu entry?
			for j = i, #menuOptions do
				menuOptions[j] = menuOptions[j+1]	-- move all up one. last one will be set to nil automatically.
			end
		end
	end
end

function displayClients()
	menuOptions = {}
	showClients = true
	
	menu.addOption("Return", choseStartServer)
	menu.display()
end

function displayStats()
	menuOptions = {}
	showClients = true
	
	menu.addOption("Return", choseStartServer)
	menu.display()
end


function choseStartServer(startServer)
	if startServer then
		status("start server")
	end

	showClients = false
	menuOptions = {}
	menu.addOption("Stop Server", menu.init, true)	-- display main menu, make sure to stop running server.
	menu.addOption("Show Clients", displayClients)
	menu.addOption("Setup")
	menu.addOption("Exit", status, "exit")
	menu.display()

end

function menu.init(stopServer)
	if stopServer then
		status("stop server")
	end
	menuOptions = {}
	
	menu.addOption("Start Server", choseStartServer, true)
	menu.addOption("Setup")
	menu.addOption("Exit", status, "exit")
	menu.display()
end

function menu.handleInput( input )
	input = tonumber(input)
	if input == nil then return end
	
	if input >= 1 and input <= #menuOptions then
		if menuOptions[input].event then
			menuOptions[input].event(menuOptions[input].arguments)
			return
		end
	end
	
	print("ERROR: Invalid input")
	menu.display()
end


function clientConnected(client)
	if client then
		table.insert(clientList, client)
	end
end

function clientLeft(client)
	for k, cl in pairs(clientList) do
		if cl == client then
			clientList[k] = nil
			return
		end
	end
end

menu.init()

function setStatus(name, status)
	print(name, status)
	details[name] = status
end

while true do
	input = thisThread:get("input")
	if input then
		menu.handleInput(input)
	end
	eventStr = thisThread:get("event".. eventNumReceived)
	if eventStr then
		eventNumReceived = eventNumReceived + 1
		print("eventStr", eventStr)
		interpretEvent(eventStr)
	end
end
