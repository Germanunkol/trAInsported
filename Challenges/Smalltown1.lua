local ch = {}

ch.name = "Challenge1"
ch.version = "5"

ch.maxTrains = 1
ch.startMoney = 25

-- create a new, empty map:
ch.map = challenges.createEmptyMap(10, 7)

-- fill some of the tiles with Rails and Houses:
ch.map[1][1] = "C"
ch.map[1][2] = "C"
ch.map[1][3] = "C"
ch.map[1][4] = "C"
ch.map[2][1] = "C"
ch.map[3][1] = "C"
ch.map[4][1] = "C"
ch.map[4][2] = "C"
ch.map[4][3] = "C"
ch.map[4][4] = "C"
ch.map[2][4] = "C"
ch.map[3][4] = "C"

ch.map[2][2] = "H"
ch.map[2][3] = "H"
ch.map[3][2] = "H"
ch.map[3][3] = "H"

ch.map[10][4] = "C"
ch.map[10][5] = "C"
ch.map[10][6] = "C"
ch.map[10][7] = "C"
ch.map[7][4] = "C"
ch.map[7][5] = "C"
ch.map[7][6] = "C"
ch.map[7][7] = "C"
ch.map[9][4] = "C"
ch.map[8][4] = "C"
ch.map[9][7] = "C"
ch.map[8][7] = "C"

ch.map[5][4] = "C"
ch.map[5][5] = "C"
ch.map[5][6] = "C"
ch.map[6][6] = "C"

ch.map[8][5] = "H"
ch.map[8][6] = "W"
ch.map[9][5] = "H"
ch.map[9][6] = "H"

local startTime = 0
local passengersCreated = false
local maxTime = 180
local passengersRemaining = 4
local startupMessage = "Welcome to Smalltown!\nSmalltown is a little town in the middle of nowhere. Only recently has it been connected to its neighbouring town by rails. Of course, all the people in Smalltown want to be the first ones shopping over there. Get the passengers to the other town within " .. maxTime .. " seconds!"

function ch.start()
	challenges.setMessage(startupMessage)
end

function ch.update(time)
	if time > 3 and not passengersCreated then
		passengersCreated = true
		passenger.new( 1, math.random(4) , 10, math.random(4) + 3 )
		passenger.new( 1, math.random(4) , 7, math.random(4) + 3 )
		
		passenger.new( 4, math.random(4) , 7, math.random(4) + 3 )
		passenger.new( 4, math.random(4) , 10, math.random(4) + 3 )
		passengersRemaining = 4
	end
	if time > maxTime then
		return "lost", "No shopping today..."
	end
	if passengersRemaining == 0 then
		return "won", "The shopping can begin!"
	end
	challenges.setStatus("Map by Germanunkol\n" .. math.floor(maxTime-time) .. " seconds remaining.\n" .. passengersRemaining .." passengers remaining.")
end

function ch.passengerDroppedOff(tr, p)
	if tr.tileX == p.destX and tr.tileY == p.destY then		
		passengersRemaining = passengersRemaining - 1
	end
end

return ch
