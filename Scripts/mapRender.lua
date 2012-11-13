
thisThread = love.thread.getThread()

require("love.image")
require("love.filesystem")
require("Scripts/TSerial")
require("Scripts/imageManipulation")
curMap = TSerial.unpack(thisThread:demand("curMap"))
curMapRailTypes = TSerial.unpack(thisThread:demand("curMapRailTypes"))
TILE_SIZE = thisThread:demand("TILE_SIZE")
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



IMAGE_HOTSPOT01 = love.image.newImageData("Images/HotSpot1.png")
IMAGE_HOTSPOT01_SHADOW = love.image.newImageData("Images/HotSpot1_Shadow.png")

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

thisThread:set("percentage", -2)

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

local percentageStep = 0
local renderingPercentage = 0

function updatePercentage()
	renderingPercentage = renderingPercentage + percentageStep
	thisThread:set("percentage", renderingPercentage)
end

thisThread:set("status", "ground")

if curMap then
	local renderingPercentage = 0
	highlightList = {}
	thisThread:set("percentage", 0)
	groundData = love.image.newImageData((curMap.width+2)*TILE_SIZE, (curMap.height+2)*TILE_SIZE)		-- ground map
	shadowData = love.image.newImageData((curMap.width+2)*TILE_SIZE, (curMap.height+2)*TILE_SIZE)		-- objects map
	objectData = love.image.newImageData((curMap.width+2)*TILE_SIZE, (curMap.height+2)*TILE_SIZE)		-- objects map
	
	percentageStep = 100/((curMap.height+2)*(curMap.width+2)*3)
	
	for i = 0,curMap.width+1,1 do
		for j = 0,curMap.height+1,1 do
			groundData:paste( IMAGE_GROUND, (i)*TILE_SIZE, (j)*TILE_SIZE )
			--col = {r = math.random(10)-5, g = math.random(10)-5, b = 0}
			--transparentPaste( groundData, IMAGE_GROUND, (i)*TILE_SIZE, (j)*TILE_SIZE, col)
			--updatePercentage()
		end
	end
	
	thisThread:set("status", "houses and rails")
	
	local houseType = 0
	for i = 0,curMap.width+1,1 do
		for j = 0,curMap.height+1,1 do
			if curMap[i][j] == "H" then
				randX, randY = math.floor(math.random()*TILE_SIZE/4-TILE_SIZE/8), math.floor(math.random()*TILE_SIZE/4-TILE_SIZE/8)
				houseType = math.random(4)
				
				col = {r = math.random(40)-20, g = 0, b = 0}
				if houseType == 1 then
					transparentPaste( shadowData, IMAGE_HOUSE01_SHADOW, (i)*TILE_SIZE+randX-26, (j)*TILE_SIZE+randY-26 )
					transparentPaste( objectData, IMAGE_HOUSE01, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, col )
				elseif houseType == 2 then
					transparentPaste( shadowData, IMAGE_HOUSE02_SHADOW, (i)*TILE_SIZE+randX-26, (j)*TILE_SIZE+randY-26 )
					transparentPaste( objectData, IMAGE_HOUSE02, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, col )
				elseif houseType == 3 then
					transparentPaste( shadowData, IMAGE_HOUSE03_SHADOW, (i)*TILE_SIZE+randX-26, (j)*TILE_SIZE+randY-26 )
					transparentPaste( objectData, IMAGE_HOUSE03, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, col )
				elseif houseType == 4 then
					transparentPaste( shadowData, IMAGE_HOUSE04_SHADOW, (i)*TILE_SIZE+randX-26, (j)*TILE_SIZE+randY-26 )
					transparentPaste( objectData, IMAGE_HOUSE04, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, col )
				end
			elseif curMap[i][j] == "S" then
				transparentPaste( shadowData, IMAGE_HOTSPOT01_SHADOW, (i)*TILE_SIZE-26, (j)*TILE_SIZE-26 )
				transparentPaste( objectData, IMAGE_HOTSPOT01, (i)*TILE_SIZE, (j)*TILE_SIZE )
				table.insert(highlightList, {frame = math.random(10), x = (i)*TILE_SIZE + 2, y = (j)*TILE_SIZE + 2})
				table.insert(highlightList, {frame = math.random(10), x = (i)*TILE_SIZE + 96, y = (j)*TILE_SIZE + 2})
				table.insert(highlightList, {frame = math.random(10), x = (i)*TILE_SIZE + 2, y = (j)*TILE_SIZE + 96})
				table.insert(highlightList, {frame = math.random(10), x = (i)*TILE_SIZE + 96, y = (j)*TILE_SIZE + 96})
			elseif curMap[i][j] == "C" then
				img = getRailImage( curMapRailTypes[i][j] )		-- get the image corresponding the rail type at this position
				if img then transparentPaste( groundData, img, (i)*TILE_SIZE, (j)*TILE_SIZE ) end
			end
			
			updatePercentage()
		end
	end
	
	thisThread:set("status", "bushes")

	for i = 0,curMap.width+1,1 do		-- randomly place trees/bushes etc
		for j = 0,curMap.height+1,1 do
			if not curMap[i][j] and math.random(7) == 1 then
				numTries = math.random(3)+1
				for k = 1, numTries do
					col = {r = math.random(20)-10, g = math.random(40)-30, b = 0}
					randX, randY = TILE_SIZE/4+math.floor(math.random()*TILE_SIZE-TILE_SIZE/2), TILE_SIZE/4+math.floor(math.random()*TILE_SIZE-TILE_SIZE/2)
					transparentPaste( shadowData, IMAGE_BUSH01_SHADOW, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY )
					transparentPaste( objectData, IMAGE_BUSH01, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, col )
				end
			end
			
			updatePercentage()
		end
	end
	
	thisThread:set("status", "trees")
	
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
						transparentPaste( shadowData, IMAGE_TREE01_SHADOW, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY )
						transparentPaste( objectData, IMAGE_TREE01, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, col)
					elseif treetype == 2 then
						transparentPaste( shadowData, IMAGE_TREE02_SHADOW, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY )
						transparentPaste( objectData, IMAGE_TREE02, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, col)
					else
						transparentPaste( shadowData, IMAGE_TREE03_SHADOW, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY )
						transparentPaste( objectData, IMAGE_TREE03, (i)*TILE_SIZE+randX, (j)*TILE_SIZE+randY, col)
					end
				end
			end
			
			updatePercentage()
		end
	end
	
	thisThread:set("groundData", groundData)
	thisThread:set("shadowData", shadowData)
	thisThread:set("objectData", objectData)
	thisThread:set("highlightList", TSerial.pack(highlightList))
	
	thisThread:set("status", "done")
	--[[for i = 0,curMap.height+1,1 do
		for j = 0,curMap.width+1,1 do
			if curMap[i][j] == "H" then
				data:paste( IMAGE_HOUSE, (i)*TILE_SIZE, (j)*TILE_SIZE )
			elseif curMap[i][j] == "S" then
				data:paste( IMAGE_HOTSPOT1, (i)*TILE_SIZE, (j)*TILE_SIZE )
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
	end]]--
end

return

