local statusMsg = {}

local currentMsg = ""
local currentErr = nil
local currentTime = 0

errorSound = love.audio.newSource("Sound/wobble_alert.wav")


function statusMsg.init(maxNumThreads)
	local initialMaxNumThreads = maxNumThreads
	
	if not statusMsgBoxThread and not statusMsgBox then		-- only start thread once!
		if not CL_FORCE_RENDER then
			ok, statusMsgBox = pcall(love.graphics.newImage, "statusMsgBox.png")
			if not ok then statusMsgBox = nil end
		end
		if (not ok or not versionCheck.getMatch() or CL_FORCE_RENDER) and maxNumThreads > 0 then
		
			maxNumThreads = maxNumThreads - 1
			
			statusMsgBox = nil
			loadingScreen.addSection("Rendering Status Msg Box")
			statusMsgBoxThread = love.thread.newThread("statusMsgBoxThread", "Scripts/renderImageBox.lua")
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
				statusMsgBoxThread:wait()
				statusMsgBoxThread = nil
				
				maxNumThreads = maxNumThreads + 1
			end
		end
	end
	
	if not statusErrBoxThread and not statusErrBox then		-- only start thread once!
		if not CL_FORCE_RENDER then
			ok, statusErrBox = pcall(love.graphics.newImage, "statusErrBox.png")
			if not ok then statusErrBox = nil end
		end
		if (not ok or not versionCheck.getMatch() or CL_FORCE_RENDER) and maxNumThreads > 0 then
		
			maxNumThreads = maxNumThreads - 1
			
			statusErrBox = nil
			loadingScreen.addSection("Rendering Status Error Box")
			statusErrBoxThread = love.thread.newThread("statusErrBoxThread", "Scripts/renderImageBox.lua")
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
				statusErrBoxThread:wait()
				statusErrBoxThread = nil
				
				maxNumThreads = maxNumThreads + 1
			end
		end
	end
	
	if not toolTipBoxThread and not toolTipBox then		-- only start thread once!
		if not CL_FORCE_RENDER then
			ok, toolTipBox = pcall(love.graphics.newImage, "toolTipBox.png")
			if not ok then toolTipBox = nil end
		end
		if (not ok or not versionCheck.getMatch() or CL_FORCE_RENDER) and maxNumThreads > 0 then
		
			maxNumThreads = maxNumThreads - 1
			
			toolTipBox = nil
			loadingScreen.addSection("Rendering Tool Tip Box")
			toolTipBoxThread = love.thread.newThread("toolTipBoxThread", "Scripts/renderImageBox.lua")
			toolTipBoxThread:start()
	
			toolTipBoxThread:set("width", TOOL_TIP_WIDTH )
			toolTipBoxThread:set("height", TOOL_TIP_HEIGHT )
			toolTipBoxThread:set("shadow", true )
			toolTipBoxThread:set("shadowOffsetX", 6 )
			toolTipBoxThread:set("shadowOffsetY", 1 )
			toolTipBoxThread:set("colR", TOOL_TIP_R )
			toolTipBoxThread:set("colG", TOOL_TIP_G )
			toolTipBoxThread:set("colB", TOOL_TIP_B )
		end
	else
		if not toolTipBox then	-- if there's no button yet, that means the thread is still running...
		
			percent = toolTipBoxThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Tool Tip Box", percent)
			end
			err = toolTipBoxThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
			status = toolTipBoxThread:get("status")
			if status == "done" then
				toolTipBox = toolTipBoxThread:get("imageData")		-- get the generated image data from the thread
				toolTipBox:encode("toolTipBox.png")
				toolTipBox = love.graphics.newImage(toolTipBox)
				toolTipBoxThread:wait()
				toolTipBoxThread = nil
				
				maxNumThreads = maxNumThreads + 1
			end
		end
	end
	return initialMaxNumThreads - maxNumThreads 	-- return how many threads have been started or removed
end


function statusMsg.initialised()
	if statusMsgBox and statusErrBox and toolTipBox then
		return true
	end
end


function statusMsg.new(txt, err)
	currentErr = err
	currentMsg = txt
	currentTime = 6
	if err then
		errorSound:rewind()
		errorSound:play()
	end
end

function statusMsg.display(dt)
	if currentTime < 3 and toolTip then
		currentTime = 0
	end
	if currentTime > 0 then
		currentTime = currentTime - dt
		love.graphics.setColor(255,255,255,255)
		love.graphics.setFont(FONT_STANDARD)
		if currentErr then
			love.graphics.draw(statusErrBox, (love.graphics.getWidth() - statusMsgBox:getWidth())/2 -10, love.graphics.getHeight() - statusMsgBox:getHeight())
		else
			love.graphics.draw(statusMsgBox, (love.graphics.getWidth() - statusMsgBox:getWidth())/2 -10, love.graphics.getHeight() - statusMsgBox:getHeight())
		end
		love.graphics.printf(currentMsg, (love.graphics.getWidth() - statusMsgBox:getWidth())/2, love.graphics.getHeight() - statusMsgBox:getHeight() + 5, statusMsgBox:getWidth()-30, "center")
	elseif toolTip then
		love.graphics.setColor(255,255,255,255)
		love.graphics.setFont(FONT_STANDARD)
		love.graphics.draw(toolTipBox, (love.graphics.getWidth() - toolTipBox:getWidth())/2 -10, love.graphics.getHeight() - toolTipBox:getHeight())
		love.graphics.printf(toolTip, (love.graphics.getWidth() - toolTipBox:getWidth())/2, love.graphics.getHeight() - toolTipBox:getHeight() + 5, toolTipBox:getWidth()-30, "center")
	end
end

return statusMsg
