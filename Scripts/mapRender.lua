thisThread = love.thread.getThread()

package.path = "Scripts/?.lua;" .. package.path

require("love.image")
require("love.filesystem")
pcall(require, "TSerial")
pcall(require, "Scripts/TSerial")
pcall(require, "misc")
pcall(require, "Scripts/misc")

-- load "globals" in dedicated mode, only get variables:
rememberDedi = DEDICATED
DEDICATED = true
pcall(require, "globals")
pcall(require, "Scripts/globals")
DEDICATED = rememberDedi

-- find out how many threads should be used (split the map up into this number of threads/images)
numThreads = getCPUNumber() or 1
--numThreads = 1
numDivisions = math.ceil(math.sqrt(numThreads))			-- by what number x and y are to be devided.


local percentageStep = 0
local renderingPercentage = 0

function updatePercentage()
	renderingPercentage = renderingPercentage + percentageStep
	thisThread:set("percentage", renderingPercentage)	
end


while true do
	curMap = TSerial.unpack(thisThread:demand("curMap"))
	curMapRailTypes = thisThread:demand("curMapRailTypes")
	TILE_SIZE = thisThread:demand("TILE_SIZE")
	
	NO_TREES = thisThread:get("NO_TREES")

	SEED = curMap.height*curMap.width

	for i = 1, curMap.width do
		for j = 1, curMap.height do
			if curMap[i][j] == "H" then
				SEED = SEED + curMap.height*curMap.width*i*j
			end
		
			if curMap[i][j] == "C" then
				SEED = SEED + curMap.height*curMap.width*i*j
			end
		end
	end

	MAX_IMG_SIZE_PX = MAX_IMG_SIZE*TILE_SIZE

	SEED = SEED % 9999

	math.randomseed(SEED)

	thisThread:set("percentage", -2)

	percentageStep = 0
	renderingPercentage = 0
	statusNum = nil	--restart

	if curMap then
	
		partWidth = math.min(math.ceil(curMap.width/numDivisions), MAX_IMG_SIZE)
		partHeight = math.min(math.ceil(curMap.height/numDivisions), MAX_IMG_SIZE)
		numImagesX = math.ceil(curMap.width/partWidth)
		numImagesY = math.ceil(curMap.height/partHeight)
		
		threadSendStatus(thisThread, "Split map into " .. numImagesX*numImagesY .. " parts.")
		threadSendStatus(thisThread, "Using " .. numThreads .. " threads.")
		threadSendStatus(thisThread, "Map: " .. curMap.width .. "x" .. curMap.height )
		percentageStep = 100/(numImagesX*numImagesY)
		
		
		-- split map into parts of roughly equal size:
		parts = {}
		for i = 1,numImagesX do
			parts[i] = {}
			for j = 1,numImagesY do
				parts[i][j] = {}
				parts[i][j].map = {width = math.min(partWidth, curMap.width - (i-1)*partWidth), height = math.min(partHeight, curMap.height - (j-1)*partHeight)}
				for k=1,parts[i][j].map.width do
					parts[i][j].map[k] = {}
				end
				
				if i == 1 then	--left side
					parts[i][j].map.left = true
				end
				if i == numImagesX then	--right side
					parts[i][j].map.right = true
				end
				if j == 1 then
					parts[i][j].map.top = true
				end
				if j == numImagesY then
					parts[i][j].map.bottom = true
				end
				parts[i][j].running = false
				parts[i][j].finished = false
				parts[i][j].done = false
			end
		end
		-- fill theses parts with the data from the curMap:
		for k = 1,curMap.width do
			curPartX = math.ceil(k/partWidth)
			for l = 1, curMap.height do
				curPartY = math.ceil(l/partHeight)
				parts[curPartX][curPartY].map[k-partWidth*(curPartX-1)][l-partHeight*(curPartY-1)] = curMap[k][l]
			end
		end
		
		groundData = {}
		shadowData = {}
		objectData = {}

		for i = 0,numImagesX do
			groundData[i] = {}
			shadowData[i] = {}
			objectData[i] = {}
			--[[for j = 0,numImagesY do
				groundData[i][j] = love.image.newImageData(MAX_IMG_SIZE*TILE_SIZE, MAX_IMG_SIZE*TILE_SIZE)		-- ground map
				shadowData[i][j] = love.image.newImageData(MAX_IMG_SIZE*TILE_SIZE, MAX_IMG_SIZE*TILE_SIZE)		-- ground map
				objectData[i][j] = love.image.newImageData(MAX_IMG_SIZE*TILE_SIZE, MAX_IMG_SIZE*TILE_SIZE)		-- ground map
			end]]--
		end
		
		
		local threadsDone = 0
		local numParts = numImagesX*numImagesY
		local numThreadsRunning = 0
		while threadsDone < numParts do
		
			if thisThread:get("abort") then
				abort = true
			end
		
			for i = 1,numImagesX do
				for j = 1,numImagesY do
					if parts[i][j].running == false and parts[i][j].finished == false and numThreadsRunning < numThreads then
						if abort then		-- don't start more threads when the abort-signal has been sent.
							threadsDone = threadsDone + 1
						else
							parts[i][j].running = true
							parts[i][j].thread = love.thread.newThread(os.time().."mapGeneratingThread(" .. i .. "," .. j .. ")", "Scripts/mapRenderPart.lua")
							parts[i][j].thread:start()
						
							parts[i][j].thread:set("map", TSerial.pack(parts[i][j].map))
							parts[i][j].thread:set("curMapRailTypes", curMapRailTypes)
						
							parts[i][j].thread:set("startCoordinateX", (i-1)*partWidth)
							parts[i][j].thread:set("startCoordinateY", (j-1)*partHeight)
							numThreadsRunning = numThreadsRunning + 1
						end
					end
					if parts[i][j].thread then
						status =  parts[i][j].thread:get("status")
						if status == "done" then
							parts[i][j].running = false
							parts[i][j].finished = true
							numThreadsRunning = numThreadsRunning - 1
							threadsDone = threadsDone + 1
							groundData[i][j] = parts[i][j].thread:get("groundData")
							shadowData[i][j] = parts[i][j].thread:get("shadowData")
							objectData[i][j] = parts[i][j].thread:get("objectData")

							parts[i][j].thread:wait()
							parts[i][j].thread = nil
							updatePercentage()
						elseif abort then
							parts[i][j].thread:set("abort", true)
							parts[i][j].thread:wait()
							parts[i][j].thread = nil
							threadsDone = threadsDone + 1
						end
					end
					if parts[i][j].thread then
						err = parts[i][j].thread:get("error")
						if err then
							error("Error in sub-thread: ".. err)
						end
					end
				end
			end
		end
		
		thisThread:set("dimensionX", numImagesX)
		thisThread:set("dimensionY", numImagesY)
		for i = 1, numImagesX do
			for j = 1, numImagesY do
				thisThread:set("groundData:" .. i .. "," .. j, groundData[i][j])
				thisThread:set("shadowData:" .. i .. "," .. j, shadowData[i][j])
				thisThread:set("objectData:" .. i .. "," .. j, objectData[i][j])
			end
		end
		
		highlightList = {}
		thisThread:set("highlightList", TSerial.pack(highlightList))
		
		thisThread:set("status", "done")
	end

end

