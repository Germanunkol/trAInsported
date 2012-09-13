ai = require("Scripts/ai")
console = require("Scripts/console")
button = require("Scripts/button")

function love.load()
	button1 = button:new(10,10,"ButtonExitOff.png", "ButtonExitOver.png", love.event.quit)
	--button1 = button1:remove()


	love.graphics.setBackgroundColor(0,0,0,50)
	print("Loading...")
	
	local fileName = "fileToRun.lua"

	--ok, msg = pcall(ai.new, fileName)
	--if not ok then print("Err: " .. msg) end
	--debug.sethook()
end

function love.update()
	button.clacMouseHover()
end

function love.draw()
	console.show()
	button.show()
	
	love.graphics.setColor(255,255,255,255)
	love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), love.graphics.getWidth()-60, 5)
end

function love.mousepressed()
	button.handleClick()
end

function love.quit()
	print("Closing.")
end
