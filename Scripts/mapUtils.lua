
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
	for i = 0, curMap.width+1 do
		for j = 0, curMap.height+1 do
			if curMap[i][j] == nil then
				if (curMap[i+1] and curMap[i+1][j] == "C") or (curMap[i-1] and curMap[i-1][j] == "C") or curMap[i][j+1] == "C" or curMap[i][j-1] == "C" then
					if math.random(2) == 1 then curMap[i][j] = "H" end
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
			elseif curMap[i][j] == "H" then
				table.insert(curMap.houseList, {x=i, y=j})
			elseif curMap[i][j] == "S" then
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

