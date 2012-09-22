local map = {}

curMap = nil

TILE_SIZE = 128		-- DO NOT CHANGE! (unless you change all the images as well)

local curMapOccupiedTiles = {}	-- stores if a certain path on a tile is already being used by another train
local curMapOccupiedExits = {}	-- stores whether a certain exit of a tile is already being used by another train

-- RAIL Pieces:
IMAGE_GROUND = love.image.newImageData("Images/Ground.png")

IMAGE_RAIL_NS = love.image.newImageData("Images/Rail_NS.png")
IMAGE_RAIL_EW = love.image.newImageData("Images/Rail_EW.png")

IMAGE_RAIL_NE = love.image.newImageData("Images/Rail_NE.png")
IMAGE_RAIL_ES = love.image.newImageData("Images/Rail_ES.png")
IMAGE_RAIL_SW = love.image.newImageData("Images/Rail_SW.png")
IMAGE_RAIL_NW = love.image.newImageData("Images/Rail_NW.png")

IMAGE_RAIL_NEW = love.image.newImageData("Images/Rail_NEW.png")
IMAGE_RAIL_NES = love.image.newImageData("Images/Rail_NES.png")
IMAGE_RAIL_ESW = love.image.newImageData("Images/Rail_ESW.png")
IMAGE_RAIL_NSW = love.image.newImageData("Images/Rail_NSW.png")

IMAGE_RAIL_NESW = love.image.newImageData("Images/Rail_NESW.png")

IMAGE_RAIL_N = love.image.newImageData("Images/Rail_N.png")
IMAGE_RAIL_E = love.image.newImageData("Images/Rail_E.png")
IMAGE_RAIL_S = love.image.newImageData("Images/Rail_S.png")
IMAGE_RAIL_W = love.image.newImageData("Images/Rail_W.png")

--Environment/Misc:
IMAGE_HOUSE1 = love.image.newImageData("Images/House1.png")

-- possible tile types:
NS = 1
EW = 2
NW = 3
SW = 4
NE = 5
ES = 6
NEW = 7
NES = 8
ESW = 9
NSW = 10
NESW = 11
WW = 12
EE = 13
NN = 14
SS = 15

--------------------------------------------------------------
--		MAP GENERATION:
--------------------------------------------------------------


-- this function iterates through the map and marks all tiles that are connected to tile i,j (by changing them to "C")
function markConnected(i, j, level)
	level = level or 0
	str = ""
	for i=1,level do str = str .. "-" end
	curMap[i][j] = "C"
	if i > 1 and (curMap[i-1][j] == "R" or curMap[i-1][j] == "T") then markConnected(i-1, j, level+1) end
	if j > 1 and (curMap[i][j-1] == "R" or curMap[i][j-1] == "T") then markConnected(i, j-1, level+1) end
	if i < curMap.height and (curMap[i+1][j] == "R" or curMap[i+1][j] == "T") then markConnected(i+1, j, level+1) end
	if j < curMap.width and (curMap[i][j+1] == "R" or curMap[i][j+1] == "T") then markConnected(i, j+1, level+1) end
end


-- starts the markConnected functions on the first tile marked "R" on the map.
function findConnections()
	for i = 1,curMap.height,1 do		-- reset
		for j = 1,curMap.width,1 do
			if curMap[i][j] == "C" then
				curMap[i][j] = "R"
			end
		end
	end
	
	for i = 1,curMap.height,1 do
		for j = 1,curMap.width,1 do
			if curMap[i][j] == "R" then
				markConnected(i,j)
				return
			end
		end
	end
end

-- resets tiles marked "T". 
-- When a tile is marked "T" that means it was part of a Test trying to connect a non-connected part of the rail to an already connected part.
function removeTs()
	for i = 1,curMap.height,1 do
		for j = 1,curMap.width,1 do
			if curMap[i][j] == "T" then
				curMap[i][j] = nil
			end
		end
	end
end


-- Moves into a random direction starting at tile i,j and tries to connect it by placing "T" s on tiles it passes. When it reaches the map's side,
-- it tries out another direction.
-- If all 4 directions have been tested, then it places down a rail across the entiry map. This makes sure that the next try succeeds.
function connectPiece(i, j)
	print("attempt to connect:", i, j)
	startI, startJ = i,j
	dir = math.random(4)
	local k = 0
	local triedDir1,triedDir2,triedDir3,triedDir4 = false, false, false, false
	while k < 2 do
		print("attempt:", k, dir)
		
		if dir == 1 then
			removeTs()
			i, j = startI, startJ
			while i > 1 and not triedDir1 do
				if not curMap[i][j] then curMap[i][j] = "T" end
				i = i - 1
				if curMap[i][j] == "C" or curMap[i][j+1] == "C" or curMap[i][j-1] == "C" then
					if not curMap[i][j] then curMap[i][j] = "T" end
					-- found a connection!
					print("found connection!")
					return
				end
			end
			triedDir1 = true
			dir = 2
		end
		if dir == 2 then
			removeTs()
			i, j = startI, startJ
			while j > 1 and not triedDir2 do
				if not curMap[i][j] then curMap[i][j] = "T" end
				j = j - 1
				if curMap[i-1][j] == "C" or curMap[i+1][j] == "C" or curMap[i][j-1] == "C" then
					if not curMap[i][j] then curMap[i][j] = "T" end
					-- found a connection!
					print("found connection!")
					return
				end
			end
			triedDir2 = true
			dir = 3
		end
		if dir == 3 then
			removeTs()
			i, j = startI, startJ
			while i < curMap.height and not triedDir3 do
				if not curMap[i][j] then curMap[i][j] = "T" end
				i = i + 1
				if curMap[i+1][j] == "C" or curMap[i][j+1] == "C" or curMap[i][j-1] == "C" then
					if not curMap[i][j] then curMap[i][j] = "T" end
					-- found a connection!
					print("found connection!")
					return
				end
			end
			triedDir3 = true
			dir = 4
		end
		if dir == 4 then
			removeTs()
			i, j = startI, startJ
			while j < curMap.width and not triedDir4 do
				if not curMap[i][j] then curMap[i][j] = "T" end
				j = j + 1
				if curMap[i+1][j] == "C" or curMap[i-1][j] == "C" or curMap[i][j+1] == "C" then
					if not curMap[i][j] then curMap[i][j] = "T" end
					-- found a connection!
					print("found connection!")
					return
				end
			end
			triedDir4 = true
			dir = 1
		end
		k = k + 1
	end
	
	-- if it ends up here, it failed to connect using just straight connections.
	-- place straight line at random position, which will always be able to connect:
	print("Couldn't connect pieces! Adding straight rail.")
	yPos = math.random(curMap.height)
	
	for i = 1,curMap.width do
		curMap[i][yPos] = "R"
	end
		
end

-- generates random rectangles of rail on the map.
function generateRailRectangles()

	local num = 3 + math.random(10)+ math.ceil(curMap.height/2)
	local k = 0
	while k < num do
		local rectWidth = math.random(curMap.width/2)+2
		local rectHeight = math.random(curMap.height/2)+2
		local i = math.random(curMap.width-2)
		local j = math.random(curMap.height-2)
	
		local x = 0
		while x <= rectWidth do
			if i+x <= curMap.width then
				if curMap[i+x] then
					curMap[i+x][j] = "R"
					if j+rectHeight <= curMap.height then
						curMap[i+x][j+rectHeight] = "R"
					end
				end
			end
			x = x + 1
		end
		
		local y = 0
		while y <= rectHeight do
			if j+y <= curMap.height then
				if curMap[i] then
					curMap[i][j+y] = "R"
					if i+rectWidth <= curMap.width then
						curMap[i+rectWidth][j+y] = "R"
					end
				end
			end
			y = y + 1
		end
		
		k = k+1
	end
end



-- Looks for unconnected pieces of rail. If some pieces are not connected, tries to connect them.
function connectLooseEnds()
	-- find all unconnected pieces:
	local allConnected = false
	local k = 0
	while allConnected == false and k < 50 do		--give it a max of 50 tries, which is plenty.
		findConnections()
		allConnected = true
		for i = 1,curMap.width do
			for j = 1,curMap.height do
				if curMap[i][j] == "R" then
					allConnected = false
					connectPiece(i,j)
					break
				end
			end
			if allConnected == false then break end
		end
		k = k+1
	end
end

-- checks for places where there are 6 junctions right next to each other and removes some of them at random (because they look horrible).
function clearLargeJunctions()
	toRemove = {}
	for i = 1,curMap.width-1,1 do
		for j = 1,curMap.height,1 do
			if curMap[i][j] == "R" then
				if curMap[i+1][j] == "R" and curMap[i-1][j] == "R" and			--neighbours are Rails
				((curMap[i][j+1] == "R" and curMap[i+1][j+1] == "R" and curMap[i-1][j+1] == "R") or		-- either line below is filled with rails
				(curMap[i][j-1] == "R" and curMap[i+1][j-1] == "R" and curMap[i-1][j-1] == "R"))		-- ... or line above is filled with rails
				then
					if math.random(5) ~= 1 then curMap[i][j] = nil end
				end
			end
		end
	end
	for i = 1,curMap.width-1,1 do
		for j = 1,curMap.height,1 do
			if curMap[i][j] == "R" then
				if curMap[i][j+1] == "R" and curMap[i][j-1] == "R" and			--neighbours are Rails
				((curMap[i+1][j] == "R" and curMap[i+1][j+1] == "R" and curMap[i+1][j-1] == "R") or		-- either line East is filled with rails
				(curMap[i-1][j] == "R" and curMap[i-1][j+1] == "R" and curMap[i-1][j-1] == "R"))		-- ... or line West is filles with rails
				then
					if math.random(5) ~= 1 then curMap[i][j] = nil end
				end
			end
		end
	end
end


function placeHouses()
	for i = 1, curMap.width do
		for j = 1, curMap.height do
			if curMap[i][j] == nil then
				if curMap[i+1][j] == "C" or curMap[i-1][j] == "C" or curMap[i][j+1] == "C" or curMap[i][j-1] == "C" then
					if math.random(3) == 1 then curMap[i][j] = "H" end
				end
			end
		end
	end
end


-- This function iterates over the whole map and calculates the rail type for each tile.
-- That's important for placing correct images on the map and for calculating movement later on.
function calculateRailTypes()
	if curMap then
		for i = 1,curMap.width do
			for j = 1,curMap.height do
				curMapRailTypes[i][j] = getRailType(i,j)
			end
		end
	end
end

-- generate a list that holds the map in a different form: not by coordinates. This way a random piece of rail can be more easily be chosen.
function generateRailList()
	curMap.railList = {}
	curMap.houseList = {}
	for i = 1, curMap.width do
		for j = 1, curMap.height do
			if curMap[i][j] == "C" then table.insert(curMap.railList, {x=i, y=j})
			elseif curMap[i][j] == "H" then table.insert(curMap.houseList, {x=i, y=j})
			end
		end
	end
end

-- Generates a new map. Any old map is dropped.
function map.generate(width, height, seed)
	if width < 4 then
		print("Minimum width is 4!")
		width = 4
	end
	if height < 4 then
		print("Minimum height is 4!")
		height = 4
	end
	
	math.randomseed(seed)
	
	curMap = setmetatable({width=width, height=height}, map_mt)
	curMapOccupiedTiles = {}
	curMapOccupiedExits = {}
	curMapRailTypes = {}
	
	for i = 0,width+1 do
		curMap[i] = {}
		curMapRailTypes[i] = {}
		if i >= 1 and i <= width then 
			curMapOccupiedTiles[i] = {}
			curMapOccupiedExits[i] = {}
			for j = 1, height do
				curMapOccupiedTiles[i][j] = {}
				curMapOccupiedTiles[i][j].from = {}
				curMapOccupiedTiles[i][j].to = {}
				
				curMapOccupiedExits[i][j] = {}
			end
		end
	end
	
	generateRailRectangles()
	map.print("Raw map:")
	clearLargeJunctions()
	
	connectLooseEnds()
	
	calculateRailTypes()
	
	placeHouses()
	
	generateRailList()
end



--------------------------------------------------------------
--		MAP TILE OCCUPATION:
--------------------------------------------------------------


function map.getIsTileOccupied(x, y, f, t)
	if not f or not t then
		return curMapOccupiedTiles[x][y]["NS"] or curMapOccupiedTiles[x][y]["SN"] or curMapOccupiedTiles[x][y]["EW"] or curMapOccupiedTiles[x][y]["WE"] or curMapOccupiedTiles[x][y]["NE"] or curMapOccupiedTiles[x][y]["EN"] or curMapOccupiedTiles[x][y]["ES"] or curMapOccupiedTiles[x][y]["SE"] or curMapOccupiedTiles[x][y]["SW"] or curMapOccupiedTiles[x][y]["WS"] or curMapOccupiedTiles[x][y]["WN"] or curMapOccupiedTiles[x][y]["NW"]
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
	--print("Occupying: ", f, t)
	if not f or not t then return end
	if not curMapOccupiedTiles[x][y][f..t] then
		curMapOccupiedTiles[x][y][f..t] = 1
	else
		curMapOccupiedTiles[x][y][f..t] = curMapOccupiedTiles[x][y][f..t]  + 1
	end
	
	curMapOccupiedExits[x][y][t] = true
	
	-- if f then curMapOccupiedTiles[x][y].from[f] = true end
	-- if t then curMapOccupiedTiles[x][y].to[t] = true end
end

function map.resetTileOccupied(x, y, f, t)
	--print("Freeing: ", f , t)
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
	pathNS = {}
	pathNS[1] = {x=48,y=0}
	pathNS[2] = {x=48,y=128}
	pathSN = {}
	pathSN[1] = {x=79,y=128}
	pathSN[2] = {x=79,y=0}
	
	pathEW = {}
	pathEW[1] = {x=128,y=48}
	pathEW[2] = {x=0,y=48}
	pathWE = {}
	pathWE[1] = {x=0,y=79}
	pathWE[2] = {x=128,y=79}
	
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
	
	pathSS = {}
	pathSS[1] = {x=79, y=128}
	pathSS[2] = {x=86, y=106}
	pathSS[3] = {x=102, y=90}
	pathSS[4] = {x=111, y=72}
	pathSS[5] = {x=110, y=47}
	pathSS[6] = {x=88, y=22}
	pathSS[7] = {x=63, y=15}
	pathSS[8] = {x=39, y=22}
	pathSS[9] = {x=17, y=47}
	pathSS[10] = {x=16, y=72}
	pathSS[11] = {x=25, y=90}
	pathSS[12] = {x=41, y=106}
	pathSS[13] = {x=48, y=128}
	
	pathWW = {}
	pathWW[1] = {x=0, y=79}
	pathWW[2] = {x=21, y=86}
	pathWW[3] = {x=37, y=102}
	pathWW[4] = {x=55, y=111}
	pathWW[5] = {x=80, y=110}
	pathWW[6] = {x=105, y=88}
	pathWW[7] = {x=112, y=63}
	pathWW[8] = {x=105, y=39}
	pathWW[9] = {x=80, y=17}
	pathWW[10] = {x=55, y=16}
	pathWW[11] = {x=37, y=25}
	pathWW[12] = {x=21, y=41}
	pathWW[13] = {x=0, y=48}
	
	pathNN = {}
	pathNN[1] = {x=48, y=0}
	pathNN[2] = {x=41, y=21}
	pathNN[3] = {x=25, y=37}
	pathNN[4] = {x=16, y=55}
	pathNN[5] = {x=17, y=80}
	pathNN[6] = {x=39, y=105}
	pathNN[7] = {x=64, y=112}
	pathNN[8] = {x=88, y=105}
	pathNN[9] = {x=110, y=80}
	pathNN[10] = {x=111, y=55}
	pathNN[11] = {x=102, y=37}
	pathNN[12] = {x=86, y=21}
	pathNN[13] = {x=79, y=0}
	
	pathEE = {}
	pathEE[1] = {x=128, y=48}
	pathEE[2] = {x=106, y=41}
	pathEE[3] = {x=90, y=25}
	pathEE[4] = {x=72, y=16}
	pathEE[5] = {x=47, y=17}
	pathEE[6] = {x=22, y=39}
	pathEE[7] = {x=15, y=64}
	pathEE[8] = {x=22, y=88}
	pathEE[9] = {x=47, y=110}
	pathEE[10] = {x=72, y=111}
	pathEE[11] = {x=90, y=102}
	pathEE[12] = {x=106, y=86}
	pathEE[13] = {x=128, y=79}
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
	print("Path not found", tileX, tileY)
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

function map.print(title)
	title = title or "Current map:"
	if curMap then
		print(title)
		local str = ""
		for j = 0,curMap.height+1,1 do
			str = ""
			for i = 0,curMap.width+1,1 do
				if curMap[i][j] then
					str = str .. curMap[i][j] .. " "
				else
					str = str .. "- "
				end
			end
			print(str)
		end
	end
end

function getRailType(i, j)
	if curMap[i-1][j] ~= "C" and curMap[i+1][j] ~= "C" and curMap[i][j-1] == "C" and curMap[i][j+1] == "C" then
		return NS
	end
	if curMap[i-1][j] == "C" and curMap[i+1][j] == "C" and curMap[i][j-1] ~= "C" and curMap[i][j+1] ~= "C" then
		return EW
	end
	
	--curves
	if curMap[i-1][j] == "C" and curMap[i+1][j] ~= "C" and curMap[i][j-1] == "C" and curMap[i][j+1] ~= "C" then
		return NW
	end
	if curMap[i-1][j] == "C" and curMap[i+1][j] ~= "C" and curMap[i][j-1] ~= "C" and curMap[i][j+1] == "C" then
		return SW
	end
	if curMap[i-1][j] ~= "C" and curMap[i+1][j] == "C" and curMap[i][j-1] == "C" and curMap[i][j+1] ~= "C" then
		return NE
	end
	if curMap[i-1][j] ~= "C" and curMap[i+1][j] == "C" and curMap[i][j-1] ~= "C" and curMap[i][j+1] == "C" then
		return ES
	end
	
	--junctions
	if curMap[i-1][j] == "C" and curMap[i+1][j] == "C" and curMap[i][j-1] == "C" and curMap[i][j+1] ~= "C" then
		return NEW
	end
	if curMap[i-1][j] ~= "C" and curMap[i+1][j] == "C" and curMap[i][j-1] == "C" and curMap[i][j+1] == "C" then
		return NES	-- NES
	end
	if curMap[i-1][j] == "C" and curMap[i+1][j] == "C" and curMap[i][j-1] ~= "C" and curMap[i][j+1] == "C" then
		return ESW	-- ESW
	end
	if curMap[i-1][j] == "C" and curMap[i+1][j] ~= "C" and curMap[i][j-1] == "C" and curMap[i][j+1] == "C" then
		return NSW	-- NSW
	end
	
	if curMap[i-1][j] == "C" and curMap[i+1][j] == "C" and curMap[i][j-1] == "C" and curMap[i][j+1] == "C" then
		return NESW	-- NESW
	end
	
	--turn around
	if curMap[i-1][j] == "C" and curMap[i+1][j] ~= "C" and curMap[i][j-1] ~= "C" and curMap[i][j+1] ~= "C" then
		return WW	-- W
	end
	if curMap[i-1][j] ~= "C" and curMap[i+1][j] == "C" and curMap[i][j-1] ~= "C" and curMap[i][j+1] ~= "C" then
		return EE	-- E
	end
	if curMap[i-1][j] ~= "C" and curMap[i+1][j] ~= "C" and curMap[i][j-1] == "C" and curMap[i][j+1] ~= "C" then
		return NN	-- N
	end
	if curMap[i-1][j] ~= "C" and curMap[i+1][j] ~= "C" and curMap[i][j-1] ~= "C" and curMap[i][j+1] == "C" then
		return SS	-- S
	end
end

function getRailImage( railType )
	--					N						S						W							E

	if railType == 1 then
		return IMAGE_RAIL_NS
	end
	if railType == 2 then
		return IMAGE_RAIL_EW
	end
	
	if railType == 3 then
		return IMAGE_RAIL_NW
	end
	if railType == 4 then
		return IMAGE_RAIL_SW
	end
	if railType == 5 then
		return IMAGE_RAIL_NE
	end
	if railType == 6 then
		return IMAGE_RAIL_ES
	end
	
	if railType == 7 then
		return IMAGE_RAIL_NEW
	end
	if railType == 8 then
		return IMAGE_RAIL_NES
	end
	if railType == 9 then
		return IMAGE_RAIL_ESW
	end
	if railType == 10 then
		return IMAGE_RAIL_NSW
	end
	
	if railType == 11 then
		return IMAGE_RAIL_NESW
	end
	
	if railType == 12 then
		return IMAGE_RAIL_W
	end
	if railType == 13 then
		return IMAGE_RAIL_E
	end
	if railType == 14 then
		return IMAGE_RAIL_N
	end
	if railType == 15 then
		return IMAGE_RAIL_S
	end
	
	return nil
end

function map.renderImage()
	print("rendering image")
	local data = nil
	local img = nil
	
	if curMap then
		data = love.image.newImageData((curMap.width+2)*TILE_SIZE, (curMap.height+2)*TILE_SIZE)
		for i = 0,curMap.height+1,1 do
			for j = 0,curMap.width+1,1 do
				if curMap[i][j] == "H" then
					data:paste( IMAGE_HOUSE1, (i)*TILE_SIZE, (j)*TILE_SIZE )
				else
					data:paste( IMAGE_GROUND, (i)*TILE_SIZE, (j)*TILE_SIZE )
					if curMap[i][j] == "C" then
						img = getRailImage( curMapRailTypes[i][j] )		-- get the image corresponding the rail type at this position
						if img then data:paste( img, (i)*TILE_SIZE, (j)*TILE_SIZE ) end
						--transparentPaste( data, img, (j)*TILE_SIZE, (i)*TILE_SIZE ) end
						--love.graphics.draw(img, (j-1)*TILE_SIZE, (i-1)*TILE_SIZE) end
					end
				end
			end
		end
	end
	return love.graphics.newImage(data)
end


--------------------------------------------------------------
--		MAP EVENTS:
--		- new passenger
--		- passenger lost
--------------------------------------------------------------

local passengerTimePassed = 10

function map.handleEvents(dt)
	passengerTimePassed = passengerTimePassed + dt*timeFactor
	if passengerTimePassed >= 2 then
		passenger.new()
		passengerTimePassed = passengerTimePassed - 2	-- to make sure it's the same on all platforms
	end
end



return map
