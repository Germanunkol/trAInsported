local passenger = {}

local passengerList = {}

passengerPositions = {}

local numPassengersTotal = 1
numPassengersDroppedOff = 0

if not DEDICATED then
	passengerImage = love.graphics.newImage("Images/Passenger.png")
	passengerVIPImage = love.graphics.newImage("Images/VIP.png")
	passengerVIPClock = love.graphics.newImage("Images/Timebar.png")
	
	PASSENGER_IMAGE_WIDTH = passengerImage:getWidth()
	PASSENGER_IMAGE_HEIGHT = passengerImage:getHeight()
else
	PASSENGER_IMAGE_WIDTH = 20
	PASSENGER_IMAGE_HEIGHT = 19
end

function randPassengerPos()
	local x, y = 0,0
	local randPos = math.random(4)
	if randPos == 1 then
		x, y = PASSENGER_IMAGE_WIDTH, PASSENGER_IMAGE_HEIGHT
	elseif randPos == 2 then
		x, y = TILE_SIZE - PASSENGER_IMAGE_WIDTH, PASSENGER_IMAGE_HEIGHT
	elseif randPos == 3 then
		x, y = PASSENGER_IMAGE_WIDTH, TILE_SIZE - PASSENGER_IMAGE_HEIGHT
	elseif randPos == 4 then
		x, y = TILE_SIZE - PASSENGER_IMAGE_WIDTH, TILE_SIZE - PASSENGER_IMAGE_HEIGHT
	end
	x = x + math.sin(os.time()+love.timer.getDelta())*15
	y = y + math.cos(os.time()+love.timer.getDelta())*15
	return x, y
end

function passenger.clearList()
	for i,p in pairs(passengerList) do
		if not p.train then
			passengerList[i] = nil
		end
	end
end

function passenger.new( givenX, givenY, givenDestX, givenDestY )
	
	if givenX then dontCreateVIP = true end
	
	if curMap and (#passengerList < MAX_NUM_PASSENGERS or givenX) then	-- allow more than MAX_NUM_PASSENGERS if forced by tutorial.
		local sIndex = math.random(#curMap.railList)
		local dIndex = math.random(#curMap.railList)
		local s = 5
		
		-- check to see if the given coordinates are a rail:
		if givenX and givenY then
			s = 0
			for k, r in pairs(curMap.railList) do
				if r.x == givenX and r.y == givenY then
					sIndex = k
					break
				end
			end
		end
		if givenDestX and givenDestY then
			for k, r in pairs(curMap.railList) do
				if r.x == givenDestX and r.y == givenDestY then
					dIndex = k
					break
				end
			end
		end
		
		while curMap.railList[dIndex].x == curMap.railList[sIndex].x and curMap.railList[dIndex].y == curMap.railList[sIndex].y do
			dIndex = dIndex + 1		-- don't allow destination to be the same as the origin.
			sIndex = math.random(#curMap.railList)
			dIndex = math.random(#curMap.railList)
		end
		
		local x, y = 0, 0

		x,y = randPassengerPos()

		xEnd, yEnd = randPassengerPos()
		
		local vip = false
		if VIP_RATIO > 0 and VIP_RATIO < 1 and math.random(1/VIP_RATIO) == 1 and not dontCreateVIP then
			vip = true
		end
		
		for i = 1,#passengerList+1 do
			if passengerList[i] == nil then
				passengerList[i] = {
						name = "P" .. numPassengersTotal,
						
						-- holds the tile position when not riding a train:
						tileX = curMap.railList[sIndex].x,
						tileY = curMap.railList[sIndex].y,
						
						-- the tile the passenger wants to go to:
						destX = curMap.railList[dIndex].x,
						destY = curMap.railList[dIndex].y,
						
						x = x,	-- position on tile
						y = y,
						xEnd = xEnd,	-- dest position on tile
						yEnd = yEnd,
						curX = x,
						curY = y,
						image = passengerImage,
						angle = math.random()*math.pi*2,
						selected = s
						}
				if vip then
					--passengerList[i].image = passengerVIPImage
					passengerList[i].vip = true
					passengerList[i].name = passengerList[i].name .. "[VIP]"
					passengerList[i].markZ = love.timer.getDelta()
					passengerList[i].vipTime = MAX_VIP_TIME
					if not DEDICATED then
						passengerList[i].sprite = love.graphics.newSpriteBatch(passengerVIPClock)
					end
					local num = math.random(#vipSpeach)
					if vipSpeach[num] then		-- just to make sure
						passengerList[i].speach = vipSpeach[num]
					end
				else
					local num = math.random(#passengerSpeach)
					if passengerSpeach[num] then		-- just to make sure
						passengerList[i].speach = passengerSpeach[num]
					end
				end
				if not passengerList[i].speach then
					passengerList[i].speach = " "
				end
				
				table.insert( passengerPositions[passengerList[i].tileX][passengerList[i].tileY], passengerList[i] )
				
				if DEDICATED then
					sendStr = "P_NEW:"
					sendStr = sendStr .. passengerList[i].name .. ","
					if passengerList[i].vip then
						sendStr = sendStr .. "true,"
						sendStr = sendStr .. passengerList[i].vipTime .. ","
					else
						sendStr = sendStr .. "false,"
						sendStr = sendStr .. "0,"
					end
					sendStr = sendStr .. passengerList[i].tileX .. ","
					sendStr = sendStr .. passengerList[i].tileY .. ","
					sendStr = sendStr .. passengerList[i].destX .. ","
					sendStr = sendStr .. passengerList[i].destY .. ","
					sendStr = sendStr .. passengerList[i].x .. ","
					sendStr = sendStr .. passengerList[i].y .. ","
					sendStr = sendStr .. passengerList[i].xEnd .. ","
					sendStr = sendStr .. passengerList[i].yEnd .. ","
					sendStr = sendStr .. passengerList[i].speach .. ","
					sendMapUpdate(sendStr)
				end
				
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
		table.insert(foundPassengers, {name=p.name, destX=p.destX, destY=p.destY})
	end
	if #foundPassengers == 0 then
		return nil
	end
	return foundPassengers
end

function passenger.boardTrain(train, name)		-- try to board the train
	--print("boarding:", name)
	for k, p in pairs(passengerList) do
		if p.name == name then	-- found the passenger in the list!
			for k, v in pairs(passengerPositions[p.tileX][p.tileY]) do		-- remove me from the field so that I can't be picked up twice:
				if v == p then
					passengerPositions[p.tileX][p.tileY][k] = nil
					stats.passengerPickedUp(p)
					train.curPassenger = p
					train.stop = train.stop + 1
					train.passengerArrived = false
					p.train = train
					stats.passengersPickedUp( train.aiID, train.ID )
					ai.passengerBoarded(train, name)
			
					if DEDICATED then
						if train.stop == 1 then
							sendStr = "TRAIN_STOP:"
							sendStr = sendStr .. train.aiID .. ","
							sendStr = sendStr .. train.name .. ","
							sendStr = sendStr .. train.stop .. ","
							sendMapUpdate(sendStr)
						end
						sendStr = "P_PICKUP:"
						sendStr = sendStr .. train.aiID .. ","
						sendStr = sendStr .. train.name .. ","
						sendStr = sendStr .. p.name .. ","
						sendMapUpdate(sendStr)
					end
			
					if tutorial and tutorial.passengerPickupEvent then
						tutorial.passengerPickupEvent()
					end
					break
				end
			end
			break
		end
	end
end

-- The ai will pass a pseudo-train (trunced down version which is visible to the ai) of the train which should dropp off a passenger.
-- This function then searches for the corresponding train and lets the passenger get off.
function passenger.leaveTrain(aiID)

	return function (pseudoTrain)
		tr = train.getByID(aiID, pseudoTrain.ID)
		if tr and tr.curPassenger then
		
			tr.stop = tr.stop + 1
			tr.curPassenger.tileX, tr.curPassenger.tileY = tr.tileX, tr.tileY		-- place passenger onto the tile the train's currently on
			
			tr.curPassenger.gettingOff = true
			
			stats.droppedOff( aiID, tr.ID )
			
			--print("dropped off: " .. tr.curPassenger.name)
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
				
				if tutorial and tutorial.passengerDropoffCorrectlyEvent then
					tutorial.passengerDropoffCorrectlyEvent( tr.curPassenger.tileX, tr.curPassenger.tileY )
				end
			else
				ai.newPassenger(tr.curPassenger)
				if tutorial and tutorial.passengerDropoffWronglyEvent then
					tutorial.passengerDropoffWronglyEvent()
				end
			end
			
			if DEDICATED then
				if tr.stop == 1 then
					sendStr = "TRAIN_STOP:"
					sendStr = sendStr .. tr.aiID .. ","
					sendStr = sendStr .. tr.name .. ","
					sendStr = sendStr .. tr.stop .. ","
					sendMapUpdate(sendStr)
				end
				sendStr = "P_DROPOFF:"
				sendStr = sendStr .. tr.aiID .. ","
				sendStr = sendStr .. tr.name .. ","
				sendStr = sendStr .. tr.curPassenger.name .. ","
				sendStr = sendStr .. tr.curPassenger.tileX .. ","
				sendStr = sendStr .. tr.curPassenger.tileY .. ","
				if tr.curPassenger.reachedDestination == true then
					sendStr = sendStr .. "true,"
				end
				sendMapUpdate(sendStr)
			end
			
			tr.curPassenger = nil
		end
	end
end

function passenger.printAll()
	for k, p in pairs(passengerList) do
		print(k, p, p.name, p.tileX, p.tileY, p.destX, p.destY)
	end
end

function passenger.init( max )

	if not DEDICATED then
		vipClockImages = {}
		for i = 1,11,1 do
			vipClockImages[i] = love.graphics.newQuad( (i-1)*32,0, 32, 32, 352, 32 )
		end
	end

	MAX_NUM_PASSENGERS = max or 0
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

if DEDICATED then

	function passenger.showAll(dt)
		local x, y = 0,0
		--love.graphics.setColor(255,255,255,255)
		for k, p in pairs(passengerList) do
			if p.train then		-- if I'm riding a train
				if not p.onTrain then	-- getting on
					if p.train.curSpeed == 0 then
						d = vecDist(p.x, p.y, p.train.x, p.train.y)
						dX = (p.train.x-p.x)/d
						dY = (p.train.y-p.y)/d
						p.x = p.x + dX*dt*PASSENGER_SPEED
						p.y = p.y + dY*dt*PASSENGER_SPEED
				
						if d < vecDist(p.x, p.y, p.train.x, p.train.y) then
							p.onTrain = true
							p.train.stop = p.train.stop - 1
							if p.train.stop == 0 then
								sendStr = "TRAIN_STOP:"
								sendStr = sendStr .. p.train.aiID .. ","
								sendStr = sendStr .. p.train.name .. ","
								sendStr = sendStr .. p.train.stop .. ","
								sendMapUpdate(sendStr)
							end
						end
					end
					x = p.x - 10 + p.train.tileX*TILE_SIZE
					y = p.y - 9.5 + p.train.tileY*TILE_SIZE
				elseif p.gettingOff and p.train.curSpeed == 0 then
					d = vecDist(p.x, p.y, p.xEnd, p.yEnd)
					dX = (p.xEnd-p.x)/d
					dY = (p.yEnd-p.y)/d
					p.x = p.x + dX*dt*PASSENGER_SPEED
					p.y = p.y + dY*dt*PASSENGER_SPEED
			
					x = p.x - 10 + p.train.tileX*TILE_SIZE
					y = p.y - 9.5 + p.train.tileY*TILE_SIZE
			
					if d < vecDist(p.x, p.y, p.xEnd, p.yEnd) then
						p.train.stop = p.train.stop - 1
						if p.train.stop == 0 then
							sendStr = "TRAIN_STOP:"
							sendStr = sendStr .. p.train.aiID .. ","
							sendStr = sendStr .. p.train.name .. ","
							sendStr = sendStr .. p.train.stop .. ","
							sendMapUpdate(sendStr)
						end
					
						p.onTrain = false
						p.train = nil
						p.gettingOff = false
					
						if p.reachedDestination then
							passengerList[k] = nil
						else		-- put them back into the list to make sure they can be picked up again!
							table.insert( passengerPositions[p.tileX][p.tileY], p )
						end
					end
				else	-- if I'm riding the train
					p.x = p.train.x
					p.y = p.train.y
					x = p.x - 19 + p.train.tileX*TILE_SIZE
					y = p.y - 9.5 + p.train.tileY*TILE_SIZE
				end
			else	-- if I'm just standing around...
				x = p.tileX*TILE_SIZE + p.x - 10
				y = p.tileY*TILE_SIZE + p.y - 9.5
			end
		
			if p.vip then
				p.vipTime = clamp(p.vipTime - dt,-10,MAX_VIP_TIME)
				--num = clamp(1+math.floor((MAX_VIP_TIME-p.vipTime)/MAX_VIP_TIME*10),1,11)
				--love.graphics.drawq(passengerVIPClock,vipClockImages[num], x-6, y-6)
				if p.vipTime < -15 then
					p.vip = false
				end
			end
			
		end
	end
else
	function passenger.showAll(dt)
		local x, y = 0,0
		love.graphics.setColor(255,255,255,255)
		for k, p in pairs(passengerList) do
			if p.train then		-- if I'm riding a train
				if not p.onTrain then	-- getting on
					if p.train.curSpeed == 0 then
						d = vecDist(p.x, p.y, p.train.x, p.train.y)
						dX = (p.train.x-p.x)/d
						dY = (p.train.y-p.y)/d
						p.x = p.x + dX*dt*PASSENGER_SPEED
						p.y = p.y + dY*dt*PASSENGER_SPEED
				
						if d < vecDist(p.x, p.y, p.train.x, p.train.y) then
							p.onTrain = true
							p.train.stop = p.train.stop - 1
						end
					end
					x = p.x - p.image:getWidth()/2 + p.train.tileX*TILE_SIZE
					y = p.y - p.image:getHeight()/2	 + p.train.tileY*TILE_SIZE
				elseif p.gettingOff and p.train.curSpeed == 0 then
					d = vecDist(p.x, p.y, p.xEnd, p.yEnd)
					dX = (p.xEnd-p.x)/d
					dY = (p.yEnd-p.y)/d
					p.x = p.x + dX*dt*PASSENGER_SPEED
					p.y = p.y + dY*dt*PASSENGER_SPEED
			
					x = p.x - p.image:getWidth()/2 + p.train.tileX*TILE_SIZE
					y = p.y - p.image:getHeight()/2	 + p.train.tileY*TILE_SIZE
			
					if d < vecDist(p.x, p.y, p.xEnd, p.yEnd) then
						p.train.stop = p.train.stop - 1
						p.onTrain = false
						p.train = nil
						p.gettingOff = false
					
						if p.reachedDestination then
							passengerList[k] = nil
						else		-- put them back into the list to make sure they can be picked up again!
							table.insert( passengerPositions[p.tileX][p.tileY], p )
						end
					end
				else	-- if I'm riding the train
					p.x = p.train.x
					p.y = p.train.y
					x = p.x - p.image:getWidth()/2 + p.train.tileX*TILE_SIZE
					y = p.y - p.image:getHeight()/2	 + p.train.tileY*TILE_SIZE
				end
			else	-- if I'm just standing around...
				x = p.tileX*TILE_SIZE + p.x - p.image:getWidth()/2
				y = p.tileY*TILE_SIZE + p.y - p.image:getHeight()/2
			end
		
			if p.vip then
				love.graphics.setColor(255,255,255,200)
				p.vipTime = clamp(p.vipTime - dt,-10,MAX_VIP_TIME)
				num = clamp(1+math.floor((MAX_VIP_TIME-p.vipTime)/MAX_VIP_TIME*10),1,11)
				love.graphics.drawq(passengerVIPClock,vipClockImages[num], x-6, y-6)
				if p.vipTime < -15 then
					p.vip = false
				end
			end
		
			-- draw passenger:
			if not p.reachedDestination then
				if p.train and p.onTrain and not p.gettingOff then
					if love.keyboard.isDown(" ") then 
						love.graphics.setColor(255,255,128,100)
						love.graphics.line(x + p.image:getWidth()/2, y + p.image:getHeight()/2, p.destX*TILE_SIZE + TILE_SIZE/2, p.destY*TILE_SIZE + TILE_SIZE/2)
					end
				else
					if love.keyboard.isDown(" ") then 
						love.graphics.setColor(64,128,255,200)
						love.graphics.line(x + p.image:getWidth()/2, y + p.image:getHeight()/2, p.destX*TILE_SIZE + TILE_SIZE/2, p.destY*TILE_SIZE + TILE_SIZE/2)
					end
					love.graphics.setColor(0,0,0,120)
					love.graphics.draw(p.image, x-4, y+6) --, p.angle, 1,1, p.image:getWidth()/2, p.image:getHeight()/2)
					love.graphics.setColor(64,128,255,255)
				
					love.graphics.draw(p.image, x, y, 0, p.scale, p.scale) --, p.angle, 1,1, p.image:getWidth()/2, p.image:getHeight()/2)
				end
			else
				love.graphics.setColor(0,0,0,120)
				love.graphics.draw(p.image, x-4, y+6) --, p.angle, 1,1, p.image:getWidth()/2, p.image:getHeight()/2)
				love.graphics.setColor(64,255,128,255) -- draw passenger green if he's reached his destination.
				love.graphics.draw(p.image, x, y, 0, p.scale, p.scale) --, p.angle, 1,1, p.image:getWidth()/2, p.image:getHeight()/2)
			end
		
			p.renderX, p.renderY = x,y
		
			--love.graphics.setColor(255,255,255,100)
			--love.graphics.print(p.name, x, y + 20)
		end
	end

	function passenger.showVIPs(dt)
		love.graphics.setColor(255,255,255,255)
		for k, p in pairs(passengerList) do
			if p.vip then
			
				p.markZ = p.markZ + dt*5
				c = math.sin(p.markZ)^2
				love.graphics.draw(passengerVIPImage, p.renderX + 4, p.renderY - 15 - 10*c, 0, 1+c/10, 1+c/10)
			end
		end
	end

	function passenger.showSelected()
		love.graphics.setFont(FONT_SMALL)
	
		for k, p in pairs(passengerList) do
			if p.selected > 0 then
		love.graphics.setColor(255,255,255)
					love.graphics.draw(pSpeachBubble, p.renderX-SPEACH_BUBBLE_WIDTH/2+10, p.renderY + 26)
		love.graphics.setColor(0,0,0)
					love.graphics.printf(p.speach, p.renderX-SPEACH_BUBBLE_WIDTH/2+22, p.renderY + 29, 190, "center")
					p.selected = p.selected - dt
					if p.vip then
						love.graphics.printf(makeTimeReadable(p.vipTime), p.renderX-SPEACH_BUBBLE_WIDTH/2+22, p.renderY + 73, 190, "center")
					end
			end
		end
	end
end

return passenger
