local msgBox = {}

local MSG_BOX_WIDTH = 400
local MSG_BOX_HEIGHT = 150

local msgBoxList = {}

local msgBox_mt = { __index = msgBox }

local msgBoxBG

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
	text = wrap(msg, msgBoxBG:getWidth()-30, FONT_BUTTON)
	height = #text*FONT_BUTTON:getHeight()
	for i=1,#msgBoxList+1,1 do
		if not msgBoxList[i] then
			--local bgImage = createMsgBoxBG(width, height + STND_BUTTON_HEIGHT + 35, text)
			msgBoxList[i] = setmetatable({x=x, y=y, width=msgBoxBG:getWidth(), text=msg, bg=msgBoxBG, index = i, buttons={}, text=text}, msgBox_mt)
			local priority = button.getPriority() + 1		-- make sure I'm the most important!
			for j = 1, #arg, 1 do
				if arg[j] == "remove" then
					b = button:new(x + (j-0.5)*(msgBoxBG:getWidth()/#arg) - STND_BUTTON_WIDTH/2, y + msgBoxBG:getHeight() - 60, "Cancel", msgBox.remove, msgBoxList[i], priority)			
				else
					b = button:new(x + (j-0.5)*(msgBoxBG:getWidth()/#arg) - STND_BUTTON_WIDTH/2, y + msgBoxBG:getHeight() - 60, arg[j].name, msgBoxEvent(msgBoxList[i], arg[j].event), arg[j].args, priority)
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
	for i = 1, #self.buttons,1 do
		self.buttons[i]:remove()
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
		end
	end
end

function msgBox.isVisible()
	for k, m in pairs(msgBoxList) do
		return true
	end
end

local msgBoxBGThread

function msgBox.init()
	
	if not msgBoxBGThread and not msgBoxBG then		-- only start thread once!
		print("starting thread:")
		loadingScreen.addSection("Rendering Message Box")
		msgBoxBGThread = love.thread.newThread("msgBoxBGThread", "Scripts/createImageBox.lua")
		msgBoxBGThread:start()
	
		msgBoxBGThread:set("width", MSG_BOX_WIDTH )
		msgBoxBGThread:set("height", MSG_BOX_HEIGHT )
		msgBoxBGThread:set("shadow", true )
		msgBoxBGThread:set("shadowOffsetX", 10 )
		msgBoxBGThread:set("shadowOffsetY", 0 )
		msgBoxBGThread:set("colR", 64 )
		msgBoxBGThread:set("colG", 160 )
		msgBoxBGThread:set("colB", 100 )
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
				msgBoxBG = love.graphics.newImage(msgBoxBG)
				msgBoxBGThread = nil
			end
		end
	end
	
	--old:
	--msgBoxBG = createBoxImage(MSG_BOX_WIDTH,MSG_BOX_HEIGHT,true, 10, 0,64,160,100)
end

function msgBox.initialised()
	if msgBoxBG then
		return true
	end
end

return msgBox
