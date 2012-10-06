
timeFactorIndex = 5
timeFactorList = {0, 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 40, 90}

function resetTimeFactor()
	for k, v in pairs(timeFactorList) do
		if v == 1 then
			timeFactorIndex = k
		end
	end
	timeFactor = timeFactorList[timeFactorIndex]
end

function love.mousepressed(x, y, b)
	if curMap and mapImage then
		if b == "l" then
			train.checkSelection()
		end
	end
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


function coordinatesToMap(x, y)
	-- rotate:
	--x, y = matrixMultiply({aa=math.cos(CAM_ANGLE), ab=-math.sin(CAM_ANGLE), ba = math.sin(CAM_ANGLE), bb = math.cos(CAM_ANGLE)},{x=x, y= y})
	-- translate:
	x, y = x - camX, y - camY
	if curMap then x, y = x + (TILE_SIZE*(curMap.width+2) - love.graphics.getWidth())/2, y + (TILE_SIZE*(curMap.height+2) - love.graphics.getHeight())/2
	
		x = x + (x-TILE_SIZE*(curMap.width+2)/2)
		y = y + (y-TILE_SIZE*(curMap.height+2)/2)
	end
	-- scale:
--	x, y = matrixMultiply({aa=camZ, ab=0, ba = 0, bb = camZ},{x=x, y= y})
	return x, y
end

function love.keypressed(key, unicode)
	if key == "f12" then
		debug.debug()
	elseif key == "f5" then
		getScreenshot()
	elseif key == "f1" then
		quickHelp.toggle()
	elseif key == "c" then
		console.toggle()
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

