local loadingScreen = {}

local sectionList = {}

local bgBox = nil
local bgBoxSmall = nil

function loadingScreen.init()
	bgBox = createBoxImage(400,50,true, 10, 0, 32,80,50)
	bgBoxSmall = createBoxImage(300,30,true, 10, 0, 32,80,50)
end

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

	x = (love.graphics.getWidth()-bgBox:getWidth())/2
	y = love.graphics.getHeight()/4 - 20
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
		y = y + bgBox:getHeight()
		
		love.graphics.setFont(FONT_STANDARD)
		for i = 1, #s.subSections do
			love.graphics.draw(bgBoxSmall, x+50, y)
			love.graphics.print(s.subSections[i], x+50+(bgBoxSmall:getWidth()-FONT_STANDARD:getWidth(s.subSections[i]))/2, y + 8)
			y = y + bgBoxSmall:getHeight()
		end
	end
end
return loadingScreen
