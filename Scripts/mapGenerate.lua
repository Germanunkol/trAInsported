require("love.filesystem")

file = love.filesystem.newFile( "threadLog.txt" )
file:open("w")

file:write("1\n")
thisThread = love.thread.getThread()

package.path = "Scripts/?.lua;" .. package.path

require("mapUtils")
require("TSerial")
require("misc")

local msgNumber = 0
print = function(...)
	sendStr = ""
	for i = 1, #arg do
		if arg[i] then
			sendStr = sendStr .. arg[i] .. "\t"
		end
	end
	thisThread:set("msg" .. msgNumber, sendStr)
	msgNumber = incrementID(msgNumber)
end

print("2")
file:write("2\n")


print("4")
width = thisThread:demand("width")

file:write("5\n")
print("5")
height = thisThread:demand("height")
seed = thisThread:demand("seed")
tutorialMap = thisThread:get("tutorialMap")

print("6")
file:write("6\n")


if tutorialMap then
	tutorialMap = TSerial.unpack(tutorialMap)
	width = tutorialMap.width
	height = tutorialMap.height
end

print("7")
file:write("7\n")

math.randomseed(seed)
if not tutorialMap then curMap = {width=width, height=height, time=0} end
curMapOccupiedTiles = {}
curMapOccupiedExits = {}
curMapRailTypes = {}


print("8")
file:write("8\n")
thisThread:set("percentage", 0)

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

print("9")
file:write("9\n")
if not tutorialMap then

	--thisThread:set("status", "rails")
	
	threadSendStatus( thisThread,"rails")
	thisThread:set("percentage", 10)
	generateRailRectangles()
	thisThread:set("percentage", 20)

	clearLargeJunctions()
	thisThread:set("percentage", 30)
	connectLooseEnds()
	thisThread:set("percentage", 40)
else
	curMap = tutorialMap
end

print("10")
file:write("10\n")
calculateRailTypes()
thisThread:set("percentage", 50)

if not tutorialMap then
	--thisThread:set("status", "houses")
	
	threadSendStatus( thisThread,"houses")
	placeHouses()
	thisThread:set("percentage", 60)

	--thisThread:set("status", "hotspots")
	
	threadSendStatus( thisThread,"hotspots")
	placeHotspots()
	thisThread:set("percentage", 70)
end

generateRailList()
thisThread:set("percentage", 90)

-- return the results to parent (main) thread:
thisThread:set("curMap", TSerial.pack(curMap))
thisThread:set("curMapRailTypes", TSerial.pack(curMapRailTypes))
thisThread:set("curMapOccupiedTiles", TSerial.pack(curMapOccupiedTiles))
thisThread:set("curMapOccupiedExits", TSerial.pack(curMapOccupiedExits))
thisThread:set("status", "done")

print("I'm done!")
file:write("Done\n")
return
