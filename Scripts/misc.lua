
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
		if type(v) == "tbl" then
			newTbl[k] = copyTable(v)
		else
			newTbl[k] = v
		end
	end
	return newTbl
end

function printTable(table, lvl)
	print(starting)
	lvl = lvl or 0
	if lvl > 10 then print("Maximum Level Depth reached")
	else
		for k, v in pairs(table) do
			if type(v) == "table" then
				print("\t\t\t", type(v))
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

function readOnlyTable(table)
   return setmetatable({}, {
     __index = table,
     __newindex = function(table, key, value)
                    error("Attempt to modify read-only table")
                  end,
     __metatable = false
   });
end


function matrixMultiply(mat, vec)
	return mat.aa*vec.x + mat.ab*vec.y, mat.ba*vec.x + mat.bb*vec.y
end

function vecDist(x1,y1,x2,y2)
	return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end
