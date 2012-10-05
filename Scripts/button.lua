local button = {}

BUTTON_WIDTH = 160
BUTTON_HEIGHT = 35

local button_mt = { __index = button }

local buttonList = {}

local buttonLevel = 1

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

function button:new(x, y, label, event, eventArgs, priority)
	priority = priority or 1
	for i=1,#buttonList+1,1 do
		if not buttonList[i] then
			-- local imageOff = createButtonOff(width, height, label)
			-- local imageOver = createButtonOver(width, height, label)
			buttonList[i] = setmetatable({x=x, y=y, imageOff=buttonOff, imageOver=buttonOver, event=event, index = i, w=buttonOff:getWidth(), h=buttonOff:getHeight(), l=label, eventArgs=eventArgs, priority=priority}, button_mt)
			button.setButtonLevel()
			return buttonList[i]
		end
	end
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
	for k, b in pairs(buttonList) do
		if b.priority == buttonLevel then
			b.mouseHover = rectangularCollision(b.x, b.y, b.w, b.h, mX, mY)
		end
	end
end

function button.handleClick()
	local hit = false
	for k, b in pairs(buttonList) do
		if b.mouseHover and b.event and not b.invisible then
			b.event(b.eventArgs)
			hit = true
		end
	end
	return hit
end

function button.show()
	love.graphics.setFont(FONT_BUTTON)
	w = buttonOver:getWidth()
	for k, b in pairs(buttonList) do
		if not b.invisible then
			if b.mouseHover then
				love.graphics.setColor(255,255,255,255)
				love.graphics.draw(b.imageOver, b.x, b.y)
				love.graphics.print(b.l, b.x + (w-FONT_BUTTON:getWidth(b.l))/2, b.y + 8)
			else
				if b.priority == buttonLevel then love.graphics.setColor(255,255,255,255)
				else love.graphics.setColor(255,255,255,150) end
				love.graphics.draw(b.imageOff, b.x, b.y)
				love.graphics.print(b.l, b.x + (w-FONT_BUTTON:getWidth(b.l))/2, b.y + 10)
			end
		end
	end
end


function button.init()
	buttonOff = createBoxImage(STND_BUTTON_WIDTH , STND_BUTTON_HEIGHT, true, 5,2, 64,160,100)
	buttonOver = createBoxImage(STND_BUTTON_WIDTH, STND_BUTTON_HEIGHT, true, 6,1, 64,160,100)
end

return button
