local menu = {}

local buttonExit = nil
local buttonRandomMatch = nil

local defaultMenuX = 10
local defaultMenuY = 30

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

function startMatch( width, height, time, maxTime, gameMode, AIs )
	--[[if mapRenderThread or mapGenerateThread then
		print("Already generating new map!")
		return
	end]]--
	
	ROUND_TIME = math.floor(maxTime)
	GAME_TYPE = gameMode

	loadingScreen.reset()
	loadingScreen.addSection("New Map")
	loadingScreen.addSubSection("New Map", "Size: " .. width .. "x" .. height)
	loadingScreen.addSubSection("New Map", "Time: Day")
	if GAME_TYPE == GAME_TYPE_TIME then
		loadingScreen.addSubSection("New Map", "Mode: Round Time (" .. ROUND_TIME .. "s)")
	elseif GAME_TYPE == GAME_TYPE_MAX_PASSENGERS then
		loadingScreen.addSubSection("New Map", "Mode: Transport enough Passengers")
	end
	
	ai.restart()	-- make sure aiList is reset!
	stats.start( #AIs )
	train.init()
	train.resetImages()
	
	print("found AI:", #AIs)
	for i = 1, #AIs do
		ok, msg = pcall(ai.new, "AI/" .. AIs[i])
		if not ok then
			print("Err: " .. msg)
		else
			stats.setAIName(i, AIs[i]:sub(1, #AIs[i]-4))
			train.renderTrainImage(AIs[i]:sub(1, #AIs[i]-4), i)
		end
	end
	
	map.new(width, height, math.random(1000))
	
	menu.exitOnly()
end




function randomMatch()
	
	simulation.stop()
	local width = math.random(4,25)
	local height = math.random(4,25)
	
	aiFiles = ai.findAvailableAIs()
	
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
	
	startMatch(width, height, 1, time, gameMode, chosenAIs)
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
end


--------------------------------------------------------------
--		MAIN MENU:
--------------------------------------------------------------


function menu.init(menuX, menuY)
	if menuX then
		defaultMenuX = menuX
		defaultMenuY = menuY
	end
	
	menu.removeAll()
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonTutorial = button:new(x, y, "Tutorial", menu.tutorials, nil)
	y = y + 45
	menuButtons.buttonNew = button:new(x, y, "New", menu.newRound, nil)
	y = y + 45
	menuButtons.buttonRandomMatch = button:new(x, y, "Random", randomMatch, nil)
	y = y + 60
	menuButtons.buttonSettings = button:new(x, y, "Settings", menu.settings, nil)
	y = y + 45
	menuButtons.buttonExit = button:new(x, y, "Exit", confirmCloseGame, nil)
	y = y + 45
	
	trainImagesCreated = false
	
	--load connection to main server:
	connection.startClient(MAIN_SERVER_IP, PORT)
	
	--reset tutorial:
	tutorial = {}
	tutorialBox.clearAll()
end



--------------------------------------------------------------
--		SETUP NEW MATCH:
--------------------------------------------------------------

checkMarkImg = love.graphics.newImage("Images/CheckMark.png")

local chosenAIs = {}
local chosenHeight, chosenWidth = 0, 0
local aiFiles = {}


function normalMatch()
	if numAIsChosen <= 0 then
		print("Need to choose at least one AI!")
		return
	end
	if chosenWidth == 0 or chosenHeight == 0 then
		print("Invalid map dimensions!")
		return
	end
	if not chosenTime then
		print("Invalid game time!")
		return
	end
	if not chosenMode then
		print("Invalid game mode!")
		return
	end
	--[[if mapRenderThread or mapGenerateThread then
		print("Already generating new map!")
		return
	end]]--
	for k, aiName in pairs(chosenAIs) do
		if not menuTrainImages[k] then
			print("Still rendering train images...")
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
	
	startMatch( chosenWidth, chosenHeight, chosenTime, maxTime, chosenMode, AIs )
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
	simulation.stop()

	menu.removeAll()
	numAIsChosen = 0
	chosenAIs = {}
	chosenWidth = 0
	chosenHeight = 0
	chosenTime = nil
	chosenMode = nil
	
	aiFiles = ai.findAvailableAIs()
	
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonReturn = button:new(x, love.graphics.getHeight() - y - STND_BUTTON_HEIGHT, "Return", menu.init, nil)
	menuButtons.buttonContinue = button:new(love.graphics.getWidth() - x - STND_BUTTON_WIDTH - 10, love.graphics.getHeight() - y - STND_BUTTON_HEIGHT, "Continue", normalMatch, nil)
	
	table.insert(menuDividers, {x=x, y = defaultMenuY, txt="Choose AIs for Match:"})
	x = x + 20
	y = y + bgBoxSmall:getHeight()+5
	jumped = false
	for k, file in pairs(aiFiles) do
		menuButtons[file] = button:newSmall(x, y, file:sub(1, #file-4), selectAI, file)
		y = y + 37
		if y > love.graphics.getWidth() - 150 then
			if jumped then		-- no more space! Only one jump.
				break
			end
			x = x + SMALL_BUTTON_WIDTH + 40
			y = defaultMenuY + bgBoxSmall:getHeight()+5
			jumped = true
		end
	end
	
	x = defaultMenuX + bgBoxSmall:getWidth()+10
	y = defaultMenuY
	table.insert(menuDividers, {x=x, y = defaultMenuY, txt="Width and Height:"})
	x = x + 20
	y = y + bgBoxSmall:getHeight()+5
	for width = 4, 26,2 do
		widthButtons[width] = button:newSmall(x, y, tostring(width), selectWidth, width)
		heightButtons[width] = button:newSmall(x + SMALL_BUTTON_WIDTH + 40, y, tostring(width), selectHeigth, width)
		y = y + 37
	end
	
	x = defaultMenuX + (bgBoxSmall:getWidth()+10)*2
	y = defaultMenuY
	table.insert(menuDividers, {x=x, y = defaultMenuY, txt="Time and Mode:"})
	x = x + 20
	y = defaultMenuY + bgBoxSmall:getHeight()+5
	for k, timeOption in pairs(POSSIBLE_TIMES) do
		timeButtons[timeOption] = button:newSmall(x, y, timeOption, selectTime, timeOption)
		y = y + 37
	end
	y = defaultMenuY + bgBoxSmall:getHeight()+5
	for k, modeOption in pairs(POSSIBLE_MODES) do
		modeButtons[modeOption] = button:newSmall(x + SMALL_BUTTON_WIDTH + 40, y, modeOption, selectMode, modeOption)
		y = y + 37
	end
	
end


--------------------------------------------------------------
--		SETTINGS MENU:
--------------------------------------------------------------

function menu.settings()
	menu.removeAll()
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonExit = button:new(x, y, "Return", menu.init, nil)
	y = y + 45
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
	tutorialData = love.filesystem.load("Tutorials/" .. fileName)
	local result = tutorialData() -- execute the chunk
	tutorial.start()
end

function menu.tutorials()
	menu.removeAll()
	x = defaultMenuX
	y = defaultMenuY
	
	menuButtons.buttonExit = button:new(x, y, "Return", menu.init, nil)
	y = y + 60
	tutFiles = findTutorialFiles()
	for i = 1, #tutFiles do
		if tutFiles[i] then
		menuButtons[i] = button:new(x, y, tutFiles[i]:sub(1, #tutFiles[i]-4), menu.executeTutorial, tutFiles[i])
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
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonExit = button:new(x, y, "End Match", confirmEndRound, nil)
	x = love.graphics.getWidth() - defaultMenuX - STND_BUTTON_WIDTH-10
	y = love.graphics.getHeight() - defaultMenuY - STND_BUTTON_HEIGHT
	menuButtons.buttonReload = button:new(x, y, "Reload", confirmReload, nil)
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
