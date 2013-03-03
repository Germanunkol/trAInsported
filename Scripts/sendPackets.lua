local sendPackets = {}

sendPacketsList = {}

require("love.filesystem")

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
	
	-- log:
	--[[
	if text:find("END_ROUND") then
		s = ""
		for k = 1, #sendPacketsList do
			s = s .. string.format("%s | %s | %s\n", sendPacketsList[k].ID, sendPacketsList[k].time, sendPacketsList[k].event)
		end
		love.filesystem.write("match.txt", s)
	end
	]]--
end

function sendPackets.getPacketNum()
	return #sendPacketsList
end

function sendPackets.init()
	sendPacketsList = {}
end

return sendPackets
