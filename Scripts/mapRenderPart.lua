thisThread = love.thread.getThread()

require("love.image")
require("love.filesystem")
pcall(require, "TSerial")
pcall(require, "Scripts/TSerial")
pcall(require, "imageManipulation")
pcall(require, "Scripts/imageManipulation")
-- load "globals" in dedicated mode, only get variables:
rememberDedi = DEDICATED
DEDICATED = true
pcall(require, "globals")
pcall(require, "Scripts/globals")
DEDICATED = rememberDedi


m = TSerial.unpack(thisThread:demand("map"))
curMapRailTypes = TSerial.unpack(thisThread:demand("curMapRailTypes"))
startCoordinateX = thisThread:demand("startCoordinateX")
startCoordinateY = thisThread:demand("startCoordinateY")

function checkAborted()
	if abort then
		return true
	end
	if thisThread:get("abort") then
		abort = true
		return true
	end
end

-- Ground:
IMAGE_GROUND = love.image.newImageData("Images/Ground.png")
IMAGE_GROUND_LEFT = love.image.newImageData("Images/BorderLeft.png")
IMAGE_GROUND_RIGHT = love.image.newImageData("Images/BorderRight.png")
IMAGE_GROUND_BOTTOM = love.image.newImageData("Images/BorderBottom.png")
IMAGE_GROUND_TOP = love.image.newImageData("Images/BorderTop.png")
IMAGE_GROUND_TOPLEFT = love.image.newImageData("Images/BorderTopLeft.png")
IMAGE_GROUND_TOPRIGHT = love.image.newImageData("Images/BorderTopRight.png")
IMAGE_GROUND_BOTTOMLEFT = love.image.newImageData("Images/BorderBottomLeft.png")
IMAGE_GROUND_BOTTOMRIGHT = love.image.newImageData("Images/BorderBottomRight.png")


--Rails:
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

--Hotspots/special Buildings:
IMAGE_HOTSPOT01 = love.image.newImageData("Images/HotSpot1.png")
IMAGE_HOTSPOT01_SHADOW = love.image.newImageData("Images/HotSpot1_Shadow.png")

-- Tutorial:
IMAGE_HOTSPOT_PIESTORE = love.image.newImageData("Images/HotSpot_PieStore.png")
IMAGE_HOTSPOT_HOME = love.image.newImageData("Images/HotSpot_Home.png")
IMAGE_HOTSPOT_SCHOOL = love.image.newImageData("Images/HotSpot_School.png")
IMAGE_HOTSPOT_PLAYGROUND = love.image.newImageData("Images/HotSpot_Playground.png")

--Environment/Misc:
IMAGE_HOUSE01 = love.image.newImageData("Images/House1.png")
IMAGE_HOUSE01_SHADOW = love.image.newImageData("Images/House1_Shadow.png")
IMAGE_HOUSE02 = love.image.newImageData("Images/House2.png")
IMAGE_HOUSE02_SHADOW = love.image.newImageData("Images/House2_Shadow.png")
IMAGE_HOUSE03 = love.image.newImageData("Images/House3.png")
IMAGE_HOUSE03_SHADOW = love.image.newImageData("Images/House3_Shadow.png")
IMAGE_HOUSE04 = love.image.newImageData("Images/House4.png")
IMAGE_HOUSE04_SHADOW = love.image.newImageData("Images/House4_Shadow.png")

IMAGE_TREE01 = love.image.newImageData("Images/Tree1.png")
IMAGE_TREE01_SHADOW = love.image.newImageData("Images/Tree1_Shadow.png")
IMAGE_TREE02 = love.image.newImageData("Images/Tree2.png")
IMAGE_TREE02_SHADOW = love.image.newImageData("Images/Tree2_Shadow.png")
IMAGE_TREE03 = love.image.newImageData("Images/Tree3.png")
IMAGE_TREE03_SHADOW = love.image.newImageData("Images/Tree3_Shadow.png")
IMAGE_BUSH01 = love.image.newImageData("Images/Bush.png")
IMAGE_BUSH01_SHADOW = love.image.newImageData("Images/Bush_Shadow.png")



function getRailImage( railType )
	--	N		S		W		E

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


xBorder = 0
yBorder = 0
startX = 1
startY = 1
endX = m.width
endY = m.height
offsetX = -1
offsetY = -1

if m.left == true then
	xBorder = yBorder + 1
	startX = 0
	offsetX = 0
end
if m.right == true then
	xBorder = yBorder + 1
	endX = m.width + 1
end
if m.top == true then
	yBorder = yBorder + 1
	startY = 0
	offsetY = 0
end
if m.bottom == true then
	yBorder = yBorder + 1
	endY = m.height + 1
end

ground = love.image.newImageData((m.width+xBorder)*TILE_SIZE, (m.height+yBorder)*TILE_SIZE)
shadows = love.image.newImageData((m.width+xBorder)*TILE_SIZE, (m.height+yBorder)*TILE_SIZE)
objects = love.image.newImageData((m.width+xBorder)*TILE_SIZE, (m.height+yBorder)*TILE_SIZE)


-- Ground and rails:
for i = startX, endX do
	for j = startY, endY do
		if i == 0 then
			if j == 0 then
				ground:paste(IMAGE_GROUND_TOPLEFT, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE)
			elseif j > m.height then
				ground:paste(IMAGE_GROUND_BOTTOMLEFT, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE)
			else
				ground:paste(IMAGE_GROUND_LEFT, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE)
			end
		elseif i > m.width then
			if j == 0 then
				ground:paste(IMAGE_GROUND_TOPRIGHT, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE)
			elseif j > m.height then
				ground:paste(IMAGE_GROUND_BOTTOMRIGHT, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE)
			else
				ground:paste(IMAGE_GROUND_RIGHT, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE)
			end
		elseif j == 0 then
			ground:paste(IMAGE_GROUND_TOP, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE)
		elseif j > m.height then
			ground:paste(IMAGE_GROUND_BOTTOM, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE)
		else
			if m[i][j] == "C" then
				ground:paste(getRailImage( curMapRailTypes[i+startCoordinateX][j+startCoordinateY] ), (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE) 		-- get the image corresponding the rail type at this position				
			else
				ground:paste(IMAGE_GROUND, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE)
				
				-- Houses etc:
				if m[i][j] == "H" then
					randX, randY = math.floor(math.random()*TILE_SIZE/4-TILE_SIZE/8), math.floor(math.random()*TILE_SIZE/4-TILE_SIZE/8)
					houseType = math.random(4)
	
					col = {r = math.random(40)-20, g = 0, b = 0}
					if houseType == 1 then
						transparentPaste( shadows, IMAGE_HOUSE01_SHADOW, (i+offsetX)*TILE_SIZE+randX-26, (j+offsetY)*TILE_SIZE+randY-26, nil, groundData)
						transparentPaste( objects, IMAGE_HOUSE01, (i+offsetX)*TILE_SIZE+randX, (j+offsetY)*TILE_SIZE+randY, col, groundData )
					elseif houseType == 2 then
						transparentPaste( shadows, IMAGE_HOUSE02_SHADOW, (i+offsetX)*TILE_SIZE+randX-26, (j+offsetY)*TILE_SIZE+randY-26, nil, groundData )
						transparentPaste( objects, IMAGE_HOUSE02, (i+offsetX)*TILE_SIZE+randX, (j+offsetY)*TILE_SIZE+randY, col, groundData )
					elseif houseType == 3 then
						transparentPaste( shadows, IMAGE_HOUSE03_SHADOW, (i+offsetX)*TILE_SIZE+randX-26, (j+offsetY)*TILE_SIZE+randY-26, nil, groundData )
						transparentPaste( objects, IMAGE_HOUSE03, (i+offsetX)*TILE_SIZE+randX, (j+offsetY)*TILE_SIZE+randY, col, groundData )
					elseif houseType == 4 then
						transparentPaste( shadows, IMAGE_HOUSE04_SHADOW, (i+offsetX)*TILE_SIZE+randX-26, (j+offsetY)*TILE_SIZE+randY-26, nil, groundData )
						transparentPaste( objects, IMAGE_HOUSE04, (i+offsetX)*TILE_SIZE+randX, (j+offsetY)*TILE_SIZE+randY, col, groundData )
					end
				elseif m[i][j] == "S" then
					transparentPaste( shadows, IMAGE_HOTSPOT01_SHADOW, (i+offsetX)*TILE_SIZE-26, (j+offsetY)*TILE_SIZE-26, nil, groundData )
					transparentPaste( objects, IMAGE_HOTSPOT01, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "PS" then	-- pie store...
					transparentPaste( shadows, IMAGE_HOTSPOT01_SHADOW, (i+offsetX)*TILE_SIZE-26, (j+offsetY)*TILE_SIZE-26, nil, groundData )
					transparentPaste( objects, IMAGE_HOTSPOT_PIESTORE, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "HO" then	-- home
					transparentPaste( shadows, IMAGE_HOTSPOT01_SHADOW, (i+offsetX)*TILE_SIZE-26, (j+offsetY)*TILE_SIZE-26, nil, groundData )
					transparentPaste( objects, IMAGE_HOTSPOT_HOME, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "SC" then	-- school
					transparentPaste( shadows, IMAGE_HOTSPOT01_SHADOW, (i+offsetX)*TILE_SIZE-26, (j+offsetY)*TILE_SIZE-26, nil, groundData )
					transparentPaste( objects, IMAGE_HOTSPOT_SCHOOL, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "PL" then	-- playground
					transparentPaste( shadows, IMAGE_HOTSPOT01_SHADOW, (i+offsetX)*TILE_SIZE-26, (j+offsetY)*TILE_SIZE-26, nil, groundData )
					transparentPaste( objects, IMAGE_HOTSPOT_PLAYGROUND, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				end
			end
		end
			--shadows:paste(IMAGE_GROUND, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE)
			--objects:paste(IMAGE_GROUND, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE)
		if checkAborted() then
			return
		end
	end
end


-- Foilage
if not NO_TREES then

	for i = startX,endX,1 do		-- randomly place trees/bushes etc
		for j = startY,endY,1 do
			if (not m[i] or not m[i][j]) and math.random(7) == 1 then
				numTries = math.random(3)+1
				for k = 1, numTries do
					col = {r = math.random(20)-10, g = math.random(40)-30, b = 0}
					randX, randY = TILE_SIZE/4+math.floor(math.random()*TILE_SIZE-TILE_SIZE/2), TILE_SIZE/4+math.floor(math.random()*TILE_SIZE-TILE_SIZE/2)
					
					if i == startX then randX = math.max(0, randX) end
					if j == startY then randY = math.max(0, randY) end
					if i == endX then randX = math.min(TILE_SIZE-IMAGE_BUSH01_SHADOW:getWidth(), randX) end
					if j == endY then randY = math.min(TILE_SIZE-IMAGE_BUSH01_SHADOW:getHeight(), randY) end
					transparentPaste( shadows, IMAGE_BUSH01_SHADOW, (i+offsetX)*TILE_SIZE+randX, (j+offsetY)*TILE_SIZE+randY, nil, groundData )
					transparentPaste( objects, IMAGE_BUSH01, (i+offsetX)*TILE_SIZE+randX, (j+offsetY)*TILE_SIZE+randY, col, groundData )
				end
			end
			if checkAborted() then
				return
			end
		end
	end

	local treetype = 0
	for i = startX,endX,1 do		-- randomly place trees/bushes etc
		for j = startY,endY,1 do
			if (not m[i] or not m[i][j]) and math.random(3) == 1 then
				numTries = math.random(5)+1
				for k = 1, numTries do
					randX, randY = math.floor(math.random()*TILE_SIZE-TILE_SIZE/2), math.floor(math.random()*TILE_SIZE-TILE_SIZE/2)
					treetype = math.random(3)
		
					col = {r = math.random(20)-10, g = math.random(40)-20, b = 0}
					if treetype == 1 then
						s = IMAGE_TREE01_SHADOW
						o = IMAGE_TREE01
					elseif treetype == 2 then
						s = IMAGE_TREE02_SHADOW
						o = IMAGE_TREE02
					else
						s = IMAGE_TREE03_SHADOW
						o = IMAGE_TREE03
					end
					
					if i == startX then randX = math.max(0, randX) end
					if j == startY then randY = math.max(0, randY) end
					if i == endX then randX = math.min(TILE_SIZE-s:getWidth(), randX) end
					if j == endY then randY = math.min(TILE_SIZE-s:getHeight(), randY) end
					
					transparentPaste( shadows, s, (i+offsetX)*TILE_SIZE+randX, (j+offsetY)*TILE_SIZE+randY, nil, groundData )
					transparentPaste( objects, o, (i+offsetX)*TILE_SIZE+randX, (j+offsetY)*TILE_SIZE+randY, col, groundData)
				end
			end
			if checkAborted() then
				return
			end
		end
	end
end

thisThread:set("groundData", ground)
thisThread:set("shadowData", shadows)
thisThread:set("objectData", objects)
thisThread:set("status", "done")
return




--[[ old:
function paste( dest, source, x, y )
	i = math.max(x, 0)/TILE_SIZE
	j = math.max(y, 0)/TILE_SIZE
	imgID_X = math.floor(i/MAX_IMG_SIZE)
	imgID_Y = math.floor(j/MAX_IMG_SIZE)
	if dest[imgID_X][imgID_Y] ~= nil then
		dest[imgID_X][imgID_Y]:paste( source, x-imgID_X*MAX_IMG_SIZE_PX, y-imgID_Y*MAX_IMG_SIZE_PX )
	end
end

highlightList = {}
thisThread:set("percentage", 0)
--shadowData = love.image.newImageData((curMap.width+2)*TILE_SIZE, (curMap.height+2)*TILE_SIZE)		-- objects map
--objectData = love.image.newImageData((curMap.width+2)*TILE_SIZE, (curMap.height+2)*TILE_SIZE)		-- objects map

if NO_TREES then
	percentageStep = 100/((curMap.height+2)*(curMap.width+2))
else
	percentageStep = 100/((curMap.height+2)*(curMap.width+2)*3)
end

for i = 0,curMap.width+1,1 do
	for j = 0,curMap.height+1,1 do
		if i == 0 and j == 0 then
			paste( groundData, IMAGE_GROUND_TOPLEFT, (i)*TILE_SIZE, (j)*TILE_SIZE )
		elseif i == 0 and j == curMap.height+1 then
			paste( groundData, IMAGE_GROUND_BOTTOMLEFT, (i)*TILE_SIZE, (j)*TILE_SIZE )
		elseif i == curMap.width+1 and j == 0 then
			paste( groundData, IMAGE_GROUND_TOPRIGHT, (i)*TILE_SIZE, (j)*TILE_SIZE )
		elseif i == curMap.width+1 and j == curMap.height+1 then
			paste( groundData, IMAGE_GROUND_BOTTOMRIGHT, (i)*TILE_SIZE, (j)*TILE_SIZE )
		elseif i == 0 then
			paste( groundData, IMAGE_GROUND_LEFT, (i)*TILE_SIZE, (j)*TILE_SIZE )
		elseif i == curMap.width+1 then
			paste( groundData, IMAGE_GROUND_RIGHT, (i)*TILE_SIZE, (j)*TILE_SIZE )
		elseif j == 0 then
			paste( groundData, IMAGE_GROUND_TOP, (i)*TILE_SIZE, (j)*TILE_SIZE )
		elseif j == curMap.height+1 then
			paste( groundData, IMAGE_GROUND_BOTTOM, (i)*TILE_SIZE, (j)*TILE_SIZE )
		else
			paste( groundData, IMAGE_GROUND, (i)*TILE_SIZE, (j)*TILE_SIZE )
		end
		--col = {r = math.random(10)-5, g = math.random(10)-5, b = 0}
		--transparentPaste( groundData, IMAGE_GROUND, (i)*TILE_SIZE, (j)*TILE_SIZE, col)
		--if updatePercentage() == false then return end
	end
end

--thisThread:set("status", "houses and rails")
threadSendStatus( thisThread,"houses and rails")

local houseType = 0
for i = 0,curMap.width+1,1 do
	for j = 0,curMap.height+1,1 do
		if curMap[i][j] == "H" then
			randX, randY = math.floor(math.random()*TILE_SIZE/4-TILE_SIZE/8), math.floor(math.random()*TILE_SIZE/4-TILE_SIZE/8)
			houseType = math.random(4)
	
			col = {r = math.random(40)-20, g = 0, b = 0}
			if houseType == 1 then
				transparentPaste( shadowData, IMAGE_HOUSE01_SHADOW, (i)*TILE_SIZE+randX-26, (j)*TILE_SIZE+randY-26, nil, groundData)
				--paste( objectData, IMAGE_HOUSE01, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY )
				transparentPaste( objectData, IMAGE_HOUSE01, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, col, groundData )
			elseif houseType == 2 then
				transparentPaste( shadowData, IMAGE_HOUSE02_SHADOW, (i)*TILE_SIZE+randX-26, (j)*TILE_SIZE+randY-26, nil, groundData )
				--paste( objectData, IMAGE_HOUSE02, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY )
				transparentPaste( objectData, IMAGE_HOUSE02, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, col, groundData )
			elseif houseType == 3 then
				transparentPaste( shadowData, IMAGE_HOUSE03_SHADOW, (i)*TILE_SIZE+randX-26, (j)*TILE_SIZE+randY-26, nil, groundData )
				--paste( objectData, IMAGE_HOUSE03, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY )
				transparentPaste( objectData, IMAGE_HOUSE03, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, col, groundData )
			elseif houseType == 4 then
				transparentPaste( shadowData, IMAGE_HOUSE04_SHADOW, (i)*TILE_SIZE+randX-26, (j)*TILE_SIZE+randY-26, nil, groundData )
				--paste( objectData, IMAGE_HOUSE04, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY )
				transparentPaste( objectData, IMAGE_HOUSE04, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, col, groundData )
			end
		elseif curMap[i][j] == "S" then
			transparentPaste( shadowData, IMAGE_HOTSPOT01_SHADOW, (i)*TILE_SIZE-26, (j)*TILE_SIZE-26, nil, groundData )
			transparentPaste( objectData, IMAGE_HOTSPOT01, (i)*TILE_SIZE, (j)*TILE_SIZE, nil, groundData )
			table.insert(highlightList, {frame = math.random(10), x = (i)*TILE_SIZE + 2, y = (j)*TILE_SIZE + 2})
			table.insert(highlightList, {frame = math.random(10), x = (i)*TILE_SIZE + 96, y = (j)*TILE_SIZE + 2})
			table.insert(highlightList, {frame = math.random(10), x = (i)*TILE_SIZE + 2, y = (j)*TILE_SIZE + 96})
			table.insert(highlightList, {frame = math.random(10), x = (i)*TILE_SIZE + 96, y = (j)*TILE_SIZE + 96})
		elseif curMap[i][j] == "C" then
			img = getRailImage( curMapRailTypes[i][j] )		-- get the image corresponding the rail type at this position
			if img then transparentPaste( groundData, img, (i)*TILE_SIZE, (j)*TILE_SIZE, nil, groundData ) end
		elseif curMap[i][j] == "PS" then	-- pie store...
			transparentPaste( shadowData, IMAGE_HOTSPOT01_SHADOW, (i)*TILE_SIZE-26, (j)*TILE_SIZE-26, nil, groundData )
			transparentPaste( objectData, IMAGE_HOTSPOT_PIESTORE, (i)*TILE_SIZE, (j)*TILE_SIZE, nil, groundData )
		elseif curMap[i][j] == "HO" then	-- home
			transparentPaste( shadowData, IMAGE_HOTSPOT01_SHADOW, (i)*TILE_SIZE-26, (j)*TILE_SIZE-26, nil, groundData )
			transparentPaste( objectData, IMAGE_HOTSPOT_HOME, (i)*TILE_SIZE, (j)*TILE_SIZE, nil, groundData )
		elseif curMap[i][j] == "SC" then	-- school
			transparentPaste( shadowData, IMAGE_HOTSPOT01_SHADOW, (i)*TILE_SIZE-26, (j)*TILE_SIZE-26, nil, groundData )
			transparentPaste( objectData, IMAGE_HOTSPOT_SCHOOL, (i)*TILE_SIZE, (j)*TILE_SIZE, nil, groundData )
		elseif curMap[i][j] == "PL" then	-- playground
			transparentPaste( shadowData, IMAGE_HOTSPOT01_SHADOW, (i)*TILE_SIZE-26, (j)*TILE_SIZE-26, nil, groundData )
			transparentPaste( objectData, IMAGE_HOTSPOT_PLAYGROUND, (i)*TILE_SIZE, (j)*TILE_SIZE, nil, groundData )
		end

		if updatePercentage() == false then return end
	end
end



if not NO_TREES then
	--thisThread:set("status", "bushes")
	threadSendStatus( thisThread,"bushes")
	for i = 0,curMap.width+1,1 do		-- randomly place trees/bushes etc
		for j = 0,curMap.height+1,1 do
			if not curMap[i][j] and math.random(7) == 1 then
				numTries = math.random(3)+1
				for k = 1, numTries do
					col = {r = math.random(20)-10, g = math.random(40)-30, b = 0}
					randX, randY = TILE_SIZE/4+math.floor(math.random()*TILE_SIZE-TILE_SIZE/2), TILE_SIZE/4+math.floor(math.random()*TILE_SIZE-TILE_SIZE/2)
					transparentPaste( shadowData, IMAGE_BUSH01_SHADOW, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, nil, groundData )
					transparentPaste( objectData, IMAGE_BUSH01, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, col, groundData )
				end
			end

			if updatePercentage() == false then return end
		end
	end
--		thisThread:set("status", "trees")

	threadSendStatus( thisThread,"trees")


	local treetype = 0
	for i = 0,curMap.width+1,1 do		-- randomly place trees/bushes etc
		for j = 0,curMap.height+1,1 do
			if not curMap[i][j] and math.random(3) == 1 then
				numTries = math.random(5)+1
				for k = 1, numTries do
					randX, randY = math.floor(math.random()*TILE_SIZE-TILE_SIZE/2), math.floor(math.random()*TILE_SIZE-TILE_SIZE/2)
					treetype = math.random(3)
		
					col = {r = math.random(20)-10, g = math.random(40)-20, b = 0}
					if treetype == 1 then
						transparentPaste( shadowData, IMAGE_TREE01_SHADOW, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, nil, groundData )
						transparentPaste( objectData, IMAGE_TREE01, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, col, groundData)
					elseif treetype == 2 then
						transparentPaste( shadowData, IMAGE_TREE02_SHADOW, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, nil, groundData )
						transparentPaste( objectData, IMAGE_TREE02, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, col, groundData)
					else
						transparentPaste( shadowData, IMAGE_TREE03_SHADOW, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, nil, groundData )
						transparentPaste( objectData, IMAGE_TREE03, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, col, groundData)
					end
				end
			end

			if updatePercentage() == false then return end
		end
	end
end
]]--

