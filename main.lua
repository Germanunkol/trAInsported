---------------------------------------------------------------------
-- trAInsported main script.
-- Run using /path/to/love /path/to/this/folder
-- Add '--server' command line option to run in dedicated server mode.
-- Created by Germanunkol (http://www.indiedb.com/members/Germanunkol)
----------------------------------------------------------------------

-- Add path to all other Scripts:
package.path = "Scripts/?.lua;" .. package.path

--[[
_require = require

function require(fileName)
	ok, module = pcall(_require(fileName))
	if not ok then
		ok, module = pcall(_require("Scripts/" ..fileName))
	end
	return module
end
]]--

-- Add Scripts used by both client and server:
--require("globals")
require("Scripts/globals")
require("Scripts/misc")
passenger = require("Scripts/passenger")
train = require("Scripts/train")
map = require("Scripts/map")
stats = require("Scripts/statistics")
ai = require("Scripts/ai")
require("Scripts/TSerial")
pSpeach = require("Scripts/passengerSpeach")
log = require("Scripts/databaseLog")
chart = require("Scripts/generateChart")

-- Command line options are parsed in conf.lua. If anything is wrong with them, the INVALID_ flags are set.
-- Handle these here:
if INVALID_PORT then
	print("Invalid port number given.")
	print("Usage: -p PORTNUMBER")
	love.event.quit()
	return
else
	if CL_PORT then
		PORT = CL_PORT
	end
	print("Using port " .. PORT .. ".")
end

if INVALID_MYSQL then
	print("Wrong usage of --mysql!")
	print("Correct would be: --mysql login,password[,host[,port]]")
	print("Example: --mysql testUser,myPassword")
	print("Example 2: --mysql testUser,myPassword,192.158.1.20,6001")
	love.event.quit()
	return
end

if INVALID_MAPSIZE then
	print("Wrong usage of --mapsize!")
	print("Range is " .. MAP_MINIMUM_SIZE + 1 .. " to 100.")
	print("Example: --mapsize 30")
	love.event.quit()
	return
elseif MAP_SIZE then
	MAP_MAXIMUM_SIZE = MAP_SIZE
end

if INVALID_MYSQL_DATABASE then
	print("Wrong usage of --mysqlDB!")
	print("Correct would be: --mysqlDB DATABASE")
	print("Default database is 'trAInsported'.")
	love.event.quit()
	return
end

if INVALID_DIRECTORY then
	print("Wrong usage of --directory!")
	print("--directory is only available on Linux Systems.")
	print("Use:\n--directory /path/to/ais")
	love.event.quit()
	return
end

if INVALID_CHART_DIRECTORY then
	print("Wrong usage of --chart!")
	print("Use:\n--chart /path/to/folder")
	love.event.quit()
	return
end

if CL_DIRECTORY then
	ok, lfs = pcall(require, "lfs")
	if not ok then 
		print("Error: Could not find Lua filesystem. Please install this to use the -d (or --directory) feature!")
		CL_DIRECTORY = nil
	else
		function findAIs (path)
			local i, files = 1, {}
			ok, msg = pcall(lfs.dir, path)
			if ok then 
				for file in lfs.dir(path) do
					if file ~= "." and file ~= ".." then
						local f = path..'/'..file
						local attr = lfs.attributes (f)
						assert (type(attr) == "table")
						if attr.mode == "directory" then
							tempFiles = findAIs (f)
							for k, tF in pairs(tempFiles) do
								
								files[i] = tF
								i = i + 1
							end
						else
							local s,e = f:find(".lua")
							if e == #f then
								files[i] = f
								i = i + 1
							end
						end
					end
				end
			end
			return files
		end
		
	end
	--t = findAIsInDir(CL_DIRECTORY)
	--for k, f in pairs(t) do
		--print(" ->",k, f)
	--end
end



if DEDICATED then
	------------------------------------------
	-- DEDICATED Server (headless):

	
	-------------------------------
	-- HANDLE COMMAND LINE OPTIONS:
	
	if INVALID_MATCH_TIME then
		print("Invalid match time given.")
		print("Usage: -m TIME (where TIME is greater than or equal to 10)")
		love.event.quit()
	else
		if CL_ROUND_TIME then
			print("Rounds will take " .. CL_ROUND_TIME .. " seconds.")
		else
			print("Rounds will take " .. FALLBACK_ROUND_TIME .. " seconds.")
		end
	end

	if INVALID_DELAY_TIME then
		print("Invalid cooldown time given.")
		print("Usage: -c TIME (where TIME is greater than or equal to 0)")
		love.event.quit()
	else
		if CL_TIME_BETWEEN_MATCHES then
			TIME_BETWEEN_MATCHES = CL_TIME_BETWEEN_MATCHES
		else
			TIME_BETWEEN_MATCHES = 10
		end
		print("Will start a new match after waiting for " .. TIME_BETWEEN_MATCHES .. " seconds.")
	end
	
	if CL_MYSQL_PORT then
		print("Will attempt to connect to database as " .. CL_MYSQL_NAME .. "@"..CL_MYSQL_HOST .. ":" .. CL_MYSQL_PORT .. ".")
	elseif CL_MYSQL_HOST then
		print("Will attempt to connect to database as " .. CL_MYSQL_NAME .. "@"..CL_MYSQL_HOST .. ".")
	end
	
	if CL_MYSQL_DATABASE then	-- supplied a database name?
		MYSQL_DATABASE = CL_MYSQL_DATABASE
		print("Using database: '" .. MYSQL_DATABASE .. "'.")
	else
		print("No database name given. Using default database: '" .. MYSQL_DATABASE .. "' (Change with --mysqlDB).")
	end
	
	if CL_SERVER_IP then
		print("I do not know what to do with -ip or -h or --host in dedicated server mode.")
		love.event.quit()
	end
	
	-------------------------------

	require("Scripts/server")	-- main Server module. Handles server's communication with the client.
	
	connectionThreadNum = 0
	connection = {}
	moveTime = 0
	timeUntilNextMatch = 0
	timeUntilMatchEnd = 0
	timeFactor = 3

	-------------------------------
	-- main function, runs at startup:
	function love.load(args)
		print("Starting in dedicated Server mode!")
		
		log.findTable()		-- look for table in database.
		
		io.close()

		map.init()

		initServer()
		
		math.randomseed(os.time())
		
		AI_DIRECTORY = "AI/"
	end
	
	
	-------------------------------
	-- runs every frame:
	function love.update()
		handleThreadMessages( connection )
	
		if map.generating() then
			map.generate()
		end
		dt = love.timer.getDelta()
		
		if not roundEnded and curMap then
			train.moveAll(dt*timeFactor)
			curMap.time = curMap.time + dt*timeFactor
			
			timeUntilMatchEnd = timeUntilMatchEnd - dt
			
		elseif not map.generating() then
		
			if timeUntilMatchEnd > 0 then		--wait until the actual match time is over:
				timeUntilMatchEnd = timeUntilMatchEnd - dt
				
				if connection.thread and lastServerTimeUpdate - timeUntilMatchEnd >= 10 then
					lastServerTimeUpdate = timeUntilMatchEnd
					connection.thread:set("time", (CL_ROUND_TIME or FALLBACK_ROUND_TIME) - timeUntilMatchEnd)
				end
				
				-- display time until next match:
				rounded = math.floor(timeUntilMatchEnd*100)/100
				s,e = string.find(rounded, "%.")
				if not s then
					rounded = rounded .. ".00"
				else
					if string.len(rounded) - e == 1 then
						rounded = rounded .. "0"
					end
				end
				if tonumber(rounded) > 0 then
					io.write( "Waiting for round to end: " .. rounded .. " seconds.","\r") io.flush()
				else
					io.write( "Waiting for round to end: 0.00 seconds.","\r") io.flush()
				end
				if timeUntilMatchEnd <= 0 then
					print("")		--jump to newline!
				end
			else
				
				-- wait for delay to be over
				timeUntilNextMatch = timeUntilNextMatch - dt
			
				-- display time until next match:
				rounded = math.floor(timeUntilNextMatch*100)/100
				s,e = string.find(rounded, "%.")
				if not s then
					rounded = rounded .. ".00"
				else
					if string.len(rounded) - e == 1 then
						rounded = rounded .. "0"
					end
				end			
				io.write( "Starting next match in " .. rounded .. " seconds.","\r")
			
				-- possibly start next match:
				if timeUntilNextMatch <= 0 then
				
					print("")		--jump to newline!
					
					stats.generateChart()
					
					io.flush()
					io.write( "Starting next match in 0.00 seconds.","\r")
				
					setupMatch()
					
					timeUntilMatchEnd = CL_ROUND_TIME or FALLBACK_ROUND_TIME
					timeUntilNextMatch = TIME_BETWEEN_MATCHES
					lastServerTimeUpdate = timeUntilMatchEnd
					
					
					loggedMatch = false
								
					connection.thread:set("nextMatch", timeUntilNextMatch)
				else
					if not loggedMatch then
						loggedMatch = true
						if #aiList > 0 then
							log.matchResults()
						end
					end
				
					io.flush()
				end
			end
		end
		if curMap and not roundEnded then
			map.handleEvents(dt)
			passenger.showAll(dt*timeFactor)
		end
	end
	
	console = {}
	function console.add(text, color)
		-- print("CONSOLE:", text)
	end
		
else


	------------------------------------------
	-- Client (graphical):
	
	-------------------------------
	-- HANDLE COMMAND LINE OPTIONS
	
	if INVALID_IP then
		print("Invalid ip given.")
		print("Usage: -h ###.###.###.### or -h localhost or -h ADDRESS")
		love.event.quit()
	end
	
	
	if CL_ROUND_TIME then
		print("I do not know what to do with match time in client mode.")
		love.event.quit()
	end
	
	if TIME_BETWEEN_MATCHES then
		print("I do not know what to do with delay time in client mode.")
		love.event.quit()
	end
	
	if not CL_SERVER_IP then
		print("No IP given. Will use fallback IP: " .. FALLBACK_SERVER_IP)
	end
	-------------------------------
	

	-- load additional modules not needed by the server:
	console = require("Scripts/console")
	require("Scripts/imageManipulation")
	require("Scripts/ui")
	require("Scripts/input")
	quickHelp = require("Scripts/quickHelp")
	button = require("Scripts/button")
	menu = require("Scripts/menu")
	msgBox = require("Scripts/msgBox")
	tutorialBox = require("Scripts/tutorialBox")
	codeBox = require("Scripts/codeBox")
	functionQueue = require("Scripts/functionQueue")
	clouds = require("Scripts/clouds")
	loadingScreen = require("Scripts/loadingScreen")
	connection = require("Scripts/connectionClient")
	simulation = require("Scripts/simulation")
	statusMsg = require("Scripts/statusMsg")
	versionCheck = require("Scripts/versionCheck")
	
	local floatPanX, floatPanY = 0,0	-- keep "floating" into the same direction for a little while...

	local renderingProcessStarted
	local toRenderList = {}
	local renderingList = {}
	local numberOfThreads = 0
	local maxNumberOfThreads = 4	--default

	-------------------------------
	-- Main function, runs at startup:
	function love.load(args)
	
		-- load screen resolution from config file:
		setupScreenResolution()
	
		numTrains = 0
		--DEBUG_OVERLAY = true
		
		time = 0
		mouseLastX = 0
		mouseLastY = 0
		MAX_PAN = 500
		camX, camY = 0,0
		camZ = 0.7
		mapMouseX, mapMouseY = 0,0

		timeFactor = 1
		serverTime = 0
		
		curMap = false
		showQuickHelp = false
		showConsole = true
		initialising = true

		loadingScreen.reset()	
		love.graphics.setBackgroundColor(BG_R, BG_G, BG_B, 255)

		versionCheck.start()
		
		love.filesystem.mkdir("AI")
		
		AI_DIRECTORY = love.filesystem.getSaveDirectory()
		AI_DIRECTORY = AI_DIRECTORY .. "/AI/"
		--[[if AI_DIRECTORY:find("/") == 1 then		-- Unix style!!
			AI_DIRECTORY = AI_DIRECTORY .. "/AI/"
		else
			AI_DIRECTORY = AI_DIRECTORY .. "\\AI\\"
		end]]--
		
		print("Will look for AIs in:",AI_DIRECTORY)
		
	end

	function finishStartupProcess()
		console.init( love.graphics.getWidth(),love.graphics.getHeight()/2 )
	
		SPEACH_BUBBLE_WIDTH = pSpeachBubble:getWidth()

		map.init()

		menu.init()
	end

	-------------------------------
	-- Runs every frame:
	function love.update(dt)
			
		if initialising then
		
			if not renderingProcessStarted then
				renderingProcessStarted = true
				numberOfThreads = 0
				local n = getCPUNumber()
				if n then
					maxNumberOfThreads = n
					print("Cores detected: " ..  maxNumberOfThreads)
				else
					print("Could not detect number of cores. Using " .. maxNumberOfThreads .. " threads.")
				end
				
				startRenderingTime = os.time()
				
				-- queue up all modules which need rendering (all of them must have the functions .init and .initialised!!)
				table.insert(toRenderList, button)
				table.insert(toRenderList, msgBox)
				table.insert(toRenderList, loadingScreen)
				table.insert(toRenderList, quickHelp)
				table.insert(toRenderList, stats)
				table.insert(toRenderList, tutorialBox)
				table.insert(toRenderList, codeBox)
				table.insert(toRenderList, statusMsg)
				table.insert(toRenderList, pSpeach)
				
			end
			
			numberOfThreads = numberOfThreads + button.init(maxNumberOfThreads - numberOfThreads)
			numberOfThreads = numberOfThreads + msgBox.init(maxNumberOfThreads - numberOfThreads)
			numberOfThreads = numberOfThreads + loadingScreen.init(maxNumberOfThreads - numberOfThreads)
			numberOfThreads = numberOfThreads + quickHelp.init(maxNumberOfThreads - numberOfThreads)
			numberOfThreads = numberOfThreads + stats.init(maxNumberOfThreads - numberOfThreads)
			numberOfThreads = numberOfThreads + tutorialBox.init(maxNumberOfThreads - numberOfThreads)
			numberOfThreads = numberOfThreads + codeBox.init(maxNumberOfThreads - numberOfThreads)
			numberOfThreads = numberOfThreads + statusMsg.init(maxNumberOfThreads - numberOfThreads)
			numberOfThreads = numberOfThreads + pSpeach.init(maxNumberOfThreads - numberOfThreads)
			
			
			if button.initialised() and msgBox.initialised() and loadingScreen.initialised()
				and quickHelp.initialised() and stats.initialised() and tutorialBox.initialised()
				and codeBox.initialised() and statusMsg.initialised() and pSpeach.initialised() then
					initialising = false
					finishStartupProcess()
					print("Rendered/Loaded images in " .. os.time() - startRenderingTime .. " seconds.")
			end
			
		else
	
			connection.handleConnection()
			functionQueue.run()
	
			if msgBox.moving then
				msgBox.handleClick()
			elseif codeBox.moving then
				codeBox.handleClick()
			elseif tutorialBox.moving then
				tutorialBox.handleClick()
			else
				button.calcMouseHover()
			end
			
			if serverTime then
				serverTime = serverTime + dt		-- continue to count up the servertime, even if there's no update. This way, I can keep up with the server.
			end
			
			if mapImage then
				if simulationMap and not roundEnded then
				
					-- allow max of 5 seconds time difference:
					if (serverTime and simulationMap.time + 5 < serverTime) or fastForward == true then
						timeFactor = 10
						fastForward = true
						-- 2 seconds is okay:
						if simulationMap.time + 2 > serverTime then
							fastForward = false
						end
					else
						timeFactor = 1
					end
					simulationMap.time = simulationMap.time + dt*timeFactor
					simulation.update(dt*timeFactor)
					if train.isRenderingImages() then
						train.renderTrainImage()
					end
				end
				if not roundEnded and not simulation.isRunning() then
					map.handleEvents(dt)
				end
	
				prevX = camX
				prevY = camY
				if panningView then
					x, y = love.mouse.getPosition()
					camX = clamp(camX - (mouseLastX-x)*0.75/camZ, -MAX_PAN, MAX_PAN)
					camY = clamp(camY - (mouseLastY-y)*0.75/camZ, -MAX_PAN, MAX_PAN)
					mouseLastX = x
					mouseLastY = y
			
					floatPanX = (camX - prevX)*40
					floatPanY = (camY - prevY)*40
				
				else
					if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
						camX = clamp(camX + 300*dt/camZ, -MAX_PAN, MAX_PAN)
					end
					if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
						camX = clamp(camX - 300*dt/camZ, -MAX_PAN, MAX_PAN)
					end 
					if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
						camY = clamp(camY + 300*dt/camZ, -MAX_PAN, MAX_PAN)
					end
					if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
						camY = clamp(camY - 300*dt/camZ, -MAX_PAN, MAX_PAN)
					end
					if love.keyboard.isDown("q") then
						camZ = clamp(camZ + dt*0.25, 0.1, 1)
						camX = clamp(camX, -MAX_PAN, MAX_PAN)
						camY = clamp(camY, -MAX_PAN, MAX_PAN)
					end
					if love.keyboard.isDown("e") then
						camZ = clamp(camZ - dt*0.25, 0.1, 1)
						camX = clamp(camX, -MAX_PAN, MAX_PAN)
						camY = clamp(camY, -MAX_PAN, MAX_PAN)
					end
			
					if camX ~= prevX or camY ~= prevY then
						floatPanX = (camX - prevX)*20
						floatPanY = (camY - prevY)*20
					end
				end
				if camX == prevX and camY == prevY then
					floatPanX = floatPanX*math.max(1 - dt*3, 0)
					floatPanY = floatPanY*math.max(1 - dt*3, 0)
					camX = clamp(camX + floatPanX*dt, -MAX_PAN, MAX_PAN)
					camY = clamp(camY + floatPanY*dt, -MAX_PAN, MAX_PAN)
				end
			elseif map.startupProcess() then
				if map.generating() then
					err = mapGenerateThread:get("error")
					if err then
						print("Error in thread", err)
					end
					curMap = map.generate()
				elseif map.rendering() then
					err = mapRenderThread:get("error")
					if err then
						print("Error in thread", err)
					end
				
					--if simulation.isRunning() then
					mapImage,mapShadowImage,mapObjectImage = map.render()
					if mapImage then
						print("received mapImage:", mapImage)
					end
					--else
						--simulationMapImage,mapShadowImage,mapObjectImage = map.render()
					--end
				end
				if train.isRenderingImages() then
					train.renderTrainImage()
				end
			
				if not train.isRenderingImages() and not map.generating() and not map.rendering() then	-- done rendering everything!
					if not simulation.isRunning() then
						runMap()	-- start the map!
					else
						simulation.runMap()
					end
				end
			else
				if menu.isRenderingImages() then
					menu.renderTrainImages()
				end
			end
		
		
			if not roundEnded then
				train.moveAll()
				if curMap then
					curMap.time = curMap.time + dt*timeFactor
				end
			end
		end
	
	end

	-------------------------------
	-- Runs every frame, displays everything on the screen:
	function love.draw()

		if initialising then		--only runs once at startup, until all images are rendered.
			loadingScreen.render()
			return
		end

		-- love.graphics.rectangle("fill",50,50,300,300)
		dt = love.timer.getDelta()
		passedTime = dt*timeFactor
	
		if mapImage then
			if simulationMap then
				simulation.show(dt)
			else
				map.show()
		
				if showQuickHelp then quickHelp.show() end
				if showConsole then console.show() end
			
				stats.displayStatus()
			end
		else
			if not hideLogo then
				love.graphics.draw(LOGO_IMG, (love.graphics.getWidth()-LOGO_IMG:getWidth())/2, love.graphics.getHeight()-LOGO_IMG:getHeight()- 50)
				love.graphics.setColor(255,255,255,100)
				love.graphics.setFont(FONT_STANDARD)
				love.graphics.print("Version: " .. VERSION, (love.graphics.getWidth()-LOGO_IMG:getWidth())/2 + 580, love.graphics.getHeight()-LOGO_IMG:getHeight() + 135)
			end
			if map.generating() or map.rendering() or attemptingToConnect then -- or trainGenerateThreads > 0 then
				loadingScreen.render()
			else
				simulation.displayTimeUntilNextMatch(nil, dt)
			end
		end

		if roundEnded and (curMap or simulationMap) and mapImage then stats.display(love.graphics.getWidth()/2-175, 40, dt) end
	
	
		button.show()
	
		tutorialBox.show()
		codeBox.show()
		if msgBox.isVisible() then
			msgBox.show()
		end
	
		menu.render()
		statusMsg.display(dt)
	
		if love.keyboard.isDown(" ") then
			love.graphics.setFont(FONT_CONSOLE)
			love.graphics.setColor(255,255,255,255)
			love.graphics.print("FPS: " .. tostring(love.timer.getFPS( )), love.graphics.getWidth()-150, 5)
			love.graphics.print('RAM: ' .. collectgarbage('count'), love.graphics.getWidth()-150,20)
			love.graphics.print('X: ' .. camX, love.graphics.getWidth()-150,35)
			love.graphics.print('Y: ' .. camY, love.graphics.getWidth()-150,50)
			love.graphics.print('Z ' .. camZ, love.graphics.getWidth()-150,65)
			love.graphics.print('Passengers: ' .. MAX_NUM_PASSENGERS, love.graphics.getWidth()-150,80)
			love.graphics.print('Trains: ' .. numTrains, love.graphics.getWidth()-150,95)
			love.graphics.print('x ' .. timeFactor, love.graphics.getWidth()-150,110)
			if curMap then love.graphics.print('time ' .. curMap.time, love.graphics.getWidth()-150,125) end
			if roundEnded then
				love.graphics.print('roundEnded: true', love.graphics.getWidth()-150,140)
			else
				love.graphics.print('roundEnded: false', love.graphics.getWidth()-150,140)
			end
		end
		
		if simulationMap and fastForward then
			love.graphics.setFont(FONT_HUGE)
			love.graphics.setColor(255,255,255,255)
			love.graphics.print("FAST FORWARD TO CATCH UP WITH SERVER", 0.5*(love.graphics.getWidth()- FONT_HUGE:getWidth("FAST FORWARD TO CATCH UP WITH SERVER")), 0.5*love.graphics.getHeight() -10)
		end
	end
	
end


-------------------------------
-- Called when closing the game:
function love.quit()
	print("Closing.")
end
