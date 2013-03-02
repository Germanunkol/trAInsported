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

function challenges.start(c, aiFileName)

	challengeRunning = true
	stats.start( 1 )
	
	-- correct anything that might have gone wrong with the map:
	c.map.time = 0
	
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
	
	map.generate(nil,nil,1,c.map)
	
	-- if the map has events, set them here!
	challengeEvents.mapRenderingDoneCallback = function()
		if c.version and c.version ~= VERSION then
			statusMsg.new("Map is built for version " .. c.version .. ", but you're running version " .. VERSION ..". There might be problems. If so, please report them!", true)
		end
		c.start()
	end
	challengeEvents.update = c.update
	challengeEvents.newTrain = c.newTrain
	
	menu.exitOnly()
end

function challenges.execute(data)

	local fileName, aiFileName = data.mapFileName, data.aiFileName

	if not map.generating() and not map.rendering() then
		print("Looking for: ","/Maps/" .. fileName)
		ok, challengeData = pcall(love.filesystem.load, "Maps/" .. fileName)
		if not ok then
			print("Error in challenge: Couldn't execute map:", challengeData)
			ok, challengeData = pcall(love.filesystem.load, "Challenges/" .. fileName)
			if not ok then
				print("Error in challenge: Couldn't execute map:", challengeData)
				return
			end
		end
		
		local c = challengeData() -- execute the chunk
		
		if not c then
			print("Error in challenge: You must return a lua table containing your challenge's data. See example file!")
			statusMsg.new("Error in challenge: You must return a lua table containing your challenge's data. See example file!", true)
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
		
		challenges.start(c, aiFileName)
	else
		statusMsg.new("Wait for rendering to finish...", true)
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
