local statistics = {}

local aiStats = {}


local IMAGE_STATS_PICKUP = love.graphics.newImage("Images/StatsIconPickUp.png")
local IMAGE_STATS_DROPOFF = love.graphics.newImage("Images/StatsIconDropOff.png")
local IMAGE_STATS_DROPOFF_WRONG = love.graphics.newImage("Images/StatsIconDropOffWrong.png")
local IMAGE_STATS_CASH = love.graphics.newImage("Images/StatsIconCash.png")
local IMAGE_STATS_TIME = love.graphics.newImage("Images/StatsIconTime.png")

local statBoxPositive = nil
local statBoxNegative = nil

function statistics.setAIName(aiID, name)
	if aiStats[aiID] then
		aiStats[aiID].name = name
	end
end

function statistics.setAIName(aiID, red, green, blue)
	if aiStats[aiID] then
		aiStats[aiID].red = red
		aiStats[aiID].green = green
		aiStats[aiID].blue = blue
	end
end

function statistics.addTrain( aiID, train )
	aiStats[aiID].trains[train.ID] = train
	aiStats[aiID].trains[train.ID].pPickedUp = 0		-- number of passengers which were picked up
	aiStats[aiID].trains[train.ID].pDroppedOff = 0	-- number of passengers dropped off
	aiStats[aiID].trains[train.ID].pTransported = 0	-- only set if the player has transported the passenger to his/her destination
	aiStats[aiID].trains[train.ID].timeBlocked = 0
	aiStats[aiID].trains[train.ID].pNormal = 0
	aiStats[aiID].trains[train.ID].pVIP = 0
	aiStats[aiID].numTrains = aiStats[aiID].numTrains + 1
end

function statistics.addMoney( aiID, money )
	aiStats[aiID].money = aiStats[aiID].money + money
	aiStats[aiID].moneyEarnedTotal = aiStats[aiID].moneyEarnedTotal + money
	if aiStats[aiID].money >= TRAIN_COST then
		ai.enoughMoney(aiID, aiStats[aiID].money)
	end
end

function statistics.subMoney( aiID, money )
	if aiStats[aiID].money >= money then
		aiStats[aiID].money = aiStats[aiID].money - money
		return true
	else
		return false
	end
end

function statistics.getMoney( aiID )
	if aiStats[aiID] then
		return aiStats[aiID].money
	else
		return 0
	end
end

function statistics.getMoneyAI( aiID )
	return function ()
		if aiStats[aiID] then
			return (aiStats[aiID].money)
		end
	end
end

function statistics.passengersPickedUp( aiID, trainID )
	aiStats[aiID].pPickedUp = aiStats[aiID].pPickedUp + 1
	aiStats[aiID].trains[trainID].pPickedUp = aiStats[aiID].trains[trainID].pPickedUp + 1
end

function statistics.droppedOff( aiID, trainID )
	aiStats[aiID].pDroppedOff = aiStats[aiID].pDroppedOff + 1
	aiStats[aiID].trains[trainID].pDroppedOff = aiStats[aiID].trains[trainID].pDroppedOff + 1
end

function statistics.broughtToDestination( aiID, trainID, vip )
	aiStats[aiID].pTransported = aiStats[aiID].pTransported + 1
	aiStats[aiID].trains[trainID].pTransported = aiStats[aiID].trains[trainID].pTransported + 1
	
	if vip then
		aiStats[aiID].pVIP = aiStats[aiID].pVIP + 1
		aiStats[aiID].trains[trainID].pVIP = aiStats[aiID].trains[trainID].pVIP + 1
	else	
		aiStats[aiID].pNormal = aiStats[aiID].pNormal + 1
		aiStats[aiID].trains[trainID].pNormal = aiStats[aiID].trains[trainID].pNormal + 1
	end
end

function statistics.trainBlockedTime( aiID, trainID, time )
	aiStats[aiID].trains[trainID].timeBlocked = aiStats[aiID].trains[trainID].timeBlocked + time
end

function secondsToReadableTime(time)		-- convert time given in seconds to a human readable time format (hours, mins, seconds)
	local hours = math.floor(time/3600)
	local mins = math.floor((time - hours*3600)/60)
	local secs = math.ceil(time - hours*3600 - mins*60)
	return hours .. "h " .. mins .. "m " .. secs .. "s"
end

function statistics.print()
	if curMap then
		
		print("Time taken: " .. secondsToReadableTime(curMap.time))		-- print in readable format
		
		for i = 1,#aiStats do
			print(aiStats[i].name .. ":")
			print("\tPicked up " .. aiStats[i].pPickedUp .. " passengers.")
			print("\tDropped off " .. aiStats[i].pDroppedOff .. " passengers.")
			print("\tBrought " .. aiStats[i].pTransported .. " passengers to their destinations.")
			print("\tCash: " .. aiStats[i].money)
			--[[for j = 1,#stats[i].trains do
				print("\t" .. stats[i].trains[j].name .. ":")
				print("\t\tPicked up " .. stats[i].trains[j].pPickedUp .. " passengers.")
				print("\t\tDropped off " .. stats[i].trains[j].pDroppedOff .. " passengers.")
				print("\t\tBrought " .. stats[i].trains[j].pTransported .. " passengers to their destinations.")
			end
			]]--
		end
		
		for k, p in pairs(passengerStats) do
			print("\t" .. k)
			printTable(p, 2)
		end
	end
end



--------------------------------------------------------------
--		PASSENGER STATS:
--------------------------------------------------------------

function statistics.newPassenger( passenger )
	passengerStats[passenger.name] = {}
	passengerStats[passenger.name].timeSpawned = curMap.time		-- save the current time
	passengerStats[passenger.name].timeOnRails = 0
	passengerStats[passenger.name].timeWaited = 0
end


function statistics.passengerPickedUp( passenger )

	passengerStats[passenger.name].timeWaited = passengerStats[passenger.name].timeWaited + (curMap.time - (passengerStats[passenger.name].timeLastDroppedOff or passengerStats[passenger.name].timeSpawned))
	if passengerStats[passenger.name].timeFirstPickedUp == nil then		-- have I been picked up before?
		passengerStats[passenger.name].timeFirstPickedUp = curMap.time		-- save the current time
		passengerStats[passenger.name].timeUntilFirstPickup = curMap.time - passengerStats[passenger.name].timeSpawned
	end
	passengerStats[passenger.name].timeLastPickup = curMap.time
end

function statistics.passengerDroppedOff( passenger )
	passengerStats[passenger.name].timeLastDroppedOff = curMap.time
	passengerStats[passenger.name].timeOnRails = passengerStats[passenger.name].timeOnRails + (curMap.time - passengerStats[passenger.name].timeLastPickup)
	if passenger.tileX == passenger.destX and passenger.tileY == passenger.destY then
		passengerStats[passenger.name].timeTotal = curMap.time - passengerStats[passenger.name].timeSpawned
	end
end

--------------------------------------------------------------
--		GENERATE STATS DISPLAY:
--------------------------------------------------------------

local numStats = 0
local statWindows = {}
--	ai:
--		most passengers picked up
--	trains:
--		most passengers picked up
--		most passengers dropped off correctly
--		most passengers dropped off wrongly 
--	passengers:
--		fastest travel
--		longest time on rails
--		longest wait
--		most dropped off (?)

function addStatWindow(newStat)
	for i=1,numStats+1 do
		if statWindows[i] == nil then
			newStat.displayTime = i-1
			numVertical = math.floor(love.graphics.getHeight()/newStat.bg:getHeight())
			yIndex = i-1
			xIndex = 0
			while yIndex > numVertical do
				yIndex = yIndex - numVertical
				xIndex = xIndex + 1
			end
			
			newStat.x = xIndex*newStat.bg:getWidth()
			newStat.y = yIndex*newStat.bg:getHeight()
			statWindows[i] = newStat
			numStats = numStats + 1
			break
		end
	end
end

function statistics.generateStatWindows()
	statWindows = {}
	allPossibleStats = {}
	numStats = 0
	-- ai: most passengers picked up:
	local mostPickedUp = 0
	local mostPickedUpID = nil
	-- ai: most passengers brought to their destination:
	local mostTransported = 0
	local mostTransportedID = nil
	-- ai: most passengers dropped off at wrong position
	local mostWrongDestination = 0
	local mostWrongDestinationID = nil
	-- ai: most money made
	local mostMoney = 0
	local mostMoneyID = nil
	-- ai: most normal transported
	local mostNormalTransported = 0
	local mostNormalTransportedID = nil
	-- ai: largest number of trains:
	local mostTrains = 0
	local mostTrainsID = nil
	
	-- train: most passengers picked up:
	local trMostPickedUp = 0
	local trMostPickedUpID = nil
	local trMostPickedUpName = nil
	-- ai: most passengers brought to their destination:
	local trMostTransported = 0
	local trMostTransportedID = nil
	local trMostTransportedName = nil
	-- ai: most passengers dropped off at wrong position
	local trMostWrongDestination = 0
	local trMostWrongDestinationID = nil
	local trMostWrongDestinationName = nil
	-- ai: most passengers dropped off at wrong position
	local trLongestBlocked = 0
	local trLongestBlockedID = nil
	local trLongestBlockedName = nil
	
	for i = 1,#aiStats do
		if aiStats[i].pPickedUp and aiStats[i].pPickedUp >= mostPickedUp then
			mostPickedUpID = i
			if mostPickedUp == aiStats[i].pPickedUp then
				mostPickedUpID = nil
			end
			mostPickedUp = aiStats[i].pPickedUp
		end
		if aiStats[i].pTransported and aiStats[i].pTransported >= mostTransported then
			mostTransportedID = i
			if mostTransported == aiStats[i].pTransported then
				mostTransportedID = nil
			end
			mostTransported = aiStats[i].pTransported
		end
		if aiStats[i].pTransported and aiStats[i].pPickedUp and aiStats[i].pPickedUp - aiStats[i].pTransported >= mostWrongDestination then
			mostWrongDestinationID = i
			if mostWrongDestination == aiStats[i].pPickedUp - aiStats[i].pTransported then
				mostWrongDestinationID = nil
			end
			mostWrongDestination = aiStats[i].pPickedUp - aiStats[i].pTransported
		end
		if aiStats[i].moneyEarnedTotal and aiStats[i].moneyEarnedTotal >= mostMoney then
			mostMoneyID = i
			if mostMoney == aiStats[i].moneyEarnedTotal then
				mostMoneyID = nil
			end
			mostMoney = aiStats[i].moneyEarnedTotal
		end
		if aiStats[i].pNormal and aiStats[i].pNormal >= mostNormalTransported then
			mostNormalTransportedID = i
			if mostNormalTransported == aiStats[i].pNormal then
				mostNormalTransportedID = nil
			end
			mostNormalTransported = aiStats[i].pNormal
		end
		if aiStats[i].numTrains and aiStats[i].numTrains >= mostTrains then
			mostTrainsID = i
			if mostTrains == aiStats[i].numTrains then
				mostTrainsID = nil
			end
			mostTrains = aiStats[i].numTrains
		end
		
		for k, tr in pairs(aiStats[i].trains) do
			if tr.pPickedUp and tr.pPickedUp >= trMostPickedUp then
				trMostPickedUpID = i
				trMostPickedUpName = tr.name
				if trMostPickedUp == tr.pPickedUp then
					trMostPickedUpID = nil
					trMostPickedUpName = nil
				end
				trMostPickedUp = tr.pPickedUp
			end
			if tr.pTransported and tr.pTransported >= trMostTransported then
				trMostTransportedID = i
				trMostTransportedName = tr.name
				if trMostTransported == tr.pTransported then
					trMostTransportedID = nil
					trMostTransportedName = nil
				end
				trMostTransported = tr.pTransported
			end
			if tr.pTransported and tr.pPickedUp and tr.pPickedUp - tr.pTransported >= trMostWrongDestination then
				trMostWrongDestinationID = i
				trMostWrongDestinationName = tr.name
				if trMostWrongDestination == tr.pPickedUp - tr.pTransported then
					trMostWrongDestinationID = nil
					trMostWrongDestinationName = nil
				end
				trMostWrongDestination = tr.pPickedUp - tr.pTransported
			end
			if tr.timeBlocked and tr.timeBlocked >= trLongestBlocked then
				trLongestBlockedID = i
				trLongestBlockedName = tr.name
				if trLongestBlocked == tr.timeBlocked then
					trLongestBlockedID = nil
					trLongestBlockedName = nil
				end
				trLongestBlocked = tr.timeBlocked
			end
		end
	end
	
	if mostPickedUpID then
		if mostPickedUp ~= 1 then
			text = "Player " .. ai.getName(mostPickedUpID) .. " picked up " .. mostPickedUp .. " passengers."
		else
			text = "Player " .. ai.getName(mostPickedUpID) .. " picked up " .. mostPickedUp .. " passenger."
		end
		icons = {}
		table.insert(icons, {img=train.getTrainImage(mostPickedUpID),x=55, y=20, shadow=true})
		table.insert(icons, {img=IMAGE_STATS_PICKUP,x=24, y=30, shadow=true})
		table.insert( allPossibleStats, {title="Hospitality", text=text, bg=statBoxPositive, icons=icons})
	end
	if mostTrainsID then
		if mostTrains ~= 1 then
			text = "Player " .. ai.getName(mostTrainsID) .. " owned " .. mostTrains .. " trains."
		else
			text = "Player " .. ai.getName(mostTrainsID) .. " owned " .. mostTrains .. " train."
		end
		icons = {}
		table.insert(icons, {img=train.getTrainImage(mostTrainsID),x=55, y=20, shadow=true})
		table.insert(icons, {img=train.getTrainImage(mostTrainsID),x=24, y=30, shadow=true})
		table.insert( allPossibleStats, {title="Fleetus Maximus", text=text, bg=statBoxPositive, icons=icons})
	end
	if mostTransportedID then
		icons = {}
		table.insert(icons, {img=train.getTrainImage(mostTransportedID),x=25, y=20, shadow=true})
		table.insert(icons, {img=IMAGE_STATS_DROPOFF,x=37, y=30, shadow=true})
		if mostTransported ~= 1 then
			text = "Player " .. ai.getName(mostTransportedID) .. " brought " .. mostTransported .. " passengers to their destinations."
		else
			text = "Player " .. ai.getName(mostTransportedID) .. " brought " .. mostTransported .. " passenger to her/his destinations."
		end
		table.insert( allPossibleStats, {title="Earned Your Pay", text=text, bg=statBoxPositive, icons=icons})
	end
	if mostNormalTransportedID then
		icons = {}
		table.insert(icons, {img=train.getTrainImage(mostNormalTransportedID),x=25, y=20, shadow=true})
		table.insert(icons, {img=IMAGE_STATS_DROPOFF,x=37, y=30, shadow=true})
		if mostNormalTransported ~= 1 then
			text = "Player " .. ai.getName(mostNormalTransportedID) .. " brought " .. mostNormalTransported .. " non-VIP passengers to their destinations."
		else
			text = "Player " .. ai.getName(mostNormalTransportedID) .. " brought " .. mostNormalTransported .. " non-VIP passenger to her/his destinations."
		end
		table.insert( allPossibleStats, {title="Socialist", text=text, bg=statBoxPositive, icons=icons})
	end
	if mostWrongDestinationID then
		icons = {}
		table.insert(icons, {img=train.getTrainImage(mostTransportedID),x=25, y=20, shadow=true})
		table.insert(icons, {img=IMAGE_STATS_DROPOFF_WRONG,x=37, y=30, shadow=true})
		if mostWrongDestination ~= 1 then
			text = "Player " .. ai.getName(mostWrongDestinationID) .. " dropped off " .. mostWrongDestination .. " passengers where they didn't want to go!"
		else
			text = "Player " .. ai.getName(mostWrongDestinationID) .. " dropped off " .. mostWrongDestination .. " passenger where he/she didn't want to go!"
		end
		table.insert( allPossibleStats, {title="Get lost...", text=text, bg=statBoxNegative, icons=icons})
	end
	if mostMoneyID then
		icons = {}
		table.insert(icons, {img=train.getTrainImage(mostMoneyID),x=25, y=20, shadow=true})
		table.insert(icons, {img=IMAGE_STATS_CASH,x=40, y=26, shadow=true})
		text = "Player " .. ai.getName(mostMoneyID) .. " earned " .. mostMoney .. " credits."
		table.insert( allPossibleStats, {title="Capitalist", text=text, bg=statBoxPositive, icons=icons})
	end
	
	--trains:
	if trMostPickedUpID then
		icons = {}
		table.insert(icons, {img=train.getTrainImage(mostPickedUpID),x=55, y=20, shadow=true})
		table.insert(icons, {img=IMAGE_STATS_PICKUP,x=24, y=30, shadow=true})
		text = trMostPickedUpName .. " [" .. ai.getName(trMostPickedUpID) .. "] " .. " picked up more passengers than any other train."
		table.insert( allPossibleStats, {title="Busy little Bee!", text=text, bg=statBoxPositive, icons=icons})
	end
	if trMostTransportedID then
		icons = {}
		table.insert(icons, {img=train.getTrainImage(mostTransportedID),x=25, y=20, shadow=true})
		table.insert(icons, {img=IMAGE_STATS_DROPOFF,x=37, y=30, shadow=true})
		text = trMostTransportedName .. " [" .. ai.getName(trMostTransportedID) .. "] " .. " brought more passengers to their destination than any other train."
		table.insert( allPossibleStats, {title="Home sweet Home", text=text, bg=statBoxPositive, icons=icons})
	end
	if trMostWrongDestinationID then
		icons = {}
		table.insert(icons, {img=train.getTrainImage(mostTransportedID),x=25, y=20, shadow=true})
		table.insert(icons, {img=IMAGE_STATS_DROPOFF_WRONG,x=37, y=30, shadow=true})
		if trMostWrongDestination ~= 1 then
			text = trMostWrongDestinationName .. " [" .. ai.getName(trMostWrongDestinationID) .. "] " .. " left " .. trMostWrongDestination .. " passengers in the middle of nowhere!"
		else
			text = trMostWrongDestinationName .. " [" .. ai.getName(trMostWrongDestinationID) .. "] " .. " left " .. trMostWrongDestination .. " passenger in the middle of nowhere!"
		end
		table.insert( allPossibleStats, {title="Why don't you walk?", text=text, bg=statBoxNegative, icons=icons})
	end
	if trLongestBlockedID then
		icons = {}
		table.insert(icons, {img=train.getTrainImage(trLongestBlockedID),x=25, y=20, shadow=true})
		table.insert(icons, {img=IMAGE_STATS_TIME,x=50, y=20})
		text = trLongestBlockedName .. " [" .. ai.getName(trLongestBlockedID) .. "] " .. " was blocked for a total of " .. math.floor(10*trLongestBlocked)/10 .. " seconds."
		table.insert( allPossibleStats, {title="Line is busy...", text=text, bg=statBoxNegative, icons=icons})
	end
	
	--randomize:
	randomizeTable(allPossibleStats)
	
	i = 0
	for k, v in pairs(allPossibleStats) do
		if i >= 4 then
			break
		end
		addStatWindow(v)
		i = i + 1
	end
end

--------------------------------------------------------------
--		SHOW STATS:
--------------------------------------------------------------


function statistics.display(globX, globY, dt)

	love.graphics.setColor(0,0,0,150)
	love.graphics.rectangle("fill", 0,0,love.graphics.getWidth(), love.graphics.getHeight())
	love.graphics.setColor(255,255,255,255)
	if not msgBox.isVisible() then
		for k, s in pairs(statWindows) do
			if s.displayTime > 0 then
				s.displayTime = s.displayTime - dt
			else
				x,y = globX + s.x, globY + s.y
				love.graphics.draw(s.bg, x, y)
				love.graphics.setFont(FONT_STAT_HEADING)
				love.graphics.printf(s.title, x, y+8, s.bg:getWidth(), "center")
		
				love.graphics.setFont(FONT_STANDARD)
				if s.icons then
					for k, icon in pairs(s.icons) do
						if icon.shadow then
							love.graphics.setColor(0,0,0,150)
							love.graphics.draw(icon.img, x+icon.x-3, y+icon.y+7)
							love.graphics.setColor(255,255,255,255)
						end
						love.graphics.draw(icon.img, x+icon.x, y+icon.y)
					end
				end
		
				love.graphics.printf(s.text, x+96, y+37, s.bg:getWidth()-110, "left")
			end
		end
	end
end

local displayStatusX = 0
local displayStatusY = 0
local displayStatusBoxWidth = 10

function statistics.displayStatus()
	if not statBoxStatus then return end
	
	love.graphics.setFont(FONT_STANDARD)
	for i = 1, #aiStats do
		if aiStats[i].name ~= "" then	-- if the ai has already been loaded and named
			x = displayStatusX + (i-1)*displayStatusBoxWidth
			
			love.graphics.setColor(aiStats[i].red,aiStats[i].green,aiStats[i].blue,255)
			love.graphics.draw(statBoxStatus, x, displayStatusY)
			love.graphics.setColor(255,255,255,255)
			love.graphics.printf(aiStats[i].name, x, displayStatusY + 15, displayStatusBoxWidth, "center")
		end
	end
end

function statistics.start( ais )
	aiStats = {}
	passengerStats = {}
	for i = 1,ais do
		aiStats[i] = {}
		aiStats[i].money = STARTUP_MONEY
		aiStats[i].moneyEarnedTotal = 0
		aiStats[i].pPickedUp = 0		-- number of passengers which were picked up
		aiStats[i].pDroppedOff = 0	-- number of passengers dropped off
		aiStats[i].pTransported = 0	-- only set if the player has transported the passenger to his/her destination
		aiStats[i].trains = {}
		aiStats[i].name = ""
		aiStats[i].pNormal = 0
		aiStats[i].pVIP = 0
		aiStats[i].numTrains = 0
		aiStats[i].red = 255	-- default colour
		aiStats[i].green = 255
		aiStats[i].blue = 255
	end
	displayStatusBoxWidth = statBoxStatus:getWidth()
	displayStatusX = love.graphics.getWidth()/2 - #aiStats/2*displayStatusBoxWidth
	displayStatusY = love.graphics.getHeight() - statBoxStatus:getHeight() - 50
end

function statistics.init()
	if not statBoxPositiveThread and not statBoxPositive then		-- only start thread once!
		loadingScreen.addSection("Rendering Stat Box (green)")
		statBoxPositiveThread = love.thread.newThread("statBoxPositiveThread", "Scripts/createImageBox.lua")
		statBoxPositiveThread:start()
	
		statBoxPositiveThread:set("width", STAT_BOX_WIDTH )
		statBoxPositiveThread:set("height", STAT_BOX_HEIGHT )
		statBoxPositiveThread:set("shadow", true )
		statBoxPositiveThread:set("shadowOffsetX", 10 )
		statBoxPositiveThread:set("shadowOffsetY", 0 )
		statBoxPositiveThread:set("colR", STAT_BOX_POSITIVE_R )
		statBoxPositiveThread:set("colG", STAT_BOX_POSITIVE_G )
		statBoxPositiveThread:set("colB", STAT_BOX_POSITIVE_B )
	else
		if not statBoxPositive then	-- if there's no button yet, that means the thread is still running...
		
			percent = statBoxPositiveThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Stat Box (green)", percent)
			end
			err = statBoxPositiveThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
			status = statBoxPositiveThread:get("status")
			if status == "done" then
				statBoxPositive = statBoxPositiveThread:get("imageData")		-- get the generated image data from the thread
				statBoxPositive = love.graphics.newImage(statBoxPositive)
				statBoxPositiveThread = nil
			end
		end
	end
	
	if not statBoxNegativeThread and not statBoxNegative then		-- only start thread once!
		loadingScreen.addSection("Rendering Stat Box (red)")
		statBoxNegativeThread = love.thread.newThread("statBoxNegativeThread", "Scripts/createImageBox.lua")
		statBoxNegativeThread:start()
	
		statBoxNegativeThread:set("width", STAT_BOX_WIDTH )
		statBoxNegativeThread:set("height", STAT_BOX_HEIGHT )
		statBoxNegativeThread:set("shadow", true )
		statBoxNegativeThread:set("shadowOffsetX", 10 )
		statBoxNegativeThread:set("shadowOffsetY", 0 )
		statBoxNegativeThread:set("colR", STAT_BOX_NEGATIVE_R )
		statBoxNegativeThread:set("colG", STAT_BOX_NEGATIVE_G )
		statBoxNegativeThread:set("colB", STAT_BOX_NEGATIVE_B )
	else
		if not statBoxNegative then	-- if there's no button yet, that means the thread is still running...
		
			percent = statBoxNegativeThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Stat Box (red)", percent)
			end
			err = statBoxNegativeThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
			status = statBoxNegativeThread:get("status")
			if status == "done" then
				statBoxNegative = statBoxNegativeThread:get("imageData")		-- get the generated image data from the thread
				statBoxNegative = love.graphics.newImage(statBoxNegative)
				statBoxNegativeThread = nil
			end
		end
	end
	if not statBoxStatusThread and not statBoxStatus then		-- only start thread once!
		loadingScreen.addSection("Rendering Stat Box (status)")
		statBoxStatusThread = love.thread.newThread("statBoxStatusThread", "Scripts/createImageBox.lua")
		statBoxStatusThread:start()
	
		statBoxStatusThread:set("width", BOX_STATUS_WIDTH )
		statBoxStatusThread:set("height", BOX_STATUS_HEIGHT )
		statBoxStatusThread:set("shadow", true )
		statBoxStatusThread:set("shadowOffsetX", 10 )
		statBoxStatusThread:set("shadowOffsetY", 0 )
		statBoxStatusThread:set("colR", STAT_BOX_STATUS_R )
		statBoxStatusThread:set("colG", STAT_BOX_STATUS_G )
		statBoxStatusThread:set("colB", STAT_BOX_STATUS_B )
	else
		if not statBoxStatus then	-- if there's no button yet, that means the thread is still running...
		
			percent = statBoxStatusThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Stat Box (status)", percent)
			end
			err = statBoxStatusThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
			status = statBoxStatusThread:get("status")
			if status == "done" then
				statBoxStatus = statBoxStatusThread:get("imageData")		-- get the generated image data from the thread
				statBoxStatus = love.graphics.newImage(statBoxStatus)
				statBoxStatusThread = nil
			end
		end
	end

	-- statBoxPositive = createBoxImage(350, 95, true, 10, 0, 64, 140, 100)
	-- statBoxStatus = createBoxImage(350, 95, true, 10, 0, 150, 90, 65)
end

function statistics.initialised()
	if statBoxPositive and statBoxNegative and statBoxStatus then
		return true
	end
end

return statistics


