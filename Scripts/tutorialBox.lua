local tutorialBox = {}

local tutorialBoxList = {}

-- remove tutorialBox box before quitting!
function tutorialBoxEvent(box, eventToCall)
	return function (args)
		tutorialBox.remove(box)
		eventToCall(args)
	end
end

function tutorialBox.new(x, y, msg, ... )
	arg = arg[1]

	--text = wrap(msg, tutorialBoxBG:getWidth()-30, FONT_BUTTON)
	for i=1,#tutorialBoxList+1,1 do
		if not tutorialBoxList[i] then
			tutorialBoxList[i] = setmetatable({x=x, y=y, width=tutorialBoxBG:getWidth(), height=tutorialBoxBG:getHeight(), text=msg, bg=tutorialBoxBG, index = i, buttons={}}, tutorialBox_mt)
			local priority = 1		-- same importance as anything else
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
	end
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


function tutorialBox.init()
	
	if not tutorialBoxBGThread and not tutorialBoxBG then		-- only start thread once!
		ok, tutorialBoxBG = pcall(love.graphics.newImage, "tutorialBoxBG.png")
		if not ok or not versionCheck.getMatch() or CL_FORCE_RENDER then
			tutorialBoxBG = nil
			loadingScreen.addSection("Rendering Tutorial Box")
			tutorialBoxBGThread = love.thread.newThread("tutorialBoxBGThread", "Scripts/renderImageBox.lua")
			tutorialBoxBGThread:start()
	
		
			tutorialBoxBGThread:set("alpha", 200 )
			tutorialBoxBGThread:set("width", TUT_BOX_WIDTH )
			tutorialBoxBGThread:set("height", TUT_BOX_HEIGHT )
			tutorialBoxBGThread:set("shadow", true )
			tutorialBoxBGThread:set("shadowOffsetX", 6 )
			tutorialBoxBGThread:set("shadowOffsetY", 1 )
			tutorialBoxBGThread:set("colR", MSG_BOX_R )
			tutorialBoxBGThread:set("colG", MSG_BOX_G )
			tutorialBoxBGThread:set("colB", MSG_BOX_B )
		end
	else
		if not tutorialBoxBG then	-- if there's no button yet, that means the thread is still running...
		
			percent = tutorialBoxBGThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Tutorial Box", percent)
			end
			err = tutorialBoxBGThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
			status = tutorialBoxBGThread:get("status")
			if status == "done" then
				tutorialBoxBG = tutorialBoxBGThread:get("imageData")		-- get the generated image data from the thread
				tutorialBoxBG:encode("tutorialBoxBG.png")
				tutorialBoxBG = love.graphics.newImage(tutorialBoxBG)
				tutorialBoxBGThread = nil
			end
		end
	end
end

function tutorialBox.initialised()
	if tutorialBoxBG then
		return true
	end
end

return tutorialBox
