local ai = {}

local aiList = {}		-- holds all the ai functions/events


local aiUserData = {		--default fallbacks in case a function is not created by the User's AI script.
	init = function () print("default init") end,
	run = function () print("default run")end,
}


local sandbox = require("Scripts/sandbox")

-- maximum times that the script may run (in seconds)
local MAX_LINES_LOADING = 10000
local MAX_LINES_EXECUTING = 1000

local coLoad = nil
linesUsed = 0

function newLineCountHook( maxLines )
	local startTime = love.timer.getTime()
	local time = 0
	local lines = 0
	linesUsed = 0
	return function ( event, l )
		if event == "line" then
			lines = lines + 1
			linesUsed = linesUsed + 1
			time = love.timer.getTime()
			if lines == maxLines then
				error("Taking too long, stopping. Time taken: " .. time-startTime .. "s.")
			end
		end
	end
end

local function safelyLoadAI(chunk, scriptName)

	print("\tCompiling code...")
	debug.sethook(newLineCountHook(MAX_LINES_LOADING), "l")
	local func, message = loadstring(chunk, scriptName)
	debug.sethook()
	if not func then
		print("Could not load script: \n", message)
		coroutine.yield()
	end
	print("\t\tSuccess! Code lines: " .. linesUsed .. " of " .. MAX_LINES_LOADING)
	
	
	print("\tRunning code:")
	func = setfenv(func, sandbox)
	debug.sethook(newLineCountHook(MAX_LINES_LOADING), "l")
	local ok, message = pcall(func)
	if not ok then
		print("Could not execute script: \n", message)
		coroutine.yield()
	end
	debug.sethook()
	print("\t\tSuccess! Code lines: " .. linesUsed .. " of " .. MAX_LINES_LOADING)
end
	
function runAiFunctionCoroutine(f)
--	f = setfenv(f, sandbox)
	debug.sethook(newLineCountHook(MAX_LINES_EXECUTING), "l")
	local ok, err = pcall(f)
	debug.sethook()
	if not ok then
		print(err)
		coroutine.yield()
	end	 -- throw up to next level
	print("\t\tSuccess! Code lines: " .. linesUsed .. " of " .. MAX_LINES_EXECUTING)
end


function ai.new(scriptName)
	print("Opening: " .. scriptName)
	local ok, chunk = pcall(love.filesystem.read, scriptName )
	if not ok then error("Could not open file: " .. chunk) end
	
	if chunk:byte(1) == 27 then error("Binary bytecode prohibited. Open source ftw!") end
	
	local aiID = 0
	
	for i = 1,#aiList+1,1 do
		if aiList[i] == nil then
			aiList[i] =	aiUserData
			aiList[i].name = scriptName
			aiID = i
			break
		end
	end
	
	--set up the ai which the user's script will have access to:
	sandbox.ai = restrictAITable(aiList[aiID])
	
	--this first coroutine compiles and runs the source code of the user's AI script:
	local crLoad = coroutine.create(safelyLoadAI)
	local ok, err = pcall(coroutine.resume, crLoad, chunk, scriptName)
	if coroutine.status(crLoad) ~= "dead" then
		crLoad = nil
		error("Coroutine stopped prematurely: " .. aiList[aiID].name)
	end
	crLoad = nil
	print("\tAI loaded.")
	
	aiList[aiID].init = sandbox.ai.init		-- if it all went right, now we can set the table.
	aiList[aiID].run = sandbox.ai.run
	
	--the second coroutine loads the ai.init() function in the user's AI script:
	print("\tInitializing AI:")
	print("ID: ", aiID)
	print("ai: ", aiList[aiID])
	print("name: ", aiList[aiID].name)
	if type(aiList[aiID].init) ~= "function" then
		print("\t\tError: No init function found")
		return
	end
	local crInit = coroutine.create(runAiFunctionCoroutine)
	coroutine.resume(crInit, aiList[aiID].init)
	if coroutine.status(crInit) ~= "dead" then
		crInit = nil
		print("Coroutine stopped prematurely: " .. aiList[aiID].name .. ".init()")
	end
	print("name", aiList[aiID].name)
	crInit = nil
	
end

function ai.run()
	for k, userAI in pairs(aiList) do
		if userAI.run then
			local cr = coroutine.create(runAiFunctionCoroutine)
			coroutine.resume(cr, userAI.run)
			if coroutine.status(cr) ~= "dead" then
				print("Coroutine stopped prematurely: " .. userAI.name .. ".run()")
			end
			cr = nil
		end
	end
end
	
return ai
