local simulation = {}

local simulationRunning = false

local packetList = {}		-- stores all the events that were received from the server ()

local trainList = {}

function simulation.init()
	simulationRunning = true
	
	curMapOccupiedTiles = {}
	curMapRailTypes = {}

	train.init()
	passenger.init()
	
	loadingScreen.reset()
	packetList = {}
	
	trainList = {}
	trainList[1] = {}
	trainList[2] = {}
	trainList[3] = {}
	trainList[4] = {}
	
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
	
	if not curMap and not map.startupProcess() then
		map.render(simulationMap)
		newMapStarting = true
	end
	
end

function simulation.isRunning()
	return simulationRunning
end

function simulation.runMap()
	roundEnded = false
end

function simulation.stop()
	mapGenerateThread = nil
	mapRenderThread = nil
	mapImage = nil
	simulationRunning = false
	simulationMap = nil
	map.endRound()
end


function sortByTime(a,b)
	if a.time < b.time then return true end
end

function addPacket(text, time)
	table.insert(packetList, {time=time, event = text})
	table.sort(packetList, sortByTime)
end

function simulation.addUpdate(text)
	s, e = text:find("|")
	if not s then
		print("ERROR: No time stamp found for packet!")
		return
	end
	time = tonumber(text:sub(1, s-1))
	text = text:sub(e+1, #text)
	addPacket(text, time)
end

function runUpdate(event)
	print("Running: " .. event)
	if event:find("NEW_TRAIN:") == 1 then
		s,e = event:find("NEW_TRAIN:")
		tbl = seperateStrings(event:sub(e+1,#event))
		ID = tbl[1]
		name = tbl[2]
		tileX = tbl[3]
		tileY = tbl[4]
		dir = tbl[5]
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
			
					trainList[ID][i] = {name=name, tileX=tileX, tileY=tileY, curSpeed = 0, stop = 0}
					path = map.getRailPath(tileX, tileY, dir)
					if path then
						curPathNode = math.ceil((#path-1)/2)
						trainList[ID][i].curDistTraveled = path[curPathNode].length
				
						trainList[ID][i].x = path[curPathNode].x
						trainList[ID][i].y = path[curPathNode].y
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
							tr.angle = getAngleByDir(tr.dir)
						else
							tr.angle = getAngleByDir(tr.dir)
						end
				
						trainList[ID][i].prevAngle = trainList[ID][i].angle
										
						dx = (path[curPathNode+1].x - trainList[ID][i].x)
						dy = (path[curPathNode+1].y - trainList[ID][i].y)
						trainList[ID][i].dxPrevSign = (dx < 0)
						trainList[ID][i].dyPrevSign = (dy < 0)
						print("Placed new train @", trainList[ID][i].tileX, trainList[ID][i].tileY, "heading:", trainList[ID][i].dir, trainList[ID][i].x, trainList[ID][i].y)
					end
					break	--important, don't add again!
				end
			end
		end
		return
	elseif event:find("NEW_AI:") == 1 then
		s,e = event:find("NEW_AI:")
		tbl = seperateStrings(event:sub(e+1,#event))
		ID = tbl[1]
		name = tbl[2]
		if ID and name then
			ID = tonumber(ID)
			train.renderTrainImage( name, ID )
		end
		return
	elseif event:find("TRAIN_CONT:") == 1 then
		s,e = event:find("TRAIN_CONT:")
		tbl = seperateStrings(event:sub(e+1,#event))
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
						print(ID, name, tileX, tileY, dir)
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
		tbl = seperateStrings(event:sub(e+1,#event))
		ID = tbl[1]
		name = tbl[2]
		stop = tbl[3]
		if ID and name and tileX and tileY and dir then
			ID = tonumber(ID)
			stop = tonumber(stop)
			if trainList[ID] then
				for k, tr in pairs(trainList[ID]) do
					if tr.name == name then
						tr.stop = stop
						break
					end
				end
			end
		end
		return
	end
end

function simulation.update(dt)
	--local changed = false
	for i = 1, #packetList do
		if not packetList[i] then
			break
		end
		if simulationMap and simulationMap.time >= packetList[i].time then
			runUpdate(packetList[i].event)
			packetList[i] = nil
			for j = i, #packetList do
				packetList[j] = packetList[j+1]
			end
		else
			break
		end
	end
	--if changed then
	--	table.sort(packetList, sortByTime)
	--end
	
	simulation.moveAllTrains(dt)
end

function simulation.draw()
	if mapImage then
		love.graphics.push()
		love.graphics.scale(camZ)
	
		love.graphics.translate(camX + love.graphics.getWidth()/(2*camZ), camY + love.graphics.getHeight()/(2*camZ))
		love.graphics.rotate(CAM_ANGLE)
		love.graphics.setColor(30,10,5, 150)
		love.graphics.rectangle("fill", -TILE_SIZE*(simulationMap.width+2)/2-120,-TILE_SIZE*(simulationMap.height+2)/2-80, TILE_SIZE*(simulationMap.width+2)+200, TILE_SIZE*(simulationMap.height+2)+200)
		love.graphics.setColor(0,0,0, 100)
		love.graphics.rectangle("fill", -TILE_SIZE*(simulationMap.width+2)/2-20, -TILE_SIZE*(simulationMap.height+2)/2+20, TILE_SIZE*(simulationMap.width+2), TILE_SIZE*(simulationMap.height+2))
		love.graphics.setColor(255,255,255, 255)
		love.graphics.draw(mapImage, -TILE_SIZE*(simulationMap.width+2)/2, -TILE_SIZE*(simulationMap.height+2)/2)
	
	
		love.graphics.translate(-TILE_SIZE*(simulationMap.width+2)/2, -TILE_SIZE*(simulationMap.height+2)/2)
	
		passenger.showAll(passedTime)
		simulation.trainShowAll()
		passenger.showVIPs(passedTime)
	
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(mapShadowImage, 0,0)	
		love.graphics.draw(mapObjectImage, 0,0)	
	
		map.renderHighlights(passedTime)
	
		if not love.keyboard.isDown("i") then clouds.renderShadows(passedTime) end

		--map.drawOccupation()
		
		love.graphics.pop()
		love.graphics.push()
		love.graphics.scale(camZ*1.5)
	
		love.graphics.translate(camX + love.graphics.getWidth()/(camZ*3), camY + love.graphics.getHeight()/(camZ*3))
		love.graphics.rotate(CAM_ANGLE)
		love.graphics.translate(-TILE_SIZE*(simulationMap.width+2)/2, -TILE_SIZE*(simulationMap.height+2)/2)
	
		--clouds.render()
	
		love.graphics.pop()
	
		if showQuickHelp then quickHelp.show() end
		if showConsole then console.show() end
	
		stats.displayStatus()
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
					brightness = 1-(#tr.path-i)/#tr.path
					love.graphics.setColor(255,0,0,255)
					love.graphics.circle( "fill", tr.tileX*TILE_SIZE+tr.path[i].x,  tr.tileY*TILE_SIZE+tr.path[i].y, brightness*4+3)
				end
			
				love.graphics.setColor(255,255,0,255)
				love.graphics.rectangle( "fill", tr.tileX*TILE_SIZE,  tr.tileY*TILE_SIZE, 10, 10)
				love.graphics.setColor(128,255,0,255)
				love.graphics.circle( "fill", tr.tileX*TILE_SIZE+tr.x, tr.tileY*TILE_SIZE+tr.y, 5)
			end
			
			love.graphics.setColor(255,255,255,255)
			x = tr.tileX*TILE_SIZE + tr.x
			y = tr.tileY*TILE_SIZE + tr.y
			scale = 1
			
			if vecDist(x, y, mapMouseX, mapMouseY) < 20 then
				scale = 3
			end
			
			love.graphics.setColor(0,0,0,120)
			love.graphics.draw( tr.image, x - 5, y + 8, tr.smoothAngle, scale, scale, tr.image:getWidth()/2, tr.image:getHeight()/2 )
			
			love.graphics.setColor(255,255,255,255)
			love.graphics.draw( tr.image, x, y, tr.smoothAngle, scale, scale, tr.image:getWidth()/2, tr.image:getHeight()/2 )
			if tr.curPassenger and tr.curPassenger.onTrain and not tr.curPassenger.gettingOff then
				love.graphics.draw( trainImageBorder, x, y, tr.smoothAngle, scale, scale, trainImageBorder:getWidth()/2, trainImageBorder:getHeight()/2 )
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

return simulation
