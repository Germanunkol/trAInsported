local quickHelp = {}

local helpBg = nil

local HELP_WIDTH, HELP_HEIGHT = 400,300

local helpStrKeys = [[Space :
W,A,S,D :
Cursor Keys :
Q,E :
C :
+ :
- :
m :
F5 :
F1 :
]]
local helpStr = [[Tactical overlay
Move view
Move view
Zoom view
Toggle console
Speed up
Slow down
Show map coordinates
Screenshot
Toggle this Help
]]

function quickHelp.show()
	love.graphics.setColor(255,255,255,255)
	love.graphics.setFont(FONT_STAT_MSGBOX)
	x,y = love.graphics.getWidth()-HELP_WIDTH-20, roundStats:getHeight() + 30
	love.graphics.draw(helpBg, x,y )
	love.graphics.printf(helpStrKeys, x+20, y+20, 120, "right")
	love.graphics.printf(helpStr, x+150, y+20, HELP_WIDTH-170, "left")
end

function quickHelp.toggle()
	if showQuickHelp then
		showQuickHelp = false
	else
		showQuickHelp = true
		if tutorial and tutorial.f1Event then
			tutorial.f1Event()
		end
	end
end

function quickHelp.setVisibility(vis)
	if vis then
		showQuickHelp = true
	else
		showQuickHelp = false
	end
end

local helpBgThread

function quickHelp.init(maxNumThreads)
	local initialMaxNumThreads = maxNumThreads

	if not helpBgThread and not helpBg then		-- only start thread once!
		if not CL_FORCE_RENDER then
			ok, helpBg = pcall(love.graphics.newImage, "helpBg.png")
			if not ok then helpBg = nil end
		end
		if (not ok or not versionCheck.getMatch() or CL_FORCE_RENDER) and maxNumThreads > 0 then
		
			maxNumThreads = maxNumThreads - 1
			
			helpBg = nil
			loadingScreen.addSection("Rendering Help Box")
			helpBgThread = love.thread.newThread("helpBgThread", "Scripts/renderImageBox.lua")
			helpBgThread:start()
	
			helpBgThread:set("width", HELP_WIDTH )
			helpBgThread:set("height", HELP_HEIGHT )
			helpBgThread:set("shadow", true )
			helpBgThread:set("shadowOffsetX", 6 )
			helpBgThread:set("shadowOffsetY", 1 )
			helpBgThread:set("colR", MSG_BOX_R )
			helpBgThread:set("colG", MSG_BOX_G )
			helpBgThread:set("colB", MSG_BOX_B )
		end
	else
		if not helpBg then	-- if there's no button yet, that means the thread is still running...
		
			percent = helpBgThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Help Box", percent)
			end
			err = helpBgThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
			status = helpBgThread:get("status")
			if status == "done" then
				helpBg = helpBgThread:get("imageData")		-- get the generated image data from the thread
				helpBg:encode("helpBg.png")
				helpBg = love.graphics.newImage(helpBg)
				helpBgThread:wait()
				helpBgThread = nil
				
				maxNumThreads = maxNumThreads + 1
			end
		end
	end
	return initialMaxNumThreads - maxNumThreads 	-- return how many threads have been started or removed
end

function quickHelp.initialised()
	if helpBg then
		return true
	end
end

return quickHelp
