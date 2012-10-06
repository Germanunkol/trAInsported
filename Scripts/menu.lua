local menu = {}

local buttonExit = nil
local buttonRandomMatch = nil

local defaultMenuX = 10
local defaultMenuY = 30


local numAIsChosen = 0
local mapSizeX = 0
local mapSizeY = 0

function confirmCloseGame()
	msgBox:new(love.graphics.getWidth()/2-210, 40, "Sure you want to quit?", {name="Yes",event=love.event.quit, args=nil},"remove")
end

function randomMatch()
	if mapRenderThread or mapGenerateThread then
		print("Already generating new map!")
		return
	end
	local width = math.random(5,5)
	local height = math.random(5,5)
	local seed = 1
	
	aiFiles = ai.findAvailableAIs()
	
	num = 0
	for k, aiName in pairs(aiFiles) do
		if num < 4 then
			print("AI/" .. aiName)
			ok, msg = pcall(ai.new, "AI/" .. aiName)
			if not ok then print("Err: " .. msg) end
			num = num + 1
		end
	end

	PLAYERCOLOUR1 = ai.getColour(1)
	PLAYERCOLOUR2 = ai.getColour(2)
	PLAYERCOLOUR3 = ai.getColour(3)
	PLAYERCOLOUR4 = ai.getColour(4)

	train.init(PLAYERCOLOUR1, PLAYERCOLOUR2, PLAYERCOLOUR3, PLAYERCOLOUR4)
	
	stats.start(num)
	stats.setAIName(1, "Ai1")
	stats.setAIName(2, "Ai2")
	stats.setAIName(3, "Ai3")
	stats.setAIName(4, "Ai4")
	
	loadingScreen.reset()
	loadingScreen.addSection("New Map")
	loadingScreen.addSubSection("New Map", "Size: " .. width .. "x" .. height)
	loadingScreen.addSubSection("New Map", "Time: Day")
	print("new map:")
	--newMap(width, height, seed)
	newMap(width, height, seed)
	
	GAME_TYPE = GAME_TYPE_TIME
	ROUND_TIME = 120 + math.random(360)
	
	aisOnMap = 4
	
	menu.exitOnly()
end

menuButtons = {}
menuDividers = {}
menuIcons = {}
widthButtons = {}
heightButtons = {}

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
	menuButtons = {}
	menuDividers = {}
	menuIcons = {}
	widthButtons = {}
	heightButtons = {}
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
	menuButtons.buttonTutorial = button:new(x, y, "Tutorial", nil, nil)
	y = y + 45
	menuButtons.buttonNew = button:new(x, y, "New", menu.newRound, nil)
	y = y + 45
	menuButtons.buttonRandomMatch = button:new(x, y, "Random", randomMatch, nil)
	y = y + 60
	menuButtons.buttonSettings = button:new(x, y, "Settings", menu.settings, nil)
	y = y + 45
	menuButtons.buttonExit = button:new(x, y, "Exit", confirmCloseGame, nil)
	y = y + 45
	
end



--------------------------------------------------------------
--		SETUP NEW MATCH:
--------------------------------------------------------------

checkMarkImg = love.graphics.newImage("Images/CheckMark.png")

chosenAIs = {}
chosenHeight, chosenWidth = 0, 0
aiFiles = {}

function selectAI(k)
	if numAIsChosen < 4 then
		numAIsChosen = numAIsChosen + 1
		menuButtons[k].event = deselectAI
		menuButtons[k].x = menuButtons[k].x + 20
		chosenAIs[k] = aiFiles[k]
		table.insert( menuIcons,  {img = checkMarkImg, x = menuButtons[k].x +  menuButtons[k].imageOff:getWidth()-19, y = menuButtons[k].y - 2, index = k})
	end
end

function deselectAI(k)
	numAIsChosen = numAIsChosen - 1
	menuButtons[k].x = menuButtons[k].x - 20
	menuButtons[k].event = selectAI
	chosenAIs[k] = nil
	for i, icon in pairs(menuIcons) do
		print(icon.index, k)
		if icon.index == k then
			menuIcons[i] = nil
		end
	end
end

function startMatch()
	if numAIsChosen <= 0 then
		print("Need to choose at least one AI!")
		return
	end
	if chosenWidth == 0 or chosenWidth == 0 then
		print("Invalid map dimensions!")
		return
	end
	if mapRenderThread or mapGenerateThread then
		print("Already generating new map!")
		return
	end
	local width = chosenWidth
	local height = chosenHeight
	local seed = 1
	
	for k, aiName in pairs(chosenAIs) do
		ok, msg = pcall(ai.new, "AI/" .. aiName)
		if not ok then print("Err: " .. msg) end
	end

	PLAYERCOLOUR1 = ai.getColour(1)
	PLAYERCOLOUR2 = ai.getColour(2)
	PLAYERCOLOUR3 = ai.getColour(3)
	PLAYERCOLOUR4 = ai.getColour(4)

	train.init(PLAYERCOLOUR1, PLAYERCOLOUR2, PLAYERCOLOUR3, PLAYERCOLOUR4)
	
	stats.start(numAIsChosen)
	stats.setAIName(1, "Ai1")
	stats.setAIName(2, "Ai2")
	stats.setAIName(3, "Ai3")
	stats.setAIName(4, "Ai4")
	
	loadingScreen.reset()
	loadingScreen.addSection("New Map")
	loadingScreen.addSubSection("New Map", "Size: " .. width .. "x" .. height)
	loadingScreen.addSubSection("New Map", "Time: Day")	
	
	print("new map:")
	--newMap(width, height, seed)
	newMap(width, height, seed)
	
	
	GAME_TYPE = GAME_TYPE_TIME
	ROUND_TIME = 120 + math.random(360)
	
	menu.exitOnly()
end

function selectWidth(x)
	for k, button in pairs(widthButtons) do
		button.event = selectWidth
		button.x = widthButtons[x].x
	end
	widthButtons[x].event = nil
	widthButtons[x].x = widthButtons[x].x + 20
	chosenWidth = x
end

function selectHeigth(y)
	for k, button in pairs(heightButtons) do
		button.event = selectHeigth
		button.x = heightButtons[y].x
	end
	heightButtons[y].event = nil
	heightButtons[y].x = heightButtons[y].x + 20
	chosenHeight = y
end

function menu.newRound()
	menu.removeAll()
	numAIsChosen = 0
	chosenAIs = {}
	chosenWidth = 0
	chosenHeight = 0
	
	aiFiles = ai.findAvailableAIs()
	
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonReturn = button:new(x, love.graphics.getHeight() - y - STND_BUTTON_HEIGHT, "Return", menu.init, nil)
	menuButtons.buttonContinue = button:new(love.graphics.getWidth() - x - STND_BUTTON_WIDTH - 10, love.graphics.getHeight() - y - STND_BUTTON_HEIGHT, "Continue", startMatch, nil)
	
	table.insert(menuDividers, {x=x, y = defaultMenuY, txt="Choose AIs for Match:"})
	x = x + 20
	y = y + bgBoxSmall:getHeight()+5
	for k, file in pairs(aiFiles) do
		menuButtons[k] = button:newSmall(x, y, file:sub(1, #file-4), selectAI, k)
		y = y + 37
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

function quitRound()
	map.endRound()
	curMap = nil
	mapImage = nil
	menu.init()
end

function confirmEndRound()
	msgBox:new(love.graphics.getWidth()/2-210, 40, "Leave the current match and return to menu?", {name="Yes",event=quitRound, args=nil},"remove")
end

function menu.exitOnly()
	menu.removeAll()
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonExit = button:new(x, y, "Exit", confirmCloseGame, nil)
end

function menu.ingame()
	menu.removeAll()
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonExit = button:new(x, y, "End Match", confirmEndRound, nil)
end

function menu.render()
	love.graphics.setColor(255,255,255,255)
	love.graphics.setFont(FONT_BUTTON)
	for k, d in pairs(menuDividers) do
		love.graphics.draw(bgBoxSmall, d.x, d.y)
		love.graphics.printf(d.txt, d.x, d.y + 5, bgBoxSmall:getWidth(), "center")
	end
	
	for k, icon in pairs(menuIcons) do
		love.graphics.draw(icon.img, icon.x, icon.y)
	end
end

return menu
