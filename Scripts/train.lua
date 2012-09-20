
--[[
Each train in the trainList holds:
tileX, tileY: the tile coordinates of the tile the train is currently on
anlge: the direction the train is currently moving in (radians)
dir: the direction the next tile is in
x, y: the position ON the tile
curNode: the node it last visited


]]--

local train = {}

local train_mt = { __index = train }

local trainList = {}

local TRAIN_SPEED = 20

trainImage = love.image.newImageData("Images/Train1.png")
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

function train.init(col1, col2, col3, col4)

	trainList[1] = {}
	trainList[2] = {}
	trainList[3] = {}
	trainList[4] = {}

	trainImagePlayer1d = love.image.newImageData(trainImage:getWidth(), trainImage:getHeight())
	trainImagePlayer2d = love.image.newImageData(trainImage:getWidth(), trainImage:getHeight())
	trainImagePlayer3d = love.image.newImageData(trainImage:getWidth(), trainImage:getHeight())
	trainImagePlayer4d = love.image.newImageData(trainImage:getWidth(), trainImage:getHeight())
	
	--[[trainImagePlayer1d:mapPixel(tint(col1))
	trainImagePlayer2d:mapPixel(tint(col2))
	trainImagePlayer3d:mapPixel(tint(col3))
	trainImagePlayer4d:mapPixel(tint(col4))
	]]--
	
	
	for i=0,trainImage:getWidth()-1 do
		for j=0,trainImage:getHeight()-1 do
			r,g,b,a = trainImage:getPixel(i, j)
			bright = 2*(0.2126 *r + 0.7152 *g + 0.0722 *b)/3--(r+g+b)/3	--calc brightness (average) of pixel
			trainImagePlayer1d:setPixel(i, j, bright*col1.r/255+r/3, bright*col1.g/255+g/3, bright*col1.b/255+b/3, a)
			trainImagePlayer2d:setPixel(i, j, bright*col2.r/255+r/3, bright*col2.g/255+g/3, bright*col2.b/255+b/3, a)
			trainImagePlayer3d:setPixel(i, j, bright*col3.r/255+r/3, bright*col3.g/255+g/3, bright*col3.b/255+b/3, a)
			trainImagePlayer4d:setPixel(i, j, bright*col4.r/255+r/3, bright*col4.g/255+g/3, bright*col4.b/255+b/3, a)
		end
	end
	trainImagePlayer1 = love.graphics.newImage(trainImagePlayer1d)
	trainImagePlayer2 = love.graphics.newImage(trainImagePlayer2d)
	trainImagePlayer3 = love.graphics.newImage(trainImagePlayer3d)
	trainImagePlayer4 = love.graphics.newImage(trainImagePlayer4d)
end

function getTrainImage( aiID )
	if aiID == 1 then return trainImagePlayer1
	elseif aiID == 2 then return trainImagePlayer2
	elseif aiID == 3 then return trainImagePlayer3
	else return trainImagePlayer4
	end
end


function train:new( aiID, x, y, dir )
	if curMap[x][y] ~= "C" then
		error("Trying to place train on non-valid tile")
	end
	for i=1,#trainList[aiID]+1,1 do
		if not trainList[aiID][i] then
			--local imageOff = createButtonOff(width, height, label)
			--local imageOver = createButtonOver(width, height, label)
			local image = getTrainImage( aiID )
			trainList[aiID][i] = setmetatable({image = image, ID = i, aiID = aiID}, button_mt)
			
			print("Placing new train at:", x, y)
			print("\tHeading:", dir)
			
			if dir == "N" then
				path = train.getRailPath(x, y, dir)
			elseif dir == "S" then
				path = train.getRailPath(x, y, dir)
			elseif dir == "E" then
				path = train.getRailPath(x, y, dir)
			else
				path = train.getRailPath(x, y, dir)
			end
			
			trainList[aiID][i].tileX = x
			trainList[aiID][i].tileY = y
			-- map.setTileOccupied(x, y, nil, dir)
			
			trainList[aiID][i].name = "train" .. i
			
			if path and path[1] then		--place at the center of the current piece.
				curPathNode = math.ceil((#path-1)/2)
				--local position:
				trainList[aiID][i].path = path
				trainList[aiID][i].curNode = curPathNode
				trainList[aiID][i].dir = dir
				
				trainList[aiID][i].x = (path[curPathNode+1].x - path[curPathNode].x)/2 + path[curPathNode].x
				trainList[aiID][i].y = (path[curPathNode+1].y - path[curPathNode].y)/2 + path[curPathNode].y
				
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
			
			return trainList[aiID][i]
		end
	end
end

-- function distance(x1,y1,x2,y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end

local blockedTrains = {}

function addBlockedTrain(tr)
	blockedTrains[#blockedTrains+1] = tr
end

function removeBlockedTrain(tr)
	local removedID = false
	for k, v in ipairs(blockedTrains) do
		if v == tr then
			removedID = k
		elseif removedID then
			blockedTrains[k-1] = blockedTrains[k]
		end
	end
	if removedID then blockedTrains[#blockedTrains] = nil
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
		dx = (tr.path[tr.curNode+1].x - tr.x)
		dy = (tr.path[tr.curNode+1].y - tr.y)
		--normalize:
		d = math.sqrt(dx ^ 2 + dy ^ 2)
		
		-- if distance is small, or sign of dx or dy has changed, go to next node:
		if d < 1 or (dx < 0) ~= (tr.dxPrevSign) or (dy < 0) ~= (tr.dyPrevSign) then
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
				print("newAngles2:", tr.angle, tr.prevAngle)
				if tr.prevAngle - tr.angle < -math.pi then
					tr.prevAngle = tr.prevAngle + 2*math.pi
					print("corrected prev angle:", tr.prevAngle)
				end
				if tr.prevAngle - tr.angle > math.pi then
					tr.prevAngle = tr.prevAngle - 2*math.pi
					print("corrected prev angle:", tr.prevAngle)
				end
				
				if not tr.path[tr.curNode+2] and not tr.freedTileOccupation then
					map.resetTileOccupied(tr.tileX, tr.tileY, tr.cameFromDir, tr.dir)	-- free up previously blocked path! Important, otherwise everthing could block.
					tr.freedTileOccupation = true
				end
			else
				
				local nextX, nextY = tr.tileX, tr.tileY
				local cameFromDir = ""
				
				if not tr.blocked then
					
					possibleDirs, num = train.getNextPossibleDirs(tr.tileX, tr.tileY, tr.dir)
					
					tr.nextDir = nil
					--tr.nextDir = possibleDirs[math.random(#possibleDirs)]
					if num > 1 then
						tr.nextDir = ai.chooseDirection(tr, possibleDirs)
					end
					
					if tr.nextDir == nil then	-- if choosing the next dir went wrong of there's only one direction to go in:
						if possibleDirs["N"] then tr.nextDir = "N"
						elseif possibleDirs["S"] then tr.nextDir = "S"
						elseif possibleDirs["E"] then tr.nextDir = "E"
						else tr.nextDir = "W"
						end
					end
					
					--print("chose: ", tr.nextDir)
					
					if not tr.freedTileOccupation then
						map.resetTileOccupied(tr.tileX, tr.tileY, tr.cameFromDir, tr.dir)	-- free up previously blocked path! Important, otherwise everthing could block.
						tr.freedTileOccupation = true
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
					
					tr.blocked = false
					
					--print("reset:", tr.tileX, tr.tileY, tr.cameFromDir, tr.dir)
					
					--print("set:", nextX, nextY, cameFromDir, tr.nextDir)
					map.setTileOccupied(nextX, nextY, cameFromDir, tr.nextDir)
					tr.freedTileOccupation = false
					
					tr.cameFromDir = cameFromDir
					
					tr.tileX, tr.tileY = nextX, nextY
				
					tr.path = train.getRailPath(tr.tileX, tr.tileY, tr.nextDir, tr.dir)
					
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
						print("newAngles1:", tr.angle, tr.prevAngle)
						if tr.prevAngle - tr.angle < -math.pi then
							tr.prevAngle = tr.prevAngle + 2*math.pi
							print("corrected prev angle:", tr.prevAngle)
						end
						if tr.prevAngle - tr.angle > math.pi then
							tr.prevAngle = tr.prevAngle - 2*math.pi
							print("corrected prev angle:", tr.prevAngle)
						end
					
						tr.x = tr.path[tr.curNode].x
						tr.y = tr.path[tr.curNode].y
					
						dx = (tr.path[tr.curNode+1].x - tr.x)
						dy = (tr.path[tr.curNode+1].y - tr.y)
						--normalize:
						d = math.sqrt(dx ^ 2 + dy ^ 2)
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
			tr.dxPrevSign = (dx < 0)
			tr.dyPrevSign = (dy < 0)
		
			fullDist = math.sqrt((tr.path[tr.curNode+1].x - tr.path[tr.curNode].x)^2 +(tr.path[tr.curNode+1].y - tr.path[tr.curNode].y)^2)
		
			partCovered = clamp(1-d/fullDist, 0, 1)	-- the part of the path between the nodes that has been traveled
		
			dx = dx/d
			dy = dy/d
		
			
			--print("before:", tr.prevAngle, tr.angle)
			--[[
			if (tr.angle - tr.prevAngle) < -math.pi then
				tr.angle = tr.angle + math.pi*2
			end
			if (tr.angle - tr.prevAngle) > math.pi then
				tr.angle = tr.angle - math.pi*2
			end]]--
			
		
			tr.smoothAngle = (tr.angle-tr.prevAngle)*partCovered + tr.prevAngle
			--print("test:", partCovered, (tr.angle-tr.prevAngle))
			--print(tr.prevAngle, tr.angle, tr.smoothAngle)
			--[[	--old:
			if dx >= 0 then
				tr.angle = math.atan(dy/dx)
			else
				tr.angle = math.atan(dy/dx) + math.pi
			end
		
			if (tr.angle - tr.smoothAngle) > math.pi then
				tr.smoothAngle = tr.smoothAngle + math.pi*2
			end
			if (tr.angle - tr.smoothAngle) < -math.pi then
				tr.smoothAngle = tr.smoothAngle - math.pi*2
			end
			
			if tr.smoothAngle < tr.angle then
				tr.smoothAngle = math.min(tr.smoothAngle + t*TRAIN_TURNSPEED, tr.angle)
			else
				tr.smoothAngle = math.max(tr.smoothAngle - t*TRAIN_TURNSPEED, tr.angle)
			end
			
			]]--
			
			--tr.smoothAngle = tr.smoothAngle + (tr.angle - tr.smoothAngle)*t*TRAIN_TURNSPEED
		
		
			tr.x = tr.x + t*dx*TRAIN_SPEED
			tr.y = tr.y + t*dy*TRAIN_SPEED
		end
	end
end

function train.moveAll()
	t = love.timer.getDelta()*timeFactor
	for k, tr in ipairs(blockedTrains) do	-- move blocked trains first! The longer they've been blocked, the earlier the move.
		moveSingleTrain(tr, t)
		tr.hasMoved = true
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


function train.clear()
	blockedTrains = {}
	trainList[1] = {}
	trainList[2] = {}
	trainList[3] = {}
	trainList[4] = {}
end

-- if I keep moving into the same direction, which direction can I move in on the next tile?
function train.getNextPossibleDirs(curTileX, curTileY , curDir)
	local nextTileX, nextTileY = curTileX, curTileY
	
	if curDir == "N" then
		nextTileY = nextTileY - 1
	elseif curDir == "S" then
		nextTileY = nextTileY + 1
	elseif curDir == "E" then
		nextTileX = nextTileX + 1
	elseif curDir == "W" then
		nextTileX = nextTileX - 1
	end
	
	railType = getRailType( nextTileX, nextTileY )
	if railType == 1 then	-- straight rail: can only keep moving in same dir
		if curDir == "N" then return {N=true}, 1
		else return {S=true}, 1 end
	end
	if railType == 2 then	-- straight rail: can only keep moving in same dir
		if curDir == "E" then return {E=true}, 1
		else return {W=true}, 1 end
	end
	--curves:
	if railType == 3 then
		if curDir == "E" then return {N=true}, 1
		else return {W=true}, 1 end
	end
	if railType == 4 then
		if curDir == "E" then return {S=true}, 1
		else return {W=true}, 1 end
	end
	if railType == 5 then
		if curDir == "W" then return {N=true}, 1
		else return {E=true}, 1 end
	end
	if railType == 6 then
		if curDir == "W" then return {S=true}, 1
		else return {E=true}, 1 end
	end
	--junctions
	if railType == 7 then
		if curDir == "S" then return {E=true, W=true}, 2
		elseif curDir == "W" then return {W=true, N=true}, 2
		else return {N=true, E=true}, 2 end
	end
	if railType == 8 then
		if curDir == "S" then return {E=true, S=true}, 2
		elseif curDir == "W" then return {S=true, N=true}, 2
		else return {N=true, E=true}, 2 end
	end
	if railType == 9 then
		if curDir == "E" then return {E=true, S=true}, 2
		elseif curDir == "W" then return {W=true, S=true}, 2
		else return {W=true, E=true}, 2 end
	end
	if railType == 10 then
		if curDir == "S" then return {S=true, W=true}, 2
		elseif curDir == "E" then return {N=true, S=true}, 2
		else return {W=true, N=true}, 2 end
	end
	if railType == 11 then
		if curDir == "E" then return {E=true, S=true, N=true}, 3
		elseif curDir == "W" then return {W=true, S=true, N=true}, 3
		elseif curDir == "S" then return {S=true, E=true, W=true}, 3
		else return {N=true, E=true, W=true}, 3 end
	end
	
	if railType == 12 then
		return {W=true}, 1
	end
	if railType == 13 then
		return {E=true}, 1
	end
	if railType == 14 then
		return {N=true}, 1
	end
	if railType == 15 then
		return {S=true}, 1
	end
end

function train.getRailPath(tileX, tileY, dir, prevDir)

	if curMapRailTypes[tileX][tileY] == 1 then
		if dir == "S" then
			return pathNS, dir
		else
			return pathSN, "N"
		end
	elseif curMapRailTypes[tileX][tileY] == 2 then
		if dir == "W" then
			return pathEW, dir
		else
			return pathWE, "E"
		end
	elseif curMapRailTypes[tileX][tileY] == 3 then
		if dir == "N" then
			return pathWN, dir
		else
			return pathNW, "W"
		end
	elseif curMapRailTypes[tileX][tileY] == 4 then
		if dir == "W" then
			return pathSW, dir
		else
			return pathWS, "S"
		end
	elseif curMapRailTypes[tileX][tileY] == 5 then
		if dir == "N" then
			return pathEN, dir
		else
			return pathNE, "E"
		end
	elseif curMapRailTypes[tileX][tileY] == 6 then
		if dir == "E" then
			return pathSE, dir
		else
			return pathES, "S"
		end
	elseif curMapRailTypes[tileX][tileY] == 7 then	-- NEW
		if dir == "E" then
			if prevDir == "E" then
				return pathWE, dir
			else
				return pathNE, "E"
			end
		elseif dir == "W" then
			if prevDir == "W" then
				return pathEW, dir
			else
				return pathNW, "W"
			end
		else
			if prevDir == "W" then
				return pathEN, dir
			else
				return pathWN, "N"
			end
		end
	elseif curMapRailTypes[tileX][tileY] == 8 then	-- NES
		if dir == "N" then
			if prevDir == "N" then
				return pathSN, dir
			else
				return pathEN, "N"
			end
		elseif dir == "S" then
			if prevDir == "S" then
				return pathNS, dir
			else
				return pathES, "S"
			end
		else
			if prevDir == "N" then
				return pathSE, dir
			else
				return pathNE, "E"
			end
		end
	elseif curMapRailTypes[tileX][tileY] == 9 then	-- ESW
		if dir == "E" then
			if prevDir == "E" then
				return pathWE, dir
			else
				return pathSE
			end
		elseif dir == "W" then
			if prevDir == "W" then
				return pathEW, dir
			else
				return pathSW, "W"
			end
		else
			if prevDir == "W" then
				return pathES, dir
			else
				return pathWS, "S"
			end
		end
	elseif curMapRailTypes[tileX][tileY] == 10 then	-- NSW
		if dir == "N" then
			if prevDir == "N" then
				return pathSN, dir
			else
				return pathWN, "N"
			end
		elseif dir == "S" then
			if prevDir == "S" then
				return pathNS, dir
			else
				return pathWS, "S"
			end
		else
			if prevDir == "S" then
				return pathNW, dir
			else
				return pathSW, "W"
			end
		end
	elseif curMapRailTypes[tileX][tileY] == 11 then	-- NESW
		if dir == "N" then
			if prevDir == "N" then
				return pathSN
			elseif prevDir == "E" then
				return pathWN, dir
			else
				return pathEN, "N"
			end
		elseif dir == "S" then
			if prevDir == "S" then
				return pathNS, dir
			elseif prevDir == "E" then
				return pathWS, dir
			else
				return pathES, "S"
			end
		elseif dir == "E" then
			if prevDir == "E" then
				return pathWE, dir
			elseif prevDir == "N" then
				return pathSE, dir
			else
				return pathNE, "E"
			end
		else
			if prevDir == "W" then
				return pathEW, dir
			elseif prevDir == "S" then
				return pathNW, dir
			else
				return pathSW, "W"
			end
		end
	elseif curMapRailTypes[tileX][tileY] == 12 then	-- W
		return pathWW, "W"
	elseif curMapRailTypes[tileX][tileY] == 13 then	-- E
		return pathEE, "E"
	elseif curMapRailTypes[tileX][tileY] == 14 then	-- N
		return pathNN, "N"
	elseif curMapRailTypes[tileX][tileY] == 15 then	-- S
		return pathSS, "S"
	end
	print("Path not found", tileX, tileY)
	return pathNS, "S"		--fallback, should never happen!
end

function train.show()
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
			
			love.graphics.setColor(0,0,0,120)
			love.graphics.draw( tr.image, x - 5, y + 8, tr.smoothAngle, 1, 1, tr.image:getWidth()/2, tr.image:getHeight()/2 )
			
			love.graphics.setColor(255,255,255,255)
			love.graphics.draw( tr.image, x, y, tr.smoothAngle, 1, 1, tr.image:getWidth()/2, tr.image:getHeight()/2 )
			--love.graphics.print( tr.name, x, y+30)
		end
	end
end

return train
