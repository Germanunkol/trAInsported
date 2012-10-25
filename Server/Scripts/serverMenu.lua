thisThread = love.thread.getThread()

local menu = {}

local menuOptions = {}

local msgNumber = 0

print = function(...)
	sendStr = ""
	for i = 1, #args do
		sendStr = args[i] .. "\t"
	end
	love.thread.set("msg" .. msgNumber, sendStr)
	msgNumber = msgNumber + 1
end

function menu.display()
	for i = 1, #menuOptions do
		print(i, menuOptions[i].title)
	end
end

function menu.addOption( title, event, arguments )
	menuOptions[#menuOptions+1] = {title = title, event = event, arguments = arguments}
end

function menu.removeOptions( title )
	for i = 1, #menuOptions do			-- look for the given menu entry
		if title == menuOptions[i].title then	-- found the menu entry?
			for j = i, #menuOptions do
				menuOptions[j] = menuOptions[j+1]	-- move all up one. last one will be set to nil automatically.
			end
		end
	end
end

function menu.init()
	menuOptions = {}
	
	menu.addOption("Start Server", love.event.quit)
	menu.addOption("Setup", love.event.quit)
	menu.addOption("Exit", love.event.quit)
end

function menu.handleInput( input )
	input = tonumber(input)
	if input == nil then return end
	
	if input >= 1 and input <= #menuOptions then
		if menuOptions[input].event then
			menuOptions[input].event(menuOptions[input].arguments)
		end
	end
end


while true do
	input = love.thread.get("input")
	if input then
		menu.handleInput(input)
		menu.display()
	end
end
