require("Scripts/mapUtils")

local map = {}

roundEnded = false

TILE_SIZE = 128		-- DO NOT CHANGE! (unless you change all the images as well)

local curMapOccupiedTiles = {}	-- stores if a certain path on a tile is already being used by another train
local curMapOccupiedExits = {}	-- stores whether a certain exit of a tile is already being used by another train

if not DEDICATED then
	IMAGE_HOTSPOT_HIGHLIGHT = love.graphics.newImage("Images/HotSpotHighlight.png")
	groundSheetGrass = love.graphics.newImage("Images/GroundSheet.png")
	groundSheetStone = love.graphics.newImage("Images/GroundSheet_Stone.png")
	objectSheet = love.graphics.newImage("Images/ObjectSheet.png")
	objectShadowSheet = love.graphics.newImage("Images/ObjectShadowsSheet.png")
end

local status = nil

local mapSeed = 0


--------------------------------------------------------------
--		INITIALISE MAP:
--------------------------------------------------------------

newMapStarting = false
local showCoordinates = false

function map.startupProcess()
	if newMapStarting == true then
		return true
	end
end

function setupMatch( width, height, time, maxTime, gameMode, AIs, region )

	winnerID = nil
	
	if DEDICATED then		-- let server choose parameteres for game:
	
		print("Finding AIs")
		aiFiles = ai.findAvailableAIs()
		
		local chosenAIs = {}
	
		aiID = 1
		for k, aiName in pairs(aiFiles) do
			if aiID <= 4 then
				chosenAIs[aiID] = aiName
				print("CHOSE AI:", aiName)
				aiID = aiID + 1
			end
		end

		curMap = nil
		
		width = math.random(MAP_MINIMUM_SIZE, MAP_MAXIMUM_SIZE)
		height = math.random(MAP_MINIMUM_SIZE, MAP_MAXIMUM_SIZE)
		time = POSSIBLE_TIMES[math.random(#POSSIBLE_TIMES)]
		region = POSSIBLE_REGIONS[math.random(#POSSIBLE_REGIONS)]
		if CL_ROUND_TIME then
			maxTime = CL_ROUND_TIME
		else
			maxTime = FALLBACK_ROUND_TIME
		end
		
		gameMode = 2 --math.random(2)
		AIs = chosenAIs
		
		--IMPORTANT!
		if connection.thread then
			-- reset all packets that have been sent last round!
			connection.channelIn:push({key="reset", true})
		end
		
	else
	
		loadingScreen.addSection(LNG.load_new_map)
		loadingScreen.addSubSection(LNG.load_new_map, LNG.load_map_size .. width .. "x" .. height)
		for k = 1,#POSSIBLE_TIMES do
			if time == POSSIBLE_TIMES[k] then			
				loadingScreen.addSubSection(LNG.load_new_map, LNG.load_map_time .. LNG.menu_time_name[k])
				break
			end
		end
		for k = 1,#POSSIBLE_TIMES do
			if time == POSSIBLE_TIMES[k] then			
				loadingScreen.addSubSection(LNG.load_new_map, LNG.load_map_time .. LNG.menu_time_name[k])
				break
			end
		end
		if gameMode == GAME_TYPE_TIME then
			loadingScreen.addSubSection(LNG.load_new_map, LNG.load_map_mode_time .. "(" .. ROUND_TIME .. LNG.seconds .. ")")
		elseif gameMode == GAME_TYPE_MAX_PASSENGERS then
			loadingScreen.addSubSection(LNG.load_new_map, LNG.load_map_mode_passengers)
		end
		
		train.resetImages()
		
		menu.exitOnly()
	end
	
	CURRENT_REGION = region or "Suburban"
	ROUND_TIME = math.floor(maxTime)
	GAME_TYPE = gameMode
	GAME_TIME = time
	ai.restart()	-- make sure aiList is reset!
	stats.start( #AIs, STARTUP_MONEY )
	train.init()
	
	map.generate(width, height, math.random(1000))
	print("found AIs:", #AIs)
	for i = 1, #AIs do
		ok, name, owner = pcall(ai.new, AIs[i])
		if not ok then
			print("Err: " .. name)
		else
			stats.setAIName(i, name, owner)
		end
		if not DEDICATED then
			train.renderTrainImage(AIs[i]:sub(1, #AIs[i]-4), i)
		end
	end
end

-- called when map has been generated and rendered
function runMap(restart)
	newMapStarting = false
	if curMap then
	
--		if console and console.flush and not restart then
	--		console.flush()
		--end
		if not challenges.isRunning() then
			MAX_NUM_TRAINS = math.floor(math.max(curMap.width*curMap.height/10, 1))
		end
		if DEDICATED then
			MAX_NUM_TRAINS = math.floor(math.max(curMap.width*curMap.height/20, 1))
		end
		
		math.randomseed(mapSeed)
		
		local maxPassengers = math.ceil(curMap.width*curMap.height/3)
		
		if CURRENT_REGION == "Urban" then
			maxPassengers = maxPassengers*2
		end
		
		passenger.init ( maxPassengers )		-- start generating random passengers, set the maximum number of them.
		
		-- If there's a tutorial callback registered by the current map, then start that now!
		if tutorial then
			if not restart and tutorial.mapRenderingDoneCallback then
				tutorial.mapRenderingDoneCallback()
			elseif restart and tutorial.restartEvent then
				tutorial.restartEvent()
			end
		end
		
		
		ai.init()
		
		if challengeEvents.mapRenderingDoneCallback then
			challengeEvents.mapRenderingDoneCallback()
		end
		 
		if not DEDICATED then
			if RENDER_CLOUDS then
				clouds.restart()
			end
			
			MAX_PAN = (math.max(curMap.width, curMap.height)*TILE_SIZE)/2		-- maximum width that the camera can move
			
			menu.ingame()
			
			resetTimeFactor()		-- set back to 1.
			
		else
			sendRoundInfo()
		end
		
		clearAllOccupations()
		
		curMap.time = 0		-- start map timer.
		
		roundEnded = false
		
		if restart and challenges.isRunning() then
			challenges.restart()
		end
		
	else
		print("ERROR: NO MAP FOUND!")
	end
	
	if not simulation or not simulation.isRunning() then
		if menu then
			menu.createSpeedControl()
		end
	end
end

function map.restart()
	
	AIs = ai.restart()	-- get list of current ais, and remove the current ais.

	printTable(AIs)
	stats.start()
	train.init()
	
	clearAllOccupations()
	
	console.flush()
	
	console.add("--- Restart ---", {r=255,g=50,b=50})
	
	for i = 1, #AIs do
		ok, name, owner = pcall(ai.new, AI_DIRECTORY .. AIs[i] .. ".lua")
		if not ok then
			print("Err: " .. name)
		else
			stats.setAIName(i, name, owner)
		end
	end
	
	runMap(true)	-- re-initialise map
end

function clearAllOccupations()

	curMapOccupiedTiles = {}
	curMapOccupiedExits = {}
	
	for i = 1,curMap.width do
		curMapOccupiedTiles[i] = {}
		curMapOccupiedExits[i] = {}
		for j = 1, curMap.height do
			curMapOccupiedTiles[i][j] = {}
			curMapOccupiedTiles[i][j].from = {}
			curMapOccupiedTiles[i][j].to = {}
		
			curMapOccupiedExits[i][j] = {}
		end
	end

end

--[[
function populateMap()
	if not curMap then return end
	
	local firstFound = false
	for i = 1, 1 do
		--firstFound = false
		for i = 1, curMap.width do
			for j = 1, curMap.height do
				if curMap[i][j] == "C" and not map.getIsTileOccupied(i, j) then
					if math.random(3) == 1 then
					--if not firstFound then
						firstFound = true
						if curMap[i-1][j] == "C" then
							train:new( math.random(4), i, j, "W" )
						elseif curMap[i+1][j] == "C" then
							train:new( math.random(4), i, j, "E" )
						elseif curMap[i][j-1] == "C" then
							train:new( math.random(4), i, j, "N" )
						else
							train:new( math.random(4), i, j, "S" )
						end
						numTrains = numTrains+1
					end
				end
			end
		end
	end
end
]]--

function file_exists(name)
	local f=io.open(name,"r")
	if f~=nil then
		io.close(f)
		return true
	else
		return false
	end
end

local mapGenerateThreadNumber = 0
local mapRenderThreadNumber = 0
-- Generates a new map. Any old map is dropped.
function map.generate(width, height, seed, tutorialMap)
	if not map.generating() then
	
		if file_exists("log.txt") and DEBUG then
			local f = io.open("log.txt", "w")
			f:write("")
			f:close()
		end
	
		newMapStarting = true
		mapRenderPercent = nil
		mapGeneratePercent = nil
		numTrains = 0
		mapSeed = seed
	
		if not DEDICATED then
	
			love.graphics.translate(camX + love.graphics.getWidth()/(2*camZ), camY + love.graphics.getHeight()/(2*camZ))
			
			simulation.stop()
			
			loadingScreen.addSection(LNG.load_generating_map)
		end
	
		mapImage,mapShadowImage,mapObjectImage = nil,nil,nil
		
		if not width then width = 4 end
		if not height then height = 4 end
		if not seed then seed = 1 end
		
		if width < MAP_MINIMUM_SIZE then
			print("Minimum width is " .. MAP_MINIMUM_SIZE "!")
			width = MAP_MINIMUM_SIZE
		end
		if height < MAP_MINIMUM_SIZE then
			print("Minimum height is " .. MAP_MINIMUM_SIZE "!")
			height = MAP_MINIMUM_SIZE
		end

		if tutorialMap then
			print("Generating new tutorial map. Width: " .. tutorialMap.width .. " Height: " .. tutorialMap.height)
		else
			print("Generating new map. Width: " .. width .. " Height: " .. height)
		end
		-- mapImage, mapShadowImage, mapObjectImage = map.render()
		--mapGenerateThreadNumber = incrementID(mapGenerateThreadNumber) -- don't generate same name twice!
		mapGenerateThread = love.thread.newThread("Scripts/mapGenerate.lua")
		mapGenerateThreadChannelIn = love.thread.newChannel()
		mapGenerateThreadChannelOut = love.thread.newChannel()
		mapGenerateThread:start( mapGenerateThreadChannelIn, mapGenerateThreadChannelOut,
			width, height, seed,
			tutorialMap and TSerial.pack(tutorialMap),-- only call .pack if tutorialMap not nil!!
			CURRENT_REGION )
		--[[	
		if tutorialMap then
		--mapGenerateThread:set("tutorialMap", TSerial.pack(tutorialMap))
			mapGenerateThreadChannelIn:push({key="tutorialMap", TSerial.pack(tutorialMap)} )
		end
		mapGenerateThreadChannelIn({key="width", width })
		mapGenerateThreadChannelIn({key="height", height })
		mapGenerateThreadChannelIn({key="seed", seed })
		if CURRENT_REGION then
			mapGenerateThreadChannelIn({key="region", CURRENT_REGION})
		end]]
		
		currentlyGeneratingMap = true
		
		prevStr = nil
	else
		local packet = mapGenerateThreadChannelOut:pop()
		if packet then
			if packet.key == "percentage" and loadingScreen then
				loadingScreen.percentage(LNG.load_generating_map, packet[1])
			end

			-- first, look for new messages:
			if packet.key == "msg" then
				print(packet[1])
				--[[if prevStr == packet[1] and packet[1] == "I'm done!" then
					print("Error: Same message twice!")
					love.event.quit()
				end
				prevStr = packet[1]]
			end

			if packet.key == "curMap" then
				curMap = TSerial.unpack(packet[1])
				print("new curMap:", curMap)
			elseif packet.key == "curMapRailTypes" then
				curMapRailTypes = TSerial.unpack(packet[1])
			elseif packet.key == "curMapOccupiedTiles" then
				curMapOccupiedTiles = TSerial.unpack(packet[1])
			elseif packet.key == "curMapOccupiedExits" then
				curMapOccupiedExits = TSerial.unpack(packet[1])
			end

			if packet.key == "status" then
				if loadingScreen then
					loadingScreen.addSubSection(LNG.load_generating_map, LNG.load_generation[packet[1]])
				end
				if packet[1] == "done" then
					print("Generating done!")

					if loadingScreen then
						loadingScreen.percentage(LNG.load_generating_map, 100)
					end
					map.print("Finished Map:")

					currentlyGeneratingMap = false
					mapGenerateThread = nil

					if not DEDICATED then
						print("Start rendering:", curMap )
						map.render(curMap)
					else
						sendMap()		-- important! send before running the map!
						runMap()
					end
					collectgarbage("collect")
				end
			end
		end
			-- then, check if there was an error:
			if mapGenerateThread then
				err = mapGenerateThread:getError()
				if err then
					print("MAP GENERATING THREAD error: " .. err)
					love.event.quit()
				end
			end
		end
	end

	function map.generating()
		if currentlyGeneratingMap then return true end
	end

	--------------------------------------------------------------
	--		MAP TILE OCCUPATION:
	--------------------------------------------------------------


	function map.drawOccupation()
		love.graphics.setColor(255,128,128,255)
		for i = 1, curMap.width do
			for j = 1, curMap.height do
				if curMapOccupiedExits[i][j]["N"] then
					love.graphics.circle("fill", i*TILE_SIZE+TILE_SIZE/2, j*TILE_SIZE+20, 5)
				end
				if curMapOccupiedExits[i][j]["S"] then
					love.graphics.circle("fill", i*TILE_SIZE+TILE_SIZE/2, j*TILE_SIZE+TILE_SIZE-20, 5)
				end
				if curMapOccupiedExits[i][j]["W"] then
					love.graphics.circle("fill", i*TILE_SIZE+20, j*TILE_SIZE+TILE_SIZE/2, 5)
				end
				if curMapOccupiedExits[i][j]["E"] then
					love.graphics.circle("fill", i*TILE_SIZE+TILE_SIZE-20, j*TILE_SIZE+TILE_SIZE/2, 5)
				end
			end
		end
	end

	function map.getIsTileOccupied(x, y, f, t)
		if not f or not t then
			if curMapOccupiedTiles[x][y]["NS"] or curMapOccupiedTiles[x][y]["SN"] or curMapOccupiedTiles[x][y]["EW"] or curMapOccupiedTiles[x][y]["WE"] or curMapOccupiedTiles[x][y]["NE"] or curMapOccupiedTiles[x][y]["EN"] or curMapOccupiedTiles[x][y]["ES"] or curMapOccupiedTiles[x][y]["SE"] or curMapOccupiedTiles[x][y]["SW"] or curMapOccupiedTiles[x][y]["WS"] or curMapOccupiedTiles[x][y]["WN"] or curMapOccupiedTiles[x][y]["NW"]
				then
					return true
				end

				for k, v in pairs(curMapOccupiedExits[x][y]) do
					if v then
				return true
			end
		end
		
		return false
	end
	directionStr = f .. t
	railType = getRailType(x,y)
--	if railType == NS or railType == EW or railType == NW or railType == WS or railType == SE or railType == NE or railType == NN or railType == SS or railType == EE or railType == WW then
	--	return false
	if curMapOccupiedTiles[x][y][directionStr] then		-- if someone's moving in the direction that I've been meaning to move,block.
		return true
	elseif curMapOccupiedExits[x][y][t] then			-- if someone's standing at the exit I was wanting to take, block.
		return true
	--[[
	if railType == NS then
		return curMapOccupiedTiles[x][y][directionStr]
	elseif railType == EW then
		return curMapOccupiedTiles[x][y][directionStr]
	elseif railType == NW then
		return curMapOccupiedTiles[x][y][directionStr]
	elseif railType == WS then
		return curMapOccupiedTiles[x][y][directionStr]
	elseif railType == SE then
		return curMapOccupiedTiles[x][y][directionStr]
	elseif railType == NE then
		return curMapOccupiedTiles[x][y][directionStr]
	elseif railType == NN then
		return curMapOccupiedTiles[x][y][directionStr]
	elseif railType == SS then
		return curMapOccupiedTiles[x][y][directionStr]
	elseif railType == EE then
		return curMapOccupiedTiles[x][y][directionStr]
	elseif railType == WW then
		return curMapOccupiedTiles[x][y][directionStr]
	]]--
	
		
	elseif railType == NES then
		if directionStr == "NS" then
			return curMapOccupiedTiles[x][y]["ES"]	-- straight line
		elseif directionStr == "SN" then
			return curMapOccupiedTiles[x][y]["ES"] or curMapOccupiedTiles[x][y]["NE"] or curMapOccupiedTiles[x][y]["EN"]
		elseif directionStr == "SE" then
			return curMapOccupiedTiles[x][y]["NE"]
		elseif directionStr == "ES" then
			return curMapOccupiedTiles[x][y]["SN"] or curMapOccupiedTiles[x][y]["NS"] or curMapOccupiedTiles[x][y]["NE"]
		elseif directionStr == "EN" then
			return curMapOccupiedTiles[x][y]["SN"]
		elseif directionStr == "NE" then
			return curMapOccupiedTiles[x][y]["SN"] or curMapOccupiedTiles[x][y]["ES"] or curMapOccupiedTiles[x][y]["SE"]
		end
		
	elseif railType == ESW then
		if directionStr == "EW" then
			return curMapOccupiedTiles[x][y]["SW"]	-- straight line
		elseif directionStr == "WE" then
			return curMapOccupiedTiles[x][y]["SW"] or curMapOccupiedTiles[x][y]["ES"] or curMapOccupiedTiles[x][y]["SE"]
		elseif directionStr == "SE" then
			return curMapOccupiedTiles[x][y]["WE"]
		elseif directionStr == "ES" then
			return curMapOccupiedTiles[x][y]["WS"] or curMapOccupiedTiles[x][y]["WE"] or curMapOccupiedTiles[x][y]["SW"]
		elseif directionStr == "SW" then
			return curMapOccupiedTiles[x][y]["EW"] or curMapOccupiedTiles[x][y]["ES"] or curMapOccupiedTiles[x][y]["WE"]
		elseif directionStr == "WS" then
			return curMapOccupiedTiles[x][y]["ES"]
		end
		
	elseif railType == NSW then
		if directionStr == "SN" then
			return curMapOccupiedTiles[x][y]["WN"]
		elseif directionStr == "NS" then
			return curMapOccupiedTiles[x][y]["SW"] or curMapOccupiedTiles[x][y]["WS"] or curMapOccupiedTiles[x][y]["WN"]
		elseif directionStr == "WS" then
			return curMapOccupiedTiles[x][y]["NS"]
		elseif directionStr == "SW" then
			return curMapOccupiedTiles[x][y]["NS"] or curMapOccupiedTiles[x][y]["WN"] or curMapOccupiedTiles[x][y]["NW"]
		elseif directionStr == "NW" then
			return curMapOccupiedTiles[x][y]["SW"]
		elseif directionStr == "WN" then
			return curMapOccupiedTiles[x][y]["SN"] or curMapOccupiedTiles[x][y]["NS"] or curMapOccupiedTiles[x][y]["SW"]
		end
	elseif railType == NEW then
		if directionStr == "WE" then
			return curMapOccupiedTiles[x][y]["NE"]
		elseif directionStr == "EW" then
			return curMapOccupiedTiles[x][y]["NE"] or curMapOccupiedTiles[x][y]["NW"] or curMapOccupiedTiles[x][y]["WN"]
		elseif directionStr == "NE" then
			return curMapOccupiedTiles[x][y]["WE"] or curMapOccupiedTiles[x][y]["WN"] or curMapOccupiedTiles[x][y]["EW"]
		elseif directionStr == "EN" then
			return curMapOccupiedTiles[x][y]["WN"]
		elseif directionStr == "WN" then
			return curMapOccupiedTiles[x][y]["EW"] or curMapOccupiedTiles[x][y]["NE"] or curMapOccupiedTiles[x][y]["EN"]
		elseif directionStr == "NW" then
			return curMapOccupiedTiles[x][y]["EW"]
		end
	elseif railType == NESW then
		if directionStr == "NS" then return curMapOccupiedTiles[x][y]["EW"] or curMapOccupiedTiles[x][y]["WE"] or curMapOccupiedTiles[x][y]["NE"] or curMapOccupiedTiles[x][y]["EN"] or curMapOccupiedTiles[x][y]["ES"] or curMapOccupiedTiles[x][y]["SE"] or curMapOccupiedTiles[x][y]["SW"] or curMapOccupiedTiles[x][y]["WS"] or curMapOccupiedTiles[x][y]["WN"] or curMapOccupiedTiles[x][y]["NW"]
		elseif directionStr == "SN" then return curMapOccupiedTiles[x][y]["EW"] or curMapOccupiedTiles[x][y]["WE"] or curMapOccupiedTiles[x][y]["NE"] or curMapOccupiedTiles[x][y]["EN"] or curMapOccupiedTiles[x][y]["ES"] or curMapOccupiedTiles[x][y]["SE"] or curMapOccupiedTiles[x][y]["SW"] or curMapOccupiedTiles[x][y]["WS"] or curMapOccupiedTiles[x][y]["WN"] or curMapOccupiedTiles[x][y]["NW"]
		elseif directionStr == "EW" then return curMapOccupiedTiles[x][y]["NS"] or curMapOccupiedTiles[x][y]["SN"] or curMapOccupiedTiles[x][y]["NE"] or curMapOccupiedTiles[x][y]["EN"] or curMapOccupiedTiles[x][y]["ES"] or curMapOccupiedTiles[x][y]["SE"] or curMapOccupiedTiles[x][y]["SW"] or curMapOccupiedTiles[x][y]["WS"] or curMapOccupiedTiles[x][y]["WN"] or curMapOccupiedTiles[x][y]["NW"]
		elseif directionStr == "WE" then return curMapOccupiedTiles[x][y]["NS"] or curMapOccupiedTiles[x][y]["SN"] or curMapOccupiedTiles[x][y]["NE"] or curMapOccupiedTiles[x][y]["EN"] or curMapOccupiedTiles[x][y]["ES"] or curMapOccupiedTiles[x][y]["SE"] or curMapOccupiedTiles[x][y]["SW"] or curMapOccupiedTiles[x][y]["WS"] or curMapOccupiedTiles[x][y]["WN"] or curMapOccupiedTiles[x][y]["NW"]
		elseif directionStr == "NE" then return curMapOccupiedTiles[x][y]["NS"] or curMapOccupiedTiles[x][y]["SN"] or curMapOccupiedTiles[x][y]["EW"] or curMapOccupiedTiles[x][y]["WE"] or curMapOccupiedTiles[x][y]["ES"] or curMapOccupiedTiles[x][y]["SE"] or curMapOccupiedTiles[x][y]["SW"] or curMapOccupiedTiles[x][y]["WS"] or curMapOccupiedTiles[x][y]["WN"] or curMapOccupiedTiles[x][y]["NW"]
		elseif directionStr == "EN" then return curMapOccupiedTiles[x][y]["NS"] or curMapOccupiedTiles[x][y]["SN"] or curMapOccupiedTiles[x][y]["EW"] or curMapOccupiedTiles[x][y]["WE"] or curMapOccupiedTiles[x][y]["ES"] or curMapOccupiedTiles[x][y]["SE"] or curMapOccupiedTiles[x][y]["SW"] or curMapOccupiedTiles[x][y]["WS"] or curMapOccupiedTiles[x][y]["WN"] or curMapOccupiedTiles[x][y]["NW"]
		elseif directionStr == "ES" then return curMapOccupiedTiles[x][y]["NS"] or curMapOccupiedTiles[x][y]["SN"] or curMapOccupiedTiles[x][y]["EW"] or curMapOccupiedTiles[x][y]["WE"] or curMapOccupiedTiles[x][y]["NE"] or curMapOccupiedTiles[x][y]["EN"] or curMapOccupiedTiles[x][y]["SW"] or curMapOccupiedTiles[x][y]["WS"] or curMapOccupiedTiles[x][y]["WN"] or curMapOccupiedTiles[x][y]["NW"]
		elseif directionStr == "SE" then return curMapOccupiedTiles[x][y]["NS"] or curMapOccupiedTiles[x][y]["SN"] or curMapOccupiedTiles[x][y]["EW"] or curMapOccupiedTiles[x][y]["WE"] or curMapOccupiedTiles[x][y]["NE"] or curMapOccupiedTiles[x][y]["EN"] or curMapOccupiedTiles[x][y]["SW"] or curMapOccupiedTiles[x][y]["WS"] or curMapOccupiedTiles[x][y]["WN"] or curMapOccupiedTiles[x][y]["NW"]
		elseif directionStr == "SW" then return curMapOccupiedTiles[x][y]["NS"] or curMapOccupiedTiles[x][y]["SN"] or curMapOccupiedTiles[x][y]["EW"] or curMapOccupiedTiles[x][y]["WE"] or curMapOccupiedTiles[x][y]["NE"] or curMapOccupiedTiles[x][y]["EN"] or curMapOccupiedTiles[x][y]["ES"] or curMapOccupiedTiles[x][y]["SE"] or curMapOccupiedTiles[x][y]["WN"] or curMapOccupiedTiles[x][y]["NW"]
		elseif directionStr == "WS" then return curMapOccupiedTiles[x][y]["NS"] or curMapOccupiedTiles[x][y]["SN"] or curMapOccupiedTiles[x][y]["EW"] or curMapOccupiedTiles[x][y]["WE"] or curMapOccupiedTiles[x][y]["NE"] or curMapOccupiedTiles[x][y]["EN"] or curMapOccupiedTiles[x][y]["ES"] or curMapOccupiedTiles[x][y]["SE"] or curMapOccupiedTiles[x][y]["WN"] or curMapOccupiedTiles[x][y]["NW"]
		elseif directionStr == "NW" then return curMapOccupiedTiles[x][y]["NS"] or curMapOccupiedTiles[x][y]["SN"] or curMapOccupiedTiles[x][y]["EW"] or curMapOccupiedTiles[x][y]["WE"] or curMapOccupiedTiles[x][y]["NE"] or curMapOccupiedTiles[x][y]["EN"] or curMapOccupiedTiles[x][y]["ES"] or curMapOccupiedTiles[x][y]["SE"] or curMapOccupiedTiles[x][y]["SW"] or curMapOccupiedTiles[x][y]["WS"]
		elseif directionStr == "WN" then return curMapOccupiedTiles[x][y]["NS"] or curMapOccupiedTiles[x][y]["SN"] or curMapOccupiedTiles[x][y]["EW"] or curMapOccupiedTiles[x][y]["WE"] or curMapOccupiedTiles[x][y]["NE"] or curMapOccupiedTiles[x][y]["EN"] or curMapOccupiedTiles[x][y]["ES"] or curMapOccupiedTiles[x][y]["SE"] or curMapOccupiedTiles[x][y]["SW"] or curMapOccupiedTiles[x][y]["WS"]
		end
	end
	
	--[[--old
	if not f and not t then		-- if f and t are left out, the function returns whether ANYTHING is on the rail.
		for k, v in pairs(curMapOccupiedTiles[x][y].from) do
			if v == true then return true end
		end
		for k, v in pairs(curMapOccupiedTiles[x][y].to) do
			if v == true then return true end
		end
	else
		-- otherwise, it checks if the given entry/exit points are occupied.
		if curMapOccupiedTiles[x][y].from[f] == true then return true end
		if curMapOccupiedTiles[x][y].to[t] == true then return true end
	end
	--]]
	return false
end

function map.setTileOccupied(x, y, f, t)
	if f and t then
		if not curMapOccupiedTiles[x][y][f..t] then
			curMapOccupiedTiles[x][y][f..t] = 1
		else
			curMapOccupiedTiles[x][y][f..t] = curMapOccupiedTiles[x][y][f..t]  + 1
		end
	end
	if t then
		curMapOccupiedExits[x][y][t] = true
	end
	
	-- if f then curMapOccupiedTiles[x][y].from[f] = true end
	-- if t then curMapOccupiedTiles[x][y].to[t] = true end
end

function map.resetTileOccupied(x, y, f, t)
	if f and t then
		if not curMapOccupiedTiles[x][y][f..t] then 
			error("Trying to free invalid occupation!: " .. f .. "," .. t)
		else
			curMapOccupiedTiles[x][y][f..t] = curMapOccupiedTiles[x][y][f..t]  - 1
			if curMapOccupiedTiles[x][y][f..t] == 0 then curMapOccupiedTiles[x][y][f..t] = nil end
		end
	end
end

function map.resetTileExitOccupied(x, y, to)
	curMapOccupiedExits[x][y][to] = false
end


--------------------------------------------------------------
--		HANDLE THE PATHS ON THE TILES:
--------------------------------------------------------------

function map.init()
	
	-- create the quads used for the sprite batch, to render the maps later:
	if not DEDICATED then
		generateMapQuads()
	end

	pathNS = {}
	pathNS[1] = {x=48,y=0}
	pathNS[2] = {x=48,y=128}
	pathNS.length = 0
	pathNS[1].length = 0
	for i = 2, #pathNS do
		pathNS.length = pathNS.length + math.sqrt((pathNS[i-1].x - pathNS[i].x)^2 + (pathNS[i-1].y - pathNS[i].y)^2)
		pathNS[i].length = pathNS.length
	end
	pathSN = {}
	pathSN[1] = {x=80,y=128}
	pathSN[2] = {x=80,y=0}
	pathSN.length = 0
	pathSN[1].length = 0
	for i = 2, #pathSN do
		pathSN.length = pathSN.length + math.sqrt((pathSN[i-1].x - pathSN[i].x)^2 + (pathSN[i-1].y - pathSN[i].y)^2)
		pathSN[i].length = pathSN.length
	end
	
	pathEW = {}
	pathEW[1] = {x=128,y=48}
	pathEW[2] = {x=0,y=48}
	pathEW.length = 0
	pathEW[1].length = 0
	for i = 2, #pathEW do
		pathEW.length = pathEW.length + math.sqrt((pathEW[i-1].x - pathEW[i].x)^2 + (pathEW[i-1].y - pathEW[i].y)^2)
		pathEW[i].length = pathEW.length
	end
	pathWE = {}
	pathWE[1] = {x=0,y=80}
	pathWE[2] = {x=128,y=80}
	pathWE.length = 0
	pathWE[1].length = 0
	for i = 2, #pathWE do
		pathWE.length = pathWE.length + math.sqrt((pathWE[i-1].x - pathWE[i].x)^2 + (pathWE[i-1].y - pathWE[i].y)^2)
		pathWE[i].length = pathWE.length
	end
	
	--[[
	pathNE = {}
	pathNE[1] = {x=48,y=0}
	pathNE[2] = {x=49,y=15}
	pathNE[3] = {x=54,y=31}
	pathNE[4] = {x=61,y=44}
	pathNE[5] = {x=72,y=56}
	pathNE[6] = {x=84,y=66}
	pathNE[7] = {x=97,y=73}
	pathNE[8] = {x=113,y=78}
	pathNE[9] = {x=128,y=79}
	pathEN = {}
	pathEN[1] = {x=128,y=48}
	pathEN[2] = {x=117,y=48}
	pathEN[3] = {x=103,y=42}
	pathEN[4] = {x=93,y=35}
	pathEN[5] = {x=85,y=24}
	pathEN[6] = {x=79,y=9}
	pathEN[7] = {x=79,y=0}
	
	pathES = {}
	pathES[1] = {x=128,y=48}
	pathES[2] = {x=113,y=49}
	pathES[3] = {x=96,y=54}
	pathES[4] = {x=83,y=61}
	pathES[5] = {x=71,y=72}
	pathES[6] = {x=61,y=84}
	pathES[7] = {x=54,y=97}
	pathES[8] = {x=49,y=113}
	pathES[9] = {x=48,y=128}
	pathSE = {}
	pathSE[1] = {x=79,y=128}
	pathSE[2] = {x=79,y=117}
	pathSE[3] = {x=85,y=103}
	pathSE[4] = {x=92,y=93}
	pathSE[5] = {x=103,y=85}
	pathSE[6] = {x=117,y=79}
	pathSE[7] = {x=128,y=79}
	
	pathSW = {}
	pathSW[1] = {x=79,y=128}
	pathSW[2] = {x=78,y=113}
	pathSW[3] = {x=73,y=96}
	pathSW[4] = {x=66,y=83}
	pathSW[5] = {x=55,y=71}
	pathSW[6] = {x=43,y=61}
	pathSW[7] = {x=30,y=54}
	pathSW[8] = {x=14,y=49}
	pathSW[9] = {x=0,y=48}
	pathWS = {}
	pathWS[1] = {x=0,y=79}
	pathWS[2] = {x=10,y=79}
	pathWS[3] = {x=24,y=85}
	pathWS[4] = {x=34,y=92}
	pathWS[5] = {x=42,y=103}
	pathWS[6] = {x=48,y=118}
	pathWS[7] = {x=48,y=128}
	
	pathWN = {}
	pathWN[1] = {x=0,y=79}
	pathWN[2] = {x=14,y=78}
	pathWN[3] = {x=31,y=73}
	pathWN[4] = {x=44,y=66}
	pathWN[5] = {x=55,y=55}
	pathWN[6] = {x=66,y=43}
	pathWN[7] = {x=73,y=30}
	pathWN[8] = {x=78,y=14}
	pathWN[9] = {x=79,y=0}
	pathNW = {}
	pathNW[1] = {x=48,y=0}
	pathNW[2] = {x=48,y=10}
	pathNW[3] = {x=42,y=24}
	pathNW[4] = {x=35,y=34}
	pathNW[5] = {x=24,y=42}
	pathNW[6] = {x=10,y=48}
	pathNW[7] = {x=0,y=48}
	]]--
	
	local radiusSmall = 48
	local radiusLarge = 80
	
	pathNE = {}
	for i = 0,10 do
		angDeg = 180 + i*9
		x = TILE_SIZE + radiusLarge*math.cos(angDeg*math.pi/180)
		y = -radiusLarge*math.sin(angDeg*math.pi/180)
		pathNE[i+1] = {x=x, y=y}
	end
	pathNE.length = 0
	pathNE[1].length = 0
	for i = 2, #pathNE do
		pathNE.length = pathNE.length + math.sqrt((pathNE[i-1].x - pathNE[i].x)^2 + (pathNE[i-1].y - pathNE[i].y)^2)
		pathNE[i].length = pathNE.length
	end
	pathEN = {}
	for i = 0,10 do
		angDeg = 270 - i*9
		x = TILE_SIZE + radiusSmall*math.cos(angDeg*math.pi/180)
		y = -radiusSmall*math.sin(angDeg*math.pi/180)
		pathEN[i+1] = {x=x, y=y}
	end
	pathEN.length = 0
	pathEN[1].length = 0
	for i = 2, #pathEN do
		pathEN.length = pathEN.length + math.sqrt((pathEN[i-1].x - pathEN[i].x)^2 + (pathEN[i-1].y - pathEN[i].y)^2)
		pathEN[i].length = pathEN.length
	end
	
	pathES = {}
	for i = 0,10 do
		angDeg = 90 + i*9
		x = TILE_SIZE + radiusLarge*math.cos(angDeg*math.pi/180)
		y = TILE_SIZE - radiusLarge*math.sin(angDeg*math.pi/180)
		pathES[i+1] = {x=x, y=y}
	end
	pathES.length = 0
	pathES[1].length = 0
	for i = 2, #pathES do
		pathES.length = pathES.length + math.sqrt((pathES[i-1].x - pathES[i].x)^2 + (pathES[i-1].y - pathES[i].y)^2)
		pathES[i].length = pathES.length
	end
	pathSE = {}
	for i = 0,10 do
		angDeg = 180 - i*9
		x = TILE_SIZE + radiusSmall*math.cos(angDeg*math.pi/180)
		y = TILE_SIZE - radiusSmall*math.sin(angDeg*math.pi/180)
		pathSE[i+1] = {x=x, y=y}
	end
	pathSE.length = 0
	pathSE[1].length = 0
	for i = 2, #pathSE do
		pathSE.length = pathSE.length + math.sqrt((pathSE[i-1].x - pathSE[i].x)^2 + (pathSE[i-1].y - pathSE[i].y)^2)
		pathSE[i].length = pathSE.length
	end
	
	pathSW = {}
	for i = 0,10 do
		angDeg = i*9
		x = radiusLarge*math.cos(angDeg*math.pi/180)
		y = TILE_SIZE - radiusLarge*math.sin(angDeg*math.pi/180)
		pathSW[i+1] = {x=x, y=y}
	end
	pathSW.length = 0
	pathSW[1].length = 0
	for i = 2, #pathSW do
		pathSW.length = pathSW.length + math.sqrt((pathSW[i-1].x - pathSW[i].x)^2 + (pathSW[i-1].y - pathSW[i].y)^2)
		pathSW[i].length = pathSW.length
	end
	pathWS = {}
	for i = 0,10 do
		angDeg = 90 - i*9
		x = radiusSmall*math.cos(angDeg*math.pi/180)
		y = TILE_SIZE - radiusSmall*math.sin(angDeg*math.pi/180)
		pathWS[i+1] = {x=x, y=y}
	end
	pathWS.length = 0
	pathWS[1].length = 0
	for i = 2, #pathWS do
		pathWS.length = pathWS.length + math.sqrt((pathWS[i-1].x - pathWS[i].x)^2 + (pathWS[i-1].y - pathWS[i].y)^2)
		pathWS[i].length = pathWS.length
	end
	
	pathWN = {}
	for i = 0,10 do
		angDeg = -90 + i*9
		x = radiusLarge*math.cos(angDeg*math.pi/180)
		y = - radiusLarge*math.sin(angDeg*math.pi/180)
		pathWN[i+1] = {x=x, y=y}
	end
	pathWN.length = 0
	pathWN[1].length = 0
	for i = 2, #pathWN do
		pathWN.length = pathWN.length + math.sqrt((pathWN[i-1].x - pathWN[i].x)^2 + (pathWN[i-1].y - pathWN[i].y)^2)
		pathWN[i].length = pathWN.length
	end
	pathNW = {}
	for i = 0,10 do
		angDeg = - i*9
		x = radiusSmall*math.cos(angDeg*math.pi/180)
		y = - radiusSmall*math.sin(angDeg*math.pi/180)
		pathNW[i+1] = {x=x, y=y}
	end
	pathNW.length = 0
	pathNW[1].length = 0
	for i = 2, #pathNW do
		pathNW.length = pathNW.length + math.sqrt((pathNW[i-1].x - pathNW[i].x)^2 + (pathNW[i-1].y - pathNW[i].y)^2)
		pathNW[i].length = pathNW.length
	end
	
	
	--------------------------------
	-- U-TURNS:
	
	local radiusUTurn = 49
	pathSS = {}
	--U-turn:
	for i = 0,39 do
		angDeg = - i*9 + 90
		x = radiusUTurn*math.cos(angDeg*math.pi/180) + TILE_SIZE/2
		y = TILE_SIZE/2 + radiusUTurn*math.sin(angDeg*math.pi/180)
		pathSS[i+1] = {x=x, y=y}
	end
	-- overlay entry curve with curve above:
	for i = 1, 10 do
		pathSS[i].x = (1-(i-1)/10)*pathSE[i].x + (i-1)/10*pathSS[i].x
		pathSS[i].y = (1-(i-1)/10)*pathSE[i].y + (i-1)/10*pathSS[i].y
	end
	-- overlay exit curve with curve above:
	for i = 1, 11 do
		pathSS[i+29].x = (i-1)/10*pathWS[i].x + (1-(i-1)/10)*pathSS[i+29].x
		pathSS[i+29].y = (i-1)/10*pathWS[i].y + (1-(i-1)/10)*pathSS[i+29].y
	end
	pathSS.length = 0
	pathSS[1].length = 0
	for i = 2, #pathSS do
		pathSS.length = pathSS.length + math.sqrt((pathSS[i-1].x - pathSS[i].x)^2 + (pathSS[i-1].y - pathSS[i].y)^2)
		pathSS[i].length = pathSS.length
	end
	
	
	pathWW = {}
	--U-turn:
	for i = 0,39 do
		angDeg = - i*9 + 180
		x = radiusUTurn*math.cos(angDeg*math.pi/180) + TILE_SIZE/2
		y = TILE_SIZE/2 + radiusUTurn*math.sin(angDeg*math.pi/180)
		pathWW[i+1] = {x=x, y=y}
	end
	-- overlay entry curve with curve above:
	for i = 1, 10 do
		pathWW[i].x = (1-(i-1)/10)*pathWS[i].x + (i-1)/10*pathWW[i].x
		pathWW[i].y = (1-(i-1)/10)*pathWS[i].y + (i-1)/10*pathWW[i].y
	end
	-- overlay exit curve with curve above:
	for i = 1, 11 do
		pathWW[i+29].x = (i-1)/10*pathNW[i].x + (1-(i-1)/10)*pathWW[i+29].x
		pathWW[i+29].y = (i-1)/10*pathNW[i].y + (1-(i-1)/10)*pathWW[i+29].y
	end
	pathWW.length = 0
	pathWW[1].length = 0
	for i = 2, #pathWW do
		pathWW.length = pathWW.length + math.sqrt((pathWW[i-1].x - pathWW[i].x)^2 + (pathWW[i-1].y - pathWW[i].y)^2)
		pathWW[i].length = pathWW.length
	end
	
	
	pathNN = {}
	--U-turn:
	for i = 0,39 do
		angDeg = - i*9 - 90
		x = radiusUTurn*math.cos(angDeg*math.pi/180) + TILE_SIZE/2
		y = TILE_SIZE/2 + radiusUTurn*math.sin(angDeg*math.pi/180)
		pathNN[i+1] = {x=x, y=y}
	end
	-- overlay entry curve with curve above:
	for i = 1, 10 do
		pathNN[i].x = (1-(i-1)/10)*pathNW[i].x + (i-1)/10*pathNN[i].x
		pathNN[i].y = (1-(i-1)/10)*pathNW[i].y + (i-1)/10*pathNN[i].y
	end
	-- overlay exit curve with curve above:
	for i = 1, 11 do
		pathNN[i+29].x = (i-1)/10*pathEN[i].x + (1-(i-1)/10)*pathNN[i+29].x
		pathNN[i+29].y = (i-1)/10*pathEN[i].y + (1-(i-1)/10)*pathNN[i+29].y
	end
	pathNN.length = 0
	pathNN[1].length = 0
	for i = 2, #pathNN do
		pathNN.length = pathNN.length + math.sqrt((pathNN[i-1].x - pathNN[i].x)^2 + (pathNN[i-1].y - pathNN[i].y)^2)
		pathNN[i].length = pathNN.length
	end
	
	
	pathEE = {}
	--U-turn:
	for i = 0,39 do
		angDeg = - i*9
		x = radiusUTurn*math.cos(angDeg*math.pi/180) + TILE_SIZE/2
		y = TILE_SIZE/2 + radiusUTurn*math.sin(angDeg*math.pi/180)
		pathEE[i+1] = {x=x, y=y}
	end
	-- overlay entry curve with curve above:
	for i = 1, 10 do
		pathEE[i].x = (1-(i-1)/10)*pathEN[i].x + (i-1)/10*pathEE[i].x
		pathEE[i].y = (1-(i-1)/10)*pathEN[i].y + (i-1)/10*pathEE[i].y
	end
	-- overlay exit curve with curve above:
	for i = 1, 11 do
		pathEE[i+29].x = (i-1)/10*pathSE[i].x + (1-(i-1)/10)*pathEE[i+29].x
		pathEE[i+29].y = (i-1)/10*pathSE[i].y + (1-(i-1)/10)*pathEE[i+29].y
	end
	pathEE.length = 0
	pathEE[1].length = 0
	for i = 2, #pathEE do
		pathEE.length = pathEE.length + math.sqrt((pathEE[i-1].x - pathEE[i].x)^2 + (pathEE[i-1].y - pathEE[i].y)^2)
		pathEE[i].length = pathEE.length
	end
	
end

function map.getRailPath(tileX, tileY, dir, prevDir)

	if curMapRailTypes[tileX][tileY] == 1 then
		if dir == "S" then
			return pathNS, dir
		else
			return pathSN, "N"
		end
	elseif curMapRailTypes[tileX][tileY] == 2 then
		if dir == "W" then
			return pathEW, dir
		else
			return pathWE, "E"
		end
	elseif curMapRailTypes[tileX][tileY] == 3 then
		if dir == "N" then
			return pathWN, dir
		else
			return pathNW, "W"
		end
	elseif curMapRailTypes[tileX][tileY] == 4 then
		if dir == "W" then
			return pathSW, dir
		else
			return pathWS, "S"
		end
	elseif curMapRailTypes[tileX][tileY] == 5 then
		if dir == "N" then
			return pathEN, dir
		else
			return pathNE, "E"
		end
	elseif curMapRailTypes[tileX][tileY] == 6 then
		if dir == "E" then
			return pathSE, dir
		else
			return pathES, "S"
		end
	elseif curMapRailTypes[tileX][tileY] == 7 then	-- NEW
		if dir == "E" then
			if prevDir == "E" then
				return pathWE, dir
			else
				return pathNE, "E"
			end
		elseif dir == "W" then
			if prevDir == "W" then
				return pathEW, dir
			else
				return pathNW, "W"
			end
		else
			if prevDir == "W" then
				return pathEN, dir
			else
				return pathWN, "N"
			end
		end
	elseif curMapRailTypes[tileX][tileY] == 8 then	-- NES
		if dir == "N" then
			if prevDir == "N" then
				return pathSN, dir
			else
				return pathEN, "N"
			end
		elseif dir == "S" then
			if prevDir == "S" then
				return pathNS, dir
			else
				return pathES, "S"
			end
		else
			if prevDir == "N" then
				return pathSE, dir
			else
				return pathNE, "E"
			end
		end
	elseif curMapRailTypes[tileX][tileY] == 9 then	-- ESW
		if dir == "E" then
			if prevDir == "E" then
				return pathWE, dir
			else
				return pathSE
			end
		elseif dir == "W" then
			if prevDir == "W" then
				return pathEW, dir
			else
				return pathSW, "W"
			end
		else
			if prevDir == "W" then
				return pathES, dir
			else
				return pathWS, "S"
			end
		end
	elseif curMapRailTypes[tileX][tileY] == 10 then	-- NSW
		if dir == "N" then
			if prevDir == "N" then
				return pathSN, dir
			else
				return pathWN, "N"
			end
		elseif dir == "S" then
			if prevDir == "S" then
				return pathNS, dir
			else
				return pathWS, "S"
			end
		else
			if prevDir == "S" then
				return pathNW, dir
			else
				return pathSW, "W"
			end
		end
	elseif curMapRailTypes[tileX][tileY] == 11 then	-- NESW
		if dir == "N" then
			if prevDir == "N" then
				return pathSN
			elseif prevDir == "E" then
				return pathWN, dir
			else
				return pathEN, "N"
			end
		elseif dir == "S" then
			if prevDir == "S" then
				return pathNS, dir
			elseif prevDir == "E" then
				return pathWS, dir
			else
				return pathES, "S"
			end
		elseif dir == "E" then
			if prevDir == "E" then
				return pathWE, dir
			elseif prevDir == "N" then
				return pathSE, dir
			else
				return pathNE, "E"
			end
		else
			if prevDir == "W" then
				return pathEW, dir
			elseif prevDir == "S" then
				return pathNW, dir
			else
				return pathSW, "W"
			end
		end
	elseif curMapRailTypes[tileX][tileY] == 12 then	-- W
		return pathWW, "W"
	elseif curMapRailTypes[tileX][tileY] == 13 then	-- E
		return pathEE, "E"
	elseif curMapRailTypes[tileX][tileY] == 14 then	-- N
		return pathNN, "N"
	elseif curMapRailTypes[tileX][tileY] == 15 then	-- S
		return pathSS, "S"
	end
	return pathNS, "S"		--fallback, should never happen!
end

-- if I keep moving into the same direction, which direction can I move in on the next tile?
function map.getNextPossibleDirs(curTileX, curTileY , curDir)
	local nextTileX, nextTileY = curTileX, curTileY
	if curDir == "N" then
		nextTileY = nextTileY - 1
	elseif curDir == "S" then
		nextTileY = nextTileY + 1
	elseif curDir == "E" then
		nextTileX = nextTileX + 1
	elseif curDir == "W" then
		nextTileX = nextTileX - 1
	end
	
	railType = getRailType( nextTileX, nextTileY )
	if railType == 1 then	-- straight rail: can only keep moving in same dir
		if curDir == "N" then return {N=true}, 1
		else return {S=true}, 1 end
	end
	if railType == 2 then	-- straight rail: can only keep moving in same dir
		if curDir == "E" then return {E=true}, 1
		else return {W=true}, 1 end
	end
	--curves:
	if railType == 3 then
		if curDir == "E" then return {N=true}, 1
		else return {W=true}, 1 end
	end
	if railType == 4 then
		if curDir == "E" then return {S=true}, 1
		else return {W=true}, 1 end
	end
	if railType == 5 then
		if curDir == "W" then return {N=true}, 1
		else return {E=true}, 1 end
	end
	if railType == 6 then
		if curDir == "W" then return {S=true}, 1
		else return {E=true}, 1 end
	end
	--junctions
	if railType == 7 then
		if curDir == "S" then return {E=true, W=true}, 2
		elseif curDir == "W" then return {W=true, N=true}, 2
		else return {N=true, E=true}, 2 end
	end
	if railType == 8 then
		if curDir == "S" then return {E=true, S=true}, 2
		elseif curDir == "W" then return {S=true, N=true}, 2
		else return {N=true, E=true}, 2 end
	end
	if railType == 9 then
		if curDir == "E" then return {E=true, S=true}, 2
		elseif curDir == "W" then return {W=true, S=true}, 2
		else return {W=true, E=true}, 2 end
	end
	if railType == 10 then
		if curDir == "S" then return {S=true, W=true}, 2
		elseif curDir == "E" then return {N=true, S=true}, 2
		else return {W=true, N=true}, 2 end
	end
	if railType == 11 then
		if curDir == "E" then return {E=true, S=true, N=true}, 3
		elseif curDir == "W" then return {W=true, S=true, N=true}, 3
		elseif curDir == "S" then return {S=true, E=true, W=true}, 3
		else return {N=true, E=true, W=true}, 3 end
	end
	
	if railType == 12 then
		return {W=true}, 1
	end
	if railType == 13 then
		return {E=true}, 1
	end
	if railType == 14 then
		return {N=true}, 1
	end
	if railType == 15 then
		return {S=true}, 1
	end
end

function map.print(title, m)
	m = m or curMap
	title = title or "Current map:"
	if m then
		print(title)
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
		end
	end
end


mapGenerationPercentage = 0

local highlightList = {}
local highlightListQuads = {}

mapThread = nil
mapThreadPercentage = 0

-- Peter's beitrag:
--[[
if(!(crash == true)){
crash();
}

-- micha's �bersetzung:
if not crash then crash() end
]]--
--

function map.render(map)
	if not currentlyRenderingMap or map ~= nil then
		--currentlyRenderingMap = true
		
		print("Rendering Map...")
		
		map = map or curMap

		local groundData, shadowData, objectData = renderMap( map,
			curMapRailTypes,
			tutorial and tutorial.noTrees,
			CURRENT_REGION )
		--currentlyRenderingMap = false
		print("Rendering done!")
		print("Rendered map with " .. map.width .. "x" .. map.height .. " tiles.")
		attemptingToConnect = false 	-- no longer show loading screen!

		loadingScreen.percentage(LNG.load_rendering_map, 100)

		currentlyRenderingMap = false

		--print("Map was rendered in " .. os.time()-renderingMapStartTime .. " seconds.")

		m = curMap or simulationMap
		if m then
			for i = 1, m.width do
				for j = 1, m.height do
					if m[i][j] == "SCHOOL" or m[i][j] == "HOSPITAL" then		--reset to normal hotspot - names were just there for rendering.
						m[i][j] = "S"
					end
					if m[i][j] and m[i][j]:find("HOUSE") then		--reset to normal house - names were just there for rendering.
						m[i][j] = "H"
					end
				end				
			end
		end

		mapImage, mapShadowImage, mapObjectImage = groundData,shadowData,objectData
		runMap()	-- start the map!
	end

	--[[
	if not currentlyRenderingMap or map ~= nil then		-- if a new map is given, render this new map!
		print("Rendering Map...")
			mapRenderThread = love.thread.newThread("Scripts/mapRender.lua")
			mapRenderThreadNumber = mapRenderThreadNumber + 1
			mapRenderThreadChannelIn = love.thread.newChannel()
			mapRenderThreadChannelOut = love.thread.newChannel()
			mapRenderThread:start( mapRenderThreadChannelIn, mapRenderThreadChannelOut )

		map = map or curMap
		mapRenderThreadChannelIn:push({key="TILE_SIZE", TILE_SIZE})
		mapRenderThreadChannelIn:push({key="curMapRailTypes", TSerial.pack(curMapRailTypes) })
		
		currentlyRenderingMap = true
		
		if tutorial and tutorial.noTrees then
			--mapRenderThread:set("NO_TREES", true)
			mapRenderThreadChannelIn:push({key="NO_TREES", true})
		end
		-- must be last, because as soon as curMap is received, thread starts rendering:
		mapRenderThreadChannelIn:push({key="curMap", TSerial.pack( map )})

		loadingScreen.addSection(LNG.load_rendering_map)
		renderingMapStartTime = os.time()

		dimensionX, dimensionY = nil,nil
	else
		local packet = mapRenderThreadChannelOut:pop()

		--percent = mapRenderThread:get("percentage")
		if packet then
		if packet.key == "percent" then
			loadingScreen.percentage(LNG.load_rendering_map, packet[1])
		end
		
		--status = mapRenderThread:get("status" .. mapRenderThreadStatusNum)
		if packet.key == "status" then
			--mapRenderThreadStatusNum = incrementID(mapRenderThreadStatusNum)
			loadingScreen.addSubSection(LNG.load_rendering_map, packet[1])
		end

		if packet.key == "dimensionX" then
			dimensionX = packet[1]
			groundData = {}
			shadowData = {}
			objectData = {}
			for i = 1, dimensionX do	
				groundData[i] = {}
				shadowData[i] = {}
				objectData[i] = {}
			end
		elseif packet.key == "dimensionY" then
			dimensionY = packet[1]
		end
		if dimensionX and dimensionY then
			for i = 1, dimensionX do
				for j = 1, dimensionY do
					if packet.key == "groundData:" .. i .. "," .. j then
						groundData[i][j] = love.graphics.newImage(packet[1])
					end
					if packet.key == "shadowData:" .. i .. "," .. j then
						shadowData[i][j] = love.graphics.newImage(packet[1])
					end
					if packet.key == "objectData:" .. i .. "," .. j then
						objectData[i][j] = love.graphics.newImage(packet[1])
					end
				end
			end
			if packet.key == "highlightList" then
				highlightList = TSerial.unpack(packet[1])
				for i = 1,20 do
					highlightListQuads[i] = love.graphics.newQuad( (i-1)*33, 0, 33, 32, 660, 32 )
				end
			end
		end

		--status = mapRenderThread:get("status")
		if packet.key == "done" then
			print("Rendering done!")
			attemptingToConnect = false 	-- no longer show loading screen!
			
			local groundData = nil
			local shadowData = nil
			local objectData = nil
			print("Receiving map with " .. dimensionX .. "x" .. dimensionY .. " pieces.")
			--shadowData = mapRenderThread:get("shadowData")
			--objectData = mapRenderThread:get("objectData")
			
			loadingScreen.percentage(LNG.load_rendering_map, 100)
			
			currentlyRenderingMap = false
			-- mapRenderThread = nil
			print("Map was rendered in " .. os.time()-renderingMapStartTime .. " seconds.")
			
			if not DEDICATED then
				m = curMap or simulationMap
				if m then
					for i = 1, m.width do
						for j = 1, m.height do
							if m[i][j] == "SCHOOL" or m[i][j] == "HOSPITAL" then		--reset to normal hotspot - names were just there for rendering.
								m[i][j] = "S"
							end
							if m[i][j] and m[i][j]:find("HOUSE") then		--reset to normal house - names were just there for rendering.
								m[i][j] = "H"
							end
						end				
					end
				end
			end
			
			return groundData,shadowData,objectData
		end
	end
		
	end]]
end

function map.rendering()
	if currentlyRenderingMap then return true end
end

function map.abortRendering()
	--[[if mapRenderThread then
		--mapRenderThread:set("abort", true)
		mapRenderThreadChannelIn:push({key="abort", true})

		mapRenderThread:wait()
		mapRenderThread = nil
	end
	]]--
	currentlyRenderingMap = false
end

function map.renderHighlights(dt)
	love.graphics.setColor(255,255,255)
	for k, hl in pairs(highlightList) do
		if math.ceil(hl.frame) >= 1 and math.ceil(hl.frame) <= #highlightListQuads then
			love.graphics.drawq(IMAGE_HOTSPOT_HIGHLIGHT, highlightListQuads[math.ceil(hl.frame)], hl.x, hl.y)
		end
		hl.frame = hl.frame + dt*15
		while hl.frame > #highlightListQuads do hl.frame = hl.frame - #highlightListQuads end
	end
end


--------------------------------------------------------------
--		SHOW THE MAP:
--------------------------------------------------------------

function map.showCoordinates(m)
	love.graphics.setColor(255,255,255,80)
	love.graphics.setFont(FONT_COORDINATES)
	local str = ""
	for i = 1, m.width do
		for j = 1, m.height do
			str = "(" .. i .. "," .. j .. ")"
			love.graphics.print(str, (i+0.5)*TILE_SIZE - FONT_COORDINATES:getWidth(str)/2, (j+0.5)*TILE_SIZE - FONT_COORDINATES:getHeight()/2)
		end
	end
end

local mapMouseX, mapMouseY = 0,0
local centerX, centerY = 0,0

function map.show()
	
	mapMouseX, mapMouseY = love.mouse.getPosition()
	
	mapMouseX, mapMouseY = mapMouseX/camZ, mapMouseY/camZ

	mapMouseX, mapMouseY = mapMouseX - camX - love.graphics.getWidth()/(2*camZ), mapMouseY - camY - love.graphics.getHeight()/(2*camZ)

	mX, mY = mapMouseX, mapMouseY
	mapMouseX, mapMouseY = math.cos(-CAM_ANGLE)*mX - math.sin(-CAM_ANGLE)*mY, math.sin(-CAM_ANGLE)*mX + math.cos(-CAM_ANGLE)*mY
	mapMouseX = mapMouseX + TILE_SIZE*(curMap.width+2)/2
	mapMouseY = mapMouseY + TILE_SIZE*(curMap.height+2)/2
	
	love.graphics.push()
	love.graphics.scale(camZ)
	
	
	--love.graphics.translate(camX + love.graphics.getWidth()/(2*camZ), camY + love.graphics.getHeight()/(2*camZ))
	love.graphics.translate(math.floor(camX + love.graphics.getWidth()/(2*camZ)), math.floor( camY + love.graphics.getHeight()/(2*camZ)))
	love.graphics.rotate(CAM_ANGLE)


	-- Draw map shadow:
	love.graphics.setColor(30,10,5, 200)

	
	x = -TILE_SIZE*(curMap.width+2)/2 - 20
	y = -TILE_SIZE*(curMap.height+2)/2 + 35
	love.graphics.draw( mapImage, x, y )
	--[[for i = 1, #mapImage do
		y = -TILE_SIZE*(curMap.height+2)/2 +35
		for j = 1, #mapImage[i] do
			if i == 1 or j == #mapImage[i] then
				love.graphics.draw(mapImage[i][j], x,  y)
			end
			
			y = y + mapImage[i][j]:getHeight()
			if j == #mapImage[i] then
				x = x + mapImage[i][j]:getWidth()
			end
		end
	end]]

	love.graphics.setColor(255,255,255, 255)
	x = -TILE_SIZE*(curMap.width+2)/2
	y = -TILE_SIZE*(curMap.height+2)/2
	love.graphics.draw( mapImage, x, y )
	love.graphics.draw( mapShadowImage, x, y )
	--[[for i = 1, #mapImage do
		for j = 1, #mapImage[i] do
			love.graphics.draw(mapImage[i][j], x,  y)
			love.graphics.draw(mapShadowImage[i][j], x,  y)
			y = y + mapImage[i][j]:getHeight()
			if j == #mapImage[i] then
				x = x + mapImage[i][j]:getWidth()
			end
		end
	end]]

	centerX, centerY = 0,0
	
	love.graphics.push()
	love.graphics.translate(-TILE_SIZE*(curMap.width+2)/2, -TILE_SIZE*(curMap.height+2)/2)

	passenger.showAll(passedTime)
	train.showAll()
	passenger.showVIPs(passedTime)
	love.graphics.pop()

	
	-- draw the objects (houses, trees ... ):
	love.graphics.setColor(255,255,255,255)
	x = -TILE_SIZE*(curMap.width+2)/2
	y = -TILE_SIZE*(curMap.height+2)/2
	love.graphics.draw( mapObjectImage, x, y )
	--[[for i = 1, #mapImage do
		for j = 1, #mapImage[i] do
			love.graphics.draw(mapObjectImage[i][j], x,  y)
			y = y + mapImage[i][j]:getHeight()
			if j == #mapImage[i] then
				--love.graphics.draw(mapImage[i][j], -TILE_SIZE*(curMap.width+2)/2 -20 + (i-1)*MAX_IMG_SIZE*TILE_SIZE, -TILE_SIZE*(curMap.height+2)/2 +35 + (j-1)*MAX_IMG_SIZE*TILE_SIZE)
				x = x + mapImage[i][j]:getWidth()
			end
		end
	end]]

	love.graphics.translate(-TILE_SIZE*(curMap.width+2)/2, -TILE_SIZE*(curMap.height+2)/2)
	
	map.renderHighlights(passedTime)
	
	passenger.showSelected()
	train.showSelected()

	if RENDER_CLOUDS then
		clouds.renderShadows(passedTime)
	end

	--map.drawOccupation()
	if showCoordinates then
		map.showCoordinates(curMap)
	end
	
	love.graphics.pop()
	
	love.graphics.push()
	love.graphics.scale(camZ*1.5)

	love.graphics.translate(camX + love.graphics.getWidth()/(camZ*3), camY + love.graphics.getHeight()/(camZ*3))
	love.graphics.rotate(CAM_ANGLE)
	love.graphics.translate(-TILE_SIZE*(curMap.width+2)/2, -TILE_SIZE*(curMap.height+2)/2)
	
	if RENDER_CLOUDS then
		clouds.render()
	end
	
	love.graphics.pop()
	
end

--------------------------------------------------------------
--		MAP EVENTS:
--		- new passenger
--		- passenger lost
--------------------------------------------------------------

-- make sure to reset these at round end!
passengerTimePassed = 0
newTrainQueueTime = 0

function map.handleEvents(dt)

	if tutorial and tutorial.handleEvents then
		tutorial.handleEvents(dt)
	else
		if not challenges.isRunning() then
			passengerTimePassed = passengerTimePassed - dt*timeFactor
			if passengerTimePassed <= 0 then
				passenger.new()
				passengerTimePassed = math.random()*3	-- to make sure it's the same on all platforms
			end
			
			if numPassengersDroppedOff >= MAX_NUM_PASSENGERS and GAME_TYPE == GAME_TYPE_MAX_PASSENGERS then
				map.endRound()
			end
		
			if (curMap.time >= ROUND_TIME and GAME_TYPE == GAME_TYPE_TIME) or CL_ROUND_TIME and (curMap.time >= CL_ROUND_TIME) then
				map.endRound()
			end
			
		end
	
		newTrainQueueTime = newTrainQueueTime + dt*timeFactor
		if newTrainQueueTime >= .1 then
			train.handleNewTrains()
			newTrainQueueTime = newTrainQueueTime - .1
		end
		
	end
end

function map.endRound()
	if tutorial and tutorial.endRound then
		tutorial.endRound()
	end
		
	challenges.removeMessage()
	roundEnded = true
	stats.print()
	if not challenges.isRunning() then
		stats.generateStatWindows()
	end
	passengerTimePassed = 0
	newTrainQueueTime = 0
	if DEDICATED then
		sendMapUpdate("END_ROUND:")
	end
end


--------------------------------------------------------------
--		MAP MOUSE EVENT:
--------------------------------------------------------------

function map.handleClick()
	local found
	
	for i,l in pairs(trainList) do
		for k,tr in pairs(l) do
			x = tr.tileX*TILE_SIZE + tr.x
			y = tr.tileY*TILE_SIZE + tr.y
			if mapMouseX > x - tr.image:getHeight()/2 and mapMouseX < x + tr.image:getHeight()/2 and
				mapMouseY > y - tr.image:getHeight()/2 and mapMouseY < y + tr.image:getHeight()/2 then
				if not tr.selected then
					found = tr
					break
				else
					tr.selected = false
				end
			end
		end
	end
	for k,p in pairs(passengerList) do
		x = p.tileX*TILE_SIZE + p.x
		y = p.tileY*TILE_SIZE + p.y
		if mapMouseX > x - p.image:getWidth()/2 and mapMouseX < x + p.image:getWidth()/2 and
			mapMouseY > y - p.image:getHeight()/2 and mapMouseY < y + p.image:getHeight()/2 then
			if not p.selected then
				found = p
				break
			else
				p.selected = false
			end
		end
	end
	
	if found then		-- only deselect others if new train or passenger was clicked on
		for k,p in pairs(passengerList) do
			p.selected = false
		end
		for i,l in pairs(trainList) do
			for k,tr in pairs(l) do
				tr.selected = false
			end
		end	
		found.selected = true
		return true
	end
end

function map.toggleShowCoordinates()
	showCoordinates = not showCoordinates
end

return map
