local simulation = {}

local simulationRunning = false

local packetList = {}		-- stores all the events that were received from the server ()

local trainList = {}

local liveSymbolX, liveSymbolY = 0, 0

simulation.mapInQueue = false

function simulation.init()

	if map.rendering() then		-- wait until map has finished rendering, then retry.
		map.abortRendering()
		loadingScreen.reset()
	end
	
	simulationRunning = true
	
	curMapOccupiedTiles = {}
	curMapRailTypes = {}

	train.init()
	passenger.init()
	
	--loadingScreen.reset()
	
	print("REMOVED PACKET LIST 2")
	packetList = {}
	simulation.nextPacket = 1
	
	trainList = {}
	trainList[1] = {}
	trainList[2] = {}
	trainList[3] = {}
	trainList[4] = {}
	
	passengerList = {}
	liveSymbolX = (love.graphics.getWidth()-FONT_BUTTON:getWidth("LIVE MATCH"))/2
	liveSymbolY = 15
	lostConnectionSymbolX = (love.graphics.getWidth()-FONT_BUTTON:getWidth("LOST CONNECTION"))/2
	lostConnectionSymbolY = 37
	
	vipClockImages = {}
	for i = 1,11,1 do
		vipClockImages[i] = love.graphics.newQuad( (i-1)*32,0, 32, 32, 352, 32 )
	end
	
	for i = 0,simulationMap.width+1 do
		curMapRailTypes[i] = {}
		if i >= 1 and i <= simulationMap.width then 
			curMapOccupiedTiles[i] = {}
			for j = 1, simulationMap.height do
				curMapOccupiedTiles[i][j] = {}
				curMapOccupiedTiles[i][j].from = {}
				curMapOccupiedTiles[i][j].to = {}
			end
		end
	end
	
	calculateRailTypes(simulationMap)
	
	if not curMap then --and map.startupProcess() then
		map.render(simulationMap)
		newMapStarting = true
		menu.exitOnly()
	end
	
end

function simulation.isRunning()
	return simulationRunning
end

local timeUntilNextMatch = 0

function simulation.displayTimeUntilNextMatch(time, dt)
	if time then
		timeUntilNextMatch = time
	else
		if timeUntilNextMatch >= 0 then
			--statusMsg.new("Next match starts in: " .. makeTimeReadable(timeUntilNextMatch), false)
			timeUntilNextMatch = timeUntilNextMatch - dt
		end
	end
end

function simulation.runMap()
	newMapStarting = false
	stats.start(4)
	clouds.restart()
	roundEnded = false
	console.flush()
	menu.ingame()
	loadingScreen.reset()
	MAX_PAN = (math.max(simulationMap.width, simulationMap.height)*TILE_SIZE)/2		-- maximum width that the camera can move
end

function simulation.stop()

	connection.closeConnection()
	
	--mapGenerateThread = nil
	--mapRenderThread = nil
	mapImage = nil
	simulationRunning = false
	simulationMap = nil
	if curMap then
		map.endRound()
	end
end

--[[
function sortByTime(a,b)
	--print(a, b, a.event, b.event)
	if a and b and a.time and b.time and a.time < b.time then return true end
end
]]--

function addPacket(ID, text, time)
	packetList[ID] = {time=time, event = text}
	--table.sort(packetList, sortByTime)
end

function simulation.addUpdate(text)
	s, e = text:find("|")
	if not s then
		print("ERROR: No ID found in packet!")
		return
	end
	
	local ID = tonumber(text:sub(1, e-1))
	text = text:sub(e+1, #text)

	s, e = text:find("|")
	if not s then
		print("ERROR: No time stamp found in packet!")
		return
	end
	time = tonumber(text:sub(1, e-1))
	text = text:sub(e+1, #text)
	addPacket(ID, text, time)
	
	if text:find("ROUND_DETAILS:") == 1 then
		s,e = text:find("ROUND_DETAILS:")
		local tbl = seperateStrings(text:sub(e+1,#text))
		if tbl[1] ~= VERSION then
			statusMsg.new("Error: Could not match versions.\n(Your version: " .. VERSION .. ", server's version: " .. tbl[1] .. ")", true)
			simulation.stop()
		end
	end
end

function runUpdate(event, t1, t2)
	if event:find("ROUND_DETAILS:") == 1 then
		s,e = event:find("ROUND_DETAILS:")
		local tbl = seperateStrings(event:sub(e+1,#event))
		
		stats.clearWindows()
		
		GAME_TYPE = tonumber(tbl[2])
		if GAME_TYPE == GAME_TYPE_TIME then
			ROUND_TIME = tonumber(tbl[3])
		elseif GAME_TYPE == GAME_TYPE_MAX_PASSENGERS then
			MAX_NUM_PASSENGERS = tonumber(tbl[3])
		end
	elseif event:find("NEW_AI:") == 1 then
		s,e = event:find("NEW_AI:")
		local tbl = seperateStrings(event:sub(e+1,#event))
		local ID = tbl[1]
		local name = tbl[2]
		local owner = tbl[3]
		if ID and name then
			ID = tonumber(ID)
			train.renderTrainImage( name, ID )
			stats.setAIName(ID, name, owner )
		end
		return
	elseif event:find("NEW_TRAIN:") == 1 then
		s,e = event:find("NEW_TRAIN:")
		local tbl = seperateStrings(event:sub(e+1,#event))
		local ID = tbl[1]
		local name = tbl[2]
		local tileX = tbl[3]
		local tileY = tbl[4]
		local dir = tbl[5]
		if ID and name and tileX and tileY and dir then
			ID = tonumber(ID)
			tileX = tonumber(tileX)
			tileY = tonumber(tileY)
			if not trainList[ID] then
				print("ERROR: trying to add a train for player:", ID)
				return
			end
			for i=1,#trainList[ID]+1,1 do
				if not trainList[ID][i] then
			
					trainList[ID][i] = {aiID=ID, ID=i,name=name, tileX=tileX, tileY=tileY, curSpeed = 0, stop = 0}
					
					stats.addTrain( ID, trainList[ID][i] )
					
					path = map.getRailPath(tileX, tileY, dir)
					if path then
						curPathNode = math.ceil((#path-1)/2)
						trainList[ID][i].curDistTraveled = path[curPathNode].length
				
						trainList[ID][i].x = path[curPathNode].x
						trainList[ID][i].y = path[curPathNode].y
						trainList[ID][i].interpolateX = trainList[ID][i].x + trainList[ID][i].tileX*TILE_SIZE
						trainList[ID][i].interpolateY = trainList[ID][i].y + trainList[ID][i].tileY*TILE_SIZE
						trainList[ID][i].path = path
						trainList[ID][i].curNode = curPathNode
						trainList[ID][i].dir = dir
						
						trainList[ID][i].angle = 0
						trainList[ID][i].prevAngle = 0
						trainList[ID][i].curSpeed = 0
						tr = trainList[ID][i]
						if tr.path[tr.curNode+1] then
							if tr.path[tr.curNode+1].x >= tr.path[tr.curNode].x then
								tr.angle = math.atan((tr.path[tr.curNode+1].y - tr.path[tr.curNode].y)/(tr.path[tr.curNode+1].x - tr.path[tr.curNode].x)) + math.pi/2
							else
								tr.angle = math.atan((tr.path[tr.curNode+1].y - tr.path[tr.curNode].y)/(tr.path[tr.curNode+1].x - tr.path[tr.curNode].x)) - math.pi/2
							end
--							tr.angle = getAngleByDir(tr.dir)
						else
							tr.angle = getAngleByDir(tr.dir)
						end
				
						trainList[ID][i].prevAngle = trainList[ID][i].angle
										
						dx = (path[curPathNode+1].x - trainList[ID][i].x)
						dy = (path[curPathNode+1].y - trainList[ID][i].y)
						trainList[ID][i].dxPrevSign = (dx < 0)
						trainList[ID][i].dyPrevSign = (dy < 0)
					end
					break	--important, don't add again!
				end
			end
		end
		return
	elseif event:find("TRAIN_CONT:") == 1 then
		s,e = event:find("TRAIN_CONT:")
		local tbl = seperateStrings(event:sub(e+1,#event))
		ID = tbl[1]
		name = tbl[2]
		tileX = tbl[3]
		tileY = tbl[4]
		dir = tbl[5]
		if ID and name and tileX and tileY and dir then
			ID = tonumber(ID)
			tileX = tonumber(tileX)
			tileY = tonumber(tileY)			
			if trainList[ID] then
				for k, tr in pairs(trainList[ID]) do
					if tr.name == name then
						tr.tileX = tileX
						tr.tileY = tileY
						if tr.overshoot then
							tr.curDistTraveled = tr.overshoot
						else
							tr.curDistTraveled = 0
						end
						tr.path = map.getRailPath(tr.tileX, tr.tileY, dir,tr.dir)
						tr.dir = dir
						tr.curNode = 1
					
						tr.prevAngle = tr.angle
						if tr.path[tr.curNode+2] then
							if tr.path[tr.curNode+2].x >= tr.path[tr.curNode].x then
								tr.angle = math.atan((tr.path[tr.curNode+2].y - tr.path[tr.curNode].y)/(tr.path[tr.curNode+2].x - tr.path[tr.curNode].x)) + math.pi/2
							else
								tr.angle = math.atan((tr.path[tr.curNode+2].y - tr.path[tr.curNode].y)/(tr.path[tr.curNode+2].x - tr.path[tr.curNode].x)) - math.pi/2
							end
						else
							tr.angle = getAngleByDir(tr.dir)
						end
						if tr.prevAngle - tr.angle < -math.pi then
							tr.prevAngle = tr.prevAngle + 2*math.pi
						end
						if tr.prevAngle - tr.angle > math.pi then
							tr.prevAngle = tr.prevAngle - 2*math.pi
						end
				
						tr.x = tr.path[tr.curNode].x
						tr.y = tr.path[tr.curNode].y
						break
					end
				end
			end
		end
		return
	elseif event:find("TRAIN_STOP:") == 1 then
		s,e = event:find("TRAIN_STOP:")
		local tbl = seperateStrings(event:sub(e+1,#event))
		ID = tbl[1]
		name = tbl[2]
		stop = tbl[3]
		if ID and name and stop then
			ID = tonumber(ID)
			stop = tonumber(stop)
			if trainList[ID] then
				for k, tr in pairs(trainList[ID]) do
					if tr.name == name then
						tr.stop = stop
						if stop == 0 then
							if tr.curPassenger then
								if not tr.curPassenger.gettingOff then
									tr.curPassenger.onTrain = true
								else
									tr.curPassenger.onTrain = false
									tr.curPassenger.train = nil
									tr.curPassenger.gettingOff = false
				
									if tr.curPassenger.reachedDestination then
										for k, passenger in pairs(passengerList) do
											if tr.curPassenger == passenger then
												passengerList[k] = nil
											end
										end
									end
									
									tr.curPassenger = nil
								end
							end
						end
						break
					end
				end
			end
		end
		return
	elseif event:find("P_NEW:") == 1 then		-- created new Passenger
		s,e = event:find("P_NEW:")
		local tbl = seperateStrings(event:sub(e+1,#event))
		name = tbl[1]
		vip = tbl[2]
		vipTime = tbl[3]
		tileX = tbl[4]
		tileY = tbl[5]
		destX = tbl[6]
		destY = tbl[7]
		x = tbl[8]
		y = tbl[9]
		xEnd = tbl[10]
		yEnd = tbl[11]
		speach = tbl[12]
		if name and tileX and tileY then
			tileX = tonumber(tileX)
			tileY = tonumber(tileY)
			destX = tonumber(destX)
			destY = tonumber(destY)
			x = tonumber(x)
			y = tonumber(y)
			xEnd = tonumber(xEnd)
			yEnd = tonumber(yEnd)
			vipTime = tonumber(vipTime)
			if vip == "true" then 
				p = {name=name, tileX=tileX, tileY=tileY, x=x, y=y, image=passengerImage, xEnd=xEnd, yEnd=yEnd, destX=destX, destY=destY, vip=true, vipTime=vipTime, speach=speach}
			else
				p = {name=name, tileX=tileX, tileY=tileY, x=x, y=y, image=passengerImage, xEnd=xEnd, yEnd=yEnd, destX=destX, destY=destY, speach=speach}
			end
			table.insert(passengerList, p)
			stats.newPassenger(p)
		end
		return
	elseif event:find("P_PICKUP:") == 1 then		-- created new Passenger
		s,e = event:find("P_PICKUP:")
		local tbl = seperateStrings(event:sub(e+1,#event))
		ID = tbl[1]
		name = tbl[2]		--train's name
		pName = tbl[3]
		local found = false
		if ID and name and pName then
			ID = tonumber(ID)
			for k, tr in pairs(trainList[ID]) do
				if tr.name == name then
					for k, p in pairs(passengerList) do
						if p.name == pName then
							p.train = tr
							tr.curPassenger = p
							p.onTrain = false
							p.gettingOff = false
							print("PASSENGER " .. p.name .. " boarded " .. name, simulationMap.time)
							
							found = true
							
							stats.passengerPickedUp(p)
							stats.passengersPickedUp(ID, tr.ID)
						end
					end
				end
			end
		end
		if not found then print("ERROR! did not find ", ID, name, pName)
			love.event.quit()
		end
		return
	elseif event:find("P_DROPOFF:") == 1 then		-- created new Passenger
		s,e = event:find("P_DROPOFF:")
		local tbl = seperateStrings(event:sub(e+1,#event))
		ID = tbl[1]
		name = tbl[2]
		pName = tbl[3]
		tileX = tbl[4]
		tileY = tbl[5]
		reachedDestination = tbl[6]
		if ID and name and pName then
			ID = tonumber(ID)
			tileX = tonumber(tileX)
			tileY = tonumber(tileY)
			for k, tr in pairs(trainList[ID]) do
				if tr.name == name then
					for k, p in pairs(passengerList) do
						if p.name == pName then
--							p.train = tr
							p.gettingOff = true
							if tr.curPassenger == p then
								tr.curPassenger = nil
							end
							
							print("PASSENGER " .. p.name .. " left " .. name, simulationMap.time)
							
							stats.passengerDroppedOff( p )
							stats.droppedOff(ID, tr.ID)
							
							if reachedDestination == "true" then
								p.reachedDestination = true
								stats.broughtToDestination(ID, tr.ID, p.vip)
							end
							--p.train = nil
							p.tileX = tileX
							p.tileY = tileY
							
						end
					end
				end
			end
		end
		return
		--stats.generateStatWindows()
	elseif event:find("NEW_STAT:") == 1 then
		s,e = event:find("NEW_STAT:")
		stats.addStatWindow(event:sub(e+1,#event))
	elseif event:find("END_ROUND:") == 1 then		-- MUST be last packet to send/receive!
		roundEnded = true
		stats.print()
	end
end

function simulation.update(dt)

	--[[
	for i = 1, #packetList do
		if not packetList[i] then
			break
		end
		if simulationMap and packetList[i].time and simulationMap.time >= packetList[i].time then
		
			runUpdate(packetList[i].event, packetList[i].time, simulationMap.time)
			
			if packetList[i].event:find("END_ROUND:") == 1 then		--last packet? make sure to run all other remaining packets!!
				for k = 1,#packetList do
					print(packetList[k].event)
					runUpdate(packetList[k].event, packetList[k].time, simulationMap.time)
				end
				packetList = {}
				return
			end
			
			packetList[i] = nil
			for j = i, #packetList do
				packetList[j] = packetList[j+1]
			end
		else
			break
		end
	end
	]]--
	
	
	-- check if there's a packet to be run. If there is one, check again if there's more.
	--print(simulationMap, simulation.nextPacket, packetList[simulation.nextPacket], #packetList, simulationMap.time) -- packetList[simulation.nextPacket].time, simulationMap.time)
	while simulationMap and packetList[simulation.nextPacket] and packetList[simulation.nextPacket].time and simulationMap.time >= packetList[simulation.nextPacket].time do
		--print("running:", simulation.nextPacket, packetList[simulation.nextPacket].event)
		runUpdate(packetList[simulation.nextPacket].event, packetList[simulation.nextPacket].time, simulationMap.time)
		
		--last packet? make sure to run all other remaining packets!! (Otherwise statistics wouldn't be shown.)
		if packetList[simulation.nextPacket].event:find("END_ROUND:") == 1 then
			for k = simulation.nextPacket,#packetList do
				runUpdate(packetList[k].event, packetList[k].time, simulationMap.time)
			end
			print("REMOVED PACKET LIST 1")
			packetList = {}
			return
		end
		
		-- do not run again!
		packetList[simulation.nextPacket] = nil
		simulation.nextPacket = simulation.nextPacket + 1
	end
	
	
	--if changed then
	--	table.sort(packetList, sortByTime)
	--end
	
	simulation.moveAllTrains(dt)
end

local liveSymbolBlinkTime = 0

function simulation.show(dt)
	if mapImage then
		love.graphics.push()
		love.graphics.scale(camZ)
	
		love.graphics.translate(camX + love.graphics.getWidth()/(2*camZ), camY + love.graphics.getHeight()/(2*camZ))
		love.graphics.rotate(CAM_ANGLE)
		--love.graphics.rectangle("fill", -TILE_SIZE*(simulationMap.width+2)/2-120,-TILE_SIZE*(simulationMap.height+2)/2-80, TILE_SIZE*(simulationMap.width+2)+200, TILE_SIZE*(simulationMap.height+2)+200)
		--love.graphics.setColor(0,0,0, 100)
	
		love.graphics.setColor(30,10,5, 150)
		
		x = -TILE_SIZE*(simulationMap.width+2)/2 -20
		for i = 1, #mapImage do
			y = -TILE_SIZE*(simulationMap.height+2)/2 +35
			for j = 1, #mapImage[i] do
				if i == 1 or j == #mapImage[i] then
					love.graphics.draw(mapImage[i][j], x,  y)
				end
			
				y = y + mapImage[i][j]:getHeight()
				if j == #mapImage[i] then
					x = x + mapImage[i][j]:getWidth()
				end
			end
		end
		love.graphics.setColor(255,255,255, 255)
		x = -TILE_SIZE*(simulationMap.width+2)/2
		for i = 1, #mapImage do
			y = -TILE_SIZE*(simulationMap.height+2)/2
			for j = 1, #mapImage[i] do
				love.graphics.draw(mapImage[i][j], x,  y)
				love.graphics.draw(mapShadowImage[i][j], x,  y)
				love.graphics.draw(mapObjectImage[i][j], x,  y)
				y = y + mapImage[i][j]:getHeight()
				if j == #mapImage[i] then
					--love.graphics.draw(mapImage[i][j], -TILE_SIZE*(curMap.width+2)/2 -20 + (i-1)*MAX_IMG_SIZE*TILE_SIZE, -TILE_SIZE*(curMap.height+2)/2 +35 + (j-1)*MAX_IMG_SIZE*TILE_SIZE)
					x = x + mapImage[i][j]:getWidth()
				end
			end
		end
	
		love.graphics.translate(-TILE_SIZE*(simulationMap.width+2)/2, -TILE_SIZE*(simulationMap.height+2)/2)
	
		simulation.passengerShowAll(passedTime)
		simulation.trainShowAll()
--		passenger.showVIPs(passedTime)
	
		map.renderHighlights(passedTime)
	
		if not love.keyboard.isDown("i") then clouds.renderShadows(passedTime) end

		--map.drawOccupation()
		
		if love.keyboard.isDown("M") then
			map.showCoordinates(simulationMap)
		end
		
		love.graphics.pop()
		love.graphics.push()
		love.graphics.scale(camZ*1.5)
	
		love.graphics.translate(camX + love.graphics.getWidth()/(camZ*3), camY + love.graphics.getHeight()/(camZ*3))
		love.graphics.rotate(CAM_ANGLE)
		love.graphics.translate(-TILE_SIZE*(simulationMap.width+2)/2, -TILE_SIZE*(simulationMap.height+2)/2)
	
		clouds.render()
		
		love.graphics.pop()
		
	
		if showQuickHelp then quickHelp.show() end
		if showConsole then console.show() end
	
		stats.displayStatus()
		
		
		love.graphics.setFont(FONT_BUTTON)
		liveSymbolBlinkTime = liveSymbolBlinkTime + dt*2
		love.graphics.setColor(0,0,0,105*math.sin(liveSymbolBlinkTime)^2+10)
		love.graphics.print("LIVE MATCH", liveSymbolX-2, liveSymbolY+6)
		love.graphics.setColor(255,255,255,205*math.sin(liveSymbolBlinkTime)^2+50)
		love.graphics.print("LIVE MATCH", liveSymbolX, liveSymbolY)
		
		if lostConnection then
			love.graphics.setColor(0,0,0,105*math.sin(liveSymbolBlinkTime)^2+10)
			love.graphics.print("LOST CONNECTION", lostConnectionSymbolX-2, lostConnectionSymbolY+6)
			love.graphics.setColor(255,64,64,205*math.sin(liveSymbolBlinkTime)^2+50)
			love.graphics.print("LOST CONNECTION", lostConnectionSymbolX, lostConnectionSymbolY)
		end
	end
end

function simulation.trainShowAll()
	love.graphics.setFont(FONT_CONSOLE)
	for k, list in pairs(trainList) do
		for k2, tr in pairs(list) do
			--love.graphics.draw( drawable, x, y, r, sx, sy, ox, oy, kx, ky )
			if not tr.image then
				tr.image = train.getTrainImage(k)
				if not tr.image then
					break	-- skip this train if the train image has not been rendered yet!
				end
			end
			if DEBUG_OVERLAY then
			
				for i = 1,#tr.path do
					--brightness = 1-(#tr.path-i)/#tr.path
					love.graphics.setColor(255,0,0,255)
					love.graphics.circle( "fill", tr.tileX*TILE_SIZE+tr.path[i].x,  tr.tileY*TILE_SIZE+tr.path[i].y, 3)
					if i > 1 then
						love.graphics.setColor(255,150,150,255)
						love.graphics.line(tr.tileX*TILE_SIZE+tr.path[i-1].x,  tr.tileY*TILE_SIZE+tr.path[i-1].y, tr.tileX*TILE_SIZE+tr.path[i].x,  tr.tileY*TILE_SIZE+tr.path[i].y)
					end
				end
		
				love.graphics.setColor(255,255,0,255)
				love.graphics.rectangle( "fill", tr.tileX*TILE_SIZE,  tr.tileY*TILE_SIZE, 10, 10)
				love.graphics.setColor(128,255,0,255)
				love.graphics.circle( "fill", tr.tileX*TILE_SIZE+tr.x, tr.tileY*TILE_SIZE+tr.y, 5)
			end
			
			love.graphics.setColor(255,255,255,255)
			x = tr.tileX*TILE_SIZE + tr.x
			y = tr.tileY*TILE_SIZE + tr.y
			
			love.graphics.setColor(0,0,0,120)
			
			tr.interpolateX = tr.interpolateX*0.2 + x*0.8
			tr.interpolateY = tr.interpolateY*0.2 + y*0.8
			
			love.graphics.draw( tr.image, tr.interpolateX - 5, tr.interpolateY + 8, tr.smoothAngle, 1, 1, tr.image:getWidth()/2, tr.image:getHeight()/2 )
			
			love.graphics.setColor(255,255,255,255)
			love.graphics.draw( tr.image, tr.interpolateX, tr.interpolateY, tr.smoothAngle, scale, scale, tr.image:getWidth()/2, tr.image:getHeight()/2 )
			if tr.curPassenger and tr.curPassenger.onTrain and not tr.curPassenger.gettingOff then
				love.graphics.draw( trainImageBorder, tr.interpolateX, tr.interpolateY, tr.smoothAngle, scale, scale, trainImageBorder:getWidth()/2, trainImageBorder:getHeight()/2 )
			end
			--love.graphics.print( tr.name, x, y+30)
		end
	end
end

function simulation.moveSingleTrain(tr, t)
	if tr.path then
		--dx = (tr.path[tr.curNode+1].x - tr.x)
		--dy = (tr.path[tr.curNode+1].y - tr.y)
		--normalize:
		--d = math.sqrt(dx ^ 2 + dy ^ 2)
		tr.curDistTraveled = tr.curDistTraveled + t*TRAIN_SPEED*tr.curSpeed
		if tr.stop == 0 then	-- accellerate
			tr.curSpeed = math.min(tr.curSpeed+TRAIN_ACCEL*t, 1)
		else
			tr.curSpeed = math.max(tr.curSpeed-TRAIN_ACCEL*t, 0)
		end
		
		--distToMove = math.sqrt(toMoveX^2+toMoveY^2)		-- length of way to travel
		
		-- print("path:")
		-- printTable(tr.path)
		
		while tr.curDistTraveled > tr.path[tr.curNode+1].length and tr.path[tr.curNode+2] do
			tr.curNode = tr.curNode + 1
			
			tr.prevAngle = tr.angle
				
			tr.prevAngle = tr.angle
			if tr.path[tr.curNode+2] then
				if tr.path[tr.curNode+2].x >= tr.path[tr.curNode].x then
					tr.angle = math.atan((tr.path[tr.curNode+2].y - tr.path[tr.curNode].y)/(tr.path[tr.curNode+2].x - tr.path[tr.curNode].x)) + math.pi/2
				else
					tr.angle = math.atan((tr.path[tr.curNode+2].y - tr.path[tr.curNode].y)/(tr.path[tr.curNode+2].x - tr.path[tr.curNode].x)) - math.pi/2
				end
			else
				tr.angle = getAngleByDir(tr.dir)
			end
			if tr.prevAngle - tr.angle < -math.pi then
				tr.prevAngle = tr.prevAngle + 2*math.pi
			end
			if tr.prevAngle - tr.angle > math.pi then
				tr.prevAngle = tr.prevAngle - 2*math.pi
			end
			
		end
		
		
		if tr.curDistTraveled > tr.path[tr.curNode+1].length then
			--tr.blocked = true
			tr.overshoot = tr.curDistTraveled - tr.path[tr.curNode+1].length
			tr.curDistTraveled = tr.path[tr.curNode+1].length
		end
		
		
		dx = tr.path[tr.curNode+1].x - tr.path[tr.curNode].x
		dy = tr.path[tr.curNode+1].y - tr.path[tr.curNode].y
		
		d = math.sqrt(dx ^ 2 + dy ^ 2)
		
		curDist = (tr.curDistTraveled - tr.path[tr.curNode].length)/(d)
		tr.x = tr.path[tr.curNode].x + dx*curDist
		tr.y = tr.path[tr.curNode].y + dy*curDist
		
		fullDist = math.sqrt((tr.path[tr.curNode+1].x - tr.path[tr.curNode].x)^2 +(tr.path[tr.curNode+1].y - tr.path[tr.curNode].y)^2)
	
		partCovered = clamp(1-d/fullDist, 0, 1)	-- the part of the path between the nodes that has been traveled
	
		tr.smoothAngle = (tr.angle-tr.prevAngle)*curDist + tr.prevAngle
		
	end
end

function simulation.moveAllTrains(t)
	
	for k, list in pairs(trainList) do	-- TO DO move through train lists in random order!
		for k, tr in pairs(list) do
			simulation.moveSingleTrain(tr, t)
		end
	end
end


function simulation.passengerShowAll(dt)
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
				end
				
				--if p.train.tileX == p.tileX and p.train.tileY == p.tileY then
					--x = p.x - p.image:getWidth()/2 + p.train.tileX*TILE_SIZE
					--y = p.y - p.image:getHeight()/2	 + p.train.tileY*TILE_SIZE
				--else
					x = p.x - p.image:getWidth()/2 + p.tileX*TILE_SIZE
					y = p.y - p.image:getHeight()/2	 + p.tileY*TILE_SIZE
				--end
			elseif p.gettingOff and p.train.curSpeed == 0 then
				d = vecDist(p.x, p.y, p.xEnd, p.yEnd)
				dX = (p.xEnd-p.x)/d
				dY = (p.yEnd-p.y)/d
				p.x = p.x + dX*dt*PASSENGER_SPEED
				p.y = p.y + dY*dt*PASSENGER_SPEED
			
				x = p.x - p.image:getWidth()/2 + p.train.tileX*TILE_SIZE
				y = p.y - p.image:getHeight()/2	 + p.train.tileY*TILE_SIZE
				p.train = nil	-- DON'T GET BACK ON!
			else	-- if I'm riding the train
				p.x = p.train.x
				p.y = p.train.y
				x = p.x - p.image:getWidth()/2 + p.train.tileX*TILE_SIZE
				y = p.y - p.image:getHeight()/2	 + p.train.tileY*TILE_SIZE
			end
		else	-- if I'm just standing around...
			if p.gettingOff then
				d = vecDist(p.x, p.y, p.xEnd, p.yEnd)
				dX = (p.xEnd-p.x)/d
				dY = (p.yEnd-p.y)/d
				p.x = p.x + dX*dt*PASSENGER_SPEED
				p.y = p.y + dY*dt*PASSENGER_SPEED
			
				x = p.x - p.image:getWidth()/2 + p.tileX*TILE_SIZE
				y = p.y - p.image:getHeight()/2	 + p.tileY*TILE_SIZE
			
				if d < vecDist(p.x, p.y, p.xEnd, p.yEnd) then
					--p.train.stop = p.train.stop - 1
					p.onTrain = false
					p.gettingOff = false
					p.train = nil
					
					if p.reachedDestination then
						passengerList[k] = nil
					end
				end
			end
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
					love.graphics.setColor(64,128,255,100)
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

return simulation
