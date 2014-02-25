local ch = {}

ch.name = "TheMaze"
ch.version = "5"

ch.maxTrains = 1
ch.startMoney = 25

-- create a new, empty map:
ch.map = challenges.createEmptyMap(35, 25)

function countNeighbouringRails(x,y)
	local numNeighbouringRails = 0
	if ch.map[x+1][y] == "C" then
		numNeighbouringRails = numNeighbouringRails + 1
	end
	if ch.map[x-1][y] == "C" then
		numNeighbouringRails = numNeighbouringRails + 1
	end
	if ch.map[x][y+1] == "C" then
		numNeighbouringRails = numNeighbouringRails + 1
	end
	if ch.map[x][y-1] == "C" then
		numNeighbouringRails = numNeighbouringRails + 1
	end
	
	return numNeighbouringRails
end

function makePath(startX, startY)
	local stuck = false
	local curX,curY = startX,startY
	local numRails = 0
	local tries = 0
	while stuck == false do

		ch.map[curX][curY] = "C"
		
		possibleDirs = {}
		-- check up:
		if curY > 1 and countNeighbouringRails(curX, curY-1) <= 1 then
			table.insert(possibleDirs, "N")
		end
		-- check down:
		if curY < ch.map.height and countNeighbouringRails(curX, curY+1) <= 1 then
			table.insert(possibleDirs, "S")
		end
		-- check right:
		if curX < ch.map.width and countNeighbouringRails(curX+1, curY) <= 1 then
			table.insert(possibleDirs, "E")
		end
		-- check left:
		if curX > 1 and countNeighbouringRails(curX-1, curY) <= 1 then
			table.insert(possibleDirs, "W")
		end
		
		if #possibleDirs == 0 then
			stuck = true
		else
			dir = possibleDirs[math.random(#possibleDirs)]
			if dir == "N" then curY = curY-1
			elseif dir == "S" then curY = curY+1
			elseif dir == "E" then curX = curX+1
			else curX = curX-1
			end
		end
		numRails = numRails + 1
		
		if stuck == true and tries < 5 then
			tries = tries + 1
			
			stuck = false
		end
	end
	
	return curX, curY, numRails
end


function removeFromTable(tbl,value)
	for k = 1, #tbl do
		if tbl[k] == value then
			table.remove(tbl, k)
			return
		end
	end
end

function drunkardWalk()
	local curX = math.random(ch.map.width)
	local curY = math.random(ch.map.height)
	local nodesAdded = 0
	
	while nodesAdded < ch.map.width*ch.map.height/5 do
	
		if ch.map[curX][curY] ~= "C" then
			ch.map[curX][curY] = "C"
			nodesAdded = nodesAdded+1
		end
	
		dirs = {"N", "S", "W", "E"}
		if curX < 3 then removeFromTable(dirs, "W") end
		if curX > ch.map.width-3 then removeFromTable(dirs, "E") end
		if curY < 3 then removeFromTable(dirs, "N") end
		if curY > ch.map.height-3 then removeFromTable(dirs, "S") end
		
		dir = dirs[math.random(#dirs)]
		if dir == "N" then
			if ch.map[curX][curY-2] ~= "C" then ch.map[curX][curY-1] = "C" end
			curY = curY-2
		elseif dir == "S" then
			if ch.map[curX][curY+2] ~= "C" then ch.map[curX][curY+1] = "C" end
			curY = curY+2
		elseif dir == "E" then
			if ch.map[curX+2][curY] ~= "C" then ch.map[curX+1][curY] = "C" end
			curX = curX+2
		else
			if ch.map[curX-2][curY] ~= "C" then ch.map[curX-1][curY] = "C" end
			curX = curX-2
		end
	end
end


-- fill some of the tiles with Rails and Houses:
--makePath(1,1)
drunkardWalk()


function findClosestRail(x, y)
	if ch.map[x][y] ~= "C" then
		local foundX = nil
		local foundY = nil
		local dist = 1

		-- search for "C" around the given position. If not found, increase the radius (dist)
		while (not foundX or not foundY) and dist < math.max(ch.map.width, ch.map.height) do
			for i = -dist,dist do
				for j = -dist,dist do
					if x +i > 0 and y+j > 0 and x +i < ch.map.width and y+j < ch.map.width then
						if ch.map[x + i][y + j] == "C" then
							foundX = x + i
							foundY = y + j
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
			print("Error: could not find Rail for passenger!")
		else
			return foundX, foundY
		end
	else
		return x,y
	end
end


local startTime = 0
local passengersCreated = false
local maxTime = 315
local passengersRemaining = 1
local startupMessage = "This map is meant for practice. There's only one path to the destination of the passenger - try to get the right path every time, without trial and error!\nWrite a proper pathfinding algorithm to do so! Then go back to the menu and start this same map again to make sure your pathfinding is working - this map is different every time you start it!"

function ch.start()
	--challenges.setMessage(startupMessage)
	
	passengerStartX, passengerStartY = findClosestRail(1,1)
	passengerEndX, passengerEndY = findClosestRail(ch.map.width, ch.map.height)
	passenger.new(passengerStartX, passengerStartY, passengerEndX, passengerEndY)
end

function ch.update(time)

	challenges.setStatus("Map by Germanunkol\n" .. passengersRemaining .. " Passengers remaining.")
	--[[if time > maxTime then
		return "lost"--, --"Oh noes, some inhabitants will starve today..."
	end]]--
	if passengersRemaining == 0 then
		return "won", "Found the maze's exit after: " .. makeTimeReadable(time) .. "!"
	end
end

function ch.passengerDroppedOff(tr, p)
	if tr.tileX == p.destX and tr.tileY == p.destY then		
		passengersRemaining = passengersRemaining - 1
	end
end



return ch
