local menu = {}

local buttonExit = nil
local buttonRandomMatch = nil

defaultMenuX = 10
defaultMenuY = 30

local numAIsChosen = 0
local mapSizeX = 0
local mapSizeY = 0
local menuTrainImages = {}
local trainImageThreads = {}
local totalNumImageThreads = 0
local currentNumImageThreads = 0

function confirmCloseGame()
	msgBox:new(love.graphics.getWidth()/2-210, 40, LNG.exit_confirm, {name=LNG.agree,event=love.event.quit, args=nil},"remove")
end

local trainImagesCreated = false

local modes = love.window.getFullscreenModes()--love.graphics.getModes()
	
for k = 1, #RESOLUTIONS do
	skip = false
	for i = 1, #modes do
		if RESOLUTIONS[k].width == modes[i].width and RESOLUTIONS[k].height == modes[i].height then
			skip = true
			break
		end
	end
	if not skip then
		table.insert(modes, RESOLUTIONS[k])
	end
end

function sortResolutions(a, b)
	if a.wdith == b.width then
		return a.height <= b.height
	else
		return a.width < b.width
	end
end

table.sort(modes, sortResolutions )   -- sort from smallest to largest


function randomMatch()
	
	if map.generating() or map.rendering() then --mapRenderThread or mapGenerateThread then
		print("Already generating new map!")
		statusMsg.new(LNG.err_already_generating_map, true)
		return
	end
	
	
	local width = math.random(MAP_MINIMUM_SIZE,MAP_MAXIMUM_SIZE)
	local height = math.random(MAP_MINIMUM_SIZE,MAP_MAXIMUM_SIZE)
	
	local aiFiles = ai.findAvailableAIs()
	
	local chosenAIs = {}
	
	aiID = 1
	for k, aiName in pairs(aiFiles) do
		if aiID <= 4 then
			chosenAIs[aiID] = aiName
			aiID = aiID + 1
		end
	end

	local gameMode = 0
	if math.random(2) == 1 then
		gameMode = GAME_TYPE_TIME
	else
		gameMode = GAME_TYPE_MAX_PASSENGERS
	end
	
	gameMode = GAME_TYPE_MAX_PASSENGERS
	
	local time = width*height*10 + math.random(width*height*10)
	
	setupMatch(width, height, 1, time, gameMode, chosenAIs, POSSIBLE_REGIONS[math.random(#POSSIBLE_REGIONS)])
end

menuButtons = {}
menuDividers = {}
menuIcons = {}
widthButtons = {}
heightButtons = {}
timeButtons = {}
regionButtons = {}
modeButtons = {}

function menu.removeAll()
	for k, b in pairs(menuButtons) do
		b:remove()
	end
	for k, b in pairs(widthButtons) do
		b:remove()
	end
	for k, b in pairs(heightButtons) do
		b:remove()
	end
	for k, b in pairs(timeButtons) do
		b:remove()
	end
	for k, b in pairs(regionButtons) do
		b:remove()
	end
	for k, b in pairs(modeButtons) do
		b:remove()
	end
	for k, t in pairs(trainImageThreads) do
		trainImageThreads[k] = nil
	end
	for k, img in pairs(menuTrainImages) do
		menuTrainImages[k] = nil
	end
	menuButtons = {}
	menuDividers = {}
	menuIcons = {}
	widthButtons = {}
	heightButtons = {}
	timeButtons = {}
	regionButtons = {}
	modeButtons = {}
	
	trainImageThreads = {}
	menuTrainImages = {}
	
	hideLogo = false
end


--------------------------------------------------------------
--		MAIN MENU:
--------------------------------------------------------------


function menu.init(menuX, menuY)
	if menuX then
		defaultMenuX = menuX
		defaultMenuY = menuY
	end
	
	simulation.stop()
	lostConnection = false
	
	if connectionThread then
		connectionThread:set("quit", true)
	end
	attemptingToConnect = false 	-- no longer show loading screen!
	loadingScreen.reset()
	
	menu.removeAll()
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonSimulation = button:new(x, y, LNG.menu_live, menu.simulation, nil, nil, nil, nil, LNG.menu_live_tooltip)
	y = y + 60
	menuButtons.buttonTutorial = button:new(x, y, LNG.menu_tutorial, menu.tutorials, nil, nil, nil, nil, LNG.menu_tutorial_tooltip)
	y = y + 45
	menuButtons.buttonChallenge = button:new(x, y, LNG.menu_challenge, menu.challenge, nil, nil, nil, nil, LNG.menu_challenge_tooltip)
	y = y + 45
	menuButtons.buttonNew = button:new(x, y, LNG.menu_compete, menu.newRound, nil, nil, nil, nil, LNG.menu_compete_tooltip)
	y = y + 45
	menuButtons.buttonRandomMatch = button:new(x, y, LNG.menu_random, randomMatch, nil, nil, nil, nil, LNG.menu_random_tooltip)
	y = y + 60
	menuButtons.buttonOpenFolder = button:new(x, y, LNG.open_folder, openAIFolder, nil, nil, nil, nil, LNG.open_folder_tooltip:gsub("AI_FOLDER_DIRECTORY", AI_DIRECTORY))
	y = y + 45
	menuButtons.buttonSettings = button:new(x, y, LNG.menu_settings, menu.settings, nil, nil, nil, nil, LNG.menu_settings_tooltip)
	y = y + 60
	menuButtons.buttonExit = button:new(x, y, LNG.menu_exit, confirmCloseGame, nil)
	y = y + 45
	
	trainImagesCreated = false
	
	--reset tutorial:
	tutorial = {}
	tutorialBox.clearAll()
	codeBox.clearAll()
	
	--reset challenge events!:
	challenges.resetEvents()
end



--------------------------------------------------------------
--		SETUP NEW MATCH:
--------------------------------------------------------------

checkMarkImg = love.graphics.newImage("/Images/CheckMark.png")

local chosenAIs = {}
local chosenHeight, chosenWidth = 0, 0
local aiFiles = {}


function normalMatch()
	if numAIsChosen <= 0 then
		statusMsg.new(LNG.menu_err_min_ai, true)
		return
	end
	if chosenWidth == 0 or chosenHeight == 0 then
		statusMsg.new(LNG.menu_err_dimensions, true)
		return
	end
	if not chosenTime then
		statusMsg.new(LNG.menu_err_time, true)
		return
	end
	if not chosenRegion then
		chosenRegion = "Rural"
	end
	if not chosenMode then
		statusMsg.new(LNG.menu_err_mode, true)
		return
	end
	for k, aiName in pairs(chosenAIs) do
		if not menuTrainImages[k] then
			statusMsg.new("Still rendering train images...\nTry again in a few seconds.", true)
			return
		end
	end
	
	if chosenMode == "Time" then
		chosenMode = GAME_TYPE_TIME
	else
		chosenMode = GAME_TYPE_MAX_PASSENGERS
	end
	
	local AIs = {}
	local index = 1
	for k, ai in pairs(chosenAIs) do
		AIs[index] = ai
		index = index + 1
	end
	
	maxTime = chosenWidth*chosenHeight*10 + math.random(chosenWidth*chosenHeight*10)
	
	setupMatch( chosenWidth, chosenHeight, chosenTime, maxTime, chosenMode, AIs, chosenRegion)
end


function selectAI(k)
	if numAIsChosen < 4 then
		numAIsChosen = numAIsChosen + 1
		menuButtons[k].event = deselectAI
		menuButtons[k].x = menuButtons[k].x + 20
		menuButtons[k].selected = true
		chosenAIs[k] = k
		if not menuTrainImages[k] then
			print("starting thread...selectAI", k .. ".lua")
			--col = generateColour(k, 1)

			local thread = love.thread.newThread("Scripts/renderTrainImage.lua")
			local cIn = love.thread.newChannel()
			local cOut = love.thread.newChannel()

			--totalNumImageThreads = totalNumImageThreads + 1
			thread:start( cIn, cOut, k )
			--trainImageThreads[k]:set("colour", TSerial.pack(col))

			trainImageThreads[k] = { thread = thread, cIn = cIn, cOut = cOut }
			currentNumImageThreads = currentNumImageThreads + 1
		else
			table.insert( menuIcons,  {img = menuTrainImages[k], angle=math.pi/3, x = menuButtons[k].x +  menuButtons[k].imageOff:getWidth()+15, y = menuButtons[k].y - 5, index = k})
		end
	end
end

function deselectAI(k)
	numAIsChosen = numAIsChosen - 1
	menuButtons[k].x = menuButtons[k].x - 20
	menuButtons[k].event = selectAI
	menuButtons[k].selected = false
	chosenAIs[k] = nil
	for i, icon in pairs(menuIcons) do
		if icon.index == k then
			menuIcons[i] = nil
		end
	end
end

function selectWidth(x)
	for k, button in pairs(widthButtons) do
		button.event = selectWidth
		button.x = widthButtons[x].x
		button.selected = false
	end
	widthButtons[x].event = nil
	widthButtons[x].x = widthButtons[x].x + 20
	widthButtons[x].selected = true
	chosenWidth = x
end

function selectHeigth(y)
	for k, button in pairs(heightButtons) do
		button.event = selectHeigth
		button.x = heightButtons[y].x
		button.selected = false
	end
	heightButtons[y].event = nil
	heightButtons[y].x = heightButtons[y].x + 20
	heightButtons[y].selected = true
	chosenHeight = y
end

function selectTime( time )
	for k, button in pairs(timeButtons) do
		button.event = selectTime
		button.x = timeButtons[time].x
		button.selected = false
	end
	timeButtons[time].event = nil
	timeButtons[time].x = timeButtons[time].x + 20
	timeButtons[time].selected = true
	chosenTime = time
end

function selectRegion( region )
	for k, button in pairs(regionButtons) do
		button.event = selectRegion
		button.x = regionButtons[region].x
		button.selected = false
	end
	print("region:" , region)
	regionButtons[region].event = nil
	regionButtons[region].x = regionButtons[region].x + 20
	regionButtons[region].selected = true
	chosenRegion = region
end

function selectMode( mode )
	for k, button in pairs(modeButtons) do
		button.event = selectMode
		button.x = modeButtons[mode].x
		button.selected = false
	end
	modeButtons[mode].event = nil
	modeButtons[mode].x = modeButtons[mode].x + 20
	modeButtons[mode].selected = true
	chosenMode = mode
end

function menu.isRenderingImages()
	if currentNumImageThreads > 0 then
		return true
	end
end

function menu.renderTrainImages()
	for k, t in pairs(trainImageThreads) do
		err = t.thread:getError()
		if err then
			print("Error in train image thread:" .. err)
			trainImageThreads[k] = nil
			currentNumImageThreads = currentNumImageThreads - 1
		end

		local packet = 	t.cOut:pop()
		if packet then
			if packet.key == "status" then
				print("Image Thread:", status)
				if packet[1] == "done" then
					trainImageThreads[k] = nil
					currentNumImageThreads = currentNumImageThreads - 1
				end
			elseif packet.key == "image" then
				menuTrainImages[k] = love.graphics.newImage( packet[1] )
				if menuButtons[k] then
					table.insert( menuIcons,  {img = menuTrainImages[k], angle=math.pi/3, x = menuButtons[k].x +  menuButtons[k].imageOff:getWidth()+15, y = menuButtons[k].y - 5, index = k})
				end
			end
		end
	end
end

function menu.newRound()

	if map.rendering() or map.generating() then
		statusMsg.new(LNG.err_wait_for_rendering, true)
		return
	end

	menu.removeAll()
	hideLogo = true
	numAIsChosen = 0
	chosenAIs = {}
	chosenWidth = 0
	chosenHeight = 0
	chosenTime = nil
	chosenMode = nil
	chosenRegion = nil
	
	local columnWidth = math.min(bgBoxSmall:getWidth()+10, love.graphics.getWidth()/3)
	
	aiFiles = ai.findAvailableAIs()
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonReturn = button:new(x, love.graphics.getHeight() - y - STND_BUTTON_HEIGHT, LNG.menu_return, menu.init, nil)
	menuButtons.buttonContinue = button:new(love.graphics.getWidth() - x - STND_BUTTON_WIDTH - 10, love.graphics.getHeight() - y - STND_BUTTON_HEIGHT, LNG.menu_start, normalMatch, nil, nil, nil, nil, LNG.menu_start_tooltip)
	
	table.insert(menuDividers, {x = x, y = defaultMenuY, txt = LNG.menu_choose_ai})
	x = x + 20
	y = y + bgBoxSmall:getHeight()+5
	jumped = false
	for k, fileName in pairs(aiFiles) do
		local s,e = fileName:find(".*/")
		e = e or 0
		menuButtons[fileName] = button:newSmall(x, y, fileName:sub(e+1, #fileName-4), selectAI, fileName, nil, nil, LNG.menu_choose_ai_tooltip)
		y = y + 37
		if y > love.graphics.getHeight() - 150 then
			if jumped then		-- no more space! Only one jump.
				break
			end
			x = x + SMALL_BUTTON_WIDTH + 40
			y = defaultMenuY + bgBoxSmall:getHeight()+5
			jumped = true
		end
	end
	
	x = defaultMenuX + columnWidth
	y = defaultMenuY
	table.insert(menuDividers, {x=x, y = defaultMenuY, txt = LNG.menu_choose_dimensions})
	x = x + 20
	y = y + bgBoxSmall:getHeight()+5
	stepSize = math.floor((MAP_MAXIMUM_SIZE-MAP_MINIMUM_SIZE)/10)
	for width = MAP_MINIMUM_SIZE, MAP_MAXIMUM_SIZE, stepSize  do
		widthButtons[width] = button:newSmall(x, y, tostring(width), selectWidth, width, nil, nil, LNG.menu_choose_dimensions_tooltip1)
		heightButtons[width] = button:newSmall(x + SMALL_BUTTON_WIDTH + 40, y, tostring(width), selectHeigth, width, nil, nil, LNG.menu_choose_dimensions_tooltip2)
		y = y + 37
	end
	
	x = defaultMenuX + (columnWidth)*2
	y = defaultMenuY
	table.insert(menuDividers, {x=x, y = defaultMenuY, txt=LNG.menu_choose_timemode})
	x = x + 20
	y = defaultMenuY + bgBoxSmall:getHeight()+5
	for k, timeOption in pairs(POSSIBLE_TIMES) do
		timeButtons[timeOption] = button:newSmall(x, y, LNG.menu_time_name[k], selectTime, timeOption, nil, nil, LNG.menu_time_tooltip[k])
		y = y + 37
	end
	y = defaultMenuY + bgBoxSmall:getHeight()+5
	for k, modeOption in pairs(POSSIBLE_MODES) do
		modeButtons[modeOption] = button:newSmall(x + SMALL_BUTTON_WIDTH + 40, y, LNG.menu_mode_name[k], selectMode, modeOption, nil, nil, LNG.menu_mode_tooltip[k])
		y = y + 37
	end
	
	x = defaultMenuX + (columnWidth)*2
	y = y + 30
	table.insert(menuDividers, {x=x, y = y, txt=LNG.menu_choose_region})
	x = x + 20
	y = y + bgBoxSmall:getHeight()+5
	for k, regionOption in pairs(POSSIBLE_REGIONS) do
		regionButtons[regionOption] = button:newSmall(x, y, LNG.menu_region_name[k], selectRegion, regionOption, nil, nil, LNG.menu_region_tooltip[k])
		y = y + 37
	end
end



--------------------------------------------------------------
--		SIMULATION START:
--------------------------------------------------------------

function menu.startSimulation(IP)
	if connectionThread then
		statusMsg.new(LNG.err_already_connecting, true)
	else
		if not map.generating() and not map.rendering() then
			--load connection to main server:
			loadingScreen.reset()
			
			attemptingToConnect = true
			loadingScreen.addSection(LNG.load_connecting)
			loadingScreen.addSubSection(LNG.load_connecting, "Server: " .. IP)
			connection.startClient(IP, PORT)
		else
			loadingScreen.addSubSection(LNG.load_connecting, LNG.load_failed)
			print("Error: already rendering a map - can't start simulation")
			statusMsg.new(LNG.err_wait_for_rendering, true)
		end
	end
end

function menu.simulation()
	menu.removeAll()
	hideLogo = true
	x = defaultMenuX
	y = defaultMenuY
	
	if CL_SERVER_IP then
	
		menu.exitOnly()
		y = y + 45
	
		if not map.generating() and not map.rendering() then
			--load connection to main server:
			--loadingScreen.reset()
			attemptingToConnect = true
			loadingScreen.addSection(LNG.load_connecting)
			loadingScreen.addSubSection(LNG.load_connecting, "Server: " .. (CL_SERVER_IP or FALLBACK_SERVER_IP))
			connection.startClient(CL_SERVER_IP or FALLBACK_SERVER_IP, PORT)
		else
			loadingScreen.addSubSection(LNG.load_connecting, LNG.load_failed)
			print("Error: already rendering a map - can't start simulation")
			statusMsg.new(LNG.err_wait_for_rendering, true)
		end
	else
		menuButtons.buttonSimulationReturn = button:new(x, y, LNG.menu_return, menu.init, nil, nil, nil, nil, LNG.menu_return_to_main_menu_tooltip)
		y = y + 60
		menuButtons.buttonSimulationMain = button:new(x, y, LNG.menu_main_server, menu.startSimulation, MAIN_SERVER_IP, nil, nil, nil, LNG.menu_main_server_tooltip)
		y = y + 45
		menuButtons.buttonSimulationLocal = button:new(x, y, LNG.menu_local_server,  menu.startSimulation, FALLBACK_SERVER_IP, nil, nil, nil, LNG.menu_local_server_tooltip)
	end
end

--------------------------------------------------------------
--		SETTINGS MENU:
--------------------------------------------------------------

local lastX, lastY

function selectResolution(res)

	lastX, lastY = love.graphics.getWidth(), love.graphics.getHeight()
	
	-- attempt to change screen resolution:
	success = love.window.setMode( res.width, res.height )
	
	if not success then
		print("Failed to set resolution!")
		statusMsg.new(LNG.menu_err_resolution, true)
	else
		menu.settings() -- re-initialise the menu.
		msgBox:new(love.graphics.getWidth()/2-210, love.graphics.getHeight()/2-100, LNG.confirm_resolution, {name=LNG.agree,event=acceptResolution, args=nil},{name=LNG.disagree,event=resetResolution, args=nil})
	end
end

function acceptResolution()
	configFile.setValue("resolution_x", love.graphics.getWidth())
	configFile.setValue("resolution_y", love.graphics.getHeight())
	menu.settings() -- re-initialise the menu.
end

function resetResolution()
	success = love.window.setMode( lastX, lastY )
	menu.settings() -- re-initialise the menu.
end

function toggleOptionClouds(enable)
	print(enable)
	if enable then
		RENDER_CLOUDS = true
	else
		RENDER_CLOUDS = false
	end

	configFile.setValue("render_clouds", enable)
	
	menu.settings() -- re-initialise the menu.
end


function menu.languageChosen(lang)
print("Attempt to load new language:", lang)
	if selectLanguage(lang) then
		configFile.setValue("language", lang)	-- save the settings!
	else
		statusMsg.new("Could not load language file. See the console for errors.", true)
	end
	menu.settings() -- re-initialise the menu.
end

function menu.settings()
	menu.removeAll()
	hideLogo = true
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonExit = button:new(x, y, LNG.menu_return, menu.init, nil)
	y = y + 45
	
	
	local columnWidth = math.min(bgBoxSmall:getWidth()+10, love.graphics.getWidth()/3)
	
	x = x + 200
	y = defaultMenuY
	table.insert(menuDividers, {x = x, y = defaultMenuY, txt = LNG.menu_settings_resolution})
	x = x + 20
	y = y + bgBoxSmall:getHeight()+5
	jumped = false
	
	for k = 1, #modes do
		res = modes[k]
		menuButtons[k] = button:newSmall(x, y, res.width .. "x" .. res.height, selectResolution, res, nil, nil, LNG.menu_resolution_tooltip)
		y = y + 37
		if y > love.graphics.getHeight() - 150 then
			if jumped then		-- no more space! Only one jump.
				break
			end
			x = x + SMALL_BUTTON_WIDTH + 40
			y = defaultMenuY + bgBoxSmall:getHeight()+5
			jumped = true
		end
	end
	x = defaultMenuX + 200 + columnWidth
	y = defaultMenuY
	table.insert(menuDividers, {x = x, y = defaultMenuY, txt = LNG.menu_settings_options})
	x = x + 20
	y = y + bgBoxSmall:getHeight()+5
	if RENDER_CLOUDS then
		menuButtons["optionClouds"] = button:newSmall(x, y, LNG.menu_clouds_on, toggleOptionClouds, false, nil, nil, LNG.menu_clouds_off_tooltip)
	else
		menuButtons["optionClouds"] = button:newSmall(x, y, LNG.menu_clouds_off, toggleOptionClouds, true, nil, nil, LNG.menu_clouds_on_tooltip)
	end
	
	x = defaultMenuX + 200 + columnWidth*2
	y = defaultMenuY
	table.insert(menuDividers, {x = x, y = defaultMenuY, txt = LNG.menu_settings_language})
	x = x + 20
	y = y + bgBoxSmall:getHeight()+5
	for k = 1, #LANGUAGES do
		menuButtons["option" .. LANGUAGES[k]] = button:newSmall(x, y, LANGUAGES[k], menu.languageChosen, LANGUAGES[k], nil, nil, LNG.menu_settings_language_tooltip1 .. " '".. LANGUAGES[k] .. "' " .. LNG.menu_settings_language_tooltip2)
		y = y + 37
	end
end


--------------------------------------------------------------
--		TUTORIAL MENU:
--------------------------------------------------------------

local function alphabetical(a, b)
	print(a,b)
	if a < b then return true end
end

function findTutorialFiles()
	local files = love.filesystem.getDirectoryItems("Tutorials")		-- load subdirectory
	local foundFiles = {}
	for k, file in ipairs(files) do
		s, e = file:find(".lua")
		if e == #file then
			print("Tutorial found: " .. k .. ". " .. file)
			table.insert(foundFiles, file)
		end
	end
	
	table.sort(foundFiles)
	
--	table.sort(files, alphabetical)
	return foundFiles
end


function menu.executeTutorial(fileName)
	if not map.generating() and not map.rendering() then
		tutorialData = love.filesystem.load( "Languages/" .. CURRENT_LANGUAGE .. "_" .. fileName)
		--print(ok,tutorialData)
		if not tutorialData then	-- fallback:
			tutorialData = love.filesystem.load("Tutorials/" .. fileName)
		end
		--print(tutorialData)
		local result = tutorialData() -- execute the chunk
		tutorial.start()
	else
		statusMsg.new("Wait for rendering to finish...", true)
	end
end

function menu.tutorials()
	menu.removeAll()
	hideLogo = true
	x = defaultMenuX
	y = defaultMenuY
	
	menuButtons.buttonExit = button:new(x, y, LNG.menu_return, menu.init, nil)
	y = y + 60
	tutFiles = findTutorialFiles()
	for i = 1, #tutFiles do
		if tutFiles[i] then
		menuButtons[i] = button:new(x, y, tutFiles[i]:sub(1, #tutFiles[i]-4), menu.executeTutorial, tutFiles[i], nil, nil, nil, tutDescriptions[i])
		end
		y = y + 45
	end
end

--------------------------------------------------------------
--		TUTORIAL MENU:
--------------------------------------------------------------

function findChallengeMapsFiles()
	local foundFiles = {}

	local files = love.filesystem.getDirectoryItems("Challenges")	-- load Maps subdirectory (in the .love file)
	for k, file in ipairs(files) do
		s, e = file:find(".lua")
		if e == #file then
			print("User Challenge Map found: " .. k .. ". " .. file)
			table.insert(foundFiles, file)
		end
	end

	local files = love.filesystem.getDirectoryItems("Maps")		-- load user maps subdirectory (in the saveDirectory)
	for k, file in ipairs(files) do
		s, e = file:find(".lua")
		if e == #file then
			print("Challenge Map found: " .. k .. ". " .. file)
			table.insert(foundFiles, file)
		end
	end
	
	return foundFiles
end


function menu.choseChallenge(mapFile)
	menu.removeAll()
	hideLogo = true
	x = defaultMenuX
	y = defaultMenuY
	
	--menuButtons.buttonExit = button:new(x, y, "Return", menu.init, nil)
	y = y + 60
	
	aiFiles = ai.findAvailableAIs()
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonReturn = button:new(x, love.graphics.getHeight() - y - STND_BUTTON_HEIGHT, "Return", menu.init, nil)
	--menuButtons.buttonContinue = button:new(love.graphics.getWidth() - x - STND_BUTTON_WIDTH - 10, love.graphics.getHeight() - y - STND_BUTTON_HEIGHT, "Continue", normalMatch, nil, nil, nil, nil, "Start the match with these settings")
	
	table.insert(menuDividers, {x = x, y = defaultMenuY, txt = LNG.menu_choose_ai})
	x = x + 20
	y = y + bgBoxSmall:getHeight()+5
	jumped = false
	for k, fileName in pairs(aiFiles) do
		local s,e = fileName:find(".*/")
		e = e or 0
		menuButtons[fileName] = button:newSmall(x, y, fileName:sub(e+1, #fileName-4), challenges.execute, {mapFileName=mapFile, aiFileName=fileName}, nil, nil, LNG.menu_choose_ai_tooltip)
		y = y + 37
		if y > love.graphics.getHeight() - 150 then
			if jumped then		-- no more space! Only one jump.
				break
			end
			x = x + SMALL_BUTTON_WIDTH + 40
			y = defaultMenuY + bgBoxSmall:getHeight()+5
			jumped = true
		end
	end
	
end


function menu.challenge()
	menu.removeAll()
	hideLogo = true
	x = defaultMenuX
	y = defaultMenuY
	
	menuButtons.buttonExit = button:new(x, y, LNG.menu_return, menu.init, nil)
	y = y + 60
	mapFiles = findChallengeMapsFiles()
	table.sort(mapFiles)
	for i = 1, #mapFiles do
		if mapFiles[i] and not mapFiles[i]:find("ExampleChallenge") then
			menuButtons[i] = button:new(x, y, mapFiles[i]:sub(1, #mapFiles[i]-4), menu.choseChallenge, mapFiles[i], nil, nil, nil, nil)
			y = y + 45
		end
	end
	
end


--------------------------------------------------------------
--		ETC:
--------------------------------------------------------------

function quitRound()
	map.endRound()
	curMap = nil
	mapImage = nil
	menu.init()
end

function menu.exitOnly()
	menu.removeAll()
	hideLogo = true
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonExit = button:new(x, y, LNG.menu_exit, confirmCloseGame, nil)
end

function confirmEndRound()
	msgBox:new(love.graphics.getWidth()/2-210, 40, LNG.confirm_leave, {name=LNG.agree,event=quitRound, args=nil},"remove")
end
function confirmReload()
	msgBox:new(love.graphics.getWidth()/2-210, 40, LNG.reload_confirm, {name=LNG.agree,event=map.restart, args=nil},"remove")
end

function menu.ingame()
	menu.removeAll()
	hideLogo = true
	x = defaultMenuX
	y = defaultMenuY
	if simulation.isRunning() then
		menuButtons.buttonExit = button:new(x, y, LNG.disconnect, confirmEndRound, nil, nil, nil, nil, LNG.menu_return_to_main_menu_tooltip)
	else
		menuButtons.buttonExit = button:new(x, y, LNG.end_match, confirmEndRound, nil, nil, nil, nil, LNG.menu_return_to_main_menu_tooltip)
	end
	x = love.graphics.getWidth() - defaultMenuX - STND_BUTTON_WIDTH-10
	y = love.graphics.getHeight() - defaultMenuY - STND_BUTTON_HEIGHT
	if not simulation.isRunning() then
		menuButtons.buttonOpenFolder = button:new(x-STND_BUTTON_WIDTH-10, y, LNG.open_folder, openAIFolder, nil, nil, nil, nil, LNG.open_folder_tooltip:gsub("AI_FOLDER_DIRECTORY", AI_DIRECTORY))
		menuButtons.buttonReload = button:new(x, y, LNG.reload, confirmReload, nil, nil, nil, nil, LNG.reload_tooltip)
	end
end

function menu.render()
	love.graphics.setColor(255,255,255,255)
	love.graphics.setFont(FONT_BUTTON)
	for k, d in pairs(menuDividers) do
		love.graphics.draw(bgBoxSmall, d.x, d.y)
		love.graphics.printf(d.txt, d.x, d.y + 5, bgBoxSmall:getWidth(), "center")
	end
	
	for k, icon in pairs(menuIcons) do
		love.graphics.draw(icon.img, icon.x, icon.y, icon.angle)--icon.img:getWidth()/2, icon.img:getHeight()/2)
	end
end

--------------------------------------------------------------
--		CREATE SPEED CONTROL:
--------------------------------------------------------------
function menu.createSpeedControl()
	if menuButtons.faster then menuButtons.faster:remove() end
	if menuButtons.pause then menuButtons.pause:remove() end
	if menuButtons.slower then menuButtons.slower:remove() end
	menuButtons.faster = button:newSquare(love.graphics.getWidth() - 30 - buttonOffSquare:getWidth(), STAT_BOX_HEIGHT + 25, "++", speedGameUp, nil, nil, nil, LNG.speed_up)
	menuButtons.pause = button:newSquare(love.graphics.getWidth() - 30 - buttonOffSquare:getWidth()*2, STAT_BOX_HEIGHT + 25, "x " .. timeFactor, pauseGame, nil, nil, nil, LNG.pause)
	menuButtons.slower = button:newSquare(love.graphics.getWidth() - 30 - buttonOffSquare:getWidth()*3, STAT_BOX_HEIGHT + 25, "--", slowGameDown, eventArgs, priority, renderSeperate, LNG.slow_down)
end

return menu
