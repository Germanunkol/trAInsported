local msgBox = {}

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
					b = button:new(x + j*(msgBoxBG:getWidth()/(#arg+1)) - STND_BUTTON_WIDTH/2, y + msgBoxBG:getHeight() - 60, "Cancel", msgBox.remove, msgBoxList[i], priority)			
				else
					b = button:new(x + j*(msgBoxBG:getWidth()/(#arg+1)) - STND_BUTTON_WIDTH/2, y + msgBoxBG:getHeight() - 60, arg[j].name, arg[j].event, arg[j].args, priority)
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

function msgBox.init()
	msgBoxBG = createBoxImage(400,150,true, 10, 0,64,160,100)
end

return msgBox
