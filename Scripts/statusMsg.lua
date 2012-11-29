local statusMsg = {}

local currentMsg = ""
local currentErr = nil
local currentTime = 0

function statusMsg.init()
	if not statusMsgBoxThread and not statusMsgBox then		-- only start thread once!
		ok, statusMsgBox = pcall(love.graphics.newImage, "statusMsgBox.png")
		if not ok or not versionCheck.getMatch() then
			statusMsgBox = nil
			loadingScreen.addSection("Rendering Status Msg Box")
			statusMsgBoxThread = love.thread.newThread("statusMsgBoxThread", "Scripts/createImageBox.lua")
			statusMsgBoxThread:start()
	
			statusMsgBoxThread:set("width", STAT_MSG_WIDTH )
			statusMsgBoxThread:set("height", STAT_MSG_HEIGHT )
			statusMsgBoxThread:set("shadow", true )
			statusMsgBoxThread:set("shadowOffsetX", 6 )
			statusMsgBoxThread:set("shadowOffsetY", 1 )
			statusMsgBoxThread:set("colR", STAT_MSG_R )
			statusMsgBoxThread:set("colG", STAT_MSG_G )
			statusMsgBoxThread:set("colB", STAT_MSG_B )
		end
	else
		if not statusMsgBox then	-- if there's no button yet, that means the thread is still running...
		
			percent = statusMsgBoxThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Status Msg Box", percent)
			end
			err = statusMsgBoxThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
			status = statusMsgBoxThread:get("status")
			if status == "done" then
				statusMsgBox = statusMsgBoxThread:get("imageData")		-- get the generated image data from the thread
				statusMsgBox:encode("statusMsgBox.png")
				statusMsgBox = love.graphics.newImage(statusMsgBox)
				statusMsgBoxThread = nil
			end
		end
	end
	
	if not statusErrBoxThread and not statusErrBox then		-- only start thread once!
		ok, statusErrBox = pcall(love.graphics.newImage, "statusErrBox.png")
		if not ok or not versionCheck.getMatch() then
			statusErrBox = nil
			loadingScreen.addSection("Rendering Status Error Box")
			statusErrBoxThread = love.thread.newThread("statusErrBoxThread", "Scripts/createImageBox.lua")
			statusErrBoxThread:start()
	
			statusErrBoxThread:set("width", STAT_MSG_WIDTH )
			statusErrBoxThread:set("height", STAT_MSG_HEIGHT )
			statusErrBoxThread:set("shadow", true )
			statusErrBoxThread:set("shadowOffsetX", 6 )
			statusErrBoxThread:set("shadowOffsetY", 1 )
			statusErrBoxThread:set("colR", STAT_ERR_R )
			statusErrBoxThread:set("colG", STAT_ERR_G )
			statusErrBoxThread:set("colB", STAT_ERR_B )
		end
	else
		if not statusErrBox then	-- if there's no button yet, that means the thread is still running...
		
			percent = statusErrBoxThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Status Error Box", percent)
			end
			err = statusErrBoxThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
			status = statusErrBoxThread:get("status")
			if status == "done" then
				statusErrBox = statusErrBoxThread:get("imageData")		-- get the generated image data from the thread
				statusErrBox:encode("statusErrBox.png")
				statusErrBox = love.graphics.newImage(statusErrBox)
				statusErrBoxThread = nil
			end
		end
	end
end


function statusMsg.initialised()
	if statusMsgBox and statusErrBox then
		return true
	end
end


function statusMsg.new(txt, err)
	currentErr = err
	currentMsg = txt
	currentTime = 7
end

function statusMsg.display(dt)
	if currentTime > 0 then
		currentTime = currentTime - dt
		love.graphics.setColor(255,255,255,255)
		love.graphics.setFont(FONT_STANDARD)
		if currentErr then
			love.graphics.draw(statusErrBox, (love.graphics.getWidth() - statusMsgBox:getWidth())/2 -10, love.graphics.getHeight() - statusMsgBox:getHeight())
		else
			love.graphics.draw(statusMsgBox, (love.graphics.getWidth() - statusMsgBox:getWidth())/2 -10, love.graphics.getHeight() - statusMsgBox:getHeight())
		end
		love.graphics.printf(currentMsg, (love.graphics.getWidth() - statusMsgBox:getWidth())/2, love.graphics.getHeight() - statusMsgBox:getHeight() + 3, statusMsgBox:getWidth()-30, "center")
	end
end

return statusMsg
