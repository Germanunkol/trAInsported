
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

local yAxisHeight = 0

function addAttribute(str, name, value)
	if not value or not name then return str end
	return str .. name .. '="' .. value .. '" '
end

function lineToSVG(x1,y1,x2,y2,color,width,animationTimeOffset,animationSpeed)
	local s
	
	if animationTimeOffset and animationSpeed then
		s = '\t<line '
		s = addAttribute(s, "x1", x1)
		s = addAttribute(s, "x2", x1)
		s = addAttribute(s, "y1", y1)
		s = addAttribute(s, "y2", y1)
		s = addAttribute(s, "stroke", color)
		s = addAttribute(s, "stroke-width", width)
		s = addAttribute(s, "display", "none")
		s = s .. '>\n'
		s = s .. '\t\t<set attributeName="display" to="inline" begin="' .. animationTimeOffset .. '" />\n'
		s = s .. '\t\t<animate attributeType="XML" attributeName="x2" from="' .. x1 .. '" to="' .. x2 .. '" dur="' .. animationSpeed .. 's" begin="' .. animationTimeOffset .. 's" fill="freeze" />\n'
		s = s .. '\t\t<animate attributeType="XML" attributeName="y2" from="' .. y1 .. '" to="' .. y2 .. '" dur="' .. animationSpeed .. 's" begin="' .. animationTimeOffset .. 's" fill="freeze" />\n'
		s = s .. '\t</line>\n'
	else
		s = '\t<line '
		s = addAttribute(s, "x1", x1)
		s = addAttribute(s, "x2", x2)
		s = addAttribute(s, "y1", y1)
		s = addAttribute(s, "y2", y2)
		s = addAttribute(s, "stroke", color)
		s = addAttribute(s, "stroke-width", width)
		s = s .. '/>\n'
	end
	
	return s
end

function boxToSVG(xPos, yPos, width, height, color, animationTimeOffset, animationSpeed)
	local s
	if animationTimeOffset and animationSpeed then
		s = '\t<rect '
		s = addAttribute(s, "x", xPos - width/2)
		s = addAttribute(s, "y", yPos)
		s = addAttribute(s, "height", 0)
		s = addAttribute(s, "width", width)
		s = addAttribute(s, "fill", color or "white")
		s = addAttribute(s, "stroke-width", 1)
		s = addAttribute(s, "stroke", "black")
		s = addAttribute(s, "style", "opacity:0.7")
		s = addAttribute(s, "display", "none")
		s = s .. '>\n'
		s = s .. '\t<set attributeName="display" to="inline" begin="' .. animationTimeOffset .. '" />\n'
		s = s .. '\t\t<animate attributeType="XML" attributeName="y" from="' .. yPos .. '" to="' .. yPos-height .. '" dur="' .. animationSpeed .. 's" begin="' .. animationTimeOffset .. 's" fill="freeze" />\n'
		s = s .. '\t\t<animate attributeType="XML" attributeName="height" from="' .. 0 .. '" to="' .. height .. '" dur="' .. animationSpeed .. 's" begin="' .. animationTimeOffset .. 's" fill="freeze" />\n'
		s = s .. '\t</rect>\n'
	else
		s = '\t<rect '
		s = addAttribute(s, "x", xPos - width/2)
		s = addAttribute(s, "y", yPos-height)
		s = addAttribute(s, "height", height)
		s = addAttribute(s, "width", width)
		s = addAttribute(s, "fill", color)
		s = addAttribute(s, "stroke-width", 1)
		s = addAttribute(s, "stroke", "black")
		s = addAttribute(s, "style", "opacity:0.5")
		s = s .. '/>\n'
	end
	
	return s
end

function textToSVG(x, y, size, text, align, rotate, color, boxLabel)
	local s = ""
	
	if boxLabel then
		s = s .. '\t<rect id="' .. boxLabel .. '-box" x="' .. x-5 .. '" y = "' .. y-10 .. '" border-radius="10" rx="5" ry="5" width="100" height="14" fill="#523E34" stroke-width="1" stroke="black"  style="opacity:0.5"/>\n'
	end
	
	s = s .. "\t<text "
	s = addAttribute(s, "x", x)
	s = addAttribute(s, "y", y)
	s = addAttribute(s, "font-size", size)
	if boxLabel then
		s = addAttribute(s, "id", boxLabel)
	end
	if align and align == "right" then
		s = addAttribute(s, "text-anchor", "end")
	end
	if rotate then
		s = addAttribute(s, "transform", "rotate(" .. rotate .. "," .. x .. "," .. y .. ")")
	end
	if not color then color = "white" end
	s = addAttribute(s, "fill", color)
	if not boxLabel then
		s = s .. "> " .. text .. " </text>\n"
	else
		s = s .. '>\n\t\t<tspan id="tspan1">' .. text .. " </tspan>\n\t</text>\n"
	end
	
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
	local stepSize = math.floor(math.max(h/10, 30))
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
	
	yAxisHeight = height-paddingBottom
	
	return s
end

function writeCoordinateSystemBarGraph(width, height, maxY)
	local s = ""	
	s = s .. "\n<!-- Coordinate System: -->\n"
	
	local h = (height-paddingBottom-paddingTop)
	local stepSize = math.floor(math.max(h/10, 30))
	for y = paddingTop, height-paddingBottom, stepSize do
		if (h-(y-paddingTop)) > 0 then
			s = s .. "\t" .. lineToSVG(paddingLeft, y, width-paddingRight, y, "grey", 1)
			s = s .. "\t" .. textToSVG(paddingLeft-4, y+2, 10, math.floor((h-(y-paddingTop))/h*maxY), "right", nil, "white")
		end
	end
	
	s = s .. "\n"
	s = s .. "<!-- Axis: -->\n"
	
	s = s .. "\t" .. lineToSVG(paddingLeft, height-paddingBottom, width-paddingRight, height-paddingBottom, "white", 3)
	s = s .. "\t" .. lineToSVG(paddingLeft, paddingTop, paddingLeft, height-paddingBottom, "white", 3)
	
	yAxisHeight = height-paddingBottom
	
	return s
end

-- a function that will add a script to the file which can draw the borders around the texts elements.
function writeBorderScript(points)
	local s = [[
	<script type="text/ecmascript">
		function add_bounding_box (text_id, padding) {
			var text_elem = document.getElementById(text_id);
			if (text_elem) {
				var t = text_elem.getClientRects();
				var r = document.getElementById(text_id + '-box');
				if (t) {
					if (r) {
				    r.setAttribute('x', t[0].left - padding);
					r.setAttribute('y', t[0].top - padding);
					r.setAttribute('width', t[0].width + padding * 2);
					r.setAttribute('height', t[0].height + padding * 2);
				    }
				}
			}
		}
		]]
		
	for k, p in pairs(points) do
		s = s .. "\n\t\tadd_bounding_box('" .. p.name .."', 2);"
	end
	s = s .. "\n\t</script>\n"
	return s
end

function chart.generate(fileName, width, height, points, xLabel, yLabel, style, animationTime)
	-- don't allow an empty list. At least one set of data is needed:
	if #points < 1 then return end
	
	
	-- setup defaults:
	animationTime = animationTime or 5
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
		-- scale all data to fit onto the chart:
		for i=1,#points do
			points[i][#points[i]+1] = {x=maxX, y = points[i][#points[i]].y}		-- add horizontal line after last node!
			for j=1,#points[i] do
				points[i][j].x = paddingLeft + (width-paddingLeft-paddingRight)*points[i][j].x/maxX
				points[i][j].y = (height-paddingBottom-paddingTop)*(maxY-points[i][j].y)/maxY + paddingTop
			end
		end
		
		chartContent = chartContent .. writeCoordinateSystem(width, height, maxX, maxY)
		if yLabel then
			chartContent = chartContent .. textToSVG(15, paddingTop, 12, yLabel, "right", -90)
		end
		if xLabel then
			chartContent = chartContent .. textToSVG(width-paddingRight, height-10, 12, xLabel, "right")
		end
		
		animTime = 0
		
		for i=1,#points do
			chartContent = chartContent .. "\n<!-- Data Set " .. i .. " -->\n"
			animSpeed = 2/#points[i]
			for j=1,#points[i]-1 do
				animTime = animTime + animSpeed
				chartContent = chartContent .. "\t" .. lineToSVG(points[i][j].x, points[i][j].y, points[i][j+1].x, points[i][j+1].y, color[i], 2, animTime, animSpeed)
			end
			animTime = animTime + .5
		end
		
		local x = paddingLeft + 10
		local y = paddingTop
		for i=1,#points do	-- label all the lines:
			if points[i].name and #points[i] > 1 then
				chartContent = chartContent .. textToSVG(x, y, 12, points[i].name, "left", nil, color[i], points[i].name)
				y = y + 16
			end
		end
		
		chartContent = chartContent .. writeBorderScript(points)
		chartContent = chartContent .. "</svg>\n"
	elseif style == "bar" then
	
		maxY = 1
		for i=1,#points do
			maxY = math.max(maxY, points[i].height)
		end
		chartContent = chartContent .. writeCoordinateSystemBarGraph(width, height, maxY)
		if yLabel then
			chartContent = chartContent .. textToSVG(15, paddingTop, 12, yLabel, "right", -90)
		end
		if xLabel then
			chartContent = chartContent .. textToSVG(width-paddingRight, height-10, 12, xLabel, "right")
		end
		
		w = (width-paddingRight-paddingLeft)/(#points+1)
		xPos = w + paddingLeft
		for i=1,#points do
			h = points[i].height*(height-paddingTop-paddingBottom)/maxY
			c = points[i].color or color[i%4 + 1]
			chartContent = chartContent .. boxToSVG(xPos, height-paddingBottom, w/2, h, c, (i-1)*(.5), 1)
			chartContent = chartContent .. textToSVG(xPos+6, height-paddingBottom-10, 12, points[i].name, "left", -90)
			if points[i].rank then
				chartContent = chartContent .. textToSVG(xPos-10, height-paddingBottom+15, 12, points[i].rank, "left", nil)
			end
			xPos = xPos + w
		end
		
		local x = paddingLeft + 10
		local y = paddingTop
		for i=1,#points do	-- label all the lines:
			if points[i].name and #points[i] > 1 then
				local lastX = x + math.random(10)
				chartContent = chartContent .. textToSVG(lastX, y, 12, points[i].name, "left", nil, color[i], points[i].name)
				y = y + 16
			end
		end
		
		chartContent = chartContent .. "</svg>\n"
	end
	
	file = io.open(fileName, "w")
	if file then
		file:write(chartContent)
		file:close()
	end
	
	return chartContent
end

return chart
