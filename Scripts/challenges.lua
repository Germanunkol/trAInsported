local challenges = {}

challengeEvents = {}

function challenges.resetEvents() -- resets all events that a challenge could be giving.
	--challengeEvent.mapRenderingDoneCallback = nil
	for k, ev in pairs(challengeEvents) do
		challengeEvent[k] = nil
	end
end

function challenges.start(c, aiFileName)

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
	challengeEvents.mapRenderingDoneCallback = c.start	
	
	menu.exitOnly()
end



function challenges.execute(data)

	local fileName, aiFileName = data.mapFileName, data.aiFileName

	if not map.generating() and not map.rendering() then
		ok, challengeData = pcall(love.filesystem.load, "Challenges/" .. fileName)
		if not ok then
			ok, challengeData = pcall(love.filesystem.load, "Maps/" .. fileName)
			if not ok then
				print("Error in challenge: Couldn't find the file.")
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
		
		if not c.name or type(c.name) ~= "string" then
			print("Error in challenge: No correct challenge name set. use ch.name = '...' to set it.")
			statusMsg.new("Error in challenge: No correct challenge name set. use ch.name = '...' to set it.", true)
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

return challenges
