local sendPackets = {}

sendPacketsList = {}

function sortByTime(a,b)
	if a.time < b.time then return true end
end

function sendPackets.add(text, time)
	-- print(time, text)
	table.insert(sendPacketsList, {time=time, event = text})
	table.sort(sendPacketsList, sortByTime)
end

function sendPackets.init()
	sendPacketsList = {}
end

return sendPackets
