local sendPackets = {}

sendPacketsList = {}

require("love.filesystem")

--[[
function sortByTime(a,b)
	if a.time < b.time then return true end
end
]]--

function sendPackets.add(packetID, text, time)
	sendPacketsList[packetID] = {ID = packetID, time=time, event = text}
	--[[local f = io.open("log.txt", "a")
	f:write(packetID .. " " .. time .. " " .. text .. "\n")
	f:close()
	]]--
end

function sendPackets.getPacketNum()
	return #sendPacketsList
end

function sendPackets.init()
	sendPacketsList = {}
end

return sendPackets
