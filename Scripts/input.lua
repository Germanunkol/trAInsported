

function love.mousepressed(x, y, b)
	--if curMap and mapImage then
		--if b == "l" then
		--	train.checkSelection()
		--end
	--end
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
	
	-- if already moving something, continue doing so:
	
	
	if panningView then return end
	
	-- else, check if something new SHOULD be moved:
	
	local hit = button.handleClick()
	if not hit then
		hit = msgBox.handleClick()
	end
	if not hit then
		hit = codeBox.handleClick()
	end
	if not hit then
		hit = tutorialBox.handleClick()
	end
	if not hit then
		if simulation.isRunning() then
			hit = simulation.handleClick()
		else		
			hit = map.handleClick()
		end
	end
	if not hit then
		panningView = true
		mouseLastX, mouseLastY = love.mouse.getPosition()
	end
end

function love.mousereleased()
	panningView = false
	msgBox.moving = nil
	codeBox.moving = nil
	tutorialBox.moving = nil
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

function speedGameUp()
	if not simulation.isRunning() then
		timeFactorIndex = math.min(timeFactorIndex + 1, #timeFactorList)
	end
	timeFactor = timeFactorList[timeFactorIndex]
	timeFactorIndexRemember = false
	if menuButtons.pause then
		menuButtons.pause.l = "x " .. timeFactor
	end
end

function slowGameDown()
	if not simulation.isRunning() then
		timeFactorIndex = math.max(timeFactorIndex - 1, 1)
	end
	timeFactor = timeFactorList[timeFactorIndex]
	timeFactorIndexRemember = false
	if menuButtons.pause then
		menuButtons.pause.l = "x " .. timeFactor
	end
end

function pauseGame()
	if timeFactorIndex == 1 then	-- unpause
		if timeFactorIndexRemember then
			timeFactorIndex = timeFactorIndexRemember
		end
		timeFactorIndexRemember = false
	else
		if not simulation.isRunning() then
			timeFactorIndexRemember = timeFactorIndex
			timeFactorIndex = 1
		end
	end
	timeFactor = timeFactorList[timeFactorIndex]
	if menuButtons.pause then
		menuButtons.pause.l = "x " .. timeFactor
	end
end


function love.keypressed(key, unicode)
	--if key == "f12" then
		--debug.debug()
	--else
	if key == "f5" then
		getScreenshot()
	elseif key == "f1" then
		quickHelp.toggle()
	elseif key == "c" then -- unicode == 99 then--key == "c" then
		console.toggle()
	elseif key == "+" then -- unicode == 43 then -- key == "+" then
		speedGameUp()
	elseif key == "-" then -- unicode == 45 then --key == "-" then
		slowGameDown()
	elseif key == "p" then
		stats.print()
	elseif key == "m" then
		map.toggleShowCoordinates()
	elseif key == " " then
		displayDebugInformation = not displayDebugInformation
--	else
	elseif key == "h" then
		hideAIStatistics = not hideAIStatistics
	end
		--print(key, unicode)
end

