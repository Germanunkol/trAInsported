local sendPackets = {}

sendPacketsList = {}

require("love.filesystem")

--[[
function sortByTime(a,b)
	if a.time < b.time then return true end
end
]]--
	
function file_exists(name)
	local f=io.open(name,"r")
	if f~=nil then
		io.close(f)
		return true
	else
		return false
	end
end

function sendPackets.add(packetID, text, time)
	sendPacketsList[packetID] = {ID = packetID, time=time, event = text}

	if file_exists("log.txt") then
		local f = io.open("log.txt", "a")
		f:write(packetID .. " " .. time .. " " .. text .. "\n")
		f:close()
	end
end

function sendPackets.getPacketNum()
	return #sendPacketsList
end

function sendPackets.init()
	sendPacketsList = {}
end

return sendPackets
