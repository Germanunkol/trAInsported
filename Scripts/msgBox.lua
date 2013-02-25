local msgBox = {}

local MSG_BOX_WIDTH = 400
local MSG_BOX_HEIGHT = 150

local msgBoxList = {}

local msgBox_mt = { __index = msgBox }

local msgBoxBG

msgBoxSound = love.audio.newSource("Sound/melodic1_affirm.wav")

function wrap(str, limit, font)
	indent = indent or ""
	indent1 = indent1 or indent
	limit = limit or 72
	local here = 1
	local line = 1
	local tbl = {}
	str:gsub("()(%S+)()",
		function(st, word, en)
			if font:getWidth((tbl[line] or "") .. " " .. word) > limit then
				line = line + 1
			end
			tbl[line] = (tbl[line] or "") .. word .. " "
		end)
	return tbl
end

-- remove message box before quitting!
function msgBoxEvent(messageBox, eventToCall)
	return function (args)
		messageBox:remove()
		eventToCall(args)
	end
end

function msgBox:new(x, y, msg, ... )
	local arg = { ... }
	text = wrap(msg, msgBoxBG:getWidth()-30, FONT_STAT_MSGBOX)
	
	for i=1,#msgBoxList+1,1 do
		if not msgBoxList[i] then
			
			msgBoxSound:rewind()
			msgBoxSound:play()
			
			msgBoxList[i] = setmetatable({x=x, y=y, width=msgBoxBG:getWidth(), height=msgBoxBG:getHeight(), bg=msgBoxBG, index = i, buttons={}, text=text}, msgBox_mt)
			local priority = button.getPriority() + 1		-- make sure I'm the most important!
			for j = 1, #arg, 1 do
				if arg[j] == "remove" then
					b = button:new(x + (j-0.5)*(msgBoxBG:getWidth()/#arg) - STND_BUTTON_WIDTH/2 -5, y + msgBoxBG:getHeight() - 60, "Cancel", msgBox.remove, msgBoxList[i], priority, nil, true)	
				else
					b = button:new(x + (j-0.5)*(msgBoxBG:getWidth()/#arg) - STND_BUTTON_WIDTH/2 -5, y + msgBoxBG:getHeight() - 60, arg[j].name, msgBoxEvent(msgBoxList[i], arg[j].event), arg[j].args, priority, nil, true)
				end
				if b then
					table.insert(msgBoxList[i].buttons, b)
				end
			end
			return msgBoxList[i]
		end
	end
end

function msgBox:remove()
	b = box or self
	for i = 1, #b.buttons,1 do
		b.buttons[i]:remove()
	end
	msgBoxList[b.index] = nil
	return nil
end

function msgBox.show()
	love.graphics.setColor(255,255,255,255)
	love.graphics.setFont(FONT_STAT_MSGBOX)
	for k, m in pairs(msgBoxList) do
		love.graphics.draw(m.bg, m.x, m.y)
		for i=1, #m.text do
			love.graphics.print(m.text[i], m.x + (m.width - FONT_STAT_MSGBOX:getWidth(m.text[i]))/2, m.y + i*FONT_STAT_MSGBOX:getHeight())
			for l, b in pairs(m.buttons) do
				button.renderSingle(b)
			end
		end
	end
end

function msgBox.isVisible()
	for k, m in pairs(msgBoxList) do
		return true
	end
end

function msgBox.handleClick()
	local mX, mY = love.mouse.getPosition()
	
	if not msgBox.moving then
	
		for k, b in pairs(msgBoxList) do
			b.moving = rectangularCollision(b.x, b.y, b.width, b.height, mX, mY)
			if b.moving then
				msgBox.moving = b
				mouseLastX = mX
				mouseLastY = mY
				return true
			end
		end
	
	else		-- allready moving a box?
		oldX = msgBox.moving.x
		oldY = msgBox.moving.y
		
		msgBox.moving.x = clamp(msgBox.moving.x + (mX - mouseLastX), 0, love.graphics.getWidth() - msgBox.moving.width)
		msgBox.moving.y = clamp(msgBox.moving.y + (mY - mouseLastY), 0, love.graphics.getHeight() - msgBox.moving.height)
		mouseLastX = mX
		mouseLastY = mY
		
		for k, button in pairs(msgBox.moving.buttons) do
			button.x = button.x + (msgBox.moving.x - oldX)
			button.y = button.y + (msgBox.moving.y - oldY)
		end
		return true
	end
end

local msgBoxBGThread

function msgBox.init(maxNumThreads)
	local initialMaxNumThreads = maxNumThreads
	
	if not msgBoxBGThread and not msgBoxBG then		-- only start thread once!
		if not CL_FORCE_RENDER then
			ok, msgBoxBG = pcall(love.graphics.newImage, "msgBoxBG.png")
			if not ok then msgBoxBG = nil end
		end
		if (not ok or not versionCheck.getMatch() or CL_FORCE_RENDER) and maxNumThreads > 0 then
		
			maxNumThreads = maxNumThreads - 1
			
			msgBoxBG = nil
			loadingScreen.addSection("Rendering Message Box")
			msgBoxBGThread = love.thread.newThread("msgBoxBGThread", "Scripts/renderImageBox.lua")
			msgBoxBGThread:start()
	
			msgBoxBGThread:set("width", MSG_BOX_WIDTH )
			msgBoxBGThread:set("height", MSG_BOX_HEIGHT )
			msgBoxBGThread:set("shadow", true )
			msgBoxBGThread:set("shadowOffsetX", 6 )
			msgBoxBGThread:set("shadowOffsetY", 1 )
			msgBoxBGThread:set("colR", MSG_BOX_R )
			msgBoxBGThread:set("colG", MSG_BOX_G )
			msgBoxBGThread:set("colB", MSG_BOX_B )
		end
	else
		if not msgBoxBG then	-- if there's no button yet, that means the thread is still running...
		
			percent = msgBoxBGThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Message Box", percent)
			end
			err = msgBoxBGThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
			status = msgBoxBGThread:get("status")
			if status == "done" then
				msgBoxBG = msgBoxBGThread:get("imageData")		-- get the generated image data from the thread
				msgBoxBG:encode("msgBoxBG.png")
				msgBoxBG = love.graphics.newImage(msgBoxBG)
				msgBoxBGThread:wait()
				msgBoxBGThread = nil
				
				maxNumThreads = maxNumThreads + 1
			end
		end
	end
	return initialMaxNumThreads - maxNumThreads 	-- return how many threads have been started or removed
end

function msgBox.initialised()
	if msgBoxBG then
		return true
	end
end

return msgBox
