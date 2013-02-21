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
	msgBox:new(love.graphics.getWidth()/2-210, 40, "Sure you want to quit?", {name="Yes",event=love.event.quit, args=nil},"remove")
end

local trainImagesCreated = false

local modes = love.graphics.getModes()
	
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
		statusMsg.new("Already generating new map! Wait for process to finish...", true)
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
	
	local time = width*height*10 + math.random(width*height*10)
	
	setupMatch(width, height, 1, time, gameMode, chosenAIs)
end

menuButtons = {}
menuDividers = {}
menuIcons = {}
widthButtons = {}
heightButtons = {}
timeButtons = {}
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
	menuButtons.buttonSimulation = button:new(x, y, "Live", menu.simulation, nil, nil, nil, nil, "Watch the live online matches!")
	y = y + 60
	menuButtons.buttonTutorial = button:new(x, y, "Tutorial", menu.tutorials, nil, nil, nil, nil, "Get to know the game!")
	y = y + 45
	menuButtons.buttonNew = button:new(x, y, "Compete", menu.newRound, nil, nil, nil, nil, "Set up a test match for your AI")
	y = y + 45
	menuButtons.buttonRandomMatch = button:new(x, y, "Random", randomMatch, nil, nil, nil, nil, "Start a random match on a random map using random AIs from your 'AI' folder")
	y = y + 60
	menuButtons.buttonSettings = button:new(x, y, "Settings", menu.settings, nil)
	y = y + 45
	menuButtons.buttonExit = button:new(x, y, "Exit", confirmCloseGame, nil)
	y = y + 45
	
	trainImagesCreated = false
	
	--reset tutorial:
	tutorial = {}
	tutorialBox.clearAll()
	codeBox.clearAll()
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
		statusMsg.new("Need to choose at least one AI!", true)
		return
	end
	if chosenWidth == 0 or chosenHeight == 0 then
		statusMsg.new("Invalid map dimensions!", true)
		return
	end
	if not chosenTime then
		statusMsg.new("Invalid game time!", true)
		return
	end
	if not chosenMode then
		statusMsg.new("Invalid game mode!", true)
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
	
	setupMatch( chosenWidth, chosenHeight, chosenTime, maxTime, chosenMode, AIs )
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
			col = generateColour(k, 1)
			trainImageThreads[k] = love.thread.newThread("menuTraimImageThread" .. totalNumImageThreads, "Scripts/renderTrainImage.lua")
			totalNumImageThreads = totalNumImageThreads + 1
			trainImageThreads[k]:start()
			trainImageThreads[k]:set("seed", k)
			trainImageThreads[k]:set("colour", TSerial.pack(col))
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
		status = t:get("status")
		err = t:get("error")
		if err then
			print("Error in train image thread:" .. err)
			trainImageThreads[k] = nil
		end
		if status == "done" then
			img = t:get("image")
			if img then
				menuTrainImages[k] = love.graphics.newImage(img)
			else
				print("Error rendering train image!")
			end
			trainImageThreads[k] = nil
			currentNumImageThreads = currentNumImageThreads - 1
			if menuButtons[k] then
				table.insert( menuIcons,  {img = menuTrainImages[k], angle=math.pi/3, x = menuButtons[k].x +  menuButtons[k].imageOff:getWidth()+15, y = menuButtons[k].y - 5, index = k})
			end
		elseif status then
			print("Image Thread:", status)
		end
	end
end

function menu.newRound()

	if map.rendering() or map.generating() then
		statusMsg.new("Wait for rendering to finish...", true)
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
	
	local columnWidth = math.min(bgBoxSmall:getWidth()+10, love.graphics.getWidth()/3)
	
	aiFiles = ai.findAvailableAIs()
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonReturn = button:new(x, love.graphics.getHeight() - y - STND_BUTTON_HEIGHT, "Return", menu.init, nil)
	menuButtons.buttonContinue = button:new(love.graphics.getWidth() - x - STND_BUTTON_WIDTH - 10, love.graphics.getHeight() - y - STND_BUTTON_HEIGHT, "Continue", normalMatch, nil, nil, nil, nil, "Start the match with these settings")
	
	table.insert(menuDividers, {x = x, y = defaultMenuY, txt = "Choose AIs for Match:"})
	x = x + 20
	y = y + bgBoxSmall:getHeight()+5
	jumped = false
	for k, fileName in pairs(aiFiles) do
		local s,e = fileName:find(".*/")
		e = e or 0
		menuButtons[fileName] = button:newSmall(x, y, fileName:sub(e+1, #fileName-4), selectAI, fileName, nil, nil, "Choose this AI for the match?")
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
	table.insert(menuDividers, {x=x, y = defaultMenuY, txt="Width and Height:"})
	x = x + 20
	y = y + bgBoxSmall:getHeight()+5
	stepSize = math.floor((MAP_MAXIMUM_SIZE-MAP_MINIMUM_SIZE)/10)
	for width = MAP_MINIMUM_SIZE, MAP_MAXIMUM_SIZE, stepSize  do
		widthButtons[width] = button:newSmall(x, y, tostring(width), selectWidth, width, nil, nil, "Set map width")
		heightButtons[width] = button:newSmall(x + SMALL_BUTTON_WIDTH + 40, y, tostring(width), selectHeigth, width, nil, nil, "Set map height")
		y = y + 37
	end
	
	x = defaultMenuX + (columnWidth)*2
	y = defaultMenuY
	table.insert(menuDividers, {x=x, y = defaultMenuY, txt="Time and Mode:"})
	x = x + 20
	y = defaultMenuY + bgBoxSmall:getHeight()+5
	for k, timeOption in pairs(POSSIBLE_TIMES) do
		timeButtons[timeOption] = button:newSmall(x, y, timeOption, selectTime, timeOption, nil, nil, POSSIBLE_TIMES_TOOLTIPS[k])
		y = y + 37
	end
	y = defaultMenuY + bgBoxSmall:getHeight()+5
	for k, modeOption in pairs(POSSIBLE_MODES) do
		modeButtons[modeOption] = button:newSmall(x + SMALL_BUTTON_WIDTH + 40, y, modeOption, selectMode, modeOption, nil, nil, POSSIBLE_MODES_TOOLTIPS[k])
		y = y + 37
	end
end



--------------------------------------------------------------
--		SIMULATION START:
--------------------------------------------------------------

function menu.startSimulation(IP)
	if connectionThread then
		statusMsg.new("Already attempting to start connection.", true)
	else
		if not map.generating() and not map.rendering() then
			--load connection to main server:
			loadingScreen.reset()
			
			attemptingToConnect = true
			loadingScreen.addSection("Connecting")
			loadingScreen.addSubSection("Connecting", "Server: " .. IP)
			connection.startClient(IP, PORT)
		else
			loadingScreen.addSubSection("Connecting", "Failed!")
			print("Error: already rendering a map - can't start simulation")
			statusMsg.new("Wait for rendering to finish... then retry.", true)
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
			loadingScreen.addSection("Connecting")
			loadingScreen.addSubSection("Connecting", "Server: " .. (CL_SERVER_IP or FALLBACK_SERVER_IP))
			connection.startClient(CL_SERVER_IP or FALLBACK_SERVER_IP, PORT)
		else
			loadingScreen.addSubSection("Connecting", "Failed!")
			print("Error: already rendering a map - can't start simulation")
			statusMsg.new("Wait for rendering to finish... then retry.", true)
		end
	else
		menuButtons.buttonSimulationReturn = button:new(x, y, "Return", menu.init, nil, nil, nil, nil, "Go back to main menu")
		y = y + 60
		menuButtons.buttonSimulationMain = button:new(x, y, "Main Server", menu.startSimulation, MAIN_SERVER_IP, nil, nil, nil, "Connect to the main server. Must be connected to the internet!")
		y = y + 45
		menuButtons.buttonSimulationLocal = button:new(x, y, "Localhost",  menu.startSimulation, FALLBACK_SERVER_IP, nil, nil, nil, "Connect to a server running on this machine.")
	end
end

--------------------------------------------------------------
--		SETTINGS MENU:
--------------------------------------------------------------


function selectResolution(res)

	-- attempt to change screen resolution:
	success = love.graphics.setMode( res.width, res.height, false, true )
	
	if not success then
		print("failed to set resolution!")
	else
	
		
		local content = love.filesystem.read(CONFIG_FILE)
		
		if content then
			local s,e = content:find("resolution_x ?= ?.-\n")
			if s then
				content = content:sub(1,s-1) .. content:sub(e+1, #content)
			end
		 	s,e = content:find("resolution_y ?= ?.-\n")
			if s then
				content = content:sub(1,s-1) .. content:sub(e+1, #content)
			end
		else
			content = ""
		end
		
		content = content .. "resolution_x = " .. res.width .. "\n"
		content = content .. "resolution_y = " .. res.height .. "\n"
		
		love.filesystem.write(CONFIG_FILE, content)
		
		menu.settings() -- re-initialise the menu.
	end
end

function menu.settings()
	menu.removeAll()
	hideLogo = true
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonExit = button:new(x, y, "Return", menu.init, nil)
	y = y + 45
	
	x = x + 200
	y = defaultMenuY
	table.insert(menuDividers, {x = x, y = defaultMenuY, txt = "Screen size:"})
	x = x + 20
	y = y + bgBoxSmall:getHeight()+5
	jumped = false
	
	for k = 1, #modes do
		res = modes[k]
		menuButtons[k] = button:newSmall(x, y, res.width .. "x" .. res.height, selectResolution, res, nil, nil, "Change resolution")
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


--------------------------------------------------------------
--		TUTORIAL MENU:
--------------------------------------------------------------

local function alphabetical(a, b)
	print(a,b)
	if a < b then return true end
end

function findTutorialFiles()
	local files = love.filesystem.enumerate("Tutorials")		-- load AI subdirector
	local foundFiles = {}
	for k, file in ipairs(files) do
		s, e = file:find(".lua")
		if e == #file then
			print("Tutorial found: " .. k .. ". " .. file)
			table.insert(foundFiles, file)
		end
	end
	
--	table.sort(files, alphabetical)
	return foundFiles
end


function menu.executeTutorial(fileName)
	if not map.generating() and not map.rendering() then
		tutorialData = love.filesystem.load("Tutorials/" .. fileName)
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
	
	menuButtons.buttonExit = button:new(x, y, "Return", menu.init, nil)
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
	menuButtons.buttonExit = button:new(x, y, "Exit", confirmCloseGame, nil)
end

function confirmEndRound()
	msgBox:new(love.graphics.getWidth()/2-210, 40, "Leave the current match and return to menu?", {name="Yes",event=quitRound, args=nil},"remove")
end
function confirmReload()
	msgBox:new(love.graphics.getWidth()/2-210, 40, "Reload the AIs?", {name="Yes",event=map.restart, args=nil},"remove")
end

function menu.ingame()
	menu.removeAll()
	hideLogo = true
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonExit = button:new(x, y, "End Match", confirmEndRound, nil, nil, nil, nil, "Return to main menu.")
	x = love.graphics.getWidth() - defaultMenuX - STND_BUTTON_WIDTH-10
	y = love.graphics.getHeight() - defaultMenuY - STND_BUTTON_HEIGHT
	if not simulation.isRunning() then
		menuButtons.buttonReload = button:new(x, y, "Reload", confirmReload, nil, nil, nil, nil, "Reload the AI scripts and restart the round.")
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

return menu
