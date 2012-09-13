local ai = {}

local aiList = {}		-- holds all the ai functions/events

local sandbox = require("Scripts/sandbox")

-- maximum times that the script may run (in seconds)
local MAX_LINES_LOADING = 100000
local MAX_LINES_EXECUTING = 10000

local coLoad = nil

function hookClosureInit( maxLines )
	local startTime = love.timer.getTime()
	local time = 0
	local lines = 0
	return function ( event )
		if event == "count" then
			lines = lines + 1
			time = love.timer.getTime()
			if lines > maxLines then
				error("Taking too long, stopping. Time taken: " .. time-startTime .. "s.")
			end
		end
	end
end

local function safelyExecute(chunk, scriptName, selfCoroutine)

	hook = hookClosureInit(MAX_TIME_LOADING)

	debug.sethook(hook, "l", 100)
	local func, message = loadstring(chunk, scriptName)
	debug.sethook()
	
	if not func then
		print("Could not load script: ", message)
		coroutine.yield()
	end
	
	func = setfenv(func, sandbox)
	
	debug.sethook(hookClosureInit(MAX_LINES_EXECUTING), "l", 100)
	local ok, message = pcall(func)
	debug.sethook()
	if not ok then
		print("Could not execute script: ", message)
		coroutine.yield()
	end
	
	print("Initializing AI:", ai.init)
	debug.sethook(hookClosureInit(MAX_LINES_EXECUTING), "l", 100)
	ok, err = pcall(ai.init)
	if not ok then
		print(err)
		coroutine.yield()
	end	 -- throw up to next level
	debug.sethook()
	print("AI initialized.")
end


function ai.new(scriptName)
	print("Opening: " .. scriptName)
	local ok, chunk = pcall(love.filesystem.read, scriptName )
	if not ok then error("Could not open file: " .. chunk) end
	
	if chunk:byte(1) == 27 then error("Binary bytecode prohibited") end
	
	for i = 1, #aiList+1,1 do
		if aiList[i] = nil then
			aiList[i] = {}
			sandbox.ai = aiList[i]
		end
	end
	
	coLoad = coroutine.create(safelyExecute)
	coroutine.resume(coLoad, chunk, scriptName)
	if coroutine.status(coLoad) ~= "dead" then
		coLoad = nil
		error("Coroutine stopped prematurely.")
	end
	coLoad = nil
end

	
return ai
