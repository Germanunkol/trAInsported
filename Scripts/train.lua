
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
local TRAIN_TURNSPEED = TRAIN_SPEED/20

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
			trainList[aiID][i] = setmetatable({image = image, ID = i}, button_mt)
			
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
			map.setTileOccupied(x, y, nil, dir)
			
			if path and path[1] then		--place at the center of the current piece.
				curPathNode = math.ceil((#path-1)/2)
				--local position:
				trainList[aiID][i].x = (path[curPathNode+1].x - path[curPathNode].x)/2 + path[curPathNode].x
				trainList[aiID][i].y = (path[curPathNode+1].y - path[curPathNode].y)/2 + path[curPathNode].y
				
				dx = (path[curPathNode+1].x - trainList[aiID][i].x)
				dy = (path[curPathNode+1].y - trainList[aiID][i].y)
				if dx >= 0 then
					trainList[aiID][i].angle = math.atan(dy/dx)
				else
					trainList[aiID][i].angle = math.atan(dy/dx) + math.pi
				end
				
				trainList[aiID][i].smoothAngle = trainList[aiID][i].angle
				trainList[aiID][i].path = path
				trainList[aiID][i].curNode = curPathNode
				trainList[aiID][i].dir = dir
				
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
		print(v, tr)
		if v == tr then
			removedID = k
		elseif removedID then
			blockedTrains[k-1] = blockedTrains[k]
		end
	end
	if removedID then blockedTrains[#blockedTrains] = nil
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
				if not tr.path[tr.curNode+2] and not tr.freedTileOccupation then
					map.resetTileOccupied(tr.tileX, tr.tileY, tr.cameFromDir, tr.dir)	-- free up previously blocked path! Important, otherwise everthing could block.
				end
			else
				
				local nextX, nextY = tr.tileX, tr.tileY
				local cameFromDir = ""
				
				if not tr.blocked then
					possibleDirs = train.getNextPossibleDirs(tr.tileX, tr.tileY, tr.dir)
				
					tr.nextDir = possibleDirs[math.random(#possibleDirs)]
					
					if not tr.freedTileOccupation then
						map.resetTileOccupied(tr.tileX, tr.tileY, tr.cameFromDir, tr.dir)	-- free up previously blocked path! Important, otherwise everthing could block.
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
					
						for k, v in pairs(path) do
							print(k, "x:" .. v.x, "y:" .. v.y)
						end
					
						tr.curNode = 1
					
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
		
		
			dx = dx/d
			dy = dy/d
		
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
			tr.smoothAngle = tr.smoothAngle + (tr.angle - tr.smoothAngle)*t*TRAIN_TURNSPEED
		
		
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
	if railType == 1 or railType == 2 then		-- straight rail: can only keep moving in same dir
		return {curDir}
	end
	--curves:
	if railType == 3 then
		if curDir == "E" then return {"N"}
		else return {"W"} end
	end
	if railType == 4 then
		if curDir == "E" then return {"S"}
		else return {"W"} end
	end
	if railType == 5 then
		if curDir == "W" then return {"N"}
		else return {"E"} end
	end
	if railType == 6 then
		if curDir == "W" then return {"S"}
		else return {"E"} end
	end
	--junctions
	if railType == 7 then
		if curDir == "S" then return {"E", "W"}
		elseif curDir == "W" then return {"W", "N"}
		else return {"N", "E"} end
	end
	if railType == 8 then
		if curDir == "S" then return {"E", "S"}
		elseif curDir == "W" then return {"S", "N"}
		else return {"N", "E"} end
	end
	if railType == 9 then
		if curDir == "E" then return {"E", "S"}
		elseif curDir == "W" then return {"W", "S"}
		else return {"W", "E"} end
	end
	if railType == 10 then
		if curDir == "S" then return {"S", "W"}
		elseif curDir == "E" then return {"N", "S"}
		else return {"W", "N"} end
	end
	if railType == 11 then
		if curDir == "E" then return {"E", "S", "N"}
		elseif curDir == "W" then return {"W", "S", "N"}
		elseif curDir == "S" then return {"S", "E", "W"}
		else return {"N", "E", "W"} end
	end
	
	if railType == 12 then
		return {"W"}
	end
	if railType == 13 then
		return {"E"}
	end
	if railType == 14 then
		return {"N"}
	end
	if railType == 15 then
		return {"S"}
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
			love.graphics.draw( tr.image, tr.tileX*TILE_SIZE+tr.x, tr.tileY*TILE_SIZE + tr.y, tr.smoothAngle, 1, 1, tr.image:getWidth()/2, tr.image:getHeight()/2 )
		end
	end
end

return train
