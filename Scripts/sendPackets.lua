local sendPackets = {}

sendPacketsList = {}

--[[
function sortByTime(a,b)
	if a.time < b.time then return true end
end
]]--

function sendPackets.add(packetID, text, time)
	-- print(time, text)
	
	--local packetID = #sendPacketsList+1
	
	sendPacketsList[packetID] = {ID = packetID, time=time, event = text}
	-- table.sort(sendPacketsList, sortByTime)
end

function sendPackets.getPacketNum()
	return #sendPacketsList
end

function sendPackets.init()
	sendPacketsList = {}
end

return sendPackets
