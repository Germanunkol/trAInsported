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
	--arg = arg[1]

	--text = wrap(msg, codeBoxBG:getWidth()-30, FONT_BUTTON)
	for i=1,#codeBoxList+1,1 do
		if not codeBoxList[i] then
			codeBoxList[i] = setmetatable({x=x, y=y, width=codeBoxBG:getWidth(), text=msg, bg=codeBoxBG, index = i, buttons={}, col=col}, codeBox_mt)
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
	love.graphics.setFont(FONT_STAT_MSGBOX)
	for k, m in pairs(codeBoxList) do
		if m.col then
			love.graphics.setColor(m.col.r, m.col.g, m.col.b, 255)
		else
			love.graphics.setColor(255,255,255,255)
		end
		love.graphics.draw(m.bg, m.x, m.y)
		love.graphics.printf(m.text, m.x + 30, m.y + 15, m.bg:getWidth()-60, "left")
		--for i=1, #m.text do
			--love.graphics.print(m.text[i], m.x + (m.width - FONT_STAT_MSGBOX:getWidth(m.text[i]))/2, m.y + i*FONT_STAT_MSGBOX:getHeight())
		--end
	end
end

function codeBox.init()
	
	if not codeBoxBGThread and not codeBoxBG then		-- only start thread once!
		ok, codeBoxBG = pcall(love.graphics.newImage, "codeBoxBG.png")
		if not ok then
			codeBoxBG = nil
			loadingScreen.addSection("Rendering Code Box")
			codeBoxBGThread = love.thread.newThread("codeBoxBGThread", "Scripts/createImageBox.lua")
			codeBoxBGThread:start()
	
			codeBoxBGThread:set("alpha", 200 )
			codeBoxBGThread:set("width", CODE_BOX_WIDTH )
			codeBoxBGThread:set("height", CODE_BOX_HEIGHT )
			codeBoxBGThread:set("shadow", true )
			codeBoxBGThread:set("shadowOffsetX", 10 )
			codeBoxBGThread:set("shadowOffsetY", 0 )
			codeBoxBGThread:set("colR", CODE_BOX_R )
			codeBoxBGThread:set("colG", CODE_BOX_G )
			codeBoxBGThread:set("colB", CODE_BOX_B )
		end
	else
		if not codeBoxBG then	-- if there's no button yet, that means the thread is still running...
		
			percent = codeBoxBGThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Code Box", percent)
			end
			err = codeBoxBGThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
			status = codeBoxBGThread:get("status")
			if status == "done" then
				codeBoxBG = codeBoxBGThread:get("imageData")		-- get the generated image data from the thread
				codeBoxBG:encode("codeBoxBG.png")
				codeBoxBG = love.graphics.newImage(codeBoxBG)
				codeBoxBGThread = nil
			end
		end
	end
end

function codeBox.initialised()
	if codeBoxBG then
		return true
	end
end

return codeBox
