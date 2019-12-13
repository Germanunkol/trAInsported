local button = {}

STANDARD = 1
SMALL = 2
SQUARE = 3

local button_mt = { __index = button }

local buttonList = {}

local buttonLevel = 1

local buttonOver = nil
local buttonOff = nil

buttonClickSound = love.audio.newSource("Sound/blip_click.wav", "static")

buttonOffSquare = love.graphics.newImage("Images/ButtonSpeedOff.png")
buttonOverSquare = love.graphics.newImage("Images/ButtonSpeedOver.png")

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
	if not label then error("button label nil!") end
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
			elseif size == SQUARE then
				buttonList[i] = setmetatable({size = SQUARE, x=x, y=y, imageOff=buttonOffSquare, imageOver=buttonOverSquare, event=event, index = i, w=buttonOverSquare:getWidth(), h=buttonOverSquare:getHeight(), l=label, eventArgs=eventArgs, priority=priority, renderSeperate = renderSeperate}, button_mt)
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

function button:newSquare(x, y, label, event, eventArgs, priority, renderSeperate, toolTip)
	return button:new(x, y, label, event, eventArgs, priority, SQUARE, renderSeperate, toolTip)
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
			buttonClickSound:seek(0)
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

function button.init(maxNumThreads)
	buttonOff = love.graphics.newImage("Images/buttonOff.png")
	buttonOver = love.graphics.newImage( "Images/buttonOver.png")
	buttonOverSmall = love.graphics.newImage( "Images/buttonOverSmall.png")
	buttonOffSmall = love.graphics.newImage( "Images/buttonOffSmall.png")
end

return button
