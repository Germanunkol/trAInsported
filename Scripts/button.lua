local button = {}

local button_mt = { __index = button }

local buttonList = {}

function button:new(x, y, imageOff, imageOver, event)
	for i=1,#buttonList+1,1 do
		if not buttonList[i] then
			if type(imageOff) == "string" then
				imageOff = love.graphics.newImage("Images/" .. imageOff)
			end
			if type(imageOver) == "string" then
				imageOver = love.graphics.newImage("Images/" .. imageOver)
			end
			buttonList[i] = setmetatable({x=x, y=y, imageOff=imageOff, imageOver=imageOver, event=event, index = i}, button_mt)
			return buttonList[i]
		end
	end
end

function button:remove()
	buttonList[self.index] = nil
	return nil
end

function rectangularCollision(xPos, yPos, width, height, xPos2, yPos2)
	return (xPos < xPos2 and xPos+width > xPos2 and yPos < yPos2 and yPos+height > yPos2)
end

function button.clacMouseHover()
	mX, mY = love.mouse.getPosition()
	for k, b in pairs(buttonList) do
		b.mouseHover = rectangularCollision(b.x, b.y, b.imageOff:getWidth(), b.imageOff:getHeight(), mX, mY)
	end
end

function button.handleClick()
	for k, b in pairs(buttonList) do
		print("button found")
		if b.mouseHover and b.event then
			print("button over found")
			b.event()
		end
	end
end

function button.show()
	love.graphics.setColor(255,255,255,255)
	for k, b in pairs(buttonList) do
		if not b.invisible then
			if b.mouseHover then
				love.graphics.draw(b.imageOver, b.x, b.y)
			else
				love.graphics.draw(b.imageOff, b.x, b.y)
			end
		end
	end
end

return button
