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
	--if not initialising then
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
	--[[else
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
	
	--end]]
end

function loadingScreen.init(maxNumThreads)
	bgBox = love.graphics.newImage( "Images/bgBox.png" )
	bgBoxSmall = love.graphics.newImage( "Images/bgBoxSmall.png")
end

return loadingScreen
