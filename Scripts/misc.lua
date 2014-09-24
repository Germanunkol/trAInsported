
timeFactorIndex = 5
timeFactorList = {0, 0.1, 0.2, 0.5, 1, 2, 5, 10, 20, 40, 90}

function resetTimeFactor()
	for k, v in pairs(timeFactorList) do
		if v == 1 then
			timeFactorIndex = k
		end
	end
	timeFactor = timeFactorList[timeFactorIndex]
end


---------------------------------------
-- scan a directory and return all the file names in as a table of strings:
function scandir(directory)
	local i, t = 0, {}
	
	if not DEDICATED then
		t = love.filesystem.getDirectoryItems("AI")
	end
	
	if #t < 1 then
		ok, test = pcall(io.popen,".")
		if ok then
			if love._os == "Windows" then		-- assume unix!
				for filename in io.popen('dir "'..directory ..'" /B'):lines() do
					i = i + 1
		
					_, pos = filename:find(".* ")		-- find last occurance of space
					pos = pos or 0
					t[i] = filename:sub(pos+1, #filename)
					print("dir returned:", filename)
				end
			else
				for filename in io.popen('ls "'..directory..'"'):lines() do
					i = i + 1
					t[i] = filename
					--print("ls -a returned:", filename)
				end
			end
		end
	end
	return t
end

---------------------------------------
-- Attempt to open a file browser with the AI folder.
function openAIFolder()
	if love._os == "OS X" then
		os.execute("open " .. AI_DIRECTORY)
	elseif love._os == "Windows" then
		os.execute("explorer  %appdata%\\LOVE\\trAInsported\\AI")
	else
		os.execute("xdg-open " .. AI_DIRECTORY)
	end
end
---------------------------------------
-- Attempt to open browser:
function openIssuesPage()
	if love._os == "OS X" then
		os.execute("open https://github.com/Germanunkol/trAInsported/issues")
	elseif love._os == "Windows" then
		os.execute("start https://github.com/Germanunkol/trAInsported/issues")
	else
		os.execute("xdg-open https://github.com/Germanunkol/trAInsported/issues")
	end
end
---------------------------------------
-- 
function reportToClipboard( msg )
	love.system.setClipboardText( msg )
end
--------------------------------------

function createTrainCopy(train)
	local tr = {ID=train.ID, name=train.name, x=train.tileX, y=train.tileY, dir=train.dir, nextX=train.nextX, nextY=train.nextY}		-- don't give the original data to the ai!
	if train.curPassenger then
		tr.passenger = {name = train.curPassenger.name, destX = train.curPassenger.destX, destY = train.curPassenger.destY}
	end
	return tr
end


---------------------------------------
-- Load screen res, etc from config file:
function loadConfiguration()
	
	x, y = configFile.getValue("resolution_x"), configFile.getValue("resolution_y")
	local resSet

	if x and y then
		print("Found resolution:",x,y)
		success = love.window.setMode( x, y )
		if success then
			resSet = true
		end
	end
	
	-- backup:
	if not resSet then
		print("Setting resolution to default values because no configuration has been found: ", DEFAULT_RES_X .. "x" .. DEFAULT_RES_Y)
		love.window.setMode(  DEFAULT_RES_X,  DEFAULT_RES_Y )
	end
	
	local clouds = configFile.getValue("render_clouds")
	if clouds == "true" then
		RENDER_CLOUDS = true
	end
	if clouds == "false" then
		RENDER_CLOUDS = false
	end

	local fullscreen = configFile.getValue("fullscreen")
	if fullscreen == "true" then
		FULLSCREEN = true
		love.window.setFullscreen(true, "desktop")
	end
	if fullscreen == "false" then
		FULLSCREEN = false
		love.window.setFullscreen(false, "desktop")
	end
end


function selectLanguage(lang)
	print("Loading language file: Languages/" .. lang .. ".lua")
	ok, chunk = pcall(love.filesystem.load, "Languages/" .. lang .. ".lua")
	if ok then
		setupFonts()	-- reset them all incase the previous language changed them!
		ok, msg = pcall(chunk)
		if ok then	
			CURRENT_LANGUAGE = lang
			return true
		else
			print(msg)
		end
	else
		print(chunk)
	end
end


---------------------------------------


function findOneOf(str, s, ...)
	start = s or 1
	local results = {}
	local arg = { ... }
	for i=1,#arg do
		local s,e, pattern = str:find("(" .. arg[i] .. ")", start)
		if s then
			results[#results+1] = {s = s, e=e, pattern = pattern}
		end
	end
	
	table.sort(results, function (a, b)
							return a.s < b.s
						end )
	if results[1] then
		return results[1].s, results[1].e, results[1].pattern
	else
		return nil
	end
end


function parseCode(str)

	-- replace tabs with spaces!
	while str:find("	") do
		s,e = str:find("	")
		
		-- place spaces:
		str = str:sub(1, s-1) .. "     " .. str:sub(e+1, #str)
	end
	
	-- seperate into lines:
	n = 1
	local text = {}
	while str:find("\n") do
		s = str:find("\n")
		--print(n, str:sub(1, s-1))
		text[n] = {fullLine = str:sub(1, s-1)}
		str = str:sub(s+1, #str)
		n = n+1
	end
	
	-- go through all lines and highlight all keywords.
	local l = 1
	while l < n do
		local s,e,p = findOneOf(text[l].fullLine, nil, "%-%-", "function", "end", "elseif", "if", "while", "for", "do", "then", "else", "return", "print")
		
		while s do
			if p == "--" then		-- if a comment was found
				if string.len(text[l].fullLine:sub(1, s-1)) > 0 then
					text[l][#text[l]+1] = {str = text[l].fullLine:sub(1, s-1), font = FONT_CODE_PLAIN, f = "plain"}
				end
				text[l][#text[l]+1] = {str = text[l].fullLine:sub(s, #text[l].fullLine), font = FONT_CODE_COMMENT,f = "comment"}
				text[l].fullLine = ""
				
				break	-- comment ALWAYS ends the line
			else
				if string.len(text[l].fullLine:sub(1, s-1)) > 0 then
					text[l][#text[l]+1] = {str = text[l].fullLine:sub(1, s-1), font = FONT_CODE_PLAIN, f = "plain"}
				end
				text[l][#text[l]+1] = {str = p, font = FONT_CODE_BOLD, f = "bold"}
				
				text[l].fullLine = text[l].fullLine:sub(e+1, #text[l].fullLine)
			
				s,e,p = findOneOf(text[l].fullLine, 1, "%-%-", "function", "end", "elseif", "if", "while", "for", "do", "then", "else", "return", "print")
			end
		end
		
	--	if string.len(text[l].fullLine) > 0 then
			text[l][#text[l]+1] = {str = text[l].fullLine, font = FONT_CODE_PLAIN}		-- anything remaining in the string should be put in here.
	--	end
		text[l].fullLine = nil		--no longer needed.
		l = l+1
	end
	
	-- lastly, calculate the actual width each string will take.
	l = 1
	while l < n do
		local x = 0
		for i = 1,#text[l] do
			text[l][i].x = x
			text[l][i].width = text[l][i].font:getWidth(text[l][i].str)
			x = x + text[l][i].width
		end
		l = l + 1
	end
	
	return text
end

function seperateStrings(str)
	tbl = {}
	index = 1
	
	if str:sub(#str,#str) ~= "," then		-- gfind will not capture a substring unless there's a comma following
		str = str .. ","
	end
	
	for val in string.gfind(str, ".-,") do
		tbl[index] = val:sub(1,#val-1)
		pos = #val+1
		index = index + 1
	end
	return tbl
end

function makeTimeReadable(time)
	days = math.floor(time/(60*60*24))
	time = time - days*60*60*24
	hours = math.floor(time/(60*60))
	time = time - hours*60*60
	minutes = math.floor(time/(60))
	time = time - minutes*60
	seconds = time
	
	local str = ""
	if days > 0 then str = str .. days .. " " .. LNG.days .. " " end
	if hours > 0 then str = str .. hours .. " " .. LNG.hours .. " "end
	if minutes > 0 then str = str .. minutes .. " " .. LNG.minutes .. " " end
	if seconds > 0 then str = str .. math.floor(seconds) .. " " .. LNG.seconds .. " " end
	return str
end




------------------------------------
-- Thread utilities:
function incrementID( num )
	if num == 99999 then
		num = 0
	else
		num = num + 1
	end
	return num
end

--[[
function threadSendStatus( channel, status )
	if not statusNum then
		statusNum = 0
	end
	t:set("status".. statusNum, status)
	statusNum = incrementID(statusNum)
end]]

local CPU_NUMBER

function getCPUNumber()
	if not CPU_NUMBER then
		if love._os == "OS X" then
			if love.filesystem.isFile("coresDetected.txt") then
				local corestxt = love.filesystem.read("coresDetected.txt")
				CPU_NUMBER = tonumber(corestxt)
			else
				os.execute(string.format("%s > %q", "sysctl -n hw.ncpu", love.filesystem.getSaveDirectory() .. "/coresDetected.txt"))

				if love.filesystem.isFile("coresDetected.txt") then
					local corestxt = love.filesystem.read("coresDetected.txt")
					CPU_NUMBER = tonumber(corestxt)
				end
			end
		elseif love._os == "Windows" then
			if io.popen then
				f = assert(io.popen("wmic cpu get NumberOfCores"))
				local content = assert(f:read("*a"))
				local i = 1
				for line in content:gmatch("%d+") do
					CPU_NUMBER = tonumber(line)
				end
				f:close()
				--if content then
				--	print(content)
				--end
			end
		else			-- linux:
			ok, f = pcall(io.popen,"nproc")
			if ok and f then
				local n = f:read("*a")
				f:close()
				CPU_NUMBER = tonumber(n)
			end
		end
	end
	return CPU_NUMBER
end
------------------------------------



function clamp(x, min, max)
	return math.max(math.min(x, max), min)
end

function cycle(x, min, max)
	y = math.floor(x/(max-min))-1
	if y > 1 then
		x = x - y*(max-min)
	end
	while x > max do
		x = x - (max-min)
	end
	while x < min do
		x = x + (max-min)
	end
	return x
end

function getPlayerColour(ID)
	if ID == 1 then
		return PLAYERCOLOUR1_CONSOLE
	end
	if ID == 2 then
		return PLAYERCOLOUR2_CONSOLE
	end
	if ID == 3 then
		return PLAYERCOLOUR3_CONSOLE
	end
	if ID == 4 then
		return PLAYERCOLOUR4_CONSOLE
	end
end

function dropAlpha(x,y,r,g,b,a)
	return r,g,b,255
end

function vonNeumannRandom(seed)		-- generates a random number using the von Neumann method.
	str = tostring(seed^2)
	while #str < 7 do
		str = "0" .. str
	end
	return tonumber(str:sub(2,6))
end


-- new random generator:
do
	local p = 7907 -- 11 in wikipedia example, but has a too short cycle
	local q = 7919 -- 19 in wikipedia example
	local s = 3
	local xn = s

	assert(p%4==3)
	assert(q%4==3)

	function randombit()
		xn = xn^2 % p*q
		return xn % 2
	end

	function myRandomseed(seed)
		xn = seed
	end

	function myRandom(a, b)
		local n = 0
		for i=0,31 do
			n = n*2 + randombit()
		end


		if not a and not b then
			return n/4294967295	-- 4294967295 is the largest number possible
		elseif not b then
			a,b = 1,a
		end
		
		if a > b then
			error("Invalid range in random function" .. a .. b)
		end
		
		
		diff = b-a + 1
		n = a + n % diff
		
		return n
	end
end

function generateColour(name, brightness)
	brightness = brightness or 1
	sum = 0
	for i = 1,#name do
		sum = sum + name:byte(i,i)
	end
	myRandomseed(sum)
	--_ = vonNeumannRandom(sum)		--discard first number, it's usually too similar.
	--__ = vonNeumannRandom(_)		--discard first number, it's usually too similar.
	--___ = vonNeumannRandom(__)		--discard first number, it's usually too similar.
	red = myRandom(0,255)
	green = myRandom(0,255)
	blue = myRandom(0,255)
	return {r=clamp(red*brightness, 0, 255), g=clamp(green*brightness, 0, 255), b=clamp(blue*brightness, 0, 255)}
end

function getScreenshot()
	local curTime = os.date("*t")
	local fileName
	if curTime then
		fileName = curTime.year .."-".. curTime.month .."-".. curTime.day .. "_" .. curTime.hour .."-".. curTime.min .."-".. curTime.sec .. ".png"
	else
		fileName = math.random(99999)
	end

	timeFactor = timeFactorList[1]
	functionQueue.new(2, function () timeFactor = timeFactorList[timeFactorIndex] end, nil)
	print( "Screenshot: " .. love.filesystem.getSaveDirectory() )
	screen = love.graphics.newScreenshot()
	screen:mapPixel(dropAlpha)
	screen:encode(fileName)
end

function fixTableIndices(tbl)

	-- make sure table has no empty slots:
	newTbl = {}
	
	local i = 1
	for k, p in pairs(tbl) do
		newTbl[i] = p
		i = i+1
	end
	return newTbl
end

function randomizeTable(tbl, n)
	n = n or #tbl
	print("During 6")
	for i = 1,n do
		local j = math.random(i, n)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	print("During 7")
	return tbl
end

function copyTable(tbl)
	local newTbl = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			newTbl[k] = copyTable(v)
		else
			newTbl[k] = v
		end
	end
	return newTbl
end

function printTable(tbl, lvl)
	lvl = lvl or 1
	local str = ""
	for i = 1,lvl-1 do
		str = str .. "\t"
	end
	if lvl > 10 then print("Maximum Level Depth reached")
	else
		for k, v in pairs(tbl) do
			if type(v) == "table" then
				print(str,k.. "{")
				printTable(v, lvl + 1)
				print(str, "}")
			else
				print(str, k, v)
			end
		end
	end
end

function readOnlyTable(table)
   return setmetatable({}, {
     __index = table,
     __newindex = function(table, key, value)
                    error("Attempt to modify read-only table")
                  end,
     __metatable = false
   });
end

function randomizeTable(tbl)
	for i = 1,#tbl do
		if #tbl > 1 then
			index1 = math.random(#tbl)
			index2 = math.random(#tbl)
			tbl[index1], tbl[index2] = tbl[index2], tbl[index1]
		end
	end
	return tbl
end

function matrixMultiply(mat, vec)
	return mat.aa*vec.x + mat.ab*vec.y, mat.ba*vec.x + mat.bb*vec.y
end

function vecDist(x1,y1,x2,y2)
	return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end

function additionalInformation(text, code)
	return function()
		if not additionalInfoBox then
			if currentTutBox then
				TUT_BOX_X = currentTutBox.x
				TUT_BOX_Y = currentTutBox.y
			end
			if TUT_BOX_Y + TUT_BOX_HEIGHT + 50 < love.graphics.getHeight() then		-- only show BELOW the current box if there's still space there...
				additionalInfoBox = tutorialBox.new(TUT_BOX_X, TUT_BOX_Y + TUT_BOX_HEIGHT +10, text, {})
			else		-- Otherwise, show it ABOVE the current tut box!
				additionalInfoBox = tutorialBox.new(TUT_BOX_X, TUT_BOX_Y - 10 - TUT_BOX_HEIGHT, text, {})
			end
		else
			tutorialBox.remove(additionalInfoBox)
			additionalInfoBox = nil
			if code and cBox then
				codeBox.remove(cBox)
				cBox = nil
			end
		end
		if code and not cBox then
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, code)
		end
	end
end
