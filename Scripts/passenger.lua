local passenger = {}

local passengerList = {}

passengerPositions = {}

MAX_NUM_PASSENGERS = 50
local numPassengersTotal = 1

local passengerImage = love.graphics.newImage("Images/Passenger.png")

function passenger.new()
	if curMap and #passengerList < MAX_NUM_PASSENGERS then
		local sIndex = math.random(#curMap.railList)
		local dIndex = math.random(#curMap.railList-1)
		if dIndex == sIndex then
			dIndex = dIndex + 1		-- don't allow destination to be the same as the origin.
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
		
		for i = 1,#passengerList+1 do
			if passengerList[i] == nil then
				passengerList[i] = {
						name = "Passenger" .. numPassengersTotal,
						tileX = curMap.railList[sIndex].x,
						tileY = curMap.railList[sIndex].y,		-- holds the tile position when not riding a train
						destX = curMap.railList[dIndex].x,
						destY = curMap.railList[dIndex].y,		-- the tile the passenger wants to go to
						x = x,	-- position on tile
						y = y,
						curX = x,
						curY = y,
						image = passengerImage,
						angle = math.random()*math.pi*2
						}
				table.insert( passengerPositions[passengerList[i].tileX][passengerList[i].tileY], passengerList[i] )
				numPassengersTotal = numPassengersTotal + 1
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
			for k, v in pairs(passengerPositions[p.tileX][p.tileY]) do		-- remove me from the field so that I can't be picked up again:
				if v == p then
					passengerPositions[p.tileX][p.tileY][k] = nil
					break
				end
			end
			train.curPassenger = p
			p.train = train
			break
		end
	end
end

function passenger.init( max )
	MAX_NUM_PASSENGERS = max
	passengerList = {}
	numPassengersTotal = 1
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
			end
		else
			love.graphics.setColor(0,0,0,120)
			love.graphics.draw(p.image, x-4, y+6)--, p.angle, 1,1, p.image:getWidth()/2, p.image:getHeight()/2)
			love.graphics.setColor(64,255,128,255)	-- draw passenger green if he's reached his destination.
		end
		
		love.graphics.draw(p.image, x, y)--, p.angle, 1,1, p.image:getWidth()/2, p.image:getHeight()/2)
			
		love.graphics.setColor(255,255,255,255)
		love.graphics.print(p.name, x, y + 20)
	end
end

return passenger
