tutorial = {}

tutMap = {}
tutMap.width = 5
tutMap.height = 4

for i = 0, tutMap.width+1 do
	tutMap[i] = {}
end

tutMap[1][3] = "C"
tutMap[2][3] = "C"
tutMap[2][4] = "C"
tutMap[3][4] = "C"
tutMap[4][4] = "C"
tutMap[5][4] = "C"


tutorialSteps = {}
currentStep = 1

currentTutBox = nil

local CODE_printHelloTrains = parseCode([[
print( "Hello trAIns!" )
]])

local CODE_trainPlacing = parseCode([[
function ai.init()
     buyTrain( 1, 3 )
end
]])

local CODE_eventExamples = parseCode([[
-- called at every round start:
function ai.init( map, money )

-- called when a train arrives at a junction:
function ai.chooseDirection(train, possibleDirections)

-- called when a train has reached a passenger's location:
function ai.foundPassengers(train, passengers)
]])

function nextTutorialStep()
	currentStep = currentStep + 1
	showCurrentStep()
end
function prevTutorialStep()
	currentStep = currentStep - 1
	showCurrentStep()
end

function showCurrentStep()
	if cBox then
		codeBox.remove(cBox)
		cBox = nil
	end
	if additionalInfoBox then
		tutorialBox.remove(additionalInfoBox)
		additionalInfoBox = nil
	end
	if tutorialSteps[currentStep].event then
		tutorialSteps[currentStep].event()
	end
	if currentTutBox then
		TUT_BOX_X = currentTutBox.x
		TUT_BOX_Y = currentTutBox.y
		tutorialBox.remove(currentTutBox)
	end
		
	currentTutBox = tutorialBox.new( TUT_BOX_X, TUT_BOX_Y, tutorialSteps[currentStep].message, tutorialSteps[currentStep].buttons )
end

function startThisTutorial()

	--define buttons for message box:
	print("tutorialSteps[1].buttons", tutorialSteps[1].buttons[1].name)
	if currentTutBox then tutorialBox.remove(currentTutBox) end
	currentTutBox = tutorialBox.new( TUT_BOX_X, TUT_BOX_Y, tutorialSteps[1].message, tutorialSteps[1].buttons )
	
end

function tutorial.start()
	
	aiFileName = "TutorialAI1.lua"
	
	ai.backupTutorialAI(aiFileName)
	ai.createNewTutAI(aiFileName, fileContent)

	stats.start( 1 )
	tutMap.time = 0
	map.print()
	
	loadingScreen.reset()
	loadingScreen.addSection("New Map")
	loadingScreen.addSubSection("New Map", "Size: " .. tutMap.width .. "x" .. tutMap.height)
	loadingScreen.addSubSection("New Map", "Time: Day")
	loadingScreen.addSubSection("New Map", "Tutorial 1: Baby steps")

	train.init()
	train.resetImages()
	
	ok, msg = pcall(ai.new, "AI/" .. aiFileName)
	if not ok then
		print("Err: " .. msg)
	else
		stats.setAIName(1, aiFileName:sub(1, #aiFileName-4))
		train.renderTrainImage(aiFileName:sub(1, #aiFileName-4), 1)
	end
	
	map.new(nil,nil,1,tutMap)
	
	tutorial.createTutBoxes()
	
	tutorial.mapRenderingDoneCallback = startThisTutorial	
	
	menu.exitOnly()
end


function tutorial.endRound()
	tutorial.placedFirstPassenger = nil
end

local codeBoxX, codeBoxY = 0,0
local tutBoxX, tutBoxY = 0,0


function additionalInformation(text)
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
		end
	end
end

function tutorial.createTutBoxes()

	CODE_BOX_X = love.graphics.getWidth() - CODE_BOX_WIDTH - 30
	CODE_BOX_Y = (love.graphics.getHeight() - TUT_BOX_HEIGHT)/2 - 50
	
	local k = 1
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Welcome to trAInsported!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Start Tutorial", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "The near future:\nA few years ago, a new product was introduced to the international market: The AI-controlled-Train, also known as 'trAIn'."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "There's three major differences between 'trAIns' and their older sisters, the trains. For one thing, they only ever pick up one passenger at a time. Secondly, they go exactly where their passengers want them to go. Thirdly, they're controlled by artificial intelligence."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "In theory, this new traffic system could work wonders. Pollution decreased, the need for private vehicles is gone and there's no more accidents due to highly advanced technology. \n\nThere's just one problem... "
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Where there's profit, competition is never far away. New businesses are each trying to gain control of the market. And this is where you come in. Your job here is to control your company's trAIns - by writing the best artificial intelligence for them.\nEnough talk, let's get started!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "You can click and drag anywhere on the map to move the view. Use the mousewheel (or Q and E) to zoom." 
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "At all times, you can press F1 to get a help screen showing you the controls. Try it!"
	tutorialSteps[k].event = setF1Event(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Good. Let's keep going.\nThe game has a subfolder called 'AI'.\nIn it, you'll find a new file that I just generated. It's called 'Tutorial1.lua'.\nOpen this file in any text editor of your choice and read it."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	if love.filesystem.getWorkingDirectory() then
		tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("The folder is located at: " .. love.filesystem.getWorkingDirectory() .. "/AI"), inBetweenSteps = true}
		tutorialSteps[k].buttons[3] = {name = "Next", event = nextTutorialStep}
	else
		tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	end
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Now, let's write some code!\nThe first thing you have to learn is how to communicate with the game. Type the code shown on the right at the bottom of Tutorial1.lua. Once done, save it and press the 'Reload' button at the bottom of this window."
	tutorialSteps[k].event = firstPrint(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("The print function allows you to print any text (meaning anything between \" quotes) or variables to the in-game console. This will allow you to easily debug your code later on. Try it out any you'll see what I mean."), inBetweenSteps = true}
	--tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Well done.\n\nThe text you printed should now show up in the in-game console on the left. This is useful for debugging later on."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "There are certain functions which your AI will need. During each round, when certain things happen, these functions will be called. There's a few examples shown in the code box. Your job will be to fill these functions with content."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = setCodeExamples
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Now, add the code on the left below your print call. This will buy your first train and place it at the position x=1, y=3. The map is split up into squares (zoom in to see them).\nX (left to right) and Y (top to bottom) are the coordinates. When done, save and click reload."
	tutorialSteps[k].event = setTrainPlacingEvent(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("Note:\n-The coordinates (X and Y) go from 1 to the map's width (or height). You'll learn more about the maximum width and height of the map later on.\n-If you call buyTrain with coordinates that don't describe a rail, the game will place the train at the closest rail that it can find."), inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Yay, you just placed your first trAIn on the map! It will automatically keep going forward.\nThe function 'ai.init()' is the a function in your script that will always be called when the round starts. In this function, you will be able to analize the map, plan your train movement and - as you just did - buy your first trains and place them on the map."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("The function ai.init() is called with 2 arguments. The first one holds the current map (more on that later) and the second one holds the amount of money you currently own. This way, you can check how many trains you can buy. You always have enough money to buy at least one train.\nfunction ai.init( map, money )"), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "I've just placed a passenger on the map. Hold down the Space bar on your keyboard to see a line showing where he wants to go!"
	tutorialSteps[k].event = setPassengerStart
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("Passengers will always be spawned near a rail."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Th"
	tutorialSteps[k].event = setPassengerStart
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "You've completed the first tutorial, well done!\n\nOn to the next one."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Quit", event = endTutorial}
	tutorialSteps[k].buttons[3] = {name = "Next", event = nextTutorial}
	k = k + 1
end

function firstPrint(k)
	return function()
		setFirstPrintEvent(k)
		cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_printHelloTrains)
		console.setVisible(true)
		quickHelp.setVisibility(false)
	end
end

function endTutorial()
	map.endRound()
	mapImage = nil
	curMap = nil
	tutorial = {}
	menu.init()
end

function nextTutorial()
	map.endRound()
	mapImage = nil
	curMap = nil
	tutorial = {}
	menu.init()
	menu.executeTutorial("Tutorial2.lua")
end

function setF1Event(k)
	return function()
		tutorial.f1Event = function ()
					tutorial.f1Event = nil
					if currentStep == k then
						nextTutorialStep()
					end
				end
			end
end


function setFirstPrintEvent(k)
	tutorial.consoleEvent = function (str)
					if str:sub(1, 13) == "[TutorialAI1]" then
						if str:upper() == string.upper("[TutorialAI1]\tHello trAIns!") then
							tutorialSteps[k+1].message = "Well done.\n\nThe text you printed should now show up in the in-game console on the left. The console also shows which AI printed the text. This will play a role when you challenge other AIs later on."
						else
							tutorialSteps[k+1].message = "Not quite the right text, but you get the idea.\n\nThe text you printed should now show up in the in-game console on the left. The console also shows which AI printed the text. This will play a role when you challenge other AIs later on."
						end
						tutorial.consoleEvent = nil
						if currentStep == k then
							nextTutorialStep()
						end
					end
				end
end

function setCodeExamples()
	cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_eventExamples)
end

function setTrainPlacingEvent(k)
	return function()
		cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_trainPlacing)
		tutorial.trainPlacingEvent = function()
				tutorial.trainPlacingEvent = nil
				tutorial.trainPlaced = true
				tutorial.numPassengers = 0
				if currentStep == k then
					nextTutorialStep()
				end
			end
		end
end

function setPassengerStart()
	print("started event!")
	if not tutorial.placedFirstPassenger then
		passenger.new(3,4, 1,3) 	-- place passenger at 3, 4 wanting to go to 1,3
		tutorial.placedFirstPassenger = true
	end
end

function tutorial.roundStats()
	x = love.graphics.getWidth()-roundStats:getWidth()-20
	y = 20
	love.graphics.draw(roundStats, x, y)
	
	t = "How to buy trains"
	love.graphics.print("Current step:", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Current step:")/2, y+10)
	love.graphics.print(t, x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth(t)/2, y+30)
end


function tutorial.handleEvents(dt)

	newTrainQueueTime = newTrainQueueTime + dt*timeFactor
	if newTrainQueueTime >= .1 then
		train.handleNewTrains()
		newTrainQueueTime = newTrainQueueTime - .1
	end
	
	--if tutorial.trainPlaced then
		--if tutorial.numPassengers == 0 then
		--end
	--end
end

fileContent = [[
-- Tutorial 1: Baby Steps
-- What you should know:
--	a) Lines starting with two dashes are comments, they will be ignored by the game.
--	b) All your instructions will be written in the Lua scripting language.
--	c) The basics of Lua are very easy to learn, and this game will teach them to you step by step.
--	d) Lua is extremly fast as well. In short:
--	e) Lua doesn't suck.
-- Now that you've successfully found the file and read this, go back to the game and press the "Next" button!
-- Note: There are text editors which highlight the keywords for the Lua language. Just search for Lua editors on the internet. This makes scripting easier but is NOT needed - any old text editor should do.
]]
