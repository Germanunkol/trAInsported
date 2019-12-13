local tutorialBox = {}

local tutorialBoxList = {}

local succeedSound = love.audio.newSource("Sound/echo_affirm1.wav", "stream")

-- remove tutorialBox box before quitting!
function tutorialBoxEvent(box, eventToCall)
	return function (args)
		tutorialBox.remove(box)
		eventToCall(args)
	end
end

function tutorialBox.new(x, y, msg, ... )
	local arg = { ... }
	arg = arg[1]

	--text = wrap(msg, tutorialBoxBG:getWidth()-30, FONT_BUTTON)
	for i=1,#tutorialBoxList+1,1 do
		if not tutorialBoxList[i] then
		
			tutorialBoxList[i] = setmetatable({x=x, y=y, width=tutorialBoxBG:getWidth(), height=tutorialBoxBG:getHeight(), text=msg, bg=tutorialBoxBG, index = i, buttons={}}, tutorialBox_mt)
			local priority = 1		-- same importance as anything else
			if arg then
				for j = 1, #arg, 1 do
					if arg[j].inBetweenSteps then
						b = button:new(x + (j-0.5)*(tutorialBoxBG:getWidth()/#arg) - STND_BUTTON_WIDTH/2 -5, y + tutorialBoxBG:getHeight() - 60, arg[j].name, arg[j].event, arg[j].args, priority, nil, true)
					else
						b = button:new(x + (j-0.5)*(tutorialBoxBG:getWidth()/#arg) - STND_BUTTON_WIDTH/2 -5, y + tutorialBoxBG:getHeight() - 60, arg[j].name, tutorialBoxEvent(tutorialBoxList[i], arg[j].event), arg[j].args, priority, nil, true)
					end
					if b then
						table.insert(tutorialBoxList[i].buttons, b)
					end
				end
			end
			return tutorialBoxList[i]
		end
	end
end

function tutorialBox.remove(box)
	b = box or self
	for i = 1, #b.buttons,1 do
		b.buttons[i]:remove()
	end
	tutorialBoxList[b.index] = nil
	return nil
end

function tutorialBox.clearAll()
	for k, b in pairs(tutorialBoxList) do
		tutorialBox.remove(b)
	end
	tutorialBoxList = {}
end

function tutorialBox.show()
	love.graphics.setColor(255,255,255,255)
	for k, m in pairs(tutorialBoxList) do
		love.graphics.setFont(FONT_STAT_MSGBOX)
		love.graphics.draw(m.bg, m.x, m.y)
		love.graphics.printf(m.text, m.x + 30, m.y + 15, m.bg:getWidth()-60, "left")
		for l, b in pairs(m.buttons) do
			button.renderSingle(b)
		end
		if os.time() - tutorialBox.showCheckMark < 5 and os.time() - tutorialBox.showCheckMark > 0 then
			x = 
			love.graphics.draw(tutorialBoxCheckMark, m.x + m.bg:getWidth() - tutorialBoxCheckMark:getWidth()/2, m.y - tutorialBoxCheckMark:getHeight()/2 +20)
			love.graphics.draw(checkmarkImage, m.x + m.bg:getWidth() - checkmarkImage:getWidth()/2, m.y - checkmarkImage:getHeight()/2 + 20)
			if tutorialBox.playSound then
				succeedSound:seek(0)
				succeedSound:play()
				tutorialBox.playSound = false
			end
		end
	end
end

function tutorialBox.succeed( inSeconds )
	inSeconds = inSeconds or 1
	tutorialBox.showCheckMark = os.time() + inSeconds
	tutorialBox.playSound = true
end

function tutorialBox.succeedOff()
	tutorialBox.playSound = false
	tutorialBox.showCheckMark = os.time() - 100		-- set back: don't display checkmark!
end

function tutorialBox.handleClick()
	local mX, mY = love.mouse.getPosition()
	
	if not tutorialBox.moving then
	
		for k, b in pairs(tutorialBoxList) do
			b.moving = rectangularCollision(b.x, b.y, b.width, b.height, mX, mY)
			if b.moving then
				tutorialBox.moving = b
				mouseLastX = mX
				mouseLastY = mY
				return true
			end
		end
	
	else		-- allready moving a box?
		oldX = tutorialBox.moving.x
		oldY = tutorialBox.moving.y
		
		tutorialBox.moving.x = clamp(tutorialBox.moving.x + (mX - mouseLastX), 0, love.graphics.getWidth() - tutorialBox.moving.width)
		tutorialBox.moving.y = clamp(tutorialBox.moving.y + (mY - mouseLastY), 0, love.graphics.getHeight() - tutorialBox.moving.height)
		mouseLastX = mX
		mouseLastY = mY
		
		for k, button in pairs(tutorialBox.moving.buttons) do
			button.x = button.x + (tutorialBox.moving.x - oldX)
			button.y = button.y + (tutorialBox.moving.y - oldY)
		end
		return true
	end
end


function tutorialBox.init(maxNumThreads)
	tutorialBox.showCheckMark = 0
	tutorialBoxCheckMark = love.graphics.newImage( "Images/tutorialBoxCheckMark.png" )
	tutorialBoxBG = love.graphics.newImage( "Images/tutorialBoxBG.png" )
end

return tutorialBox
