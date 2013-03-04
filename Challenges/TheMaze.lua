local ch = {}

ch.name = "Challenge1"
ch.version = "1"

ch.maxTrains = 1
ch.startMoney = 25

-- create a new, empty map:
ch.map = challenges.createEmptyMap(20, 20)

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
		map.print(ch.map)
	end
end


-- fill some of the tiles with Rails and Houses:
--makePath(1,1)
drunkardWalk()

local startTime = 0
local passengersCreated = false
local maxTime = 315
local passengersRemaining = 4
local startupMessage = "After the railway was built, lots of people started moving to Smalltown.\nThe city grew.\nStill, there was no store in Smalltown - so people had to get to the neighbouring town to buy food. Get them there, and fast!"

function ch.start()
	--challenges.setMessage(startupMessage)
end

function ch.update(time)

	if time > maxTime then
		return "lost", "Oh noes, some inhabitants will starve today..."
	end
	if passengersRemaining == 0 then
		return "won", "Food for everyone!"
	end
	challenges.setStatus("Map by Germanunkol\n" .. math.floor(maxTime-time) .. " seconds remaining.\n4 Passengers remaining.")
end

function ch.passengerDroppedOff(tr, p)
	if tr.tileX == p.destX and tr.tileY == p.destY then		
		passengersRemaining = passengersRemaining - 1
	end
end

return ch
