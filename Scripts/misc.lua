
function clamp(x, min, max)
	return math.max(math.min(x, max), min)
end


function dropAlpha(x,y,r,g,b,a)
	return r,g,b,255
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
	for k, v in pairs(table) do
		if type(v) == "table" then
			--printTable(table, lvl + 1)
		else
			str = ""
			for i = 1,lvl do
				str = str .. "\t"
			end
			print(str, k, v)
		end
	end
end
