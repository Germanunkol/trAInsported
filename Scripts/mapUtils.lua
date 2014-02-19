
--------------------------------------------------------------
--		MAP GENERATION:
--------------------------------------------------------------
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

-- this function iterates through the map and marks all tiles that are connected to tile i,j (by changing them to "C")
function markConnected(i, j, level)
	level = level or 0
	curMap[i][j] = "C"
	if i > 1 and (curMap[i-1][j] == "R" or curMap[i-1][j] == "T") then markConnected(i-1, j, level+1) end
	if j > 1 and (curMap[i][j-1] == "R" or curMap[i][j-1] == "T") then markConnected(i, j-1, level+1) end
	if i < curMap.width and (curMap[i+1][j] == "R" or curMap[i+1][j] == "T") then markConnected(i+1, j, level+1) end
	if j < curMap.height and (curMap[i][j+1] == "R" or curMap[i][j+1] == "T") then markConnected(i, j+1, level+1) end
end


-- starts the markConnected functions on the first tile marked "R" on the map.
function findConnections()
	for i = 1,curMap.width,1 do		-- reset
		for j = 1,curMap.height,1 do
			if curMap[i][j] == "C" then
				curMap[i][j] = "R"
			end
		end
	end
	
	for i = 1,curMap.width do
		for j = 1,curMap.height do
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
	for i = 1,curMap.width,1 do
		for j = 1,curMap.height,1 do
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
	startI, startJ = i,j
	dir = math.random(4)
	local k = 0
	local triedDir1,triedDir2,triedDir3,triedDir4 = false, false, false, false
	while k < 2 do
		
		if dir == 1 then
			removeTs()
			i, j = startI, startJ
			while i > 1 and not triedDir1 do
				if not curMap[i][j] then curMap[i][j] = "T" end
				i = i - 1
				if curMap[i-1][j] == "C" or curMap[i][j+1] == "C" or curMap[i][j-1] == "C" then
					if not curMap[i][j] then curMap[i][j] = "T" end
					-- found a connection!
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
					return
				end
			end
			triedDir2 = true
			dir = 3
		end
		if dir == 3 then
			removeTs()
			i, j = startI, startJ
			ok, err = pcall(function()
			while i < curMap.width and not triedDir3 do
				if not curMap[i][j] then curMap[i][j] = "T" end
				i = i + 1
				if curMap[i+1][j] == "C" or curMap[i][j+1] == "C" or curMap[i][j-1] == "C" then
					if not curMap[i][j] then curMap[i][j] = "T" end
					-- found a connection!
					return
				end
			end
			end)
			if not ok then error(err .. "\ni " .. i .. "\nj " .. j) end
			triedDir3 = true
			dir = 4
		end
		if dir == 4 then
			removeTs()
			i, j = startI, startJ
			while j < curMap.height and not triedDir4 do
				if not curMap[i][j] then curMap[i][j] = "T" end
				j = j + 1
				if curMap[i+1][j] == "C" or curMap[i-1][j] == "C" or curMap[i][j+1] == "C" then
					if not curMap[i][j] then curMap[i][j] = "T" end
					-- found a connection!
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
	yPos = math.random(curMap.height)
	
	for i = 1,curMap.width do
		curMap[i][yPos] = "R"
	end
		
end

-- generates random rectangles of rail on the map.
function generateRailRectangles()

	local num = 6 + math.random(10)+ math.ceil(curMap.height/2)
	local k = 0
	while k < num do
		local rectWidth = math.random(curMap.width)
		local rectHeight = math.random(curMap.height)
		local i = math.floor(math.random(1, curMap.width) - rectWidth/2)
		local j = math.floor(math.random(1, curMap.height) - rectHeight/2)
		
		-- top rail:
		if j >= 1 and j <= curMap.height then
			local x = 0
			while x < rectWidth do
				if i+x >= 1 and i+x <= curMap.width then
					curMap[i+x][j] = "R"
				end
				x = x + 1
			end
		end
		
		-- bottom rail:
		if j+rectHeight >= 1 and j+rectHeight <= curMap.height then
			local x = 0
			while x < rectWidth do
				if i+x >= 1 and i+x <= curMap.width then
					curMap[i+x][j+rectHeight] = "R"
				end
				x = x + 1
			end
		end
		
		-- left rail:
		if i >= 1 and i <= curMap.width then
			local y = 0
			while y < rectHeight do
				if j+y >= 1 and j+y <= curMap.height then
					curMap[i][j+y] = "R"
				end
				y = y + 1
			end
		end
		
		-- right rail:
		if i+rectWidth >= 1 and i+rectWidth <= curMap.width then
			local y = 0
			while y < rectHeight do
				if j+y >= 1 and j+y <= curMap.height then
					curMap[i+rectWidth][j+y] = "R"
				end
				y = y + 1
			end
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

	local placed = false
	local schoolPlaced = false
	local hospitalPlaced = false
	
	for i = 0, curMap.width+1 do
		for j = 0, curMap.height+1 do
			placed = false
			if curMap[i][j] == nil then
				if i > 0 and j > 0 and i < curMap.width-1 and j < curMap.height-1 then		-- place large house
					if curMap[i+1][j] == nil and curMap[i][j+1] == nil and curMap[i+1][j+1] == nil then
						if math.random(20) == 1 and not schoolPlaced then
							curMap[i][j] = "SCHOOL11"
							curMap[i+1][j] = "SCHOOL21"
							curMap[i][j+1] = "SCHOOL12"
							curMap[i+1][j+1] = "SCHOOL22"
							schoolPlaced = true
							placed = true
						end
						if math.random(20) == 1 and not hospitalPlaced then
							curMap[i][j] = "HOSPITAL11"
							curMap[i+1][j] = "HOSPITAL21"
							curMap[i][j+1] = "HOSPITAL12"
							curMap[i+1][j+1] = "HOSPITAL22"
							hospitalPlaced = true
							placed = true
						end
					end
				end
				if not placed and ((curMap[i+1] and curMap[i+1][j] == "C") or (curMap[i-1] and curMap[i-1][j] == "C") or curMap[i][j+1] == "C" or curMap[i][j-1] == "C") then
					if region == "Urban" then
						if math.random(7) > 1 then
							curMap[i][j] = "H"
						end
					else
						if math.random(2) == 1 then
							curMap[i][j] = "H"
						end
					end
				end
			end
		end
	end
	
	if region == "Urban" then
		for i = 1, curMap.width do
			for j = 1, curMap.height do
				if curMap[i][j] == "H" and curMap[i][j+1] == "H" then
					if math.random(4) > 1 then
						if math.random(2) == 1 then
							curMap[i][j] = "HOUSE_1_LARGE11"
							curMap[i][j+1] = "HOUSE_1_LARGE12"
						else
							curMap[i][j] = "HOUSE_2_LARGE11"
							curMap[i][j+1] = "HOUSE_2_LARGE12"
						end
					end
				end
				if curMap[i][j] == "H" and curMap[i+1][j] == "H" then
				
					if math.random(4) > 1 then
						if math.random(2) == 1 then
							curMap[i][j] = "HOUSE_3_LARGE11"
							curMap[i+1][j] = "HOUSE_3_LARGE21"
						else
							curMap[i][j] = "HOUSE_4_LARGE11"
							curMap[i+1][j] = "HOUSE_4_LARGE21"
						end
					end
				end
			end
		end
	end
end

function placeHotspots()		-- at random, place hotspots.
	for i = 1, curMap.width do
		for j = 1, curMap.height do
			if curMap[i][j] == nil then
				if curMap[i+1][j] == "C" or curMap[i-1][j] == "C" or curMap[i][j+1] == "C" or curMap[i][j-1] == "C" then
					if math.random(5) == 1 then curMap[i][j] = "S" end		-- make hotspot
				end
			end
		end
	end
end


-- This function iterates over the whole map and calculates the rail type for each tile.
-- That's important for placing correct images on the map and for calculating movement later on.
function calculateRailTypes(map)
	map = map or curMap
	if map then
		for i = 1,map.width do
			for j = 1,map.height do
				curMapRailTypes[i][j] = getRailType(i,j, map)
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
			if curMap[i][j] == "C" then 
				table.insert(curMap.railList, {x=i, y=j})
			elseif curMap[i][j] == "H" or curMap[i][k] and curMap[i][j]:find("HOUSE") then
				table.insert(curMap.houseList, {x=i, y=j})
			elseif curMap[i][j] == "S" or curMap[i][j] == "SCHOOL" or curMap[i][j] == "HOSPITAL" then
				if curMap[i+1][j] == "C" then
					for k = 1,25 do
						table.insert(curMap.railList, {x=i+1, y=j})		-- 25 times as likely to spawn passenger if the rail is near a hotspot.
					end
				elseif curMap[i-1][j] == "C" then
					for k = 1,25 do
						table.insert(curMap.railList, {x=i-1, y=j})		-- 25 times as likely to spawn passenger if the rail is near a hotspot.
					end
				elseif curMap[i][j+1] == "C" then
					for k = 1,25 do
						table.insert(curMap.railList, {x=i, y=j+1})		-- 25 times as likely to spawn passenger if the rail is near a hotspot.
					end
				elseif curMap[i][j-1] == "C" then
					for k = 1,25 do
						table.insert(curMap.railList, {x=i, y=j-1})		-- 25 times as likely to spawn passenger if the rail is near a hotspot.
					end
				end
			end
		end
	end
	
end


function getRailType(i, j, map)
	map = map or curMap
	if map[i-1][j] ~= "C" and map[i+1][j] ~= "C" and map[i][j-1] == "C" and map[i][j+1] == "C" then
		return NS
	end
	if map[i-1][j] == "C" and map[i+1][j] == "C" and map[i][j-1] ~= "C" and map[i][j+1] ~= "C" then
		return EW
	end
	
	--curves
	if map[i-1][j] == "C" and map[i+1][j] ~= "C" and map[i][j-1] == "C" and map[i][j+1] ~= "C" then
		return NW
	end
	if map[i-1][j] == "C" and map[i+1][j] ~= "C" and map[i][j-1] ~= "C" and map[i][j+1] == "C" then
		return SW
	end
	if map[i-1][j] ~= "C" and map[i+1][j] == "C" and map[i][j-1] == "C" and map[i][j+1] ~= "C" then
		return NE
	end
	if map[i-1][j] ~= "C" and map[i+1][j] == "C" and map[i][j-1] ~= "C" and map[i][j+1] == "C" then
		return ES
	end
	
	--junctions
	if map[i-1][j] == "C" and map[i+1][j] == "C" and map[i][j-1] == "C" and map[i][j+1] ~= "C" then
		return NEW
	end
	if map[i-1][j] ~= "C" and map[i+1][j] == "C" and map[i][j-1] == "C" and map[i][j+1] == "C" then
		return NES	-- NES
	end
	if map[i-1][j] == "C" and map[i+1][j] == "C" and map[i][j-1] ~= "C" and map[i][j+1] == "C" then
		return ESW	-- ESW
	end
	if map[i-1][j] == "C" and map[i+1][j] ~= "C" and map[i][j-1] == "C" and map[i][j+1] == "C" then
		return NSW	-- NSW
	end
	
	if map[i-1][j] == "C" and map[i+1][j] == "C" and map[i][j-1] == "C" and map[i][j+1] == "C" then
		return NESW	-- NESW
	end
	
	--turn around
	if map[i-1][j] == "C" and map[i+1][j] ~= "C" and map[i][j-1] ~= "C" and map[i][j+1] ~= "C" then
		return WW	-- W
	end
	if map[i-1][j] ~= "C" and map[i+1][j] == "C" and map[i][j-1] ~= "C" and map[i][j+1] ~= "C" then
		return EE	-- E
	end
	if map[i-1][j] ~= "C" and map[i+1][j] ~= "C" and map[i][j-1] == "C" and map[i][j+1] ~= "C" then
		return NN	-- N
	end
	if map[i-1][j] ~= "C" and map[i+1][j] ~= "C" and map[i][j-1] ~= "C" and map[i][j+1] == "C" then
		return SS	-- S
	end
end

local mapQuads = {}

function newQuad( x, y, img, w, h )
	img = img or groundSheetGrass
	w = w or 1
	h = h or 1
	return love.graphics.newQuad( (x-1)*TILE_SIZE, (y-1)*TILE_SIZE,
								TILE_SIZE*h, TILE_SIZE*h,
								img:getWidth(), img:getHeight() )
end

function generateMapQuads()

	mapQuads.plain = newQuad( 2, 2 )		-- center, empty piece

	mapQuads.borderLT = newQuad( 1, 1 )		-- left top border
	mapQuads.borderCT = newQuad( 2, 1 )		-- center top border
	mapQuads.borderRT = newQuad( 3, 1 )		-- right top border
	mapQuads.borderLM = newQuad( 1, 2 )		-- left middle border
	mapQuads.borderRM = newQuad( 3, 2 )		-- right middle border
	mapQuads.borderLB = newQuad( 1, 3 )		-- left bottom border
	mapQuads.borderCB = newQuad( 2, 3 )		-- center bottom border
	mapQuads.borderRB = newQuad( 3, 3 )		-- right bottom border

	-- Rails:
	mapQuads[NS] = newQuad( 5, 3 )
	mapQuads[EW] = newQuad( 4, 3 )

	mapQuads[NW] = newQuad( 5, 5 )
	mapQuads[SW] = newQuad( 5, 4 )
	mapQuads[NE] = newQuad( 4, 5 )
	mapQuads[ES] = newQuad( 4, 4 )

	mapQuads[NEW] = newQuad( 1, 5 )
	mapQuads[NES] = newQuad( 1, 4 )
	mapQuads[ESW] = newQuad( 2, 5 )
	mapQuads[NSW] = newQuad( 2, 4 )

	mapQuads[NESW] = newQuad( 3, 4 )

	mapQuads[WW] = newQuad( 4, 2 )
	mapQuads[EE] = newQuad( 5, 1 )
	mapQuads[NN] = newQuad( 5, 2 )
	mapQuads[SS] = newQuad( 4, 1 )


--Hotspots/special Buildings:
	mapQuads.HOTSPOT01 = newQuad( 1, 1, objectSheet )
	mapQuads.HOTSPOT01_SHADOW = newQuad( 1, 1, objectShadowSheet )

-- Misc/Tutorial:
	mapQuads.HOTSPOT_HOME = newQuad( 1, 4, objectSheet )
	mapQuads.HOTSPOT_SCHOOL = newQuad( 1, 4, objectSheet )
	mapQuads.HOTSPOT_PLAYGROUND = newQuad( 8, 1, objectSheet )
	mapQuads.HOTSPOT_PLAYGROUND_SHADOW = newQuad( 8, 1, objectShadowSheet )
	mapQuads.HOTSPOT_PIESTORE = newQuad( 10, 1, objectSheet )
	mapQuads.HOTSPOT_BOOKSTORE = newQuad( 5, 3, objectSheet )
	mapQuads.HOTSPOT_STORE = newQuad( 9, 1, objectSheet )
	mapQuads.HOTSPOT_STORE_SHADOW = newQuad( 9, 1, objectShadowSheet )
	mapQuads.HOTSPOT_CINEMA = newQuad( 6, 3, objectSheet )
	mapQuads.HOTSPOT_CINEMA_SHADOW = newQuad( 6, 3, objectShadowSheet )

	mapQuads.HOTSPOT_SCHOOL00 = newQuad( 3, 1, objectSheet )
	mapQuads.HOTSPOT_SCHOOL10 = newQuad( 4, 1, objectSheet )
	mapQuads.HOTSPOT_SCHOOL01 = newQuad( 3, 2, objectSheet )
	mapQuads.HOTSPOT_SCHOOL11 = newQuad( 4, 2, objectSheet )
	mapQuads.HOTSPOT_SCHOOL_SHADOW00 = newQuad( 3, 1, objectShadowSheet )
	mapQuads.HOTSPOT_SCHOOL_SHADOW10 = newQuad( 4, 1, objectShadowSheet )
	mapQuads.HOTSPOT_SCHOOL_SHADOW01 = newQuad( 3, 2, objectShadowSheet )
	mapQuads.HOTSPOT_SCHOOL_SHADOW11 = newQuad( 4, 2, objectShadowSheet )

	mapQuads.HOTSPOT_HOSPITAL00 = newQuad( 1, 1, objectSheet )
	mapQuads.HOTSPOT_HOSPITAL10 = newQuad( 2, 1, objectSheet )
	mapQuads.HOTSPOT_HOSPITAL01 = newQuad( 1, 2, objectSheet )
	mapQuads.HOTSPOT_HOSPITAL11 = newQuad( 2, 2, objectSheet )
	mapQuads.HOTSPOT_HOSPITAL_SHADOW00 = newQuad( 1, 1, objectShadowSheet )
	mapQuads.HOTSPOT_HOSPITAL_SHADOW10 = newQuad( 2, 1, objectShadowSheet )
	mapQuads.HOTSPOT_HOSPITAL_SHADOW01 = newQuad( 1, 2, objectShadowSheet )
	mapQuads.HOTSPOT_HOSPITAL_SHADOW11 = newQuad( 2, 2, objectShadowSheet )

--Environment/Misc:
	mapQuads.HOUSE01 = newQuad( 3, 4, objectSheet )
	mapQuads.HOUSE01_SHADOW = newQuad( 3, 4, objectShadowSheet, 1.5, 1.5 )
	mapQuads.HOUSE02 = newQuad( 5, 4, objectSheet )
	mapQuads.HOUSE02_SHADOW = newQuad( 5, 4, objectShadowSheet, 1.5, 1.5 )
	mapQuads.HOUSE03 = newQuad( 7, 4, objectSheet )
	mapQuads.HOUSE03_SHADOW = newQuad( 7, 4, objectShadowSheet, 1.5, 1.5 )
	mapQuads.HOUSE04 = newQuad( 9, 4, objectSheet )
	mapQuads.HOUSE04_SHADOW = newQuad( 9, 4, objectShadowSheet, 1.5, 1.5 )

	mapQuads.HOUSE05 = newQuad( 8, 2, objectSheet )
	mapQuads.HOUSE05_SHADOW = newQuad( 8, 2, objectShadowSheet )
	mapQuads.HOUSE06 = newQuad( 9, 2, objectSheet )
	mapQuads.HOUSE06_SHADOW = newQuad( 9, 2, objectShadowSheet )
	mapQuads.HOUSE07 = newQuad( 10, 2, objectSheet )
	mapQuads.HOUSE07_SHADOW = newQuad( 10, 2, objectShadowSheet )

	mapQuads.HOUSE01_L11 = newQuad( 6, 1, objectSheet )
	mapQuads.HOUSE01_L_SHADOW11 = newQuad( 6, 1, objectShadowSheet )
	mapQuads.HOUSE01_L12 = newQuad( 6, 2, objectSheet )
	mapQuads.HOUSE01_L_SHADOW12 = newQuad( 6, 2, objectShadowSheet )
	mapQuads.HOUSE02_L11 = newQuad( 5, 1, objectSheet )
	mapQuads.HOUSE02_L_SHADOW11 = newQuad( 5, 1, objectShadowSheet )
	mapQuads.HOUSE02_L12 = newQuad( 5, 2, objectSheet )
	mapQuads.HOUSE02_L_SHADOW12 = newQuad( 5, 2, objectShadowSheet )
	mapQuads.HOUSE03_L11 = newQuad( 3, 3, objectSheet )
	mapQuads.HOUSE03_L_SHADOW11 = newQuad( 3, 3, objectShadowSheet )
	mapQuads.HOUSE03_L21 = newQuad( 4, 3, objectSheet )
	mapQuads.HOUSE03_L_SHADOW21 = newQuad( 4, 3, objectShadowSheet )
	mapQuads.HOUSE04_L11 = newQuad( 1, 3, objectSheet )
	mapQuads.HOUSE04_L_SHADOW11 = newQuad( 1, 3, objectShadowSheet )
	mapQuads.HOUSE04_L21 = newQuad( 2, 3, objectSheet )
	mapQuads.HOUSE04_L_SHADOW21 = newQuad( 2, 3, objectShadowSheet )

	mapQuads.TREE01 = newQuad( 7, 1, objectSheet )
	mapQuads.TREE01_SHADOW = newQuad( 7, 1, objectShadowSheet )
	mapQuads.TREE02 = newQuad( 7, 2, objectSheet )
	mapQuads.TREE02_SHADOW = newQuad( 7, 2, objectShadowSheet )
	mapQuads.TREE03 = newQuad( 7, 3, objectSheet )
	mapQuads.TREE03_SHADOW = newQuad( 7, 3, objectShadowSheet )
	mapQuads.BUSH01 = newQuad( 8, 3, objectSheet )
	mapQuads.BUSH01_SHADOW = newQuad( 8, 3, objectShadowSheet )

	mapQuads.PARK = newQuad( 3, 5 )
end

function renderMap( map, curMapRailTypes, noTrees, region )

	local groundData
	if region == "Urban" then
		groundData = love.graphics.newSpriteBatch( groundSheetStone, (map.width+2)*(map.height+2) * 2)
	else
		groundData = love.graphics.newSpriteBatch( groundSheetGrass, (map.width+2)*(map.height+2))
	end

	local shadowData = love.graphics.newSpriteBatch( objectShadowSheet, (map.width+2)*(map.height+2) )
	local objectData = love.graphics.newSpriteBatch( objectSheet, (map.width+2)*(map.height+2))

	--printTable(curMapRailTypes)

	-- border:
	groundData:add( mapQuads.borderLT, 0,0 )
	groundData:add( mapQuads.borderRT, (map.width+1)*TILE_SIZE,0 )
	groundData:add( mapQuads.borderLB, 0,(map.height+1)*TILE_SIZE )
	groundData:add( mapQuads.borderRB, (map.width+1)*TILE_SIZE,(map.height+1)*TILE_SIZE )

	for x = 1, map.width do
		groundData:add( mapQuads.borderCT, x*TILE_SIZE, 0 )
		groundData:add( mapQuads.borderCB, x*TILE_SIZE, (map.height+1)*TILE_SIZE )
	end
	for y = 1, map.height do
		groundData:add( mapQuads.borderLM, 0, y*TILE_SIZE )
		groundData:add( mapQuads.borderRM, (map.width+1)*TILE_SIZE, y*TILE_SIZE )
	end

	for x = 1, map.width do
		for y = 1, map.height do

			if map[x][y] == "C" and mapQuads[curMapRailTypes[x][y]] then

				groundData:add( mapQuads[curMapRailTypes[x][y]], x*TILE_SIZE, y*TILE_SIZE )
			else
				groundData:add( mapQuads.plain, x*TILE_SIZE, y*TILE_SIZE )
			end

			-- Houses etc:
			if map[x][y] == "H" then
				randX, randY = math.floor(myRandom()*TILE_SIZE/4-TILE_SIZE/8), math.floor(myRandom()*TILE_SIZE/4-TILE_SIZE/8)
				--[[if x == endX then randX = -TILE_SIZE/8 end
				if j == endY then randY = -TILE_SIZE/8 end
				if x == startX then randX = TILE_SIZE/8 end
				if j == startX then randY = TILE_SIZE/8 end]]
				if region == "Urban" then
					houseType = myRandom(3)
					col = {r = myRandom(40)-20, g = 0, b = 0}
					if houseType == 1 then
						shadowData:add( mapQuads.HOUSE05_SHADOW, (x)*TILE_SIZE+randX, (y)*TILE_SIZE+randY)
						objectData:add( mapQuads.HOUSE05, (x)*TILE_SIZE+randX, (y)*TILE_SIZE+randY)
					elseif houseType == 2 then
						shadowData:add( mapQuads.HOUSE06_SHADOW, (x)*TILE_SIZE+randX, (y)*TILE_SIZE+randY)
						objectData:add( mapQuads.HOUSE06, (x)*TILE_SIZE+randX, (y)*TILE_SIZE+randY)
					elseif houseType == 3 then
						shadowData:add( mapQuads.HOUSE07_SHADOW, (x)*TILE_SIZE+randX, (y)*TILE_SIZE+randY)
						objectData:add( mapQuads.HOUSE07, (x)*TILE_SIZE+randX, (y)*TILE_SIZE+randY)
					end
				else
					houseType = myRandom(4)
					col = {r = myRandom(40)-20, g = 0, b = 0}
					if houseType == 1 then
						shadowData:add( mapQuads.HOUSE01_SHADOW, (x)*TILE_SIZE+randX-26, (y)*TILE_SIZE+randY-26)
						objectData:add( mapQuads.HOUSE01, (x)*TILE_SIZE+randX, (y)*TILE_SIZE+randY)
					elseif houseType == 2 then
						shadowData:add( mapQuads.HOUSE02_SHADOW, (x)*TILE_SIZE+randX-26, (y)*TILE_SIZE+randY-26)
						objectData:add( mapQuads.HOUSE02, (x)*TILE_SIZE+randX, (y)*TILE_SIZE+randY)
					elseif houseType == 3 then
						shadowData:add( mapQuads.HOUSE03_SHADOW, (x)*TILE_SIZE+randX-26, (y)*TILE_SIZE+randY-26)
						objectData:add( mapQuads.HOUSE03, (x)*TILE_SIZE+randX, (y)*TILE_SIZE+randY)
					elseif houseType == 4 then
						shadowData:add( mapQuads.HOUSE04_SHADOW, (x)*TILE_SIZE+randX-26, (y)*TILE_SIZE+randY-26)
						objectData:add( mapQuads.HOUSE04, (x)*TILE_SIZE+randX, (y)*TILE_SIZE+randY)
					end
				end
			elseif map[x][y] == "S" then
				if region == "Urban" then
					choice = myRandom(5)
				else
					choice = myRandom(4)
				end
				if choice == 1 then
					shadowData:add( mapQuads.HOTSPOT_STORE_SHADOW, (x)*TILE_SIZE, (y)*TILE_SIZE)
					objectData:add( mapQuads.HOTSPOT_STORE, (x)*TILE_SIZE, (y)*TILE_SIZE)
				elseif choice == 2 then
					shadowData:add( mapQuads.HOTSPOT_STORE_SHADOW, (x)*TILE_SIZE, (y)*TILE_SIZE)
					objectData:add( mapQuads.HOTSPOT_PIESTORE, (x)*TILE_SIZE, (y)*TILE_SIZE)
				elseif choice == 3 then
					shadowData:add( mapQuads.HOTSPOT_STORE_SHADOW, (x)*TILE_SIZE, (y)*TILE_SIZE)
					objectData:add( mapQuads.HOTSPOT_BOOKSTORE, (x)*TILE_SIZE, (y)*TILE_SIZE)
				elseif choice == 4 then
					shadowData:add( mapQuads.HOTSPOT_PLAYGROUND_SHADOW, (x)*TILE_SIZE, (y)*TILE_SIZE)
					objectData:add( mapQuads.HOTSPOT_PLAYGROUND, (x)*TILE_SIZE, (y)*TILE_SIZE)
				else
					shadowData:add( mapQuads.HOTSPOT_CINEMA_SHADOW, (x)*TILE_SIZE, (y)*TILE_SIZE)
					objectData:add( mapQuads.HOTSPOT_CINEMA, (x)*TILE_SIZE, (y)*TILE_SIZE)
				end
			elseif map[x][y] == "PS" then	-- pie store...
				shadowData:add( mapQuads.HOTSPOT_STORE_SHADOW, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOTSPOT_PIESTORE, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "STORE" then	-- store...
				shadowData:add( mapQuads.HOTSPOT_STORE_SHADOW, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOTSPOT_STORE, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "HO" then	-- home
				shadowData:add( mapQuads.HOTSPOT01_SHADOW, (x)*TILE_SIZE-26, (y)*TILE_SIZE-26)
				objectData:add( mapQuads.HOTSPOT_HOME, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "SCHOOL11" then	-- school
				shadowData:add( mapQuads.HOTSPOT_SCHOOL_SHADOW00, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOTSPOT_SCHOOL00, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "SCHOOL12" then	-- school
				shadowData:add( mapQuads.HOTSPOT_SCHOOL_SHADOW01, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOTSPOT_SCHOOL01, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "SCHOOL21" then	-- school
				shadowData:add( mapQuads.HOTSPOT_SCHOOL_SHADOW10, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOTSPOT_SCHOOL10, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "SCHOOL22" then	-- school
				shadowData:add( mapQuads.HOTSPOT_SCHOOL_SHADOW11, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOTSPOT_SCHOOL11, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "HOSPITAL11" then	-- HOSPITAL
				shadowData:add( mapQuads.HOTSPOT_HOSPITAL_SHADOW00, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOTSPOT_HOSPITAL00, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "HOSPITAL12" then	-- HOSPITAL
				shadowData:add( mapQuads.HOTSPOT_HOSPITAL_SHADOW01, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOTSPOT_HOSPITAL01, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "HOSPITAL21" then	-- HOSPITAL
				shadowData:add( mapQuads.HOTSPOT_HOSPITAL_SHADOW10, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOTSPOT_HOSPITAL10, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "HOSPITAL22" then	-- HOSPITAL
				shadowData:add( mapQuads.HOTSPOT_HOSPITAL_SHADOW11, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOTSPOT_HOSPITAL11, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "HOUSE_1_LARGE11" then	-- HOSPITAL
				shadowData:add( mapQuads.HOUSE01_L_SHADOW11, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOUSE01_L11, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "HOUSE_1_LARGE12" then	-- HOSPITAL
				shadowData:add( mapQuads.HOUSE01_L_SHADOW12, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOUSE01_L12, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "HOUSE_2_LARGE11" then	-- HOSPITAL
				shadowData:add( mapQuads.HOUSE02_L_SHADOW11, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOUSE02_L11, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "HOUSE_2_LARGE12" then	-- HOSPITAL
				shadowData:add( mapQuads.HOUSE02_L_SHADOW12, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOUSE02_L12, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "HOUSE_3_LARGE11" then	-- HOSPITAL
				shadowData:add( mapQuads.HOUSE03_L_SHADOW11, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOUSE03_L11, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "HOUSE_3_LARGE21" then	-- HOSPITAL
				shadowData:add( mapQuads.HOUSE03_L_SHADOW21, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOUSE03_L21, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "HOUSE_4_LARGE11" then	-- HOSPITAL
				shadowData:add( mapQuads.HOUSE04_L_SHADOW11, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOUSE04_L11, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "HOUSE_4_LARGE21" then	-- HOSPITAL
				shadowData:add( mapQuads.HOUSE04_L_SHADOW21, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOUSE04_L21, (x)*TILE_SIZE, (y)*TILE_SIZE)
			elseif map[x][y] == "PL" then	-- playground
				shadowData:add( mapQuads.HOTSPOT_PLAYGROUND_SHADOW, (x)*TILE_SIZE, (y)*TILE_SIZE)
				objectData:add( mapQuads.HOTSPOT_PLAYGROUND, (x)*TILE_SIZE, (y)*TILE_SIZE)
			end
		end
	end

	-- Foilage
	if not NO_TREES then

		if region == "Urban" then
			local treetype = 0
			for x = 0,map.width+1 do		-- randomly place trees/bushes etc
				for y = 0,map.height+1 do
					if (not map[x] or not map[x][y]) and myRandom(4) == 1 then
						if x ~= 0 and x ~= map.width+1 and y ~= 0 and y~= map.height+1 then
							groundData:add( mapQuads.PARK, (x)*TILE_SIZE, (y)*TILE_SIZE)
						end
						numTries = myRandom(5)+1
						for k = 1, numTries do
							randX, randY = math.floor(myRandom()*TILE_SIZE-TILE_SIZE/2), math.floor(myRandom()*TILE_SIZE-TILE_SIZE/2)
							treetype = myRandom(3)

							if treetype == 1 then
								s = mapQuads.TREE01_SHADOW
								o = mapQuads.TREE01
							elseif treetype == 2 then
								s = mapQuads.TREE02_SHADOW
								o = mapQuads.TREE02
							else
								s = mapQuads.TREE03_SHADOW
								o = mapQuads.TREE03
							end

							--[[if i == startX then randX = math.max(0, randX) end
							if j == startY then randY = math.max(0, randY) end
							if i == endX then randX = math.min(TILE_SIZE-s:getWidth(), randX) end
							if j == endY then randY = math.min(TILE_SIZE-s:getHeight(), randY) end]]

							shadowData:add( s, (x)*TILE_SIZE+randX, (y)*TILE_SIZE+randY)
							objectData:add( o, (x)*TILE_SIZE+randX, (y)*TILE_SIZE+randY )
						end
					end
				end
			end
		else
			for x = 0,map.width+1 do		-- randomly place trees/bushes etc
				for y = 0,map.height+1 do
					if (not map[x] or not map[x][y]) and myRandom(4) == 1 then
						numTries = myRandom(3)+1
						for k = 1, numTries do
							--col = {r = myRandom(20)-10, g = myRandom(40)-30, b = 0}
							randX, randY = TILE_SIZE/4+math.floor(myRandom()*TILE_SIZE-TILE_SIZE/2), TILE_SIZE/4+math.floor(myRandom()*TILE_SIZE-TILE_SIZE/2)

							if i == startX then randX = math.max(0, randX) end
							if j == startY then randY = math.max(0, randY) end
							if i == endX then randX = math.min(TILE_SIZE*0.5, randX) end
							if j == endY then randY = math.min(TILE_SIZE*0.5, randY) end
							shadowData:add( mapQuads.BUSH01_SHADOW, (x)*TILE_SIZE+randX, (y)*TILE_SIZE+randY)
							objectData:add( mapQuads.BUSH01, (x)*TILE_SIZE+randX, (y)*TILE_SIZE+randY )
						end
					end
				end
			end

			local treetype = 0
			for x = 0,map.width+1 do		-- randomly place trees/bushes etc
				for y = 0,map.height+1 do
					if (not map[x] or not map[x][y]) and myRandom(3) == 1 then
						numTries = myRandom(5)+1
						for k = 1, numTries do
							randX, randY = math.floor(myRandom()*TILE_SIZE-TILE_SIZE/2), math.floor(myRandom()*TILE_SIZE-TILE_SIZE/2)
							treetype = myRandom(3)

							if treetype == 1 then
								s = mapQuads.TREE01_SHADOW
								o = mapQuads.TREE01
							elseif treetype == 2 then
								s = mapQuads.TREE02_SHADOW
								o = mapQuads.TREE02
							else
								s = mapQuads.TREE03_SHADOW
								o = mapQuads.TREE03
							end

							--[[if i == startX then randX = math.max(0, randX) end
							if j == startY then randY = math.max(0, randY) end
							if i == endX then randX = math.min(TILE_SIZE-s:getWidth(), randX) end
							if j == endY then randY = math.min(TILE_SIZE-s:getHeight(), randY) end]]

							shadowData:add( s, (x)*TILE_SIZE+randX, (y)*TILE_SIZE+randY)
							objectData:add( o, (x)*TILE_SIZE+randX, (y)*TILE_SIZE+randY )
						end
					end
				end
			end
		end
	end

	return groundData, shadowData, objectData
end

