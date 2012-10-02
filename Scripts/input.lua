
timeFactorIndex = 5
timeFactorList = {0, 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 40, 120}

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
	if key == "f1" then
		debug.debug()
	elseif key == "f5" then
		getScreenshot()
	elseif key == "+" then
		timeFactorIndex = math.min(timeFactorIndex + 1, #timeFactorList)
		timeFactor = timeFactorList[timeFactorIndex]
	elseif key == "-" then
		timeFactorIndex = math.max(timeFactorIndex - 1, 1)
		timeFactor = timeFactorList[timeFactorIndex]
	elseif key == "p" then
		stats.print()
	else
		print(key, unicode)
	end
end

