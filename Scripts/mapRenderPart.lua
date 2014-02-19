--thisThread = love.thread.getThread()
--
args = {...}

channelIn = args[1]
channelOut = args[2]
m = TSerial.unpack(args[3])
curMapRailTypes = TSerial.unpack(args[4])
startCoordinateX = args[5]
startCoordinateY = args[6]
region = args[7]
seed = args[8] + startCoordinateX + startCoordinateY

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

--[[m = TSerial.unpack(thisThread:demand("map"))
curMapRailTypes = TSerial.unpack(thisThread:demand("curMapRailTypes"))
startCoordinateX = thisThread:demand("startCoordinateX")
startCoordinateY = thisThread:demand("startCoordinateY")
region = thisThread:get("region")
seed = thisThread:demand("seed") + startCoordinateX + startCoordinateY]]

function checkAborted()
	if abort then
		return true
	end
	packet = channelIn:pop()
	if packet and packet.key == "abort" then
		abort = true
		return true
	end
end

-- new random generator:
do
	local p = 7907 -- 11 in wikipedia example, but has a too short cycle
	local q = 7919 -- 19 in wikipedia example
	local s = 3
	local xn = s

	assert(p%4==3)
	assert(q%4==3)

	function randombit()
		xn = xn^2 % p*q
		return xn % 2
	end

	function myRandomseed(seed)
		xn = seed
	end

	function myRandom(a, b)
		local n = 0
		for i=0,31 do
			n = n*2 + randombit()
		end


		if not a and not b then
			return n/4294967295	-- 4294967295 is the largest number possible
		elseif not b then
			a,b = 1,a
		end
		
		if a > b then
			error("Invalid range in random function" .. a .. b)
		end
		
		
		diff = b-a + 1
		n = a + n % diff
		
		return n
	end
end

myRandomseed(seed)


-- Ground:
if region == "Urban" then
	IMAGE_GROUND = love.image.newImageData("Images/Ground_Stone.png")
	IMAGE_GROUND_LEFT = love.image.newImageData("Images/BorderLeft_Stone.png")
	IMAGE_GROUND_RIGHT = love.image.newImageData("Images/BorderRight_Stone.png")
	IMAGE_GROUND_BOTTOM = love.image.newImageData("Images/BorderBottom_Stone.png")
	IMAGE_GROUND_TOP = love.image.newImageData("Images/BorderTop_Stone.png")
	IMAGE_GROUND_TOPLEFT = love.image.newImageData("Images/BorderTopLeft_Stone.png")
	IMAGE_GROUND_TOPRIGHT = love.image.newImageData("Images/BorderTopRight_Stone.png")
	IMAGE_GROUND_BOTTOMLEFT = love.image.newImageData("Images/BorderBottomLeft_Stone.png")
	IMAGE_GROUND_BOTTOMRIGHT = love.image.newImageData("Images/BorderBottomRight_Stone.png")
else
	IMAGE_GROUND = love.image.newImageData("Images/Ground.png")
	IMAGE_GROUND_LEFT = love.image.newImageData("Images/BorderLeft.png")
	IMAGE_GROUND_RIGHT = love.image.newImageData("Images/BorderRight.png")
	IMAGE_GROUND_BOTTOM = love.image.newImageData("Images/BorderBottom.png")
	IMAGE_GROUND_TOP = love.image.newImageData("Images/BorderTop.png")
	IMAGE_GROUND_TOPLEFT = love.image.newImageData("Images/BorderTopLeft.png")
	IMAGE_GROUND_TOPRIGHT = love.image.newImageData("Images/BorderTopRight.png")
	IMAGE_GROUND_BOTTOMLEFT = love.image.newImageData("Images/BorderBottomLeft.png")
	IMAGE_GROUND_BOTTOMRIGHT = love.image.newImageData("Images/BorderBottomRight.png")
end

IMAGE_PARK = love.image.newImageData("Images/Park_Stone.png")

--Rails:
if region == "Urban" then
	IMAGE_RAIL_NS = love.image.newImageData("Images/Rail_NS_Stone.png")
	IMAGE_RAIL_EW = love.image.newImageData("Images/Rail_EW_Stone.png")
	IMAGE_RAIL_NE = love.image.newImageData("Images/Rail_NE_Stone.png")
	IMAGE_RAIL_ES = love.image.newImageData("Images/Rail_ES_Stone.png")
	IMAGE_RAIL_SW = love.image.newImageData("Images/Rail_SW_Stone.png")
	IMAGE_RAIL_NW = love.image.newImageData("Images/Rail_NW_Stone.png")
	IMAGE_RAIL_NEW = love.image.newImageData("Images/Rail_NEW_Stone.png")
	IMAGE_RAIL_NES = love.image.newImageData("Images/Rail_NES_Stone.png")
	IMAGE_RAIL_ESW = love.image.newImageData("Images/Rail_ESW_Stone.png")
	IMAGE_RAIL_NSW = love.image.newImageData("Images/Rail_NSW_Stone.png")
	IMAGE_RAIL_NESW = love.image.newImageData("Images/Rail_NESW_Stone.png")
	IMAGE_RAIL_N = love.image.newImageData("Images/Rail_N_Stone.png")
	IMAGE_RAIL_E = love.image.newImageData("Images/Rail_E_Stone.png")
	IMAGE_RAIL_S = love.image.newImageData("Images/Rail_S_Stone.png")
	IMAGE_RAIL_W = love.image.newImageData("Images/Rail_W_Stone.png")
else
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
end


--Hotspots/special Buildings:
IMAGE_HOTSPOT01 = love.image.newImageData("Images/HotSpot1.png")
IMAGE_HOTSPOT01_SHADOW = love.image.newImageData("Images/HotSpot1_Shadow.png")

-- Misc/Tutorial:
IMAGE_HOTSPOT_HOME = love.image.newImageData("Images/HotSpot_Home.png")
IMAGE_HOTSPOT_SCHOOL = love.image.newImageData("Images/HotSpot_School.png")
IMAGE_HOTSPOT_PLAYGROUND = love.image.newImageData("Images/Hotspot_Playground.png")
IMAGE_HOTSPOT_PLAYGROUND_SHADOW = love.image.newImageData("Images/Hotspot_Playground_Shadow.png")
IMAGE_HOTSPOT_PIESTORE = love.image.newImageData("Images/Hotspot_Piestore.png")
IMAGE_HOTSPOT_BOOKSTORE = love.image.newImageData("Images/Hotspot_Bookstore.png")
IMAGE_HOTSPOT_STORE = love.image.newImageData("Images/Hotspot_Store.png")
IMAGE_HOTSPOT_STORE_SHADOW = love.image.newImageData("Images/Hotspot_Store_Shadow.png")
IMAGE_HOTSPOT_CINEMA = love.image.newImageData("Images/Hotspot_Cinema.png")
IMAGE_HOTSPOT_CINEMA_SHADOW = love.image.newImageData("Images/Hotspot_Cinema_Shadow.png")

IMAGE_HOTSPOT_SCHOOL00 = love.image.newImageData("Images/Hotspot_School-0-0.png")
IMAGE_HOTSPOT_SCHOOL10 = love.image.newImageData("Images/Hotspot_School-1-0.png")
IMAGE_HOTSPOT_SCHOOL01 = love.image.newImageData("Images/Hotspot_School-0-1.png")
IMAGE_HOTSPOT_SCHOOL11 = love.image.newImageData("Images/Hotspot_School-1-1.png")
IMAGE_HOTSPOT_SCHOOL_SHADOW00 = love.image.newImageData("Images/Hotspot_School_Shadow-0-0.png")
IMAGE_HOTSPOT_SCHOOL_SHADOW10 = love.image.newImageData("Images/Hotspot_School_Shadow-1-0.png")
IMAGE_HOTSPOT_SCHOOL_SHADOW01 = love.image.newImageData("Images/Hotspot_School_Shadow-0-1.png")
IMAGE_HOTSPOT_SCHOOL_SHADOW11 = love.image.newImageData("Images/Hotspot_School_Shadow-1-1.png")

IMAGE_HOTSPOT_HOSPITAL00 = love.image.newImageData("Images/Hotspot_Hospital-0-0.png")
IMAGE_HOTSPOT_HOSPITAL10 = love.image.newImageData("Images/Hotspot_Hospital-1-0.png")
IMAGE_HOTSPOT_HOSPITAL01 = love.image.newImageData("Images/Hotspot_Hospital-0-1.png")
IMAGE_HOTSPOT_HOSPITAL11 = love.image.newImageData("Images/Hotspot_Hospital-1-1.png")
IMAGE_HOTSPOT_HOSPITAL_SHADOW00 = love.image.newImageData("Images/Hotspot_Hospital_Shadow-0-0.png")
IMAGE_HOTSPOT_HOSPITAL_SHADOW10 = love.image.newImageData("Images/Hotspot_Hospital_Shadow-1-0.png")
IMAGE_HOTSPOT_HOSPITAL_SHADOW01 = love.image.newImageData("Images/Hotspot_Hospital_Shadow-0-1.png")
IMAGE_HOTSPOT_HOSPITAL_SHADOW11 = love.image.newImageData("Images/Hotspot_Hospital_Shadow-1-1.png")


--Environment/Misc:
IMAGE_HOUSE01 = love.image.newImageData("Images/House1.png")
IMAGE_HOUSE01_SHADOW = love.image.newImageData("Images/House1_Shadow.png")
IMAGE_HOUSE02 = love.image.newImageData("Images/House2.png")
IMAGE_HOUSE02_SHADOW = love.image.newImageData("Images/House2_Shadow.png")
IMAGE_HOUSE03 = love.image.newImageData("Images/House3.png")
IMAGE_HOUSE03_SHADOW = love.image.newImageData("Images/House3_Shadow.png")
IMAGE_HOUSE04 = love.image.newImageData("Images/House4.png")
IMAGE_HOUSE04_SHADOW = love.image.newImageData("Images/House4_Shadow.png")

IMAGE_HOUSE05 = love.image.newImageData("Images/House5.png")
IMAGE_HOUSE05_SHADOW = love.image.newImageData("Images/House5_Shadow.png")
IMAGE_HOUSE06 = love.image.newImageData("Images/House6.png")
IMAGE_HOUSE06_SHADOW = love.image.newImageData("Images/House6_Shadow.png")
IMAGE_HOUSE07 = love.image.newImageData("Images/House7.png")
IMAGE_HOUSE07_SHADOW = love.image.newImageData("Images/House7_Shadow.png")

IMAGE_HOUSE01_L11 = love.image.newImageData("Images/House_1_Large-0-0.png")
IMAGE_HOUSE01_L_SHADOW11 = love.image.newImageData("Images/House_1_Large_Shadow-0-0.png")
IMAGE_HOUSE01_L12 = love.image.newImageData("Images/House_1_Large-0-1.png")
IMAGE_HOUSE01_L_SHADOW12 = love.image.newImageData("Images/House_1_Large_Shadow-0-1.png")
IMAGE_HOUSE02_L11 = love.image.newImageData("Images/House_2_Large-0-0.png")
IMAGE_HOUSE02_L_SHADOW11 = love.image.newImageData("Images/House_2_Large_Shadow-0-0.png")
IMAGE_HOUSE02_L12 = love.image.newImageData("Images/House_2_Large-0-1.png")
IMAGE_HOUSE02_L_SHADOW12 = love.image.newImageData("Images/House_2_Large_Shadow-0-1.png")
IMAGE_HOUSE03_L11 = love.image.newImageData("Images/House_3_Large-0-0.png")
IMAGE_HOUSE03_L_SHADOW11 = love.image.newImageData("Images/House_3_Large_Shadow-0-0.png")
IMAGE_HOUSE03_L21 = love.image.newImageData("Images/House_3_Large-1-0.png")
IMAGE_HOUSE03_L_SHADOW21 = love.image.newImageData("Images/House_3_Large_Shadow-1-0.png")
IMAGE_HOUSE04_L11 = love.image.newImageData("Images/House_4_Large-0-0.png")
IMAGE_HOUSE04_L_SHADOW11 = love.image.newImageData("Images/House_4_Large_Shadow-0-0.png")
IMAGE_HOUSE04_L21 = love.image.newImageData("Images/House_4_Large-1-0.png")
IMAGE_HOUSE04_L_SHADOW21 = love.image.newImageData("Images/House_4_Large_Shadow-1-0.png")

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
				--if not m[i][j] and myRandom(2) == 1 then
					--ground:paste(IMAGE_PARK, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE)
				--end
				
				-- Houses etc:
				if m[i][j] == "H" then
					randX, randY = math.floor(myRandom()*TILE_SIZE/4-TILE_SIZE/8), math.floor(myRandom()*TILE_SIZE/4-TILE_SIZE/8)
					if i == endX then randX = -TILE_SIZE/8 end
					if j == endY then randY = -TILE_SIZE/8 end
					if i == startX then randX = TILE_SIZE/8 end
					if j == startX then randY = TILE_SIZE/8 end
					if region == "Urban" then
						houseType = myRandom(3)
						col = {r = myRandom(40)-20, g = 0, b = 0}
						if houseType == 1 then
							transparentPaste( shadows, IMAGE_HOUSE05_SHADOW, (i+offsetX)*TILE_SIZE+randX, (j+offsetY)*TILE_SIZE+randY, nil, groundData)
							transparentPaste( objects, IMAGE_HOUSE05, (i+offsetX)*TILE_SIZE+randX, (j+offsetY)*TILE_SIZE+randY, col, groundData )
						elseif houseType == 2 then
							transparentPaste( shadows, IMAGE_HOUSE06_SHADOW, (i+offsetX)*TILE_SIZE+randX, (j+offsetY)*TILE_SIZE+randY, nil, groundData )
							transparentPaste( objects, IMAGE_HOUSE06, (i+offsetX)*TILE_SIZE+randX, (j+offsetY)*TILE_SIZE+randY, col, groundData )
						elseif houseType == 3 then
							transparentPaste( shadows, IMAGE_HOUSE07_SHADOW, (i+offsetX)*TILE_SIZE+randX, (j+offsetY)*TILE_SIZE+randY, nil, groundData )
							transparentPaste( objects, IMAGE_HOUSE07, (i+offsetX)*TILE_SIZE+randX, (j+offsetY)*TILE_SIZE+randY, col, groundData )
						end
					else
						houseType = myRandom(4)
						col = {r = myRandom(40)-20, g = 0, b = 0}
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
					end
				elseif m[i][j] == "S" then
					if region == "Urban" then
						choice = myRandom(5)
					else
						choice = myRandom(4)
					end
					if choice == 1 then
						transparentPaste( shadows, IMAGE_HOTSPOT_STORE_SHADOW, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
						transparentPaste( objects, IMAGE_HOTSPOT_STORE, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					elseif choice == 2 then
						transparentPaste( shadows, IMAGE_HOTSPOT_STORE_SHADOW, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
						transparentPaste( objects, IMAGE_HOTSPOT_PIESTORE, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					elseif choice == 3 then
						transparentPaste( shadows, IMAGE_HOTSPOT_STORE_SHADOW, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
						transparentPaste( objects, IMAGE_HOTSPOT_BOOKSTORE, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					elseif choice == 4 then
						transparentPaste( shadows, IMAGE_HOTSPOT_PLAYGROUND_SHADOW, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
						transparentPaste( objects, IMAGE_HOTSPOT_PLAYGROUND, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					else
						transparentPaste( shadows, IMAGE_HOTSPOT_CINEMA_SHADOW, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE,nil, groundData )
						transparentPaste( objects, IMAGE_HOTSPOT_CINEMA, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					end
				elseif m[i][j] == "PS" then	-- pie store...
					transparentPaste( shadows, IMAGE_HOTSPOT_STORE_SHADOW, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOTSPOT_PIESTORE, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "STORE" then	-- store...
					transparentPaste( shadows, IMAGE_HOTSPOT_STORE_SHADOW, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOTSPOT_STORE, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "HO" then	-- home
					transparentPaste( shadows, IMAGE_HOTSPOT01_SHADOW, (i+offsetX)*TILE_SIZE-26, (j+offsetY)*TILE_SIZE-26, nil, groundData )
					transparentPaste( objects, IMAGE_HOTSPOT_HOME, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "SCHOOL11" then	-- school
					transparentPaste( shadows, IMAGE_HOTSPOT_SCHOOL_SHADOW00, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOTSPOT_SCHOOL00, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "SCHOOL12" then	-- school
					transparentPaste( shadows, IMAGE_HOTSPOT_SCHOOL_SHADOW01, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOTSPOT_SCHOOL01, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "SCHOOL21" then	-- school
					transparentPaste( shadows, IMAGE_HOTSPOT_SCHOOL_SHADOW10, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOTSPOT_SCHOOL10, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "SCHOOL22" then	-- school
					transparentPaste( shadows, IMAGE_HOTSPOT_SCHOOL_SHADOW11, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOTSPOT_SCHOOL11, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "HOSPITAL11" then	-- HOSPITAL
					transparentPaste( shadows, IMAGE_HOTSPOT_HOSPITAL_SHADOW00, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOTSPOT_HOSPITAL00, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "HOSPITAL12" then	-- HOSPITAL
					transparentPaste( shadows, IMAGE_HOTSPOT_HOSPITAL_SHADOW01, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOTSPOT_HOSPITAL01, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "HOSPITAL21" then	-- HOSPITAL
					transparentPaste( shadows, IMAGE_HOTSPOT_HOSPITAL_SHADOW10, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOTSPOT_HOSPITAL10, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "HOSPITAL22" then	-- HOSPITAL
					transparentPaste( shadows, IMAGE_HOTSPOT_HOSPITAL_SHADOW11, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOTSPOT_HOSPITAL11, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "HOUSE_1_LARGE11" then	-- HOSPITAL
					transparentPaste( shadows, IMAGE_HOUSE01_L_SHADOW11, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOUSE01_L11, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "HOUSE_1_LARGE12" then	-- HOSPITAL
					transparentPaste( shadows, IMAGE_HOUSE01_L_SHADOW12, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOUSE01_L12, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "HOUSE_2_LARGE11" then	-- HOSPITAL
					transparentPaste( shadows, IMAGE_HOUSE02_L_SHADOW11, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOUSE02_L11, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "HOUSE_2_LARGE12" then	-- HOSPITAL
					transparentPaste( shadows, IMAGE_HOUSE02_L_SHADOW12, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOUSE02_L12, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "HOUSE_3_LARGE11" then	-- HOSPITAL
					transparentPaste( shadows, IMAGE_HOUSE03_L_SHADOW11, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOUSE03_L11, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "HOUSE_3_LARGE21" then	-- HOSPITAL
					transparentPaste( shadows, IMAGE_HOUSE03_L_SHADOW21, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOUSE03_L21, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "HOUSE_4_LARGE11" then	-- HOSPITAL
					transparentPaste( shadows, IMAGE_HOUSE04_L_SHADOW11, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOUSE04_L11, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "HOUSE_4_LARGE21" then	-- HOSPITAL
					transparentPaste( shadows, IMAGE_HOUSE04_L_SHADOW21, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
					transparentPaste( objects, IMAGE_HOUSE04_L21, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
				elseif m[i][j] == "PL" then	-- playground
					transparentPaste( shadows, IMAGE_HOTSPOT_PLAYGROUND_SHADOW, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE, nil, groundData )
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

	if region == "Urban" then
		local treetype = 0
		for i = startX,endX,1 do		-- randomly place trees/bushes etc
			for j = startY,endY,1 do
				if (not m[i] or not m[i][j]) and myRandom(4) == 1 then
					if i ~= 0 and i ~= m.width+1 and j ~= 0 and j~= m.height+1 then
						ground:paste(IMAGE_PARK, (i+offsetX)*TILE_SIZE, (j+offsetY)*TILE_SIZE)
					end
					numTries = myRandom(5)+1
					for k = 1, numTries do
						randX, randY = math.floor(myRandom()*TILE_SIZE-TILE_SIZE/2), math.floor(myRandom()*TILE_SIZE-TILE_SIZE/2)
						treetype = myRandom(3)
		
						col = {r = myRandom(20)-10, g = myRandom(10)-10, b = 0}
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
	else
		for i = startX,endX,1 do		-- randomly place trees/bushes etc
			for j = startY,endY,1 do
				if (not m[i] or not m[i][j]) and myRandom(4) == 1 then
					numTries = myRandom(3)+1
					for k = 1, numTries do
						col = {r = myRandom(20)-10, g = myRandom(40)-30, b = 0}
						randX, randY = TILE_SIZE/4+math.floor(myRandom()*TILE_SIZE-TILE_SIZE/2), TILE_SIZE/4+math.floor(myRandom()*TILE_SIZE-TILE_SIZE/2)
					
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
				if (not m[i] or not m[i][j]) and myRandom(3) == 1 then
					numTries = myRandom(5)+1
					for k = 1, numTries do
						randX, randY = math.floor(myRandom()*TILE_SIZE-TILE_SIZE/2), math.floor(myRandom()*TILE_SIZE-TILE_SIZE/2)
						treetype = myRandom(3)
		
						col = {r = myRandom(20)-10, g = myRandom(40)-20, b = 0}
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
end

channelOut:push({key="groundData", ground})
channelOut:push({key="shadowData", shadow})
channelOut:push({key="objectData", objects})
channelOut:push({key="status", "done"})

--[[thisThread:set("groundData", ground)
thisThread:set("shadowData", shadows)
thisThread:set("objectData", objects)
thisThread:set("status", "done")]]
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
		--col = {r = myRandom(10)-5, g = myRandom(10)-5, b = 0}
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
			randX, randY = math.floor(myRandom()*TILE_SIZE/4-TILE_SIZE/8), math.floor(myRandom()*TILE_SIZE/4-TILE_SIZE/8)
			houseType = myRandom(4)
	
			col = {r = myRandom(40)-20, g = 0, b = 0}
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
			table.insert(highlightList, {frame = myRandom(10), x = (i)*TILE_SIZE + 2, y = (j)*TILE_SIZE + 2})
			table.insert(highlightList, {frame = myRandom(10), x = (i)*TILE_SIZE + 96, y = (j)*TILE_SIZE + 2})
			table.insert(highlightList, {frame = myRandom(10), x = (i)*TILE_SIZE + 2, y = (j)*TILE_SIZE + 96})
			table.insert(highlightList, {frame = myRandom(10), x = (i)*TILE_SIZE + 96, y = (j)*TILE_SIZE + 96})
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
			if not curMap[i][j] and myRandom(7) == 1 then
				numTries = myRandom(3)+1
				for k = 1, numTries do
					col = {r = myRandom(20)-10, g = myRandom(40)-30, b = 0}
					randX, randY = TILE_SIZE/4+math.floor(myRandom()*TILE_SIZE-TILE_SIZE/2), TILE_SIZE/4+math.floor(myRandom()*TILE_SIZE-TILE_SIZE/2)
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
			if not curMap[i][j] and myRandom(3) == 1 then
				numTries = myRandom(5)+1
				for k = 1, numTries do
					randX, randY = math.floor(myRandom()*TILE_SIZE-TILE_SIZE/2), math.floor(myRandom()*TILE_SIZE-TILE_SIZE/2)
					treetype = myRandom(3)
		
					col = {r = myRandom(20)-10, g = myRandom(40)-20, b = 0}
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

