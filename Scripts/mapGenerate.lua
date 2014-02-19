
local args = {...}

local channelIn = args[1]
local channelOut = args[2]

local width = args[3]
local height = args[4]
local seed = args[5]
local tutorialMap = args[6]
local region = args[7]

require("love.filesystem")
package.path = "Scripts/?.lua;" .. package.path

pcall(require, "mapUtils")
pcall(require, "Scripts/mapUtils")
pcall(require, "TSerial")
pcall(require, "Scripts/TSerial")
pcall(require, "misc")
pcall(require, "Scripts/misc")

print = function(...)
	local sendStr = ""
	
	local arg = { ... }
	for i = 1, #arg do
		if arg[i] then
			sendStr = sendStr .. arg[i] .. "\t"
		end
	end
	channelOut:push({key="msg", sendStr})
end

------------------------------------
-- Start generating the map:

if tutorialMap then
	tutorialMap = TSerial.unpack(tutorialMap)
	width = tutorialMap.width
	height = tutorialMap.height
end

math.randomseed(seed)

if not tutorialMap then
	curMap = {width=width, height=height, time=0}
	curMap.region = region or "Suburban"
	curMap.seed = seed
else
	tutorialMap.region = region or "Suburban"
	tutorialMap.seed = seed
end
curMapOccupiedTiles = {}
curMapOccupiedExits = {}
curMapRailTypes = {}

channelOut:push({key="percentage", 0})

for i = 0,width+1 do
	if not tutorialMap then curMap[i] = {} end
	curMapRailTypes[i] = {}
	if i >= 1 and i <= width then 
		curMapOccupiedTiles[i] = {}
		curMapOccupiedExits[i] = {}
		for j = 1, height do
			curMapOccupiedTiles[i][j] = {}
			curMapOccupiedTiles[i][j].from = {}
			curMapOccupiedTiles[i][j].to = {}

			curMapOccupiedExits[i][j] = {}
		end
	end
end

if not tutorialMap then


	channelOut:push({key="status", "rails"})

	channelOut:push({key="percentage", 10})
	generateRailRectangles()
	channelOut:push({key="percentage", 20})

	clearLargeJunctions()
	channelOut:push({key="percentage", 30})
	connectLooseEnds()
	channelOut:push({key="percentage", 40})
else
	curMap = tutorialMap

	for i = 0,width+1 do
		for j = 0, height+1 do
			if curMap[i][j] == "SCHOOL" then
				curMap[i][j] = "SCHOOL11"
				curMap[i][j+1] = "SCHOOL12"
				curMap[i+1][j] = "SCHOOL21"
				curMap[i+1][j+1] = "SCHOOL22"
			end
		end
	end

end

calculateRailTypes()
channelOut:push({key="percentage", 50})

if not tutorialMap then

	channelOut:push({key="status","houses"})
	placeHouses()
	channelOut:push({key="percentage", 60})

	channelOut:push({key="status","hotspots"})
	placeHotspots()
	channelOut:push({key="percentage", 70})
end

generateRailList()
channelOut:push({key="percentage", 90})

for i = 0,width+1 do
	for j = 0, height+1 do
		if curMap[i][j] == "SCHOOL" then
			curMap[i][j] = "S"
		end
	end
end

channelOut:push({key="percentage", 100})
-- return the results to parent (main) thread:
channelOut:push({key="curMap", TSerial.pack(curMap)})
channelOut:push({key="curMapRailTypes", TSerial.pack(curMapRailTypes)})
channelOut:push({key="curMapOccupiedTiles", TSerial.pack(curMapOccupiedTiles)})
channelOut:push({key="curMapOccupiedExits", TSerial.pack(curMapOccupiedExits)})
channelOut:push({key="status", "done"})
