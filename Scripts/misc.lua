
function clamp(x, min, max)
	return math.max(math.min(x, max), min)
end

function cycle(x, min, max)
	y = math.floor(x/(max-min))-1
	print("before", x, min, may)
	if y > 1 then
		x = x - y*(max-min)
	end
	print("after", x, min, may)
	while x > max do
		x = x - (max-min)
	end
	while x < min do
		x = x + (max-min)
	end
	return x
end

function dropAlpha(x,y,r,g,b,a)
	return r,g,b,255
end

function vonNeumannRandom(seed)		-- generates a random number using the von Neumann method.
	print("neumann:")
	str = tostring(seed^2)
	print(str)
	while #str < 7 do
		str = "0" .. str
	end
	print(tonumber(str:sub(2,6)))
	return tonumber(str:sub(2,6))
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

function printTable(table, lvl)
	lvl = lvl or 0
	if lvl > 10 then print("Maximum Level Depth reached")
	else
		for k, v in pairs(table) do
			if type(v) == "table" then
				printTable(v, lvl + 1)
			else
				str = ""
				for i = 1,lvl do
					str = str .. "\t"
				end
				print(str, k, v)
			end
		end
	end
end
