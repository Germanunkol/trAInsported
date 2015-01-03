local console = {}

local consoleLines = {}


local consoleStartLine = 1

function console.show()
	e = math.min(#consoleLines, consoleStartLine+console.numLines)
	love.graphics.setFont(FONT_CONSOLE)
	for i = consoleStartLine,e do
		love.graphics.setColor(consoleLines[i].colour.r,consoleLines[i].colour.g,consoleLines[i].colour.b, 255)
		love.graphics.print( consoleLines[i].str, 20, console.y + (i-consoleStartLine)*FONT_CONSOLE:getHeight() )
	end
end

function console.add( text, colour )
	if DEDICATED then
		return
	end

	if not type(text) == "string" then error("Passing wrong arguments to function console.add!") end

	colour = type(colour) == "table" and colour or {r=255,g=255,b=255}
	
	local nextLine = nil
	newLinePos = text:find("\n")
	if newLinePos then
		nextLine = text:sub(newLinePos+1, #text)
		text = text:sub(1, newLinePos-1)
	end
	
	local str = ""
	
	if tutorial and tutorial.consoleEvent then		-- if the tutorial has registered an event for me, run it now.
		tutorial.consoleEvent(text)
	end
	
	-- workaround! Maybe make this better:
	if #consoleLines > 2000 then
		for k = 200,1 do
			consoleLines[k] = consoleLines[#consoleLines]
			consoleLines[#consoleLines] = nil
		end
		linesToDelete = #consoleLines
		for k = linesToDelete, 201 do
			consoleLines[linesToDelete] = nil
		end
	end
	
    print(type(text))
	for c in text:gmatch(".") do
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
	if not DEDICATED then
		print("C:", text)
	end
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
