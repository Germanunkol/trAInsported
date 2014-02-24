local challenges = {}

challengeEvents = {}
local challengeRunning = false

local challengeStatus = ""

function challenges.resetEvents() -- resets all events that a challenge could be giving.
	--challengeEvent.mapRenderingDoneCallback = nil
	for k, ev in pairs(challengeEvents) do
		challengeEvents[k] = nil
	end
	challengeStatus = ""
	challengeRunning = false
end

function challenges.isRunning()
	return challengeRunning
end

function challenges.setEvents(c)
-- if the map has events, set them here!
	challengeEvents.update = c.update
	challengeEvents.newTrain = c.newTrain
	challengeEvents.passengerBoarded = c.passengerBoarded
	challengeEvents.passengerDroppedOff = c.passengerDroppedOff
	
	challengeEvents.mapRenderingDoneCallback = function()
		if c.version and c.version ~= VERSION then
			statusMsg.new("Map is built for version " .. c.version .. ", but you're running version " .. VERSION ..". There might be problems. If so, please report them!", true)
		end
		c.start()
	end
end

function challenges.start(c, aiFileName)

	challengeRunning = true
	
	MAX_NUM_TRAINS = c.maxTrains
	
	stats.start( 1, c.startMoney )
	
	-- correct anything that might have gone wrong with the map:
	c.map.time = 0
--[[	
	print(c.map.height, c.map.width)
	local m = c.map
		local str = ""
		for j = 0,m.height+1,1 do
			str = ""
			for i = 0,m.width+1,1 do
				if m[i][j] then
					str = str .. m[i][j] .. " "
				else
					str = str .. "- "
				end
			end
			print(str)
		end]]


	loadingScreen.reset()
	loadingScreen.addSection("New Map")
	loadingScreen.addSubSection("New Map", "Size: " .. c.map.width .. "x" .. c.map.height)
	loadingScreen.addSubSection("New Map", "Challenge: " .. c.name)

	train.init()
	train.resetImages()
	
	ai.restart()	-- make sure aiList is reset!
		
	ok, msg = pcall(ai.new, aiFileName)
	if not ok then
		print("Err: " .. msg)
	else
		local s, e, aiName= aiFileName:find(".*/(.-)%.lua")
		if not aiName then
			aiName = aiFileName:sub(1, #aiFileName-4)
		end
		stats.setAIName(1, aiName)
		train.renderTrainImage(aiFileName:sub(1, #aiFileName-4), 1)
	end
	
	challenges.setEvents(c)
	
	map.generate(nil,nil,1,c.map)
	
	menu.exitOnly()
end

local fileName, aiFileName

function challenges.execute(data)

	if data then
		fileName, aiFileName = data.mapFileName, data.aiFileName
	end

	challenges.resetEvents()	-- just in case...

	if not map.generating() and not map.rendering() then
		print("Looking for: ","Maps/" .. fileName)
		challengeData = love.filesystem.load( "Maps/" .. fileName)
		if not challengeData then
			print("Problem in challenge: Couldn't find/execute map. Error:", challengeData)
			print("Fallback: Looking for file in internal path...")
			challengeData = love.filesystem.load( "Challenges/" .. fileName)
			if not challengeData then
				print("Error in challenge: Couldn't execute map:", challengeData)
				return
			else
				print("Success: Map found in Challenges/ subfolder!")
			end
		end
		
		local ok, c
		do		-- just in case. I don't think this actually does anything.
			c = challengeData() -- execute the chunk
		end
	--[[	
		if not ok then
			print(c)
			statusMsg.new("Could not execute challenge script. See console for more details.", true)
			menu.init()
		end]]
		
		if not c then
			print("Error in challenge: You must return a lua table containing your challenge's data. See example file!")
			statusMsg.new("Error in challenge: You must return a lua table containing your challenge's data. See example file!", true)
			menu.init()
			return
		end
		
		if not c.map or type(c.map) ~= "table" then
			print("Error in challenge: The returned map must be a valid lua table containing map data.")
			statusMsg.new("Error in challenge: The returned map must be a valid lua table containing map data.", true)
			return
		else
			c.map = challenges.fixMap( c.map )
		end
		
		if not c.start or not type(c.start) == "function" then
			print("Error in challenge: No starting function found.")
			statusMsg.new("Error in challenge: No starting function found.", true)
			return
		end

		challenges.start(c, aiFileName)
		
	else
		statusMsg.new("Wait for rendering to finish...", true)
	end
end

function removeSingleRails( m )
	print(m[6][2])
	for x = 1, m.width do
		for y = 1, m.height do
			if m[x][y] == "C" then
				local num = 0
				num = num + (m[x+1] and (m[x+1][y] == "C" and 1) or 0)
				num = num + (m[x-1] and (m[x-1][y] == "C" and 1) or 0)
				num = num + (m[x][y+1] == "C" and 1 or 0)
				num = num + (m[x][y-1] == "C" and 1 or 0)
				
				if num == 0 then
					m[x][y] = nil
					return true
				end
			end
		end
	end
	print(m[6][2])
	print(m[6][2])
end

function challenges.fixMap( m )

	printTable(m)
	local new = {}
	local width = m.width
	local height = m.height

	if not width then
		width = #m
	end
	if not height then
		height = 0
		for x = 1, width do
			height = math.max(#m[x], height)
		end
	end

	print( "Set width and height:", width, height )

	-- copy only the fields in the map's data which are inside the valid region:
	for x = 0, width+1 do
		new[x] = {}
		for y = 1, height+1 do
			if x == 0 or x == width+1 or y == 0 or y == height+1 then
				if m[x] then
					m[x][y] = nil
				end
			end
			if m[x] and m[x][y] then
				new[x][y] = m[x][y]
			end
		end
	end

	new.width, new.height = width, height
	
	-- remove all rails which aren't connected:
	while removeSingleRails( new ) do
	end
	
	return new
end

function challenges.restart()
	challenges.resetEvents()	-- just in case...

	print("RESTART!")
	
	if not map.generating() and not map.rendering() then

		print("Looking for: ","Maps/" .. fileName)
		challengeData = love.filesystem.load( "Maps/" .. fileName)
		if not challengeData then
			print("Problem in challenge: Couldn't find/execute map. Error:", challengeData)
			print("Fallback: Looking for file in internal path...")
			challengeData = love.filesystem.load( "Challenges/" .. fileName)
			if not challengeData then
				print("Error in challenge: Couldn't execute map:", challengeData)
				return
			else
				print("Success: Map found in Challenges/ subfolder!")
			end
		end
		
		local ok, c
		do		-- just in case. I don't think this actually does anything.
			c = challengeData() -- execute the chunk
		end

		if not c then
			print("Error in challenge: You must return a lua table containing your challenge's data. See example file!")
			statusMsg.new("Error in challenge: You must return a lua table containing your challenge's data. See example file!", true)
			menu.init()
			return
		end

		if not c.map or type(c.map) ~= "table" then
			print("Error in challenge: The returned map must be a valid lua table containing map data.")
			statusMsg.new("Error in challenge: The returned map must be a valid lua table containing map data.", true)
			return
		end

		if not c.start or not type(c.start) == "function" then
			print("Error in challenge: No starting function found.")
			statusMsg.new("Error in challenge: No starting function found.", true)
			return
		end

		challenges.setEvents(c)
		c.map.time = 0
		
		MAX_NUM_TRAINS = c.maxTrains
		--stats.start( 1, c.startMoney )
		
		c.start()
		challengeRunning = true
	end
end

-- display the current status message set by the user:
function challenges.roundStats()
	love.graphics.setColor(255,255,255,255)
			love.graphics.setFont(FONT_STAT_HEADING)
	x = love.graphics.getWidth()-roundStats:getWidth()-20
	y = 20
	love.graphics.draw(roundStats, x, y)
	
	love.graphics.printf(challengeStatus, x +20, y+10, roundStats:getWidth() - 40)
end


-- utilities for the map creator:

function challenges.createEmptyMap(width, height)
	m = {}
	m.width = width
	m.height = height
	for k = 0, width+1 do
		m[k] = {}
	end
	return m
end

function challenges.convertTableToMap(table)
  	local map = {}
	local _mapAssoc = {}
	_mapAssoc[0] = nil
	_mapAssoc[1] = "C"
	_mapAssoc[2] = "H"
	_mapAssoc[3] = "S"
	_mapAssoc[4] = "STORE"
	map[0] = {}
	for i,row in ipairs(table) do
		for j,value in ipairs(row) do
			if value > 0 then
				map[j][i] = _mapAssoc[value]
			end
		end	
	end
	map[j+1] = {}
	map.width = j
	map.height = i
	return map
end

function challenges.setMessage(msg)
	if currentTutBox then
		TUT_BOX_X = currentTutBox.x
		TUT_BOX_Y = currentTutBox.y
		tutorialBox.remove(currentTutBox)
	end
	currentTutBox = tutorialBox.new( TUT_BOX_X, TUT_BOX_Y, msg, nil )
end

function challenges.removeMessage()
	if currentTutBox then
		tutorialBox.remove(currentTutBox)
	end
end

function challenges.setStatus(msg)
	challengeStatus = msg
end


return challenges
