local passenger = {}

local passengerList = {}

passengerPositions = {}

MAX_NUM_PASSENGERS = 50
VIP_RATIO = 1/2
MAX_VIP_TIME = 30

local numPassengersTotal = 1
local numPassengersDroppedOff = 0

local passengerImage = love.graphics.newImage("Images/Passenger.png")
local passengerVIPImage = love.graphics.newImage("Images/VIP.png")
local passengerVIPClock = love.graphics.newImage("Images/Timebar.png")

function passenger.new()
	if curMap and #passengerList < MAX_NUM_PASSENGERS then
		local sIndex = math.random(#curMap.railList)
		local dIndex = math.random(#curMap.railList)
		
		while curMap.railList[dIndex].x == curMap.railList[sIndex].x and curMap.railList[dIndex].y == curMap.railList[sIndex].y do
			dIndex = dIndex + 1		-- don't allow destination to be the same as the origin.
			sIndex = math.random(#curMap.railList)
			dIndex = math.random(#curMap.railList)
		end
		
		local x, y = 0,0
		local randPos = math.random(2)
		if randPos == 1 then
			x, y = 0,0
		elseif randPos == 2 then
			x, y = TILE_SIZE - passengerImage:getWidth(), 0
		elseif randPos == 3 then
			x, y = 0, TILE_SIZE - passengerImage:getHeight()
		elseif randPos == 4 then
			x, y = TILE_SIZE - passengerImage:getWidth(), TILE_SIZE - passengerImage:getHeight()
		end
		
		x = x + math.sin(os.time()+love.timer.getDelta())*15
		y = y + math.cos(os.time()+love.timer.getDelta())*15
		local vip = false
		if VIP_RATIO > 0 and VIP_RATIO < 1 and math.random(1/VIP_RATIO) == 1 then
			vip = true
		end
		
		for i = 1,#passengerList+1 do
			if passengerList[i] == nil then
				passengerList[i] = {
						name = "P" .. numPassengersTotal,
						tileX = curMap.railList[sIndex].x,
						tileY = curMap.railList[sIndex].y,		-- holds the tile position when not riding a train
						destX = curMap.railList[dIndex].x,
						destY = curMap.railList[dIndex].y,		-- the tile the passenger wants to go to
						x = x,	-- position on tile
						y = y,
						curX = x,
						curY = y,
						image = passengerImage,
						angle = math.random()*math.pi*2,
						}
				if vip then
					--passengerList[i].image = passengerVIPImage
					passengerList[i].vip = true
					passengerList[i].name = passengerList[i].name .. "[VIP]"
					passengerList[i].markZ = love.timer.getDelta()
					passengerList[i].vipTime = MAX_VIP_TIME
					passengerList[i].sprite = love.graphics.newSpriteBatch(passengerVIPClock)
				end
				
				table.insert( passengerPositions[passengerList[i].tileX][passengerList[i].tileY], passengerList[i] )
				numPassengersTotal = numPassengersTotal + 1
				
				stats.newPassenger(passengerList[i], curMap.roundTime)
				
				ai.newPassenger(passengerList[i])
				
				
				break
			end
		end
	end
end

-- check if there's one or more passengers at the given location. If so, return their names.
function passenger.find(x, y)
	local foundPassengers = {}
	for k, p in pairs(passengerPositions[x][y]) do
		table.insert(foundPassengers, p.name)
	end
	if #foundPassengers == 0 then
		return nil
	end
	printTable(foundPassengers)
	return foundPassengers
end

function passenger.boardTrain(train, name)		-- try to board the train
	print("boarding:", name)
	for k, p in pairs(passengerList) do
		if p.name == name then	-- found the passenger in the list!
			for k, v in pairs(passengerPositions[p.tileX][p.tileY]) do		-- remove me from the field so that I can't be picked up twice:
				if v == p then
					passengerPositions[p.tileX][p.tileY][k] = nil
					break
				end
			end
			
			stats.passengerPickedUp(p)
			train.curPassenger = p
			p.train = train
			stats.passengersPickedUp( train.aiID, train.ID )
			break
		end
	end
end

-- The ai will pass a pseudo-train (trunced down version which is visible to the ai) of the train which should dropp off a passenger.
-- This function then searches for the corresponding train and lets the passenger get off.
function passenger.leaveTrain(aiID)

	return function (pseudoTrain)
		tr = train.getByID(aiID, pseudoTrain.ID)
		if tr then
			tr.curPassenger.train = nil
			tr.curPassenger.tileX, tr.curPassenger.tileY = tr.tileX, tr.tileY		-- place passenger onto the tile the train's currently on
			
			stats.droppedOff( aiID, tr.ID )
			
			print("dropped off: " .. tr.curPassenger.name)
			stats.passengerDroppedOff( tr.curPassenger )
			
			-- check if I have reached my destination
			if tr.curPassenger.tileX == tr.curPassenger.destX and tr.curPassenger.tileY == tr.curPassenger.destY then
				tr.curPassenger.reachedDestination = true
				
				stats.broughtToDestination( aiID, tr.ID, tr.curPassenger.vip )
				if tr.curPassenger.vip == true and tr.curPassenger.vipTime > 0 then
					stats.addMoney( aiID, MONEY_VIP )
				else
					stats.addMoney( aiID, MONEY_PASSENGER )
				end
				
				numPassengersDroppedOff = numPassengersDroppedOff + 1
				if numPassengersDroppedOff >= MAX_NUM_PASSENGERS then
					map.endRound()
				end
			else		-- put them back into the list to make sure they can be picked up again!
				table.insert( passengerPositions[tr.curPassenger.tileX][tr.curPassenger.tileY], tr.curPassenger )
			end
			
			tr.curPassenger = nil
		end
	end
end

function passenger.init( max )

	vipClockImages = {}
	for i = 1,11,1 do
		vipClockImages[i] = love.graphics.newQuad( (i-1)*32,0, 32, 32, 352, 32 )
	end

	MAX_NUM_PASSENGERS = max
	passengerList = {}
	numPassengersTotal = 1
	numPassengersDroppedOff = 0
	passengerPositions = {}
	if curMap then
		for i = 1, curMap.width do
			passengerPositions[i] = {}
			for j = 1, curMap.height do
				passengerPositions[i][j] = {}
			end
		end
	end
end

function passenger.showAll(dt)
	local x, y = 0,0
	love.graphics.setColor(255,255,255,255)
	for k, p in pairs(passengerList) do
		if p.train then		-- if I'm riding a train	
			x = p.train.x - p.image:getWidth()/2 + p.train.tileX*TILE_SIZE
			y =  p.train.y - p.image:getHeight()/2	 + p.train.tileY*TILE_SIZE
		else	-- if I'm just standing around...
			x = p.tileX*TILE_SIZE + p.x
			y = p.tileY*TILE_SIZE + p.y
		end
		
		if p.vip then
			love.graphics.setColor(255,255,255,200)
			p.vipTime = clamp(p.vipTime - dt*timeFactor,-10,MAX_VIP_TIME)
			num = clamp(1+math.floor((MAX_VIP_TIME-p.vipTime)/MAX_VIP_TIME*10),1,11)
			love.graphics.drawq(passengerVIPClock,vipClockImages[num], x-6, y-6)
			if p.vipTime < -15 then
				p.vip = false
			end
		end
		
		-- draw passenger:
		if not p.reachedDestination then
			if p.train then
				if love.keyboard.isDown(" ") then 
					love.graphics.setColor(255,255,128,100)
					love.graphics.line(x + p.image:getWidth()/2, y + p.image:getHeight()/2, p.destX*TILE_SIZE + TILE_SIZE/2, p.destY*TILE_SIZE + TILE_SIZE/2)
				end
				
				love.graphics.setColor(255,255,128,255)
			else
				if love.keyboard.isDown(" ") then 
					love.graphics.setColor(64,128,255,100)
					love.graphics.line(x + p.image:getWidth()/2, y + p.image:getHeight()/2, p.destX*TILE_SIZE + TILE_SIZE/2, p.destY*TILE_SIZE + TILE_SIZE/2)
				end
				love.graphics.setColor(0,0,0,120)
				love.graphics.draw(p.image, x-4, y+6)--, p.angle, 1,1, p.image:getWidth()/2, p.image:getHeight()/2)
				love.graphics.setColor(64,128,255,255)
				
				love.graphics.draw(p.image, x, y, 0, p.scale, p.scale)--, p.angle, 1,1, p.image:getWidth()/2, p.image:getHeight()/2)
			end
		else
			love.graphics.setColor(0,0,0,120)
			love.graphics.draw(p.image, x-4, y+6)--, p.angle, 1,1, p.image:getWidth()/2, p.image:getHeight()/2)
			love.graphics.setColor(64,255,128,255)	-- draw passenger green if he's reached his destination.
			love.graphics.draw(p.image, x, y, 0, p.scale, p.scale)--, p.angle, 1,1, p.image:getWidth()/2, p.image:getHeight()/2)
		end
		
		if p.vip then
			
			love.graphics.setColor(255,255,255,255)
			p.markZ = p.markZ + dt*timeFactor*5
			c = math.sin(p.markZ)^2
			love.graphics.draw(passengerVIPImage, x + 4, y - 15 - 10*c, 0, 1+c/10, 1+c/10)
		end
			
		love.graphics.setColor(255,255,255,100)
		love.graphics.print(p.name, x, y + 20)
	end
end

return passenger
