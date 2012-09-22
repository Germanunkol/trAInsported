ai = require("Scripts/ai")
console = require("Scripts/console")
require("Scripts/ui")
require("Scripts/misc")
require("Scripts/input")
button = require("Scripts/button")
msgBox = require("Scripts/msgBox")
map = require("Scripts/map")
train = require("Scripts/train")
functionQueue = require("Scripts/functionQueue")
passenger = require("Scripts/passenger")
numTrains = 0

FONT_BUTTON = love.graphics.newFont( 18 )
FONT_STANDARD = love.graphics.newFont( 12 )

PLAYERCOLOUR1 = {r=255,g=50,b=50}
PLAYERCOLOUR2 = {r=64,g=64,b=250}
PLAYERCOLOUR3 = {r=255,g=200,b=64}
PLAYERCOLOUR4 = {r=0,g=255,b=0}


time = 0
mouseLastX = 0
mouseLastY = 0
MAX_PAN = 500
camX, camY = -500,0
camZ = 0.3

timeFactor = 1

function closeGame()
	msgBox:new(love.graphics.getWidth()/2-200,love.graphics.getHeight()/2-200,2, "Sure you want to quit?", {name="Yes",event=love.event.quit, args=nil},"remove")
end

function newMap()
--	math.randomseed(1)
	numTrains = 0
	train.clear()
	
	map.generate(25,25, love.timer.getDelta()*os.time()*math.random()*100000)
	map.print("Finished Map:")
	mapImage = map.renderImage()
	
	
	if curMap then
		MAX_PAN = (math.max(curMap.width, curMap.height)*TILE_SIZE)/2
		
		passenger.init (math.ceil(curMap.width*curMap.height/3) )		-- start generating random passengers, set the maximum number of them.
		populateMap()
		ai.init()
	end
	
end

function populateMap()
	if not curMap then return end
	
	local firstFound = false
	for i = 1, 1 do
		--firstFound = false
		for i = 1, curMap.width do
			for j = 1, curMap.height do
				if curMap[i][j] == "C" and not map.getIsTileOccupied(i, j) then
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
end

function love.load()

	ok, msg = pcall(ai.new, "AI/ai1.lua")
	if not ok then print("Err: " .. msg) end
	ok, msg = pcall(ai.new, "AI/ai2.lua")
	if not ok then print("Err: " .. msg) end
	ok, msg = pcall(ai.new, "AI/ai3.lua")
	if not ok then print("Err: " .. msg) end
	ok, msg = pcall(ai.new, "AI/ai4.lua")
	if not ok then print("Err: " .. msg) end

	train.init(PLAYERCOLOUR1, PLAYERCOLOUR2, PLAYERCOLOUR3, PLAYERCOLOUR4)
	map.init()
	newMap()
	
	
	button1 = button:new(10, 30, 90, 45, "Exit", closeGame, nil)
	button2 = button:new(10, 85, 90, 45, "New", newMap, nil)
	--button3 = button:new(10, 140, 90, 45, "", love.event.quit, nil)
	--button4 = button:new(10, 195, 90, 45, "", love.event.quit, nil)

	love.graphics.setBackgroundColor(90,60,40,255)
	print("Loading...")
	
	
	--ok, msg = pcall(ai.new, "AI/fileToRun2.lua")
	--if not ok then print("Err: " .. msg) end
	--debug.sethook()
	--box1 = createMsgBox(100, 50)
	--box2 = createMsgBox(300, 200)
	
end



function love.update(dt)
	-- ai.run()
	time = time + dt
	functionQueue.run()
	
	map.handleEvents(dt)
	
	button.calcMouseHover()
	if mapImage then
		if panningView then
			x, y = love.mouse.getPosition()
			camX = clamp(camX - (mouseLastX-x)*0.75/camZ, -MAX_PAN, MAX_PAN)
			camY = clamp(camY - (mouseLastY-y)*0.75/camZ, -MAX_PAN, MAX_PAN)
			mouseLastX = x
			mouseLastY = y
		else
			if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
				camX = clamp(camX + 150*dt/camZ, -MAX_PAN, MAX_PAN)
			end
			if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
				camX = clamp(camX - 150*dt/camZ, -MAX_PAN, MAX_PAN)
			end 
			if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
				camY = clamp(camY + 150*dt/camZ, -MAX_PAN, MAX_PAN)
			end
			if love.keyboard.isDown("down") or love.keyboard.isDown("s") then
				camY = clamp(camY - 150*dt/camZ, -MAX_PAN, MAX_PAN)
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
		end
	end
	
	train.moveAll()
end


function love.draw()
	-- love.graphics.rectangle("fill",50,50,300,300)
	dt = love.timer.getDelta()
	if mapImage then
		love.graphics.push()
		love.graphics.rotate(-0.1)
		love.graphics.scale(camZ)
		
		love.graphics.translate(camX + love.graphics.getWidth()/2/camZ, camY + love.graphics.getHeight()/2/camZ)
		love.graphics.setColor(34,10,10, 105)
		love.graphics.rectangle("fill", -TILE_SIZE*(curMap.width+2)/2-100,-TILE_SIZE*(curMap.height+2)/2-100, TILE_SIZE*(curMap.width+2)+200, TILE_SIZE*(curMap.height+2)+200)
		love.graphics.setColor(255,255,255, 255)
		love.graphics.draw(mapImage, -TILE_SIZE*(curMap.width+2)/2, -TILE_SIZE*(curMap.width+2)/2)
		love.graphics.translate(-TILE_SIZE*(curMap.width+2)/2, -TILE_SIZE*(curMap.height+2)/2)
		train.showAll()
		passenger.showAll(dt)
	
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
	love.graphics.print('x ' .. timeFactor, love.graphics.getWidth()-100,80)
	
	-- love.graphics.draw(box1, 100, 100)
	-- love.graphics.draw(box2, 200, 100)
end

function love.quit()
	print("Closing.")
end
