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
	if currentTutBox then tutorialBox.remove(currentTutBox) end
	currentTutBox = tutorialBox.new( 150, (love.graphics.getHeight() - TUT_BOX_HEIGHT)/2, tutorialSteps[currentStep].message, tutorialSteps[currentStep].buttons )
end

function startThisTutorial()

	--define buttons for message box:
	print("tutorialSteps[1].buttons", tutorialSteps[1].buttons[1].name)
	if currentTutBox then tutorialBox.remove(currentTutBox) end
	currentTutBox = tutorialBox.new( 150, (love.graphics.getHeight() - TUT_BOX_HEIGHT)/2, tutorialSteps[1].message, tutorialSteps[1].buttons )
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

local codeBoxX, codeBoxY = 0,0
local tutBoxX, tutBoxY = 0,0


function additionalInformation(text)
	return function()
		if not additionalInfoBox then
			additionalInfoBox = tutorialBox.new(150, (love.graphics.getHeight() - TUT_BOX_HEIGHT)/2 - TUT_BOX_HEIGHT - 10, text, {})
		end
	end
end

function tutorial.createTutBoxes()

	codeBoxX = love.graphics.getWidth() - CODE_BOX_WIDTH - 100
	codeBoxY = (love.graphics.getHeight() - TUT_BOX_HEIGHT)/2 - 50


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
	tutorialSteps[k].message = "There's three major differences between 'trAIns' and their older sisters, the trains. For one thing, they only ever pick up one passenger at a time. Secondly, they go exactly where their passengers want them to. Thirdly, they're controlled by artificial intelligence."
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
	tutorialSteps[k].message = "Well done.\nNext, add the code on the left below your print call. This will buy your first train and place it at the position x=1, y=3.\nX is the width and Y is the height of the sqare at which you want to place the train."
	tutorialSteps[k].event = setTrainPlacingEvent(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("Note:\n-The coordinates (X and Y) go from 1 to the map's width (or height). You'll learn more about the maximum width and height of the map later on.\n-If you call buyTrain with coordinates that don't describe a rail, the game will place the train at the closest rail that it can find."), inBetweenSteps = true}
	k = k + 1
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Yay, you just placed your first trAIn on the map! It will automatically keep going forward."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorial}
	tutorialSteps[k].message = "You've completed the first tutorial, well done! On to the next one."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Quit", event = endTutorial}
	tutorialSteps[k].buttons[3] = {name = "Next", event = nextTutorial}
end

function firstPrint(k)
	return function()
		setFirstPrintEvent(k)
		cBox = codeBox.new(codeBoxX, codeBoxY, "print( \"Hello trAIns!\" )")
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
							tutorialSteps[k+1].message = "Well done.\nNext, add the code on the left below your print call. This will buy your first train and place it at the position x=1, y=3. X is the width and Y is the height of the sqare at which you want to place the train."
						else
							tutorialSteps[k+1].message = "Not quite the right text, but you get the idea.\nNext, add the code on the left below your print call. This will buy your first train and place it at the position x=1, y=3. X is the width and Y is the height of the sqare at which you want to place the train."
						end
						tutorial.consoleEvent = nil
						if currentStep == k then
							nextTutorialStep()
						end
					end
				end
end

function setTrainPlacingEvent(k)
	return function()
		cBox = codeBox.new(codeBoxX, codeBoxY, "function ai.init()\n   buyTrain( 1, 3 )\nend")
		tutorial.trainPlacingEvent = function()
				tutorial.trainPlacingEvent = nil
				if currentStep == k then
					nextTutorialStep()
				end
			end
		end
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
