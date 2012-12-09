
--[[
Each train in the trainList holds:
tileX, tileY: the tile coordinates of the tile the train is currently on
anlge: the direction the train is currently moving in (radians)
dir: the direction the next tile is in
x, y: the position ON the tile
curNode: the node it last visited


]]--

local train = {}

local blockedTrains = {}

local newTrainQueue = {}

local train_mt = { __index = train }

local trainList = {}

trainImageBorder = love.graphics.newImage("Images/Train1Boarded.png")

local trainImages = {}
local trainImageThreads = {}
local numTrainImageThreads = 0
local totalNumImageThreads = 0

--[[
trainImagePlayer1
trainImagePlayer2
trainImagePlayer3
trainImagePlayer4
]]--

function tint(col)
	local bright = 0
	return function (x,y,r,g,b,a)
		bright = (r+g+b)/3	--calc brightness (average) of pixel
		return bright*col.r/255, bright*col.g/255, bright*col.b/255, a
	end
end

function train.init()
	
	newTrainQueue = {}

	trainList[1] = {}
	trainList[2] = {}
	trainList[3] = {}
	trainList[4] = {}
	
	trainImageThreads = {}
	numTrainImageThreads = 0
	blockedTrains = {}

end

function train.resetImages()
	trainImages = {}
end

function train.setTrainImage( img, ID )
	trainImages[ID] = img
end

function train.getTrainImage( ID )
	return trainImages[ID]
end

function train.renderTrainImage( name, ID )
	if name and ID then
		print("starting thread...train.renderTrainImage", name .. ".lua")
		col = generateColour(name .. ".lua", 1)
		trainImageThreads[ID] = love.thread.newThread("traimImageThread" .. totalNumImageThreads, "Scripts/renderTrainImage.lua")
		totalNumImageThreads = totalNumImageThreads + 1
		trainImageThreads[ID]:start()
		trainImageThreads[ID]:set("seed", name .. ".lua")
		trainImageThreads[ID]:set("colour", TSerial.pack(col))
		numTrainImageThreads = numTrainImageThreads + 1
	else
		for k, t in pairs(trainImageThreads) do
			status = t:get("status")
			err = t:get("error")
			if err then
				print("Error in train image thread:" .. err)
				trainImageThreads[k] = nil
			end
			if status == "done" then
				print("Rendered train image:", k)
				img = t:get("image")
				if img then
					trainImages[k] = love.graphics.newImage(img)
				else
					print("Error rendering train image!")
				end
				trainImageThreads[k] = nil
				numTrainImageThreads = numTrainImageThreads - 1
			elseif status then
				print("Image Thread:", status)
			end
		end
	end
end

function train.isRenderingImages()
	if numTrainImageThreads > 0 then
		return true
	end
end

function train.buyNew(aiID)
	return function (posX, posY, dir)
		print("ATTEMPT TO BUY NEW TRAIN", aiID, posX, posY, dir)
		if type(posX) == "number" and type(posY) == "number" then
			posX = math.floor(clamp(posX, 1, curMap.width))
			posY = math.floor(clamp(posY, 1, curMap.height))
			
			if stats.getMoney(aiID) >= TRAIN_COST then
				print("Bought new Train", aiID, posX, posY)
				stats.subMoney(aiID, TRAIN_COST)
				table.insert(newTrainQueue, {aiID=aiID, posX=posX, posY=posY, dir=dir})
				if tutorial and tutorial.trainPlacingEvent then
					tutorial.trainPlacingEvent()
				end
			else
				console.add("Error: " .. ai.getName(aiID) .. " tried to buy new train but doesn't have enough cash!", {r=255,g=50,b=50})
			end
		else
			console.add("Error: X and Y passed to 'buyTrain' must be numbers!", {r=255,g=50,b=50})
		end
	end
end

function train.handleNewTrains()		-- go through list of newly created trains and place them on the map!
	if not curMap then return end
	
	for k, tr in pairs(newTrainQueue) do
		if curMap[tr.posX][tr.posY] ~= "C" then
			local foundX = nil
			local foundY = nil
			local dist = 1
			
			-- search for "C" around the given position. If not found, increase the radius (dist)
			while (not foundX or not foundY) and dist < math.max(curMap.width, curMap.height) do
				for i = -dist,dist do
					for j = -dist,dist do
						if tr.posX +i > 0 and tr.posY+j > 0 and tr.posX +i < curMap.width and tr.posY+j < curMap.width then
							if curMap[tr.posX + i][tr.posY + j] == "C" then
								foundX = tr.posX + i
								foundY = tr.posY + j
								break
							end
						end
					end
					if foundX and foundY then
						break
					end
				end
				dist = dist + 1
			end
			if not foundX or not foundY then
				print("Error: could not find Rail to place train on!")
				newTrainQueue[k] = nil
			else
				tr.posX = foundX
				tr.posY = foundY
			end
		else
			if not map.getIsTileOccupied(tr.posX, tr.posY) then
				train:new( tr.aiID, tr.posX, tr.posY, tr.dir )
				newTrainQueue[k] = nil	-- don't generate again!
			end
		end
	end
end

function train:new( aiID, x, y, dir )
	if curMap[x][y] ~= "C" then
		error("Trying to place train on non-valid tile")
	end
	if #trainList[aiID] >= MAX_NUM_TRAINS then
		return
	end
	for i=1,#trainList[aiID]+1,1 do
		if not trainList[aiID][i] then
			--local imageOff = createButtonOff(width, height, label)
			--local imageOver = createButtonOver(width, height, label)
			local image = trainImages[aiID]
			trainList[aiID][i] = setmetatable({image = image, ID = i, aiID = aiID}, button_mt)
			
			--print("Placing new train at:", x, y)
			--print("\tHeading:", dir)
			path = nil
			if dir == "N" then
				if curMap[x][y-1] == "C" then
					path = map.getRailPath(x, y, dir)
				end
			elseif dir == "S" then
				if curMap[x][y+1] == "C" then
					path = map.getRailPath(x, y, dir)
				end
			elseif dir == "E" then
				if curMap[x+1][y] == "C" then
					path = map.getRailPath(x, y, dir)
				end
			elseif dir == "W" then
				if curMap[x-1][y] == "C" then
					path = map.getRailPath(x, y, dir)
				end
			end
			
			if not path then
				if curMap[x][y-1] == "C" then
					path = map.getRailPath(x, y, "N")
					dir = "N"
				elseif curMap[x][y+1] == "C" then
					path = map.getRailPath(x, y, "S")
					dir = "S"
				elseif curMap[x+1][y] == "C" then
					path = map.getRailPath(x, y, "E")
					dir = "E"
				else
					path = map.getRailPath(x, y, "W")
					dir = "W"
				end
				
			end
			
			trainList[aiID][i].tileX = x
			trainList[aiID][i].tileY = y
			
			map.setTileOccupied(x, y, nil, dir)
			
			trainList[aiID][i].name = "Train" .. i
			trainList[aiID][i].timeBlocked = 0
			
			trainList[aiID][i].curDistTraveled = 0
			trainList[aiID][i].curSpeed = 0
			trainList[aiID][i].stop = 0
			
			if path and path[1] then		--place at the center of the current piece.
				curPathNode = math.ceil((#path-1)/2)
				trainList[aiID][i].curDistTraveled = path[curPathNode].length
				
				trainList[aiID][i].x = path[curPathNode].x
				trainList[aiID][i].y = path[curPathNode].y
				
				
				--local position:
				trainList[aiID][i].path = path
				trainList[aiID][i].curNode = curPathNode
				trainList[aiID][i].dir = dir
				
				--trainList[aiID][i].x = (path[curPathNode+1].x - path[curPathNode].x)/2 + path[curPathNode].x
				--trainList[aiID][i].y = (path[curPathNode+1].y - path[curPathNode].y)/2 + path[curPathNode].y
				
				tr = trainList[aiID][i]
				if tr.path[tr.curNode+1] then
					if tr.path[tr.curNode+1].x >= tr.path[tr.curNode].x then
						tr.angle = math.atan((tr.path[tr.curNode+1].y - tr.path[tr.curNode].y)/(tr.path[tr.curNode+1].x - tr.path[tr.curNode].x)) + math.pi/2
					else
						tr.angle = math.atan((tr.path[tr.curNode+1].y - tr.path[tr.curNode].y)/(tr.path[tr.curNode+1].x - tr.path[tr.curNode].x)) - math.pi/2
					end
				else
					tr.angle = getAngleByDir(tr.dir)
				end
				
				trainList[aiID][i].prevAngle = trainList[aiID][i].angle
				
				
				dx = (path[curPathNode+1].x - trainList[aiID][i].x)
				dy = (path[curPathNode+1].y - trainList[aiID][i].y)
				trainList[aiID][i].dxPrevSign = (dx < 0)
				trainList[aiID][i].dyPrevSign = (dy < 0)
				
				
			else
				trainList[aiID][i].x = 0
				trainList[aiID][i].y = math.random(100)
			end
			
			print("NEW TRAIN!!")
			stats.addTrain(aiID, {ID=i, name=trainList[aiID][i].name})
			return trainList[aiID][i]
		end
	end
end


function train.getByID( aiID, trainID)
	if trainList[aiID] then
		for k, tr in pairs(trainList[aiID]) do
			if tr.ID == trainID then return tr end
		end
	end
	return nil
end
-- function distance(x1,y1,x2,y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end


function addBlockedTrain(tr)
	blockedTrains[#blockedTrains+1] = tr
	tr.timeBlocked = 0
end

function removeBlockedTrain(tr)
	local removedID = false
	for k, v in ipairs(blockedTrains) do
		if v == tr then
			removedID = k
		elseif removedID then
			blockedTrains[k-1] = blockedTrains[k]
			stats.trainBlockedTime( tr.aiID, tr.ID, tr.timeBlocked )
		end
	end
	
	if removedID then
		blockedTrains[#blockedTrains] = nil
	end
end

function getAngleByDir( dir )
	if dir == "N" then
		return 0
	elseif dir == "S" then
		return math.pi
	elseif dir == "E" then
		return math.pi/2
	else
		return -math.pi/2
	end
end

function moveSingleTrain(tr, t)
	if tr.path then
		--dx = (tr.path[tr.curNode+1].x - tr.x)
		--dy = (tr.path[tr.curNode+1].y - tr.y)
		--normalize:
		--d = math.sqrt(dx ^ 2 + dy ^ 2)
		tr.curDistTraveled = tr.curDistTraveled + t*TRAIN_SPEED*tr.curSpeed
		if tr.stop == 0 then	--accellerate
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
			tr.curDistTraveled = tr.curDistTraveled - tr.path[tr.curNode+1].length	-- remember overshoot!
			
			local nextX, nextY = tr.tileX, tr.tileY
			local cameFromDir = ""
			
			if not tr.blocked then		-- "blocked" is set if I've already checked for directions in a previous frame and the direction I chose was blocked.
				
				tr.possibleDirs, tr.numDirections = map.getNextPossibleDirs(tr.tileX, tr.tileY, tr.dir)
				
				tr.nextDir = nil
				
				if tr.numDirections > 1 then	-- if there's only one direction, there's no point in asking the ai in which direction it wants to move.
					tr.nextDir = ai.chooseDirection(tr, tr.possibleDirs)
				end
				
				if tr.nextDir == nil then	-- fallback: if choosing the next dir went wrong or if there's only one direction to go in:
					if tr.possibleDirs["N"] then tr.nextDir = "N"
					elseif tr.possibleDirs["S"] then tr.nextDir = "S"
					elseif tr.possibleDirs["E"] then tr.nextDir = "E"
					else tr.nextDir = "W"
					end
				end
				
				map.resetTileOccupied(tr.tileX, tr.tileY, tr.cameFromDir, tr.dir)	-- free up previously blocked path! Important, otherwise everthing could block.
				
			else
				if tr.timeBlocked > MAX_BLOCK_TIME then
					
					stats.trainBlockedTime( tr.aiID, tr.ID, tr.timeBlocked )
					tr.timeBlocked = 0
					
					if tr.numDirections > 1 then	-- if there's only one direction, there's no point in asking the ai in which direction it wants to move.
						tr.nextDir = ai.blocked(tr, tr.possibleDirs, tr.nextDir)
					end
				end
			end
			
			if tr.dir == "N" then
				nextY = nextY - 1
				cameFromDir = "S"
				--print("moved north")
			end
			if tr.dir == "S" then
				nextY = nextY + 1
				cameFromDir = "N"
				--print("moved south")
			end
			if tr.dir == "W" then
				nextX = nextX - 1
				cameFromDir = "E"
				--print("moved west")
			end
			if tr.dir == "E" then
				nextX = nextX + 1
				cameFromDir = "W"
				--print("moved east")
			end
			
			if not map.getIsTileOccupied(nextX, nextY, cameFromDir, tr.nextDir) then
				
				if tr.blocked then removeBlockedTrain(tr) end
				map.resetTileExitOccupied(tr.tileX, tr.tileY, tr.dir)
				
				tr.timeBlocked = 0
				tr.blocked = false
				
				map.setTileOccupied(nextX, nextY, cameFromDir, tr.nextDir)
				tr.freedTileOccupation = false
				
				tr.cameFromDir = cameFromDir
				
				tr.tileX, tr.tileY = nextX, nextY
				
				if tutorial and tutorial.reachedNewTileEvent then
					tutorial.reachedNewTileEvent( tr.tileX, tr.tileY )
				end
			
				tr.path = map.getRailPath(tr.tileX, tr.tileY, tr.nextDir, tr.dir)
				
				
				tr.dir = tr.nextDir
			
				if tr.path then
				
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
				
					-- dx = (tr.path[tr.curNode+1].x - tr.x)
					-- dy = (tr.path[tr.curNode+1].y - tr.y)
					--normalize:
					-- d = math.sqrt(dx ^ 2 + dy ^ 2)
				end
				
				if tr.curPassenger and tr.curPassenger.onTrain then
					if tr.curPassenger.destX == tr.tileX and tr.curPassenger.destY == tr.tileY then	-- I'm entering my passenger's destination!
						ai.foundDestination(tr)
					end
				end
								
				p = passenger.find(tr.tileX, tr.tileY)
				if p then
					ai.foundPassengers(tr, p)		-- call the event. This way the ai can choose whether to take the passenger aboard or not.
				end
				
			else
				tr.curDistTraveled = 0
				if not tr.blocked then
					print("train is blocked, adding!", tr.tileX, tr.tileY, tr.ID, tr.aiID)
					addBlockedTrain(tr)
					tr.blocked = true
				end
			end
		
		end
		
		
		if not tr.blocked then
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
		
		--[[
		
		-- if traveling would bring me past the node:
		if d <= distToMove then
			distToMove = distToMove - d
			if tr.path[tr.curNode+2] then
				tr.curNode = tr.curNode + 1
				
				dx = (tr.path[tr.curNode+1].x - tr.x)
				dy = (tr.path[tr.curNode+1].y - tr.y)
				--normalize:
				d = math.sqrt(dx ^ 2 + dy ^ 2)
				
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
			else
				
				local nextX, nextY = tr.tileX, tr.tileY
				local cameFromDir = ""
				
				if not tr.blocked then		-- "blocked" is set if I've already checked for directions in a previous frame and the direction I chose was blocked.
					
					tr.possibleDirs, tr.numDirections = map.getNextPossibleDirs(tr.tileX, tr.tileY, tr.dir)
					
					tr.nextDir = nil
					
					if tr.numDirections > 1 then	-- if there's only one direction, there's no point in asking the ai in which direction it wants to move.
						tr.nextDir = ai.chooseDirection(tr, tr.possibleDirs)
					end
					
					if tr.nextDir == nil then	-- fallback: if choosing the next dir went wrong or if there's only one direction to go in:
						if tr.possibleDirs["N"] then tr.nextDir = "N"
						elseif tr.possibleDirs["S"] then tr.nextDir = "S"
						elseif tr.possibleDirs["E"] then tr.nextDir = "E"
						else tr.nextDir = "W"
						end
					end
					
					map.resetTileOccupied(tr.tileX, tr.tileY, tr.cameFromDir, tr.dir)	-- free up previously blocked path! Important, otherwise everthing could block.
					
				else
					if tr.timeBlocked > MAX_BLOCK_TIME then
						
						tr.timeBlocked = 0
						
						if tr.numDirections > 1 then	-- if there's only one direction, there's no point in asking the ai in which direction it wants to move.
							tr.nextDir = ai.blocked(tr, tr.possibleDirs, tr.nextDir)
						end
					end
				end
				
				if tr.dir == "N" then
					nextY = nextY - 1
					cameFromDir = "S"
					--print("moved north")
				end
				if tr.dir == "S" then
					nextY = nextY + 1
					cameFromDir = "N"
					--print("moved south")
				end
				if tr.dir == "W" then
					nextX = nextX - 1
					cameFromDir = "E"
					--print("moved west")
				end
				if tr.dir == "E" then
					nextX = nextX + 1
					cameFromDir = "W"
					--print("moved east")
				end
				
				if not map.getIsTileOccupied(nextX, nextY, cameFromDir, tr.nextDir) then
					
					if tr.blocked then removeBlockedTrain(tr) end
					map.resetTileExitOccupied(tr.tileX, tr.tileY, tr.dir)
					
					tr.timeBlocked = 0
					tr.blocked = false
					
					--print("reset:", tr.tileX, tr.tileY, tr.cameFromDir, tr.dir)
					
					--print("set:", nextX, nextY, cameFromDir, tr.nextDir)
					map.setTileOccupied(nextX, nextY, cameFromDir, tr.nextDir)
					tr.freedTileOccupation = false
					
					tr.cameFromDir = cameFromDir
					
					tr.tileX, tr.tileY = nextX, nextY
				
					tr.path = map.getRailPath(tr.tileX, tr.tileY, tr.nextDir, tr.dir)
					
					tr.dir = tr.nextDir
				
					if tr.path then
					
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
					
						dx = (tr.path[tr.curNode+1].x - tr.x)
						dy = (tr.path[tr.curNode+1].y - tr.y)
						--normalize:
						d = math.sqrt(dx ^ 2 + dy ^ 2)
					end
					
					if tr.curPassenger then
						if tr.curPassenger.destX == tr.tileX and tr.curPassenger.destY == tr.tileY then	-- I'm entering my passenger's destination!
							ai.foundDestination(tr)
						end
					end
									
					p = passenger.find(tr.tileX, tr.tileY)
					if p then
						ai.foundPassengers(tr, p)		-- call the event. This way the ai can choose whether to take the passenger aboard or not.
					end
					
				else
					if not tr.blocked then
						addBlockedTrain(tr)
						tr.blocked = true
					end
				end
			end
		end
		
		if not tr.blocked then
			--tr.dxPrevSign = (dx < 0)
			--tr.dyPrevSign = (dy < 0)
		
			fullDist = math.sqrt((tr.path[tr.curNode+1].x - tr.path[tr.curNode].x)^2 +(tr.path[tr.curNode+1].y - tr.path[tr.curNode].y)^2)
		
			partCovered = clamp(1-d/fullDist, 0, 1)	-- the part of the path between the nodes that has been traveled
		
			dx = dx/d
			dy = dy/d
			
		
			tr.smoothAngle = (tr.angle-tr.prevAngle)*partCovered + tr.prevAngle
		
			tr.x = tr.x + t*dx*TRAIN_SPEED
			tr.y = tr.y + t*dy*TRAIN_SPEED
		end
		]]--
		
	end
end

function train.moveAll()
	t = love.timer.getDelta()*timeFactor
	for k, tr in ipairs(blockedTrains) do	-- move blocked trains first! The longer they've been blocked, the earlier the move.
		moveSingleTrain(tr, t)
		tr.hasMoved = true
		if tr.blocked then
			tr.timeBlocked = tr.timeBlocked + t
		end
	end
	
	for k, list in pairs(trainList) do	-- TO DO move through train lists in random order!
		for k, tr in pairs(list) do
			if tr.hasMoved == false then
				moveSingleTrain(tr, t)
			end
			tr.hasMoved = false	-- reset for next round!
		end
	end
end

function train.getBlockedTrains()
	return blockedTrains
end

function train.showAll()

	love.graphics.setFont(FONT_CONSOLE)
	for k, list in pairs(trainList) do
		for k, tr in pairs(list) do
			--love.graphics.draw( drawable, x, y, r, sx, sy, ox, oy, kx, ky )
			
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
			if tr.timeBlocked > 0 then
				love.graphics.print( tr.timeBlocked, x, y+30)
			end
		end
	end
end

function train.checkSelection()
	x,y = love.mouse.getPosition()
		-- love.graphics.scale(camZ)
		-- love.graphics.translate(camX + love.graphics.getWidth()/(2*camZ), camY + love.graphics.getHeight()/(2*camZ))
end


return train
