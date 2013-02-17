local console = {}

local consoleLines = {}


local consoleStartLine = 1

function console.show()
	e = math.min(#consoleLines, consoleStartLine+console.numLines)
	love.graphics.setFont(FONT_CONSOLE)
	for i = consoleStartLine,e do
		love.graphics.setColor(consoleLines[i].colour.r,consoleLines[i].colour.g,consoleLines[i].colour.b, 255)
		love.graphics.print(consoleLines[i].str, 20, console.y + (i-consoleStartLine)*FONT_CONSOLE:getHeight() )
	end
end

function console.add( text, colour )
	if DEDICATED then
		return
	end
	
	local nextLine = nil
	newLinePos = text:find("\n")
	if newLinePos then
		nextLine = text:sub(newLinePos+1, #text)
		text = text:sub(1, newLinePos-1)
	end
	
	local str = ""
	if colour == nil then colour = {r=255,g=255,b=255} end
	
	if tutorial and tutorial.consoleEvent then		-- if the tutorial has registered an event for me, run it now.
		tutorial.consoleEvent(text)
	end
	
	for c in text:gfind(".") do
		if c == "\t" then
			str = str .. "   "
		else
			str = str .. c
		end
		if FONT_CONSOLE:getWidth(str) > console.width - 40 then
			consoleLines[#consoleLines+1] = {}
			consoleLines[#consoleLines].str = str
			consoleLines[#consoleLines].colour = colour
			str = ""
		end
	end
	if #str ~= 0 then
		consoleLines[#consoleLines+1] = {}
		consoleLines[#consoleLines].str = str
		consoleLines[#consoleLines].colour = colour
	end
	
	consoleStartLine = math.floor(math.max(#consoleLines - console.numLines, 1))
	
	print("C:", text)
	if nextLine then
		console.add( nextLine, colour )
	end
end

function console.flush()
	consoleLines = {}
	consoleStartLine = 1
end

function console.toggle()
	if showConsole then
		showConsole = false
	else
		showConsole = true
	end
end

function console.setVisible(vis)
	if vis then
		showConsole = true
	else
		showConsole = false
	end
end

function console.init(width, y)
	console.y = y
	console.width = width
	console.numLines = (love.graphics.getHeight()-y)/FONT_CONSOLE:getHeight()-1
	consoleStartLine = 1
	consoleLines = {}
end

return console
