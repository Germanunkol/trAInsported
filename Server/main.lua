require("Scripts/misc")
map = require("Scripts/serverMap")
passenger = require("Scripts/passenger")
train = require("Scripts/train")
ai = require("Scripts/ai")
stats = require("Scripts/statistics")
require("Scripts/globals")
console = require("Scripts/serverConsole")

menu = {}
connectionThreadNum = 0
connection = {}

PORT = 5556

timeFactor = 1
TILE_SIZE = 128

timeUntilNextMatch = 0*1

function love.load()
	io.close()
	--[[menu.thread = love.thread.newThread("menuThread", "Scripts/menuThread.lua")
	menu.thread:start()
	menu.msgNumber = 0
	menu.statusNumber = 0
	menu.eventNumber = 0
	
	inputThread = love.thread.newThread("inputThread", "Scripts/inputThread.lua")
	inputThread:start()
	]]--
	
	map.init()
	
	initServer()
end

function initServer()
	if connection.thread then
		connection.thread:set("input", "close")	-- tell the current thread to close
	end
	print("Starting Server")
	
	connection.thread = love.thread.newThread("connectionThread" .. connectionThreadNum, "Scripts/connectionThread.lua")
	connectionThreadNum = connectionThreadNum + 1
	connection.thread:start()
	connection.thread:set("PORT", PORT)
	connection.msgNumber = 0
	connection.packetNum = 0
	
	connection.thread:set("nextMatch", timeUntilNextMatch)
end

function startMap()

	aiFiles = ai.findAvailableAIs()
	
	local chosenAIs = {}
	
	aiID = 1
	for k, aiName in pairs(aiFiles) do
		if aiID <= 4 then
			chosenAIs[aiID] = aiName
			aiID = aiID + 1
		end
	end

	curMap = nil
	startMatch(4, 5, "day", 20, GAME_TYPE_TIME, chosenAIs)
end

function stopServer()
	if connection.thread then
		connection.thread:set("input", "close")	-- tell the current thread to close
		connection.thread = nil
		curMap = nil
	end
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

function handleMenuStatus()
	str = menu.thread:get("status" .. menu.statusNumber)
	while str do
		if str == "exit" then
			love.event.quit()
		end
		if str == "input" then
			inputThread:set("getInput", true)
		end
		if str == "start server" then
			initServer()
		end
		if str == "stop server" then
			stopServer()
		end
		menu.statusNumber = incrementID(menu.statusNumber)
		str = menu.thread:get("status" .. menu.statusNumber)
	end
	
end

timePassed = 0
moveTime = 0
t = 0

function love.update()
	--handleThreadMessages( menu )
	handleThreadMessages( connection )
	
	--handleMenuStatus()
	
	-- check if there was new input that was received by the input thread.
	-- if so, pass it to the menu.
	--[[input = inputThread:get("input")
	if input then
		print("input received:", input)
		menu.thread:set("input", input)
	end
	
	err = inputThread:get("error")
	if err then
		print("THREAD error (input): " .. err)
		love.event.quit()
	end
	]]--
	
	if map.generating() then --not curMap and connection.thread then
		map.generate()
	end
	dt = love.timer.getDelta()
	if not roundEnded and curMap then
		if moveTime > .1 then
			train.moveAll(moveTime)
			moveTime = moveTime - .1
		end
		moveTime = moveTime + dt*timeFactor
		curMap.time = curMap.time + dt*timeFactor
	else
		t = t + dt
		if t > 1 then
			print("startNextMatchIn: ", timeUntilNextMatch)
			t = 0
		end
		timeUntilNextMatch = timeUntilNextMatch - dt
		if timeUntilNextMatch < 0 then
			print("STARTING!")
			startMap()
			timeUntilNextMatch = 5*1
			connection.thread:set("nextMatch", timeUntilNextMatch)
		end
	end
	if curMap then
		if not roundEnded then
			map.handleEvents(dt)
			if os.time() - timePassed >= 1 then
				timePassed = os.time()
				-- train.printAll()
			end
			passenger.showAll(dt)
		end
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
	sendStr = sendStr .. GAME_TYPE .. ","
	if GAME_TYPE == GAME_TYPE_TIME then
		sendStr = sendStr .. ROUND_TIME .. ","
	elseif GAME_TYPE == GAME_TYPE_MAX_PASSENGERS then
		sendStr = sendStr .. MAX_NUM_PASSENGERS .. ","
	end
	
	sendMapUpdate(sendStr)
end
