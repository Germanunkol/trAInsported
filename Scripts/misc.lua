
function seperateStrings(str, seperator)
	tbl = {}
	index = 1
	for val in string.gfind(str, ".-,") do
		tbl[index] = val:sub(1,#val-1)
		index = index + 1
	end
	return tbl
end

function makeTimeReadable(time)
	days = math.floor(time/(60*60*24))
	time = time - days*60*60*24
	hours = math.floor(time/(60*60))
	time = time - hours*60*60
	minutes = math.floor(time/(60))
	time = time - minutes*60
	seconds = time
	
	local str = ""
	if days > 0 then str = str .. days .. " days " end
	if hours > 0 then str = str .. hours .. " h " end
	if minutes > 0 then str = str .. minutes .. " mins " end
	if seconds > 0 then str = str .. math.floor(seconds) .. " secs " end
	return str
end

function incrementID( num )
	if num == 99999 then
		num = 0
	else
		num = num + 1
	end
	return num
end


function clamp(x, min, max)
	return math.max(math.min(x, max), min)
end

function cycle(x, min, max)
	y = math.floor(x/(max-min))-1
	if y > 1 then
		x = x - y*(max-min)
	end
	while x > max do
		x = x - (max-min)
	end
	while x < min do
		x = x + (max-min)
	end
	return x
end

function getPlayerColour(ID)
	if ID == 1 then
		return PLAYERCOLOUR1_CONSOLE
	end
	if ID == 2 then
		return PLAYERCOLOUR2_CONSOLE
	end
	if ID == 3 then
		return PLAYERCOLOUR3_CONSOLE
	end
	if ID == 4 then
		return PLAYERCOLOUR4_CONSOLE
	end
end

function dropAlpha(x,y,r,g,b,a)
	return r,g,b,255
end

function vonNeumannRandom(seed)		-- generates a random number using the von Neumann method.
	str = tostring(seed^2)
	while #str < 7 do
		str = "0" .. str
	end
	return tonumber(str:sub(2,6))
end


function generateColour(name, brightness)
	brightness = brightness or 1
	sum = 0
	for i = 1,#name do
		sum = sum + name:byte(i,i)
	end
	_ = vonNeumannRandom(sum)		--discard first number, it's usually too similar.
	__ = vonNeumannRandom(_)		--discard first number, it's usually too similar.
	___ = vonNeumannRandom(__)		--discard first number, it's usually too similar.
	red = vonNeumannRandom(___)
	green = vonNeumannRandom(red)
	blue = vonNeumannRandom(green)
	red = cycle(red, 0, 255)
	blue = cycle(blue, 0, 255)
	green = cycle(green, 0, 255)
	return {r=clamp(red*brightness, 0, 255), g=clamp(green*brightness, 0, 255), b=clamp(blue*brightness, 0, 255)}
end

function getScreenshot()
	local curTime = os.date("*t")
	local fileName
	if curTime then
		fileName = curTime.year .."-".. curTime.month .."-".. curTime.day .. "_" .. curTime.hour .."-".. curTime.min .."-".. curTime.sec .. ".png"
	else
		fileName = math.random(99999)
	end

	timeFactor = timeFactorList[1]
	functionQueue.new(2, function () timeFactor = timeFactorList[timeFactorIndex] end, nil)
	print( "Screenshot: " .. love.filesystem.getSaveDirectory() )
	screen = love.graphics.newScreenshot()
	screen:mapPixel(dropAlpha)
	screen:encode(fileName)
end

function copyTable(tbl)
	local newTbl = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			newTbl[k] = copyTable(v)
		else
			newTbl[k] = v
		end
	end
	return newTbl
end

function printTable(tbl, lvl)
	lvl = lvl or 1
	local str = ""
	for i = 1,lvl-1 do
		str = str .. "\t"
	end
	if lvl > 10 then print("Maximum Level Depth reached")
	else
		for k, v in pairs(tbl) do
			if type(v) == "table" then
				print(str,k.. "{")
				printTable(v, lvl + 1)
				print(str, "}")
			else
				print(str, k, v)
			end
		end
	end
end

function readOnlyTable(table)
   return setmetatable({}, {
     __index = table,
     __newindex = function(table, key, value)
                    error("Attempt to modify read-only table")
                  end,
     __metatable = false
   });
end

function randomizeTable(tbl)	
	for i = 1,#tbl do
		index1 = math.random(#tbl)
		index2 = math.random(#tbl)
		tbl[index1], tbl[index2] = tbl[index2], tbl[index1]
	end
end

function matrixMultiply(mat, vec)
	return mat.aa*vec.x + mat.ab*vec.y, mat.ba*vec.x + mat.bb*vec.y
end

function vecDist(x1,y1,x2,y2)
	return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end
