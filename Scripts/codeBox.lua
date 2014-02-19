local codeBox = {}

local codeBoxList = {}

-- remove codeBox box before quitting!
function codeBoxEvent(box, eventToCall)
	return function (args)
		codeBox.remove(box)
		eventToCall(args)
	end
end

function codeBox.new(x, y, msg, col)

	--text = wrap(msg, codeBoxBG:getWidth()-30, FONT_BUTTON)
	for i=1,#codeBoxList+1,1 do
		if not codeBoxList[i] then
			codeBoxList[i] = setmetatable({x=x, y=y, width=codeBoxBG:getWidth(), height=codeBoxBG:getHeight(), text=msg, bg=codeBoxBG, index = i, buttons={}, col=col}, codeBox_mt)
			local priority = 1		-- same importance as anything else
			--[[for j = 1, #arg, 1 do
				if arg[j] == "remove" then
					b = button:new(x + (j-0.5)*(codeBoxBG:getWidth()/#arg) - STND_BUTTON_WIDTH/2, y + codeBoxBG:getHeight() - 60, "Cancel", codeBox.remove, codeBoxList[i], priority)			
				else
					for k, p in pairs(arg[j]) do
						print(k, p)
					end
					b = button:new(x + (j-0.5)*(codeBoxBG:getWidth()/#arg) - STND_BUTTON_WIDTH/2, y + codeBoxBG:getHeight() - 60, arg[j].name, codeBoxEvent(codeBoxList[i], arg[j].event), arg[j].args, priority)
				end
				if b then
					table.insert(codeBoxList[i].buttons, b)
				end
			end]]--
			return codeBoxList[i]
		end
	end
end

function codeBox.remove(box)
	b = box or self
	for i = 1, #b.buttons,1 do
		b.buttons[i]:remove()
	end
	CODE_BOX_X = b.x
	CODE_BOX_Y = b.y
	codeBoxList[b.index] = nil
	return nil
end

function codeBox.clearAll()
	for k, b in pairs(codeBoxList) do
		codeBox.remove(b)
	end
	codeBoxList = {}
end

function codeBox.show()

	for k, m in pairs(codeBoxList) do
		love.graphics.setColor(255,255,255,255)
		love.graphics.draw(m.bg, m.x, m.y)
		--love.graphics.printf(m.text, m.x + 30, m.y + 15, m.bg:getWidth()-60, "left")
		height = 0
		for line = 1, #m.text do
			for lineSegment = 1, #m.text[line] do
				love.graphics.setColor(255, 255, 255, 255)
				if m.text[line][lineSegment].font == FONT_CODE_COMMENT then
					love.graphics.setColor(200, 255, 170, 255)
				elseif m.text[line][lineSegment].font == FONT_CODE_PLAIN then
					love.graphics.setColor(200, 200, 200, 255)
				end
				love.graphics.setFont(m.text[line][lineSegment].font)
				love.graphics.print(m.text[line][lineSegment].str, m.x + 30 + m.text[line][lineSegment].x, m.y + 15 + height)
			end
			if m.text[line][1] and m.text[line][1].font then
				height = height + m.text[line][1].font:getHeight() + 2
			end
		end
		--for i=1, #m.text do
			--love.graphics.print(m.text[i], m.x + (m.width - FONT_STAT_MSGBOX:getWidth(m.text[i]))/2, m.y + i*FONT_STAT_MSGBOX:getHeight())
		--end
	end
end


function codeBox.handleClick()
	local mX, mY = love.mouse.getPosition()
	
	if not codeBox.moving then
	
		for k, b in pairs(codeBoxList) do
			b.moving = rectangularCollision(b.x, b.y, b.width, b.height, mX, mY)
			if b.moving then
				codeBox.moving = b
				mouseLastX = mX
				mouseLastY = mY
				return true
			end
		end
	
	else		-- allready moving a box?
		oldX = codeBox.moving.x
		oldY = codeBox.moving.y
		
		codeBox.moving.x = clamp(codeBox.moving.x + (mX - mouseLastX), 0, love.graphics.getWidth() - codeBox.moving.width)
		codeBox.moving.y = clamp(codeBox.moving.y + (mY - mouseLastY), 0, love.graphics.getHeight() - codeBox.moving.height)
		mouseLastX = mX
		mouseLastY = mY
		
		for k, button in pairs(codeBox.moving.buttons) do
			button.x = button.x + (codeBox.moving.x - oldX)
			button.y = button.y + (codeBox.moving.y - oldY)
		end
		return true
	end
end

function codeBox.init(maxNumThreads)
	codeBoxBG = love.graphics.newImage( "Images/codeBoxBG.png")
end

return codeBox
