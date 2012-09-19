local map = {}

curMap = nil

TILE_SIZE = 128		-- DO NOT CHANGE! (unless you change all the images as well)

local occupied = {}

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

function removeTs()
	for i = 1,curMap.height,1 do
		for j = 1,curMap.width,1 do
			if curMap[i][j] == "T" then
				curMap[i][j] = nil
			end
		end
	end
end

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

function calculateRailTypes()
	if curMap then
		for i = 1,curMap.width do
			for j = 1,curMap.height do
				curMapRailTypes[i][j] = getRailType(i,j)
			end
		end
	end
end

function map.generate(width, height)
	if width < 4 then
		print("Minimum width is 4!")
		width = 4
	end
	if height < 4 then
		print("Minimum height is 4!")
		height = 4
	end
	
	curMap = setmetatable({width=width, height=height}, map_mt)
	--occupied = {}
	curMapRailTypes = {}
	
	for i = 0,height+1 do
		curMap[i] = {}
		--occupied[i] = {}
		curMapRailTypes[i] = {}
		--for j=1,width do
			--occupied[i][j] = {}
		--end
	end
	
	generateRailRectangles()
	map.print("Raw map:")
	clearLargeJunctions()
	
	connectLooseEnds()
	
	calculateRailTypes()
	
	placeHouses()
end


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
	pathNE[2] = {x=72,y=56}
	pathNE[3] = {x=128,y=79}
	pathEN = {}
	pathEN[1] = {x=128,y=48}
	pathEN[2] = {x=93,y=35}
	pathEN[3] = {x=79,y=0}
	
	pathES = {}
	pathES[1] = {x=128,y=48}
	pathES[2] = {x=71,y=72}
	pathES[3] = {x=48,y=128}
	pathSE = {}
	pathSE[1] = {x=79,y=128}
	pathSE[2] = {x=92,y=93}
	pathSE[3] = {x=128,y=79}
	
	pathSW = {}
	pathSW[1] = {x=79,y=128}
	pathSW[2] = {x=55,y=71}
	pathSW[3] = {x=0,y=48}
	pathWS = {}
	pathWS[1] = {x=0,y=79}
	pathWS[2] = {x=34,y=92}
	pathWS[3] = {x=48,y=128}
	
	pathWN = {}
	pathWN[1] = {x=0,y=79}
	pathWN[2] = {x=55,y=55}
	pathWN[3] = {x=79,y=0}
	pathNW = {}
	pathNW[1] = {x=48,y=0}
	pathNW[2] = {x=35,y=34}
	pathNW[3] = {x=0,y=48}
	
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
		return 1	-- NS
	end
	if curMap[i-1][j] == "C" and curMap[i+1][j] == "C" and curMap[i][j-1] ~= "C" and curMap[i][j+1] ~= "C" then
		return 2	-- EW
	end
	
	--curves
	if curMap[i-1][j] == "C" and curMap[i+1][j] ~= "C" and curMap[i][j-1] == "C" and curMap[i][j+1] ~= "C" then
		return 3	-- NW
	end
	if curMap[i-1][j] == "C" and curMap[i+1][j] ~= "C" and curMap[i][j-1] ~= "C" and curMap[i][j+1] == "C" then
		return 4	-- SW
	end
	if curMap[i-1][j] ~= "C" and curMap[i+1][j] == "C" and curMap[i][j-1] == "C" and curMap[i][j+1] ~= "C" then
		return 5	-- NE
	end
	if curMap[i-1][j] ~= "C" and curMap[i+1][j] == "C" and curMap[i][j-1] ~= "C" and curMap[i][j+1] == "C" then
		return 6	-- ES
	end
	
	--junctions
	if curMap[i-1][j] == "C" and curMap[i+1][j] == "C" and curMap[i][j-1] == "C" and curMap[i][j+1] ~= "C" then
		return 7	-- NEW
	end
	if curMap[i-1][j] ~= "C" and curMap[i+1][j] == "C" and curMap[i][j-1] == "C" and curMap[i][j+1] == "C" then
		return 8	-- NES
	end
	if curMap[i-1][j] == "C" and curMap[i+1][j] == "C" and curMap[i][j-1] ~= "C" and curMap[i][j+1] == "C" then
		return 9	-- ESW
	end
	if curMap[i-1][j] == "C" and curMap[i+1][j] ~= "C" and curMap[i][j-1] == "C" and curMap[i][j+1] == "C" then
		return 10	-- NSW
	end
	
	if curMap[i-1][j] == "C" and curMap[i+1][j] == "C" and curMap[i][j-1] == "C" and curMap[i][j+1] == "C" then
		return 11	-- NESW
	end
	
	--turn around
	if curMap[i-1][j] == "C" and curMap[i+1][j] ~= "C" and curMap[i][j-1] ~= "C" and curMap[i][j+1] ~= "C" then
		return 12	-- W
	end
	if curMap[i-1][j] ~= "C" and curMap[i+1][j] == "C" and curMap[i][j-1] ~= "C" and curMap[i][j+1] ~= "C" then
		return 13	-- E
	end
	if curMap[i-1][j] ~= "C" and curMap[i+1][j] ~= "C" and curMap[i][j-1] == "C" and curMap[i][j+1] ~= "C" then
		return 14	-- N
	end
	if curMap[i-1][j] ~= "C" and curMap[i+1][j] ~= "C" and curMap[i][j-1] ~= "C" and curMap[i][j+1] == "C" then
		return 15	-- S
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



function addBackground(x, y, r, g, b, a)
	return r*a+50,g*a+90,b*a+50,255
end

function transparentPaste(dest, source, destX, destY)
	--print(destX, destY, dest:getPointer(), source:getPointer())
	local rs,gs,bs,as,rd,gd,bd,ad
	for x = 1,source:getWidth()-1 do 
		for y = 1,source:getHeight()-1 do
			rs,gs,bs,as = source:getPixel(x,y)
			rd,gd,bd,ad = dest:getPixel(destX+x, destY+y)
			if as == 0 then
				dest:setPixel(destX+x, destY+y, rd, gd, bd, 255)
			else
				r = rs*as/255 + rd*ad/255*(255-as)/255
				g = gs*as/255 + gd*ad/255*(255-as)/255
				b = bs*as/255 + bd*ad/255*(255-as)/255
				dest:setPixel(destX+x, destY+y, r,g,b, 255)
			end
		end
	end
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

--[[
function map.setOccupied( i, j, dir )
	if occupied[i][j][dir] then
		error("Error: Map tile allready occupied!", i, j, dir)
	else
		occupied[i][j][dir] = true
	end
end
function map.getOccupied( i, j, dir )
	return occupied[i][j][dir]
end]]--

function map.setPaths()
	curMapPaths = {}
	for i = 1,curMap.height do
		curMapPaths[i] = {}
	end
	for i = 1,curMap.height do
		for j = 1, curMap.width do
			if curMap[i][j] == "C" then
				curMapPaths[i] = createPath(curMapRailTypes[i][j])
			end
		end
	end
end

return map
