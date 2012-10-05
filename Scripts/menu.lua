local menu = {}

local buttonExit = nil
local buttonRandomMatch = nil

local defaultMenuX = 10
local defaultMenuY = 30


function confirmCloseGame()
	msgBox:new(love.graphics.getWidth()/2-210, 40, "Sure you want to quit?", {name="Yes",event=love.event.quit, args=nil},"remove")
end

function randomMatch()
	if mapRenderThread or mapGenerateThread then
		print("Already generating new map!")
		return
	end
	local width = math.random(4,20)
	local height = math.random(4,20)
	local seed = 1
	print("ls:")
	loadingScreen.reset()
	loadingScreen.addSection("New Map")
	loadingScreen.addSubSection("New Map", "Size: " .. width .. "x" .. height)
	loadingScreen.addSubSection("New Map", "Time: Day")
	print("new map:")
	--newMap(width, height, seed)
	newMap(width, height, seed)
	
	menu.exitOnly()
end

menuButtons = {}

function removeAllMenuButtons()
	for k, b in pairs(menuButtons) do
		b:remove()
	end
	menuButtons = {}
end

function menu.init(menuX, menuY)
	
	if menuX then
		defaultMenuX = menuX
		defaultMenuY = menuY
	end
	
	removeAllMenuButtons()
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonTutorial = button:new(x, y, "Tutorial", nil, nil)
	y = y + 45
	menuButtons.buttonNew = button:new(x, y, "New", nil, nil)
	y = y + 45
	menuButtons.buttonRandomMatch = button:new(x, y, "Random", randomMatch, nil)
	y = y + 60
	menuButtons.buttonSettings = button:new(x, y, "Settings", menu.settings, nil)
	y = y + 45
	menuButtons.buttonExit = button:new(x, y, "Exit", confirmCloseGame, nil)
	y = y + 45
end


function menu.settings()
	removeAllMenuButtons()
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
	removeAllMenuButtons()
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonExit = button:new(x, y, "Exit", confirmCloseGame, nil)
end

function menu.ingame()
	removeAllMenuButtons()
	x = defaultMenuX
	y = defaultMenuY
	menuButtons.buttonExit = button:new(x, y, "End Match", confirmEndRound, nil)
end

return menu
