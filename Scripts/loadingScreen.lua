local loadingScreen = {}

local sectionList = {}

bgBox = nil
bgBoxSmall = nil

local BOX_WIDTH = 400
local BOX_HEIGHT = 50
local BOX_WIDTH_SMALL = 300
local BOX_HEIGHT_SMALL = 30

function loadingScreen.reset()
	sectionList = {}
	percentages = {}
end

function loadingScreen.addSection(section)
	for k=1, #sectionList+1 do
		if sectionList[k] == nil then
			sectionList[k] = {}
			sectionList[k].name = section
			sectionList[k].subSections = {}
			sectionList[k].percentage = 0
			break
		end
	end
end

function loadingScreen.percentage(section, percent)
	for k, s in pairs(sectionList) do
		if s.name == section then
			s.percentage = percent
			break
		end
	end
end

function loadingScreen.addSubSection(section, subSection)
	for k, s in pairs(sectionList) do
		if s.name == section then
			for k=1, #s.subSections+1 do
				if s.subSections[k] == nil then
					s.subSections[k] = subSection
					break
				end
			end
			break
		end
	end
end

function loadingScreen.render()
	if initialising == false then
		x = (love.graphics.getWidth()-bgBox:getWidth())/2
		y = 40
		for k,s in pairs(sectionList) do
			y = y + 20
			love.graphics.setFont(FONT_BUTTON)
			love.graphics.draw(bgBox, x, y)
			str = ""
			if s.percentage > 0 then
				strPercentage = tostring(math.floor(10*s.percentage)/10)
				if #strPercentage <= 2 then strPercentage = strPercentage .. ".0" end
				str = s.name .. " " .. strPercentage .. "%"
			else
				str = s.name
			end
		
			love.graphics.print(str, x+(bgBox:getWidth()-FONT_BUTTON:getWidth(str))/2, y + 15)
			y = y + bgBox:getHeight()-7
			
			love.graphics.setFont(FONT_STANDARD)
			for i = 1, #s.subSections do
				love.graphics.draw(bgBoxSmall, x+50, y)
				love.graphics.print(s.subSections[i], x+50+(bgBoxSmall:getWidth()-FONT_STANDARD:getWidth(s.subSections[i]))/2, y + 8)
				y = y + bgBoxSmall:getHeight()-7
			end
			y = y + 7
		end
	else
		love.graphics.setFont(FONT_STANDARD)
		love.graphics.print("Loading... Generating new images (only has to be done once)", 10, 20)
		t = love.thread.getThreads()
		num = 0
		for k, v in pairs(t) do
			num = num + 1
		end
		love.graphics.print(num .. " threads running", 20, 40)
		x = 30
		y = 40
		love.graphics.setFont(FONT_CONSOLE)
		for k,s in pairs(sectionList) do
			y = y + 20
			str = ""
			if s.percentage > 0 then
				strPercentage = tostring(math.floor(10*s.percentage)/10)
				if #strPercentage <= 2 then strPercentage = strPercentage .. ".0" end
				str = s.name .. " " .. strPercentage .. "%"
			else
				str = s.name
			end
		
			love.graphics.print(str, x, y)
			
			for i = 1, #s.subSections do
				y = y + 15
				love.graphics.print(s.subSections[i], x+50, y)
			end
		end
	end
	
	--if trainGenerateThreads > 0 then
	
	--end
end

local bgBoxThread

function loadingScreen.init(maxNumThreads)
	local initialMaxNumThreads = maxNumThreads
	
	if not bgBoxThread and not bgBox then		-- only start thread once!
		if not CL_FORCE_RENDER then
			ok, bgBox = pcall(love.graphics.newImage, "bgBox.png")
			if not ok then bgBox = nil end
		end
		if (not ok or not versionCheck.getMatch() or CL_FORCE_RENDER) and maxNumThreads > 0 then
		
			maxNumThreads = maxNumThreads - 1
			
			bgBox = nil
			loadingScreen.addSection("Rendering Loading Box")
			bgBoxThread = love.thread.newThread("bgBoxThread", "Scripts/renderImageBox.lua")
			bgBoxThread:start()
	
			bgBoxThread:set("width", BOX_WIDTH )
			bgBoxThread:set("height", BOX_HEIGHT )
			bgBoxThread:set("shadow", true )
			bgBoxThread:set("shadowOffsetX", 6 )
			bgBoxThread:set("shadowOffsetY", 1 )
			bgBoxThread:set("colR", LOAD_BOX_LARGE_R )
			bgBoxThread:set("colG", LOAD_BOX_LARGE_G )
			bgBoxThread:set("colB", LOAD_BOX_LARGE_B )
		end
	else
		if not bgBox then	-- if there's no button yet, that means the thread is still running...
		
			percent = bgBoxThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Loading Box", percent)
			end
			err = bgBoxThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
			status = bgBoxThread:get("status")
			if status == "done" then
				bgBox = bgBoxThread:get("imageData")		-- get the generated image data from the thread
				bgBox:encode("bgBox.png")
				bgBox = love.graphics.newImage(bgBox)
				bgBoxThread:wait()
				bgBoxThread = nil
				
				maxNumThreads = maxNumThreads + 1
			end
		end
	end
	
	if not bgBoxSmallThread and not bgBoxSmall then		-- only start thread once!
		if not CL_FORCE_RENDER then
			ok, bgBoxSmall = pcall(love.graphics.newImage, "bgBoxSmall.png")
			if not ok then bgBoxSmall = nil end
		end
		if (not ok or not versionCheck.getMatch() or CL_FORCE_RENDER) and maxNumThreads > 0 then
		
			maxNumThreads = maxNumThreads - 1
			
			bgBoxSmall = nil
			loadingScreen.addSection("Rendering Loading Box (small)")
			bgBoxSmallThread = love.thread.newThread("bgBoxSmallThread", "Scripts/renderImageBox.lua")
			bgBoxSmallThread:start()
	
			bgBoxSmallThread:set("width", BOX_WIDTH_SMALL )
			bgBoxSmallThread:set("height", BOX_HEIGHT_SMALL )
			bgBoxSmallThread:set("shadow", true )
			bgBoxSmallThread:set("shadowOffsetX", 6 )
			bgBoxSmallThread:set("shadowOffsetY", 1 )
			bgBoxSmallThread:set("colR", LOAD_BOX_SMALL_R )
			bgBoxSmallThread:set("colG", LOAD_BOX_SMALL_G )
			bgBoxSmallThread:set("colB", LOAD_BOX_SMALL_B )
		end
	else
		if not bgBoxSmall then	-- if there's no button yet, that means the thread is still running...
		
			percent = bgBoxSmallThread:get("percentage")
			if percent then
				loadingScreen.percentage("Rendering Loading Box (small)", percent)
			end
			err = bgBoxSmallThread:get("error")
			if err then
				print("Error in thread:", err)
			end
		
			status = bgBoxSmallThread:get("status")
			if status == "done" then
				bgBoxSmall = bgBoxSmallThread:get("imageData")		-- get the generated image data from the thread
				bgBoxSmall:encode("bgBoxSmall.png")
				bgBoxSmall = love.graphics.newImage(bgBoxSmall)
				bgBoxSmallThread:wait()
				bgBoxSmallThread = nil
				
				maxNumThreads = maxNumThreads + 1
			end
		end
	end
	
	return initialMaxNumThreads - maxNumThreads 	-- return how many threads have been started or removed
end

function loadingScreen.initialised()
	if bgBox and bgBoxSmall then
		return true
	end
end

return loadingScreen
