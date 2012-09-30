local statistics = {}

local stats = {}

MONEY_PASSENGER = 5
MONEY_VIP = 15

function statistics.init( ais )

	--statBGImage = love.graphics.newImage()
	stats = {}
	stats.numAIs = ais
	stats.passengers = {}
	print(ais)
	for i = 1,ais do
		stats[i] = {}
		stats[i].money = 0
		stats[i].pPickedUp = 0		-- number of passengers which were picked up
		stats[i].pDroppedOff = 0	-- number of passengers dropped off
		stats[i].pTransported = 0	-- only set if the player has transported the passenger to his/her destination
		stats[i].trains = {}
		stats[i].name = "default"
	end
end

function statistics.setAIName(aiID, name)
	stats[aiID].name = name
end

function statistics.addTrain( aiID, train )
	stats[aiID].trains[train.ID] = train
	stats[aiID].trains[train.ID].pPickedUp = 0		-- number of passengers which were picked up
	stats[aiID].trains[train.ID].pDroppedOff = 0	-- number of passengers dropped off
	stats[aiID].trains[train.ID].pTransported = 0	-- only set if the player has transported the passenger to his/her destination
end

function statistics.addCash( aiID, money )
	stats[aiID].money = stats[aiID].money + money
end

function statistics.subCash( aiID, money )
	if stats[aiID].money >= money then
		stats[aiID].money = stats[aiID].money - money
		return true
	else
		return false
	end
end

function statistics.passengersPickedUp( aiID, trainID )
	stats[aiID].pPickedUp = stats[aiID].pPickedUp + 1
	stats[aiID].trains[trainID].pPickedUp = stats[aiID].trains[trainID].pPickedUp + 1
end

function statistics.droppedOff( aiID, trainID )
	stats[aiID].pDroppedOff = stats[aiID].pDroppedOff + 1
	stats[aiID].trains[trainID].pDroppedOff = stats[aiID].trains[trainID].pDroppedOff + 1
end

function statistics.broughtToDestination( aiID, trainID )
	stats[aiID].pTransported = stats[aiID].pTransported + 1
	stats[aiID].trains[trainID].pTransported = stats[aiID].trains[trainID].pTransported + 1
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
		
		for i = 1,stats.numAIs do
			print(stats[i].name .. ":")
			print("\tPicked up " .. stats[i].pPickedUp .. " passengers.")
			print("\tDropped off " .. stats[i].pDroppedOff .. " passengers.")
			print("\tBrought " .. stats[i].pTransported .. " passengers to their destinations.")
			print("\tCash: " .. stats[i].money)
			--[[for j = 1,#stats[i].trains do
				print("\t" .. stats[i].trains[j].name .. ":")
				print("\t\tPicked up " .. stats[i].trains[j].pPickedUp .. " passengers.")
				print("\t\tDropped off " .. stats[i].trains[j].pDroppedOff .. " passengers.")
				print("\t\tBrought " .. stats[i].trains[j].pTransported .. " passengers to their destinations.")
			end
			]]--
		end
		
		for k, p in pairs(stats.passengers) do
			print("\t" .. k)
			printTable(p, 2)
		end
	end
end


--------------------------------------------------------------
--		PASSENGER STATS:
--------------------------------------------------------------

function statistics.newPassenger( passenger )
	stats.passengers[passenger.name] = {}
	stats.passengers[passenger.name].timeSpawned = curMap.time		-- save the current time
	stats.passengers[passenger.name].timeOnRails = 0
	stats.passengers[passenger.name].timeWaited = 0
end


function statistics.passengerPickedUp( passenger )

	stats.passengers[passenger.name].timeWaited = stats.passengers[passenger.name].timeWaited + (curMap.time - (stats.passengers[passenger.name].timeLastDroppedOff or stats.passengers[passenger.name].timeSpawned))
	if stats.passengers[passenger.name].timeFirstPickedUp == nil then		-- have I been picked up before?
		stats.passengers[passenger.name].timeFirstPickedUp = curMap.time		-- save the current time
		stats.passengers[passenger.name].timeUntilFirstPickup = curMap.time - stats.passengers[passenger.name].timeSpawned
	end
	stats.passengers[passenger.name].timeLastPickup = curMap.time
end

function statistics.passengerDroppedOff( passenger )
	stats.passengers[passenger.name].timeLastDroppedOff = curMap.time
	stats.passengers[passenger.name].timeOnRails = stats.passengers[passenger.name].timeOnRails + (curMap.time - stats.passengers[passenger.name].timeLastPickup)
	if passenger.tileX == passenger.destX and passenger.tileY == passenger.destY then
		stats.passengers[passenger.name].timeTotal = curMap.time - stats.passengers[passenger.name].timeSpawned
	end
end



--------------------------------------------------------------
--		PASSENGER STATS:
--------------------------------------------------------------

function statistics.display()

end


return statistics


