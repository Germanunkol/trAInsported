local tutorialBox = {}

function tutorialBox.new()
	
end


function tutorialBox.init()
	
	if not tutorialBoxBGThread and not tutorialBoxBG then		-- only start thread once!
		loadingScreen.addSection("Rendering Message Box")
		tutorialBoxBGThread = love.thread.newThread("tutorialBoxBGThread", "Scripts/createImageBox.lua")
		tutorialBoxBGThread:start()
	
		tutorialBoxBGThread:set("width", TUT_BOX_WIDTH )
		tutorialBoxBGThread:set("height", TUT_BOX_HEIGHT )
		tutorialBoxBGThread:set("shadow", true )
		tutorialBoxBGThread:set("shadowOffsetX", 10 )
		tutorialBoxBGThread:set("shadowOffsetY", 0 )
		tutorialBoxBGThread:set("colR", TUT_BOX_R )
		tutorialBoxBGThread:set("colG", TUT_BOX_G )
		tutorialBoxBGThread:set("colB", TUT_BOX_B )
		
	else
		if not tutorialBoxBG then	-- if there's no button yet, that means the thread is still running...
		
			percent = tutorialBoxBGThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Message Box", percent)
			end
			err = tutorialBoxBGThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
			status = tutorialBoxBGThread:get("status")
			if status == "done" then
				tutorialBoxBG = tutorialBoxBGThread:get("imageData")		-- get the generated image data from the thread
				tutorialBoxBG = love.graphics.newImage(tutorialBoxBG)
				tutorialBoxBGThread = nil
			end
		end
	end
end
