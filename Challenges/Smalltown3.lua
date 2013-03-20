local ch = {}

ch.name = "Challenge3"
ch.version = "2"

ch.maxTrains = 2
ch.startMoney = 50

-- create a new, empty map:
ch.map = challenges.createEmptyMap(17, 13)

-- fill some of the tiles with Rails and Houses:
ch.map[4][4] = "C"
ch.map[4][5] = "C"
ch.map[4][6] = "C"
ch.map[4][7] = "C"
ch.map[6][4] = "C"
ch.map[4][4] = "C"
ch.map[7][4] = "C"
ch.map[7][5] = "C"
ch.map[7][6] = "C"
ch.map[7][7] = "C"
ch.map[5][7] = "C"
ch.map[6][7] = "C"
ch.map[5][4] = "C"

ch.map[5][5] = "H"
ch.map[5][6] = "H"
ch.map[6][5] = "H"
ch.map[6][6] = "H"

ch.map[3][6] = "H"
ch.map[3][5] = "H"
ch.map[3][4] = "H"
ch.map[3][3] = "H"
ch.map[4][3] = "H"
ch.map[5][3] = "H"
ch.map[6][3] = "H"
ch.map[7][3] = "H"
ch.map[8][3] = "H"

ch.map[8][4] = "C"
ch.map[9][4] = "C"
ch.map[10][4] = "C"
ch.map[11][4] = "C"

ch.map[8][5] = "H"
ch.map[8][6] = "H"
ch.map[9][5] = "H"
ch.map[10][5] = "H"

ch.map[13][7] = "C"
ch.map[13][8] = "C"
ch.map[13][9] = "C"
ch.map[13][10] = "C"
ch.map[10][7] = "C"
ch.map[10][8] = "C"
ch.map[10][9] = "C"
ch.map[10][10] = "C"
ch.map[12][7] = "C"
ch.map[11][7] = "C"
ch.map[12][10] = "C"
ch.map[11][10] = "C"

ch.map[8][7] = "C"
ch.map[8][8] = "C"
ch.map[8][9] = "C"
ch.map[9][9] = "C"

ch.map[11][8] = "H"
ch.map[11][9] = "STORE"
ch.map[12][8] = "H"
ch.map[12][9] = "H"

-- u-turn:
ch.map[7][9] = "C"

-- outer lower ring:
ch.map[14][7] = "C"
ch.map[15][7] = "C"
ch.map[15][8] = "C"
ch.map[15][9] = "C"
ch.map[15][10] = "C"
ch.map[15][11] = "C"
ch.map[15][12] = "C"
ch.map[14][12] = "C"
ch.map[13][12] = "C"
ch.map[12][12] = "C"
ch.map[11][12] = "C"
ch.map[10][12] = "C"
ch.map[10][11] = "C"
ch.map[14][8] = "H"
ch.map[14][9] = "H"
ch.map[14][10] = "H"
ch.map[14][11] = "STORE"
ch.map[13][11] = "H"
ch.map[12][11] = "H"

local startTime = 0
local passengersCreated = false
local maxTime = 355
local passengersRemaining = 7
local startupMessage = "A few years later. Recognize the place? In an attempt to make the transport system more efficient, the mayors of the two towns have each decided to give you enough money to buy a train - but they want each train to stay in their own town. Build one train in each town, and don't move them into the other town! Use the U-turn on tile (7,9) to turn around exchange passengers!\nEvery time a train moves onto tile (7,9), your AI's 'ai.mapEvent()' will be called and the train will be passed as an argument.\nNo time limit on this one - take your time."
local firstTrain
local secondTrain
local upperTrain
local lowerTrain
local firstTrain_lastX
local firstTrain_lastY
local secondTrain_lastX
local secondTrain_lastY

function ch.start()
	challenges.setMessage(startupMessage)
end

function ch.update(time)
	if time > 3 and not passengersCreated then
		passengersCreated = true
		
		for k = 1,10 do
			passenger.new()
		end
		
		passenger.new(15, 8, 4, 5 )
		passenger.new(11, 4, 11, 12 )
		
		passengersRemaining = 12
	end

	
	
	if firstTrain then
		if firstTrain.tileX ~= firstTrain_lastX or firstTrain.tileY ~= firstTrain_lastY then
			firstTrain_lastX = firstTrain.tileX
			firstTrain_lastY = firstTrain.tileY
			if firstTrain.tileX == 7 and firstTrain.tileY == 9 then
				ai.mapEvent(1, createTrainCopy(firstTrain))
			end
		end
	
		if firstTrain.tileX < 8 and firstTrain.tileY < 7 then			-- in the upper corner?
			if upperTrain == nil then
				upperTrain = firstTrain
			end
			if upperTrain ~= firstTrain then
				return "lost", firstTrain.name .. " moved into the upper town!"
			end
		elseif firstTrain.tileX >= 10 and firstTrain.tileY >= 9 then
			if lowerTrain == nil then
				lowerTrain = lowerTrain
			end
			if lowerTrain ~= firstTrain then
				return "lost", firstTrain.name .. " moved into the lower town!"
			end
		end
	end
	if secondTrain then
		if secondTrain.tileX ~= secondTrain_lastX or secondTrain.tileY ~= secondTrain_lastY then
			secondTrain_lastX = secondTrain.tileX
			secondTrain_lastY = secondTrain.tileY
			if secondTrain.tileX == 7 and secondTrain.tileY == 9 then
				ai.mapEvent(1, createTrainCopy(secondTrain))
			end
		end
	
		if secondTrain.tileX <= 8 and secondTrain.tileY <= 7 then			-- in the upper corner?
			if upperTrain == nil then
				upperTrain = secondTrain
			end
			if upperTrain ~= secondTrain then
				return "lost", secondTrain.name .. " moved into the upper town!"
			end
		elseif secondTrain.tileX >= 10 and secondTrain.tileY >= 9 then
			if lowerTrain == nil then
				lowerTrain = secondTrain
			end
			if lowerTrain ~= secondTrain then
				return "lost", secondTrain.name .. " moved into the lower town!"
			end
		end
	end
	challenges.setStatus("Map by Germanunkol\n" .. passengersRemaining .. " passengers remaining.")
	
	if passengersRemaining == 0 then
		return "won", "Well done! You showed those mayors what you can work with!\n Time: " .. makeTimeReadable(time)
	end
end

function ch.passengerDroppedOff(tr, p)
	if tr.tileX == p.destX and tr.tileY == p.destY then		
		passengersRemaining = passengersRemaining - 1
	end
end

function ch.newTrain(tr)
	if not firstTrain then
		firstTrain = tr
	else
		secondTrain = tr
	end
end

return ch
