local button = {}

STANDARD = 1
SMALL = 2

local button_mt = { __index = button }

local buttonList = {}

local buttonLevel = 1

local buttonOver = nil
local buttonOff = nil

buttonClickSound = love.audio.newSource("Sound/blip_click.wav", "static")

function button.getPriority()
	return buttonLevel
end

function button.setButtonLevel()
	local highest = 1
	for i=1,#buttonList,1 do
		if buttonList[i] then
			if buttonList[i].priority > highest then
				highest = buttonList[i].priority
			end
			buttonList[i].mouseHover = false
		end
	end
	buttonLevel = highest
end

local buttnOff, buttnOver

function button:new(x, y, label, event, eventArgs, priority, size, renderSeperate, toolTip)
	priority = priority or 1
	size = size or STANDARD
	for i=1,#buttonList+1,1 do
		if not buttonList[i] then
			-- local imageOff = createButtonOff(width, height, label)
			-- local imageOver = createButtonOver(width, height, label)
			if size == STANDARD then
				buttonList[i] = setmetatable({size = STANDARD, x=x, y=y, imageOff=buttonOff, imageOver=buttonOver, event=event, index = i, w=buttonOff:getWidth(), h=buttonOff:getHeight(), l=label, eventArgs=eventArgs, priority=priority, renderSeperate = renderSeperate}, button_mt)
			elseif size == SMALL then
				buttonList[i] = setmetatable({size = SMALL, x=x, y=y, imageOff=buttonOffSmall, imageOver=buttonOverSmall, event=event, index = i, w=buttonOverSmall:getWidth(), h=buttonOverSmall:getHeight(), l=label, eventArgs=eventArgs, priority=priority, renderSeperate = renderSeperate}, button_mt)
			end
			buttonList[i].toolTip = toolTip
			button.setButtonLevel()
			return buttonList[i]
		end
	end
end

function button:newSmall(x, y, label, event, eventArgs, priority, renderSeperate, toolTip)
	return button:new(x, y, label, event, eventArgs, priority, SMALL, renderSeperate, toolTip)
end

function button:remove()
	buttonList[self.index] = nil
	button.setButtonLevel()
	return nil
end

function button:setInvisible(bool)
	self.invisible = bool
end

function rectangularCollision(xPos, yPos, width, height, xPos2, yPos2)
	return (xPos < xPos2 and xPos+width > xPos2 and yPos < yPos2 and yPos+height > yPos2)
end

function button.calcMouseHover()
	mX, mY = love.mouse.getPosition()
	toolTip = nil
	for k, b in pairs(buttonList) do
		if b.priority == buttonLevel then
			b.mouseHover = rectangularCollision(b.x, b.y, b.w, b.h, mX, mY)
			if b.mouseHover then
				toolTip = b.toolTip
			end
		end
	end
end


function button.handleClick()
	local hit = false
	for k, b in pairs(buttonList) do
		if b.mouseHover and b.event and not b.invisible then
			b.event(b.eventArgs)
			buttonClickSound:rewind()
			buttonClickSound:play()
			hit = true
		end
	end
	return hit
end

function button.renderSingle(b)
	if b.size == SMALL then
		f = FONT_BUTTON_SMALL
	else
		f = FONT_BUTTON
	end
	love.graphics.setFont(f)
	if b.selected then
		red,green,blue = 50,255,50
	else
		red,green,blue = 255,255,255
	end
	
	if b.mouseHover then
		love.graphics.setColor(red,green,blue,255)
		love.graphics.draw(b.imageOver, b.x, b.y)
		love.graphics.setColor(255,255,255,255)
		love.graphics.printf(b.l, b.x, b.y + 8, b.imageOver:getWidth(), "center")
	else
		if b.priority == buttonLevel then
			love.graphics.setColor(red,green,blue,255)
			love.graphics.draw(b.imageOff, b.x, b.y)
			love.graphics.setColor(255,255,255,255)
			love.graphics.printf(b.l, b.x, b.y + 10, b.imageOver:getWidth(), "center")
		else
			love.graphics.setColor(200,150,180,255)
			love.graphics.draw(b.imageOff, b.x, b.y)
			love.graphics.setColor(255,255,255,100)
			love.graphics.printf(b.l, b.x, b.y + 10, b.imageOver:getWidth(), "center")
		end
	end
end

function button.show()
	w = buttonOver:getWidth()
	for k, b in pairs(buttonList) do
		if not b.invisible and not b.renderSeperate then
			button.renderSingle(b)
		end
	end
end

local buttonOffThread = nil
local buttonOverThread = nil
local status = false

function button.init(maxNumThreads)
	local initialMaxNumThreads = maxNumThreads

	if not buttonOffThread and not buttonOff then		-- only start thread once!
		if not CL_FORCE_RENDER then
			ok, buttonOff = pcall(love.graphics.newImage, "buttonOff.png")
		end
		if (not ok or not versionCheck.getMatch() or CL_FORCE_RENDER) and maxNumThreads > 0 then
		
			maxNumThreads = maxNumThreads - 1
		
			buttonOff = nil
			loadingScreen.addSection("Rendering Deactivated Button")
			buttonOffThread = love.thread.newThread("buttonOffThread", "Scripts/renderImageBox.lua")
			buttonOffThread:start()
	
			buttonOffThread:set("width", STND_BUTTON_WIDTH )
			buttonOffThread:set("height", STND_BUTTON_HEIGHT )
			buttonOffThread:set("shadow", true )
			buttonOffThread:set("shadowOffsetX", 5 )
			buttonOffThread:set("shadowOffsetY", 2 )
			buttonOffThread:set("colR", BUTTON_OFF_R )
			buttonOffThread:set("colG", BUTTON_OFF_G )
			buttonOffThread:set("colB", BUTTON_OFF_B )
		end
	else
		if not buttonOff then	-- if there's no button yet, that means the thread is still running...
		
			percent = buttonOffThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Deactivated Button", percent)
			end
			err = buttonOffThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
			status = buttonOffThread:get("status")
			if status == "done" then
				buttonOff = buttonOffThread:get("imageData")		-- get the generated image data from the thread
				buttonOff:encode("buttonOff.png")
				buttonOff = love.graphics.newImage(buttonOff)
				buttonOffThread:wait()
				buttonOffThread = nil
				
				maxNumThreads = maxNumThreads + 1
			end
		end
	end
	
	if not buttonOverThread and not buttonOver then		-- only start thread once!
		if not CL_FORCE_RENDER then
			ok, buttonOver = pcall(love.graphics.newImage, "buttonOver.png")
		end
		if (not ok or not versionCheck.getMatch() or CL_FORCE_RENDER) and maxNumThreads > 0 then		
			maxNumThreads = maxNumThreads - 1
		
			buttonOver = nil
			loadingScreen.addSection("Rendering Activated Button")
			buttonOverThread = love.thread.newThread("buttonOverThread", "Scripts/renderImageBox.lua")
			buttonOverThread:start()
	
			buttonOverThread:set("width", STND_BUTTON_WIDTH )
			buttonOverThread:set("height", STND_BUTTON_HEIGHT )
			buttonOverThread:set("shadow", true )
			buttonOverThread:set("shadowOffsetX", 6 )
			buttonOverThread:set("shadowOffsetY", 1 )
			buttonOverThread:set("brightness", 100 )
			buttonOverThread:set("colR", BUTTON_OVER_R )
			buttonOverThread:set("colG", BUTTON_OVER_G )
			buttonOverThread:set("colB", BUTTON_OVER_B )
		end
	else
		if not buttonOver then	-- if there's no button yet, that means the thread is still running...
		
			percent = buttonOverThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Activated Button", percent)
			end
			
			err = buttonOverThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
		
			status = buttonOverThread:get("status")
			if status == "done" then
				buttonOver = buttonOverThread:get("imageData")		-- get the generated image data from the thread
				buttonOver:encode("buttonOver.png")
				buttonOver = love.graphics.newImage(buttonOver)
				buttonOverThread:wait()
				buttonOverThread = nil
				
				maxNumThreads = maxNumThreads + 1
			end
		end
	end
	
	if not buttonOffSmallThread and not buttonOffSmall then		-- only start thread once!
		if not CL_FORCE_RENDER then
			ok, buttonOffSmall = pcall(love.graphics.newImage, "buttonOffSmall.png")
		end
		if (not ok or not versionCheck.getMatch() or CL_FORCE_RENDER) and maxNumThreads > 0 then
		
			maxNumThreads = maxNumThreads - 1
		
			buttonOffSmall = nil
			loadingScreen.addSection("Rendering Deactivated Button (small)")
			buttonOffSmallThread = love.thread.newThread("buttonOffSmallThread", "Scripts/renderImageBox.lua")
			buttonOffSmallThread:start()
	
			buttonOffSmallThread:set("width", SMALL_BUTTON_WIDTH )
			buttonOffSmallThread:set("height", SMALL_BUTTON_HEIGHT )
			buttonOffSmallThread:set("shadow", true )
			buttonOffSmallThread:set("shadowOffsetX", 5 )
			buttonOffSmallThread:set("shadowOffsetY", 2 )
			buttonOffSmallThread:set("colR", BUTTON_OFF_R )
			buttonOffSmallThread:set("colG", BUTTON_OFF_G )
			buttonOffSmallThread:set("colB", BUTTON_OFF_B )
		end
	else
		if not buttonOffSmall then	-- if there's no button yet, that means the thread is still running...
		
			percent = buttonOffSmallThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Deactivated Button (small)", percent)
			end
			err = buttonOffSmallThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
			status = buttonOffSmallThread:get("status")
			if status == "done" then
				buttonOffSmall = buttonOffSmallThread:get("imageData")		-- get the generated image data from the thread
				buttonOffSmall:encode("buttonOffSmall.png")
				buttonOffSmall = love.graphics.newImage(buttonOffSmall)
				buttonOffSmallThread:wait()
				buttonOffSmallThread = nil
				
				maxNumThreads = maxNumThreads + 1
			end
		end
	end
	
	if not buttonOverSmallThread and not buttonOverSmall then		-- only start thread once!
	
		if not CL_FORCE_RENDER then
			ok, buttonOverSmall = pcall(love.graphics.newImage, "buttonOverSmall.png")
		end
		if (not ok or not versionCheck.getMatch() or CL_FORCE_RENDER) and maxNumThreads > 0 then
		
			maxNumThreads = maxNumThreads - 1
		
			buttonOverSmall = nil
			loadingScreen.addSection("Rendering Activated Button (small)")
			buttonOverSmallThread = love.thread.newThread("buttonOverSmallThread", "Scripts/renderImageBox.lua")
			buttonOverSmallThread:start()
	
			buttonOverSmallThread:set("width", SMALL_BUTTON_WIDTH )
			buttonOverSmallThread:set("height", SMALL_BUTTON_HEIGHT )
			buttonOverSmallThread:set("shadow", true )
			buttonOverSmallThread:set("shadowOffsetX", 6 )
			buttonOverSmallThread:set("shadowOffsetY", 1 )
			buttonOverSmallThread:set("brightness", 100 )
			buttonOverSmallThread:set("colR", BUTTON_OVER_R )
			buttonOverSmallThread:set("colG", BUTTON_OVER_G )
			buttonOverSmallThread:set("colB", BUTTON_OVER_B )
		end
	else
		if not buttonOverSmall then	-- if there's no button yet, that means the thread is still running...
		
			percent = buttonOverSmallThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Activated Button (small)", percent)
			end
			
			err = buttonOverSmallThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
		
			status = buttonOverSmallThread:get("status")
			if status == "done" then
				buttonOverSmall = buttonOverSmallThread:get("imageData")		-- get the generated image data from the thread
				buttonOverSmall:encode("buttonOverSmall.png")
				buttonOverSmall = love.graphics.newImage(buttonOverSmall)
				buttonOverSmallThread:wait()
				buttonOverSmallThread = nil
				
				maxNumThreads = maxNumThreads + 1
			end
		end
	end
	
	return initialMaxNumThreads - maxNumThreads 	-- return how many threads have been started or removed
end

function button.initialised()
	if buttonOver and buttonOff and buttonOverSmall and buttonOffSmall then
		return true
	end
end

return button
