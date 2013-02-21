local chart = {}

local color = {}
color[1] = "red"
color[2] = "green"
color[3] = "yellow"
color[4] = "orange"

backgroundColor = "#321E14"

local paddingLeft = 45
local paddingBottom = 40
local paddingTop = 30
local paddingRight = 45

function addAttribute(str, name, value)
	if not value or not name then return str end
	return str .. name .. '="' .. value .. '" '
end

function lineToSVG(x1,y1,x2,y2,color,width,animationTimeOffset,animationSpeed)
	local s = '<line '
	s = addAttribute(s, "x1", x1)
	s = addAttribute(s, "x2", x2)
	s = addAttribute(s, "y1", y1)
	s = addAttribute(s, "y2", y2)
	s = addAttribute(s, "stroke", color)
	s = addAttribute(s, "stroke-width", width)
	s = s .. '/>\n'
	
	if animationTimeOffset and animationSpeed then
	
	end
	
	return s
end

function textToSVG(x, y, size, text, align, rotate, color)
	local s = "<text "
	s = addAttribute(s, "x", x)
	s = addAttribute(s, "y", y)
	s = addAttribute(s, "font-size", size)
	if align and align == "right" then
		s = addAttribute(s, "text-anchor", "end")
	end
	if rotate then
		s = addAttribute(s, "transform", "rotate(" .. rotate .. "," .. x .. "," .. y .. ")")
	end
	if not color then color = "white" end
	s = addAttribute(s, "fill", color)
	s = s .. "> " .. text .. " </text>\n"
	return s
end

function sortPoints(a,b)
	if a and b then
		if a.x ~= b.x then
			return a.x < b.x
		else
			return a.y < b.y
		end
	end
end

function writeHeader(width, height)
	s ='<?xml version="1.0" standalone="no"?>\n'
	s = s .. '<svg width="' .. width .. '" height="' .. height .. '" viewBox="0 0 ' .. width .. ' ' .. height .. '" xmlns="http://www.w3.org/2000/svg" version="1.1"\n'
	s = s .. 'xmlns:xlink="http://www.w3.org/1999/xlink">\n'
	s = s .. '\n\n<!-- Generate background: -->\n\t<rect x="1" y="1" border-radius="10" rx="20" ry="20" width="' .. width - 2 .. '" height="' .. height -2 .. '" fill="' .. backgroundColor .. '" stroke-width="1" stroke="black" />\n'
	return s
end

function writeCoordinateSystem(width, height, maxX, maxY)
	local s = ""
	
	s = s .. "\n<!-- Coordinate System: -->\n"
	
	local h = (height-paddingBottom-paddingTop)
	local stepSize = math.max(h/10, 30)
	for y = paddingTop, height-paddingBottom, stepSize do
		if (h-(y-paddingTop)) > 0 then
			s = s .. "\t" .. lineToSVG(paddingLeft, y, width-paddingRight, y, "grey", 1)
			s = s .. "\t" .. textToSVG(paddingLeft-4, y+2, 10, math.floor((h-(y-paddingTop))/h*maxY), "right", nil, "white")
		end
	end
	
	local w = width-paddingLeft-paddingRight
	local stepSize = math.max(w/10, 40)
	for x = paddingLeft, width-paddingRight, stepSize do
		s = s .. "\t" .. textToSVG(x, height-paddingBottom + 15, 10, math.floor((x-paddingLeft)/w*maxX), "right", nil, "white")
	end
	
	s = s .. "\n"
	s = s .. "<!-- Axis: -->\n"
	
	s = s .. "\t" .. lineToSVG(paddingLeft, height-paddingBottom, width-paddingRight, height-paddingBottom, "white", 3)
	s = s .. "\t" .. lineToSVG(paddingLeft, paddingTop, paddingLeft, height-paddingBottom, "white", 3)
	
	return s
end

function chart.generate(fileName, width, height, points, xLabel, yLabel, style, animationTime)
	-- don't allow an empty list. At least one set of data is needed:
	if #points < 1 then return end
	
	-- setup defaults:
	animationTime = animationTime or 0
	style = style or "line"
	
	-- sort list by x, then by y:
	for i=1,#points do
		table.sort(points[i], sortPoints)
	end
	
	local chartContent = writeHeader(width, height)
	
	if style == "line" then
	
		maxX = 1
		maxY = 1
		for i=1,#points do
			if points[i][#points[i]] then
				maxX = math.max(points[i][#points[i]].x, maxX) -- enough, because list was sorted by x
			end
			for j=1,#points[i] do
				maxY = math.max(points[i][j].y, maxY)
			end
		end
		print("MAX: ", maxX, maxY)
		-- scale all data to fit onto the chart:
		for i=1,#points do
			for j=1,#points[i] do
				points[i][j].x = paddingLeft + (width-paddingLeft-paddingRight)*points[i][j].x/maxX
				points[i][j].y = (height-paddingBottom-paddingTop)*(maxY-points[i][j].y)/maxY + paddingTop
			end
		end
		
		chartContent = chartContent .. writeCoordinateSystem(width, height, maxX, maxY)
		chartContent = chartContent .. textToSVG(15, paddingTop, 12, yLabel, "right", -90)
		chartContent = chartContent .. textToSVG(width-paddingRight, height-10, 12, xLabel, "right")
		
		animSpeed = animationTime*width/maxX
		
		for i=1,#points do
			chartContent = chartContent .. "\n<!-- Data Set " .. i .. " -->\n"
			for j=1,#points[i]-1 do
				animTime = animationTime*points[i][j+1].x/maxX	--could be 0
				chartContent = chartContent .. "\t" .. lineToSVG(points[i][j].x, points[i][j].y, points[i][j+1].x, points[i][j+1].y, color[i], 2, animTime, animSpeed)
			end
			if points[i][#points[i]] and points[i].name and #points[i] > 1 then
				local lastX = points[i][#points[i]].x
				local lastY = points[i][#points[i]].y
				chartContent = chartContent .. textToSVG(lastX, lastY, 12, points[i].name, "right", nil, color[i])
			end
		end
		
		chartContent = chartContent .. "</svg>\n"
		
	end
	
	file = io.open(fileName, "w")
	if file then
		file:write(chartContent)
		file:close()
	end
end

return chart
