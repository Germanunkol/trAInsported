
function printTable(table, lvl)
	if not type(table) == "table" then
		print("not a table!")
		return
	end
	
	lvl = lvl or 0
	for k, v in pairs(table) do
		if type(v) == "table" then
			printTable(table, lvl + 1)
		else
			str = ""
			for i = 1,lvl do
				str = str .. "\t"
			end
			print(str, k, v)
		end
	end
end

function ai.init()
	print("Initialized! one one eleven")
	--print(dropPassenger)
	--abc = {}
	--table.insert(abc, "hey")
	print("wtf")
end

function ai.chooseDirection(train, possibleDirections)
	tbl = {}
	if possibleDirections["N"] then
		tbl[#tbl+1] = "N"
	end
	if possibleDirections["S"] then
		tbl[#tbl+1] = "S"
	end
	if possibleDirections["E"] then
		tbl[#tbl+1] = "E"
	end
	if possibleDirections["W"] then
		tbl[#tbl+1] = "W"
	end
	return tbl[random(#tbl)]
end

function ai.blocked(train, possibleDirections, lastDirection)
	--train.tileX = 1
	if possibleDirections["S"] and random(2) == 1 then
		return "S"
	end
	if possibleDirections["E"] and random(2) == 1 then
		return "E"
	end
	if possibleDirections["N"] and random(2) == 1 then
		return "N"
	end
	if possibleDirections["W"] and random(2) == 1 then
		return "W"
	end
end

function ai.foundPassengers(train, passengers)
	return passengers[1]
end

function ai.foundDestination(train)
	print("get off!")
	dropPassenger(train)
end
