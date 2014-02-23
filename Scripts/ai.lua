local ai = {}

aiList = {}		-- holds all the ai functions/events

local aiUserData = {		--default fallbacks in case a function is not created by the User's AI script.
	init = function () print("No ai.init() function found.") end,
	chooseDirection = function () print("No valid \"ai.chooseDirection\" function found. Using fallback.") end,
	blocked = function () print("No valid \"ai.blocked\" function found. Using fallback.") end,
	foundPassengers = function () print("Implement a function \"ai.foundPassengers\" if you want to pick up passengers!") end,
	foundDestination = function () print("Implement a function \"ai.foundDestination\" if you want to earn money!") end,
	enoughMoney = function () print("Implement a function \"ai.enoughMoney\" if you want to get notifications when you have enough money to buy a new train!") end
}

local sandbox = require("Scripts/sandbox")

-- maximum times that the script may run (in seconds)
local MAX_LINES_LOADING = 50000
local MAX_LINES_EXECUTING = 5000

local coLoad = nil
linesUsed = 0

ai_currentMaxLines = 0
ai_currentLines = 0

hookfunctionMetatable = {}	-- dummy table to compare against.

function newLineCountHook( maxLines )
	local startTime = love.timer.getTime()
	local time = 0
	local lines = 0
	linesUsed = 0
	ai_currentLines = lines
	ai_currentMaxLines = maxLines
	return function ( event, l )
		if event == "line" then
			lines = lines + 1
			linesUsed = linesUsed + 1
			time = love.timer.getTime()
			if lines == maxLines then
				err = {msg="Taking too long, stopping. Time taken: " .. time-startTime .. "s."}
				setmetatable(err, hookfunctionMetatable)
				error(err)
			end
			ai_currentLines = lines
			ai_currentMaxLines = maxLines
		end
	end
end

function traceback (err)
	if type(err) == "table" then
		err = err.msg
	end
	local level = 1
	local s, e = err:find("%[.-%]")
	if e then
		err = err:sub(e+1, #err)
	end
	local errorMessage = err .. "\n"
	local firstFound = false
	while true do
		local info = debug.getinfo(level, "Sl")
		if not info then break end
		--if info.what == "C" then   -- is a C function?
			--errorMessage = errorMessage .. level .. ": C function\n"
		--else   -- a Lua function
		--	if info.source:find("/AI/") then
		if firstFound or info.source:find("/AI/") then
			firstFound = true
			funcName = info.source--:gsub(".*/", "")
			errorMessage = errorMessage .. level .. ": " .. string.format("[%s]: line %d", funcName, info.currentline) .. "\n"
			--end
		end
		level = level + 1
	end
	return errorMessage
end

local function safelyLoadAI(chunk, scriptName, sb)

	print("\tCompiling code...")
	debug.sethook(newLineCountHook(MAX_LINES_LOADING), "l")
	local func, message = loadstring( "TRAINSPORTED = true;" .. chunk, scriptName)
	debug.sethook()
	if not func then
		--print("Could not load script: \n", message)
		local s = scriptName:gsub(".*/", "")
		console.add("Could not load script: (" .. s .. "): " .. message, {r=255,g=50,b=50})
		coroutine.yield()
	end
	print("\t\tSuccess! Code lines: " .. linesUsed .. " of " .. MAX_LINES_LOADING)
	
	
	print("\tRunning code:")
	func = setfenv(func, sb)
	debug.sethook(newLineCountHook(MAX_LINES_LOADING), "l")
	local ok, message = xpcall(func, traceback)
	if not ok then
		--print("Could not execute script: \n", message)
		local s = scriptName:gsub(".*/", "")
		console.add("Could not execute script: (" .. s .. "): " .. message, {r=255,g=50,b=50})
		coroutine.yield()
	end
	debug.sethook()
	print("\t\tSuccess! Code lines: " .. linesUsed .. " of " .. MAX_LINES_LOADING)
end

	
local socket = require("socket")
function runAiFunctionCoroutine(f, lines, ... )
	--local t = socket.gettime()
	debug.sethook(newLineCountHook(lines), "l")

	args = {...}
	local ok, msg = xpcall(function() return f( unpack(args) ) end, traceback)
	if not ok then
		local shorterMessage = ""
		local found = false
		console.add("Error occured when calling function: " .. msg, {r=255,g=50,b=50})
		for line in msg:gmatch("[^\n]-\n") do
			if line:find("Taking too long") then
			shorterMessage = shorterMessage .. line
			else
				if line:find("%[string.*%]") then
					found = true
				end
				if found then
					shorterMessage = shorterMessage .. line
				else
				end
			end
		end
		if shorterMessage then console.add("Error found in your function: " .. shorterMessage, {r=255,g=50,b=50}) end
		coroutine.yield()
	end
	debug.sethook()
	--print("Took: (ms)", (socket.gettime() - t)*1000)
	return msg
end

function ai.new(scriptName)
	--local ok, chunk = pcall(love.filesystem.read, scriptName
	print("ScriptName:", scriptName)
	local ok, chunk = false, false
	fh = io.open( scriptName,"r")
	if fh and fh.read then
		ok, chunk = pcall(fh.read, fh, "*all" )
		fh:close()
		
		if chunk:byte(1) == 27 then error("Binary bytecode prohibited. Open source ftw!")
			console.add("Binary bytecode prohibited. Open source ftw!", {r=255,g=50,b=50})
			return
		end
	else
		scriptName = scriptName:gsub(AI_DIRECTORY, "")
		scriptName = "AI/" .. scriptName
		ok, chunk = pcall(love.filesystem.read, scriptName)
	end
	
	if not ok or not chunk then
		if chunk and type(chunk) == "string" then
			error("Could not open file: " .. chunk)
		else
			error("Could not open file: " .. scriptName)
		end
		console.add("Failed to open file (" .. scriptName .. "): " .. msg, {r=255,g=50,b=50})
		return
	end
	
	local aiID = 0
	
	for i = 1,#aiList+1,1 do
		if aiList[i] == nil then
			aiID = i
			aiList[i] =	copyTable(aiUserData)
			local s,e, name = scriptName:find(".*/(.*)%.lua")
			print("NAME:",name)
			
			e = e or 0
			aiList[i].name = name
			aiList[i].scriptName = scriptName
			
			local s,e, owner = scriptName:find(".*/(.-)/")
			if owner == name and not DEDICATED then
				s,e, owner = scriptName:find(".*/(.-)/(.-)/")
			end
			print("OWNER:",owner)
			aiList[i].owner = owner or "Unknown"
			break
		end
	end
	
	--set up the ai which the user's script will have access to:
	sb = sandbox.createNew(aiID, scriptName)
	sb.ai = {}
	
	--this first coroutine compiles and runs the source code of the user's AI script:
	local crLoad = coroutine.create(safelyLoadAI)
	local ok, err = pcall(coroutine.resume, crLoad, chunk, scriptName, sb)
	if coroutine.status(crLoad) ~= "dead" then
		crLoad = nil
		error("\tCoroutine stopped prematurely: " .. aiList[aiID].name)
	end
	crLoad = nil
	print("\tAI loaded.")
	
	aiList[aiID].init = sb.ai.init		-- if it all went right, now we can set the table.
	aiList[aiID].chooseDirection = sb.ai.chooseDirection
	aiList[aiID].blocked = sb.ai.blocked
	aiList[aiID].newPassenger = sb.ai.newPassenger
	aiList[aiID].passengerBoarded = sb.ai.passengerBoarded
	aiList[aiID].foundPassengers = sb.ai.foundPassengers
	aiList[aiID].foundDestination = sb.ai.foundDestination
	aiList[aiID].enoughMoney = sb.ai.enoughMoney
	aiList[aiID].newTrain = sb.ai.newTrain
	aiList[aiID].mapEvent = sb.ai.mapEvent
	
	return aiList[aiID].name, aiList[aiID].owner
end



function ai.init()
	for aiID = 1, #aiList do
		--the second coroutine loads the ai.init() function in the user's AI script:
		print("Initialising AI:", "ID: " .. aiID, "Name: ", aiList[aiID].name, aiList[aiID].scriptName)
		if aiList[aiID].init then
			local crInit = coroutine.create(runAiFunctionCoroutine)
			ok, msg = coroutine.resume(crInit, aiList[aiID].init, MAX_LINES_LOADING, copyTable(curMap), stats.getMoney(aiID), MAX_NUM_TRAINS)
			if not ok then print("NEW ERROR:", msg) end
			if coroutine.status(crInit) ~= "dead" then
				crInit = nil
				console.add(aiList[aiID].name .. ": Stopped function: ai.init()", {r = 255,g=50,b=50})
				--print("\tCoroutine stopped prematurely: " .. aiList[aiID].name .. ".init()")
			end
		else
			print("\tNo ai.init() function found for this AI")
		end
		crInit = nil
		
		if DEDICATED then
			sendStr = "NEW_AI:"
			sendStr = sendStr .. aiID .. ","
			sendStr = sendStr .. aiList[aiID].name .. ","
			sendStr = sendStr .. aiList[aiID].owner .. ","
			sendMapUpdate(sendStr)
		end
	end
end

function ai.restart()
	aiNames = {}
	for i = 1, #aiList do
		aiNames[i] = aiList[i].name
		aiList[i] = nil
	end
	return aiNames
end

function ai.chooseDirection(train, possibleDirs)
	--print("choosing dir:", train.aiID)
	local result = nil
	if aiList[train.aiID] then
		if aiList[train.aiID].chooseDirection then
		
			if tutorial and tutorial.chooseDirectionEvent then
				tutorial.chooseDirectionEvent()
			end
			
			local cr = coroutine.create(runAiFunctionCoroutine)
			
			tr = {ID=train.ID, name=train.name, x=train.tileX, y=train.tileY, dir=train.dir, nextX=train.nextX, nextY=train.nextY}		-- don't give the original data to the ai!
			if train.curPassenger then
				tr.passenger = {name = train.curPassenger.name, destX = train.curPassenger.destX, destY = train.curPassenger.destY}
			end
			dirs = copyTable(possibleDirs)
			
			ok, result = coroutine.resume(cr, aiList[train.aiID].chooseDirection, MAX_LINES_EXECUTING, tr, dirs)
			if not ok or coroutine.status(cr) ~= "dead" then
				console.add(aiList[train.aiID].name .. ": Stopped function: ai.chooseDirection()", {r = 255,g=50,b=50})
				--print("\tCoroutine stopped prematurely: " .. aiList[train.aiID].name .. ".chooseDirection()")
			end
			
			if tutorial and tutorial.chooseDirectionEventCleanup then
				tutorial.chooseDirectionEventCleanup()
			end
		end
	end
	
	--print("ai chose:", result)
	if (result == "N" and possibleDirs["N"]) or (result == "S" and possibleDirs["S"]) or (result == "E" and possibleDirs["E"]) or (result == "W" and possibleDirs["W"]) then
		return result
	else
		return nil
	end
end


function ai.newTrain(train)
	--print("choosing dir:", train.aiID)
	local result = nil
	if aiList[train.aiID] then
		if aiList[train.aiID].newTrain then
			
			local cr = coroutine.create(runAiFunctionCoroutine)
			
			tr = {ID=train.ID, name=train.name, x=train.tileX, y=train.tileY, dir=train.dir}		-- don't give the original data to the ai!
			if train.curPassenger then
				tr.passenger = {name = train.curPassenger.name, destX = train.curPassenger.destX, destY = train.curPassenger.destY}
			end
			
			ok, result = coroutine.resume(cr, aiList[train.aiID].newTrain, MAX_LINES_EXECUTING, tr)
			if not ok or coroutine.status(cr) ~= "dead" then
				console.add(aiList[train.aiID].name .. ": Stopped function: ai.newTrain()", {r = 255,g=50,b=50})
			end
		end
	end
end



function ai.blocked(train, possibleDirs, lastDir)
	local result = nil
	if aiList[train.aiID] then
		if aiList[train.aiID].blocked then
			local cr = coroutine.create(runAiFunctionCoroutine)
			
			tr = {ID=train.ID, name=train.name, x=train.tileX, y=train.tileY, dir=train.dir, nextX=train.nextX, nextY=train.nextY}		-- don't give the original data to the ai!
			if train.curPassenger then
				tr.passenger = {name = train.curPassenger.name, destX = train.curPassenger.destX, destY = train.curPassenger.destY}
			end
			dirs = copyTable(possibleDirs)
			
			ok, result = coroutine.resume(cr, aiList[train.aiID].blocked, MAX_LINES_EXECUTING, tr, dirs, lastDir)
			if not ok or coroutine.status(cr) ~= "dead" then
				console.add(aiList[train.aiID].name .. ": Stopped function: ai.blocked()", {r = 255,g=50,b=50})
				--print("\tCoroutine stopped prematurely: " .. aiList[train.aiID].name .. ".blocked()")
			end
		end
	end
	
	--print("ai chose:", result)
	if (result == "N" and possibleDirs["N"]) or (result == "S" and possibleDirs["S"]) or (result == "E" and possibleDirs["E"]) or (result == "W" and possibleDirs["W"]) then
		return result
	else
		return lastDir		-- retry the same path if there was no new path specified
	end
end

function ai.newPassenger(p)
	for aiID = 1, #aiList do
		
		if aiList[aiID].newPassenger then		-- if the function has been defined by the player
		
			local cr = coroutine.create(runAiFunctionCoroutine)
			ok, result = coroutine.resume(cr, aiList[aiID].newPassenger, MAX_LINES_EXECUTING, p.name, p.tileX, p.tileY, p.destX, p.destY, p.vipTime)
			if not ok or coroutine.status(cr) ~= "dead" then
				console.add(aiList[aiID].name .. ": Stopped function: ai.newPassenger()", {r = 255,g=50,b=50})
				--print("\tCoroutine stopped prematurely: " .. aiList[aiID].name .. ".newPassenger()")
			end
			cr = nil
		end
	end
end

function ai.foundPassengers(train, p)		-- called when the train enters a tile which holds passengers.
	local result = nil
	if aiList[train.aiID] then
		if aiList[train.aiID].foundPassengers then
			local cr = coroutine.create(runAiFunctionCoroutine)
			
			tr = {ID=train.ID, name=train.name, x=train.tileX, y=train.tileY, dir=train.dir}		-- don't give the original data to the ai!
			if train.curPassenger then
				tr.passenger = {name = train.curPassenger.name, destX = train.curPassenger.destX, destY = train.curPassenger.destY}
			end
			
			-- don't let the ai change the original list of passengers!
			local pCopy = copyTable(p)				
			
			ok, result = coroutine.resume(cr, aiList[train.aiID].foundPassengers, MAX_LINES_EXECUTING, tr, pCopy)
			if not ok or coroutine.status(cr) ~= "dead" then
				console.add(aiList[train.aiID].name .. ": Stopped function: ai.foundPassenger()", {r = 255,g=50,b=50})
				--print("\tCoroutine stopped prematurely: " .. aiList[train.aiID].name .. ".foundPassengers()")
			end
		end
	end
	
	-- if a passenger name was returned, then try to let this passenger board the train:
	if result and not train.curPassenger then		-- ... but only if the train does not currently carry a passenger.
		for k, pass in pairs(p) do
			if result.name and pass.name == result.name then
				passenger.boardTrain(train, pass.name)
				--print("boarded")
				break
			end
		end
	end
end

function ai.passengerBoarded(train, passenger)		-- called when another player's train picks up a passenger
	local result = nil
	for i = 1, #aiList do
		if i ~= train.aiID and aiList[i] then
			if aiList[i].passengerBoarded then
				local cr = coroutine.create(runAiFunctionCoroutine)
			
				tr = {ID=train.ID, name=train.name, x=train.tileX, y=train.tileY, dir=train.dir}		-- don't give the original data to the ai!
				if train.curPassenger then
					tr.passenger = {name = train.curPassenger.name, destX = train.curPassenger.destX, destY = train.curPassenger.destY}
				end
			
				ok, result = coroutine.resume(cr, aiList[i].passengerBoarded, MAX_LINES_EXECUTING, tr, passenger)
				if not ok or coroutine.status(cr) ~= "dead" then		
					console.add(aiList[i].name .. ": Stopped function: ai.foundDestination()", {r = 255,g=50,b=50})
					--print("\tCoroutine stopped prematurely: " .. aiList[i].name .. ".foundDestination()")
				end
			end
		end
	end
end

function ai.foundDestination(train)		-- called when the train enters a field that its passenger wants to go to.
	local result = nil
	if aiList[train.aiID] then
		if aiList[train.aiID].foundDestination then
			local cr = coroutine.create(runAiFunctionCoroutine)
			
			tr = {ID=train.ID, name=train.name, x=train.tileX, y=train.tileY, dir=train.dir}		-- don't give the original data to the ai!
			if train.curPassenger then
				tr.passenger = {name = train.curPassenger.name, destX = train.curPassenger.destX, destY = train.curPassenger.destY}
			end
			
			ok, result = coroutine.resume(cr, aiList[train.aiID].foundDestination, MAX_LINES_EXECUTING, tr)
			if not ok or coroutine.status(cr) ~= "dead" then		
				console.add(aiList[train.aiID].name .. ": Stopped function: ai.foundDestination()", {r = 255,g=50,b=50})
				--print("\tCoroutine stopped prematurely: " .. aiList[train.aiID].name .. ".foundDestination()")
			end
		end
	end
end

function ai.mapEvent(aiID, ... )		-- called when the map script wants to.
	local result = nil
	if aiList[aiID] then
		if aiList[aiID].mapEvent then
			local cr = coroutine.create(runAiFunctionCoroutine)
			
			args = {...}
			ok, result = coroutine.resume(cr, aiList[aiID].mapEvent, MAX_LINES_EXECUTING, unpack(args))
			if not ok or coroutine.status(cr) ~= "dead" then		
				console.add(aiList[aiID].name .. ": Stopped function: ai.mapEvent()", {r = 255,g=50,b=50})
				--print("\tCoroutine stopped prematurely: " .. aiList[train.aiID].name .. ".foundDestination()")
			end
		end
	end
end

function ai.enoughMoney(aiID, cash)
	local result = nil
	if aiList[aiID] then
		if aiList[aiID].enoughMoney then
			local cr = coroutine.create(runAiFunctionCoroutine)
			
			ok, result = coroutine.resume(cr, aiList[aiID].enoughMoney, MAX_LINES_EXECUTING, cash)
			if not ok or coroutine.status(cr) ~= "dead" then
				console.add(aiList[aiID].name .. ": Stopped function: ai.enoughMoney()", {r = 255,g=50,b=50})
				--print("\tCoroutine stopped prematurely: " .. aiList[aiID].name .. ".enoughMoney()")
			end
		end
	end
end

function ai.getName(ID)
	if aiList[ID] then return aiList[ID].name
	else return simulation.getName[ID]
	end
end

function ai.findAvailableAIs(randomize)
	if CL_DIRECTORY then
		local fileNames = nil
		if MYSQL then 
			fileNames = chooseAIfromDB( 1 )
		end
		if not fileNames then
			fileNames = findAIs(CL_DIRECTORY)
			fileNames = fixTableIndices(fileNames)
			fileNames = randomizeTable(fileNames, 4)
		end
		return fileNames
	else
		--local files = love.filesystem.enumerate(love.filesystem.getSaveDirectory() .. "/AI")		-- load AI subdirectory
		
		--local directory = love.filesystem.getWorkingDirectory()
		--local files = findAIs(directory)
		print("Searching: ", AI_DIRECTORY)
		local files = scandir(AI_DIRECTORY)
		
		--if #files < 1 then
		--	files = 
		--end
		
		for k, file in ipairs(files) do
			if file:find("Backup.lua") then
				files[k] = nil
			else
				if file == "." or file == ".." then
					files[k] = nil
				else
					s, e = file:find(".lua")
					if e == #file then
						files[k] = AI_DIRECTORY .. files[k]
					else
						--check if this was a zip file! in this case, it would be:
						--	folderName
						--	folderName/folderName.lua
						--	folderName/possible other include files and folders.
						f = io.open(AI_DIRECTORY .. files[k] .. "/" .. files[k] .. ".lua")
						if f then
							files[k] = AI_DIRECTORY .. files[k] .. "/" .. files[k] .. ".lua"
							f:close()
						else
							files[k] = nil
						end
					end
				end
			end
		end
		
		files = fixTableIndices(files)
		
		if randomize then
			return randomizeTable(files, 4)
		else
			--table.sort(files)
			return files
		end
	end
end

function ai.backupTutorialAI( fileName )

	if love.filesystem.exists( "AI/" .. fileName ) then
		local content = love.filesystem.read( "AI/".. fileName )
		--local contents = file:read("*all")
		
		love.filesystem.write( "AI/" .. fileName:sub(1, #fileName-4) .. "-(" .. os.time() .. ")-Backup.lua", content)
		--file:write(contents)
		--file:close()
		print("Backed up tutorial AI to: " .. "AI/" .. fileName:sub(1, #fileName-4) .. "-(" .. os.time() .. ")-Backup.lua" )

		statusMsg.new("Found old AI for this tutorial!\nBacked up to:" .. "AI/" .. fileName:sub(1, #fileName-4) .. "-(" .. os.time() .. ")-Backup.lua", true)
	end

end

function ai.createNewTutAI( fileName, fileContent)
	ai.backupTutorialAI( fileName )
	print("Attempt to create tutorial file:", fileName)
	print("Path:", AI_DIRECTORY .. fileName)

	love.filesystem.write( "AI/" .. fileName, fileContent )
	--[[file = io.open( AI_DIRECTORY .. fileName, "w")
	if not file then
		print("Path2:", "AI/" .. fileName)
		file = io.open( "AI/" .. fileName, "w")
	end
	print("File result2:", file)
	if file then
		print("Writing to tut file:", fileContent:sub(1, 20) .. "...")
		file:write(fileContent)
		file:close()
	end]]
end
return ai
