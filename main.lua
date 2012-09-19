ai = require("Scripts/ai")
console = require("Scripts/console")
require("Scripts/ui")
button = require("Scripts/button")
msgBox = require("Scripts/msgBox")
map = require("Scripts/map")
train = require("Scripts/train")
numTrains = 0

FONT_BUTTON = love.graphics.newFont( 18 )
FONT_STANDARD = love.graphics.newFont( 12 )

PLAYERCOLOUR1 = {r=255,g=50,b=50}
PLAYERCOLOUR2 = {r=64,g=64,b=250}
PLAYERCOLOUR3 = {r=255,g=200,b=64}
PLAYERCOLOUR4 = {r=64,g=255,b=64}


time = 0
local mouseLastX = 0
local mouseLastY = 0
local MAX_PAN = 500
local camX, camY = 0,0
camZ = 0.5


function closeGame()
	msgBox:new(love.graphics.getWidth()/2-200,love.graphics.getHeight()/2-200,2, "Sure you want to quit?", {name="Yes",event=love.event.quit, args=nil},"remove")
end

function newMap()
--	math.randomseed(1)
	numTrains = 0
	train.clear()
	map.generate(35,35)
	map.print("Finished Map:")
	mapImage = map.renderImage()
	
	firstFound = false
	for i = 1, 3 do
		firstFound = false
		for i = 1, curMap.height do
			for j = 1, curMap.width do
				if curMap[i][j] == "C" then
					if math.random(3) == 1 then
					--if not firstFound then
						firstFound = true
						if curMap[i-1][j] == "C" then
							train:new( math.random(4), i, j, "W" )
						elseif curMap[i+1][j] == "C" then
							train:new( math.random(4), i, j, "E" )
						elseif curMap[i][j-1] == "C" then
							train:new( math.random(4), i, j, "N" )
						else
							train:new( math.random(4), i, j, "S" )
						end
					end
					numTrains = numTrains+1
				end
			end
		end
	end
	if curMap then
		MAX_PAN = (math.max(curMap.width, curMap.height)*TILE_SIZE)/2
	end
end

function love.load()
	train.init(PLAYERCOLOUR1, PLAYERCOLOUR2, PLAYERCOLOUR3, PLAYERCOLOUR4)
	map.init()
	newMap()
	
	button1 = button:new(10, 30, 90, 45, "Exit", closeGame, nil)
	button2 = button:new(10, 85, 90, 45, "New", newMap, nil)
	button3 = button:new(10, 140, 90, 45, "", love.event.quit, nil)
	button4 = button:new(10, 195, 90, 45, "", love.event.quit, nil)

	love.graphics.setBackgroundColor(90,60,40,255)
	print("Loading...")
	
	--ok, msg = pcall(ai.new, "AI/fileToRun.lua")
	--if not ok then print("Err: " .. msg) end
	
	--ok, msg = pcall(ai.new, "AI/fileToRun2.lua")
	--if not ok then print("Err: " .. msg) end
	--debug.sethook()
	--box1 = createMsgBox(100, 50)
	--box2 = createMsgBox(300, 200)
	
end



function love.update()
	-- ai.run()
	time = time + love.timer.getDelta()
	button.calcMouseHover()
	if panningView and mapImage then
		x, y = love.mouse.getPosition()
		camX = clamp(camX - (mouseLastX-x)*0.75/camZ, -MAX_PAN, MAX_PAN)
		camY = clamp(camY - (mouseLastY-y)*0.75/camZ, -MAX_PAN, MAX_PAN)
		mouseLastX = x
		mouseLastY = y
	end
	
	train.move()
end

function clamp(x, min, max)
	return math.max(math.min(x, max), min)
end

function love.draw()
	-- love.graphics.rectangle("fill",50,50,300,300)
	if mapImage then
		love.graphics.push()
		love.graphics.rotate(-0.25)
		love.graphics.scale(camZ)
		
		love.graphics.translate(camX + love.graphics.getWidth()/2/camZ, camY + love.graphics.getHeight()/2/camZ)
		love.graphics.setColor(34,10,10, 105)
		--love.graphics.rectangle("fill", -100,-100, TILE_SIZE*(curMap.width+2)+200, TILE_SIZE*(curMap.height+2)+200)
		love.graphics.setColor(255,255,255, 255)
		love.graphics.draw(mapImage, -TILE_SIZE*(curMap.width+2)/2, -TILE_SIZE*(curMap.width+2)/2)
		love.graphics.translate(-TILE_SIZE*(curMap.width+2)/2, -TILE_SIZE*(curMap.height+2)/2)
		train.show()
	
		love.graphics.pop()
	end
	
	console.show()
	msgBox.show()
	button.show()
	
	
	love.graphics.setFont(FONT_STANDARD)
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("FPS: " .. tostring(love.timer.getFPS( )), love.graphics.getWidth()-100, 5)
	love.graphics.print('RAM: ' .. collectgarbage('count'), love.graphics.getWidth()-100,20)
	love.graphics.print('X: ' .. camX, love.graphics.getWidth()-100,35)
	love.graphics.print('Y: ' .. camY, love.graphics.getWidth()-100,50)
	love.graphics.print('Trains: ' .. numTrains, love.graphics.getWidth()-100,65)
	
	-- love.graphics.draw(box1, 100, 100)
	-- love.graphics.draw(box2, 200, 100)
end


function love.mousepressed(x, y, b)
	if b == "wd" then
		camZ = clamp(camZ - 0.05, 0.1, 1)
		camX = clamp(camX, -MAX_PAN, MAX_PAN)
		camY = clamp(camY, -MAX_PAN, MAX_PAN)
		return
	end
	if b == "wu" then
		camZ = clamp(camZ + 0.05, 0.1, 1)
		camX = clamp(camX, -MAX_PAN, MAX_PAN)
		camY = clamp(camY, -MAX_PAN, MAX_PAN)
		return
	end
	if panningView then return end
	local hit = button.handleClick()
	if not hit then
		panningView = true
		mouseLastX, mouseLastY = love.mouse.getPosition()
	end
end

function love.mousereleased()
	panningView = false
end

function love.keypressed(key, unicode)
	if key == "d" then
		debug.debug()
	elseif key == "s" then
		getScreenshot()
	end
end


function getScreenshot()
	local curTime = os.date("*t")
	local fileName
	if curTime then
		fileName = curTime.year .."-".. curTime.month .."-".. curTime.day .. "_" .. curTime.hour .."-".. curTime.min .."-".. curTime.sec .. ".png"
	else
		fileName = math.random(99999)
	end

	--love.filesystem.setIdentity("trAInsported")
	print("")

	print( "Screenshot: " .. love.filesystem.getSaveDirectory() )
	screen = love.graphics.newScreenshot()
	screen:encode(fileName)
end

function love.quit()
	print("Closing.")
end
