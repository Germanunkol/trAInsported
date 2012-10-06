local quickHelp = {}

local helpBg = nil

local HELP_WIDTH, HELP_HEIGHT = 400,300



local helpStrKeys = [[F1 : 
Space :
W,A,S,D :
Cursor Keys :
Q,E :
C :
+ :
- :
F5 :
]]
local helpStr = [[Toggle this Help
Tactical Overview
Move View
Move View
Zoom View
Toggle Console
Speed up
Slow down
Screenshot
]]

function quickHelp.show()
	love.graphics.setColor(255,255,255,255)
	love.graphics.setFont(FONT_STAT_MSGBOX)
	x,y = (love.graphics.getWidth()-HELP_WIDTH)/2, (love.graphics.getHeight()-HELP_HEIGHT)/2
	love.graphics.draw(helpBg, x,y )
	love.graphics.printf(helpStrKeys, x+20, y+20, 120, "right")
	love.graphics.printf(helpStr, x+150, y+20, HELP_WIDTH-170, "left")
end

function quickHelp.toggle()
	if showQuickHelp then
		showQuickHelp = false
	else
		showQuickHelp = true
	end
end

local helpBgThread

function quickHelp.init()

	if not helpBgThread and not helpBg then		-- only start thread once!
		print("starting thread:")
		loadingScreen.addSection("Rendering Help Box")
		helpBgThread = love.thread.newThread("helpBgThread", "Scripts/createImageBox.lua")
		helpBgThread:start()
	
		helpBgThread:set("width", HELP_WIDTH )
		helpBgThread:set("height", HELP_HEIGHT )
		helpBgThread:set("shadow", true )
		helpBgThread:set("shadowOffsetX", 10 )
		helpBgThread:set("shadowOffsetY", 0 )
		helpBgThread:set("colR", 64 )
		helpBgThread:set("colG", 160 )
		helpBgThread:set("colB", 100 )
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
				helpBg = love.graphics.newImage(helpBg)
				helpBgThread = nil
			end
		end
	end
	--helpBg = createBoxImage(HELP_WIDTH,HELP_HEIGHT,true, 10, 0,64,160,100)
end

function quickHelp.initialised()
	if helpBg then
		return true
	end
end

return quickHelp
