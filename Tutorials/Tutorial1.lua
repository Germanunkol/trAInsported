tutorial = {}

tutMap = {}
tutMap.width = 5
tutMap.height = 6

for i = 0, tutMap.width+1 do
	tutMap[i] = {}
end

tutMap[2][2] = "C"
tutMap[2][3] = "C"
tutMap[2][5] = "C"
tutMap[3][5] = "C"
tutMap[4][5] = "C"
tutMap[4][4] = "H"

tutorialSteps = {}
currentStep = 1

currentTutBox = nil

function nextTutorialStep()
	currentStep = currentStep + 1
	if tutorialSteps[currentStep].event then
		tutorialSteps[currentStep].event()
	end
	if currentTutBox then tutorialBox.remove(currentTutBox) end
	currentTutBox = tutorialBox.new( love.graphics.getWidth()/2- 200, love.graphics.getHeight()/2-100, tutorialSteps[currentStep].message, tutorialSteps[currentStep].buttons )
end
function prevTutorialStep()
	currentStep = currentStep - 1
	if tutorialSteps[currentStep].event then
		tutorialSteps[currentStep].event()
	end
	if currentTutBox then tutorialBox.remove(currentTutBox) end
	currentTutBox = tutorialBox.new( love.graphics.getWidth()/2- 200, love.graphics.getHeight()/2-100, tutorialSteps[currentStep].message, tutorialSteps[currentStep].buttons )
end

function startThisTutorial()

	--define buttons for message box:
	print("tutorialSteps[1].buttons", tutorialSteps[1].buttons[1].name)
	if currentTutBox then tutorialBox.remove(currentTutBox) end
	currentTutBox = tutorialBox.new( love.graphics.getWidth()/2- 200, love.graphics.getHeight()/2-100, tutorialSteps[1].message, tutorialSteps[1].buttons )
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
		stats.setAIName(k, aiFileName:sub(1, #aiFileName-4))
		train.renderTrainImage(aiFileName:sub(1, #aiFileName-4), i)
	end
	
	map.new(nil,nil,1,tutMap)
	
	tutorial.createTutBoxes()
	
	tutorial.mapRenderingDoneCallback = startThisTutorial	
	
	menu.exitOnly()
end

function tutorial.createTutBoxes()
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
	tutorialSteps[k].message = "Where there's profit, competition is never far. New businesses are each trying to gain control of the market. And this is where you come in. Your job here is to control your company's trAIns - by writing the best artificial intelligence for them.\nEnough talk, let's get started!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "You can click and drag anywhere on the map to move the view." 
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
	tutorialSteps[k].message = "You've completed the first tutorial, well done! On to the next one."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "End", event = endTutorial}
end

function endTutorial()
	menu.init()
	map.endRound()
	mapImage = nil
	curMap = nil
	tutorial = {}
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

fileContent = [[
-- Tutorial 1: Baby Steps
-- What you should know:
--	a) Lines starting with two dashes are comments, they will be ignored by the game.
--	b) All your instructions will be written in the Lua scripting language.
--	c) The basics of Lua are very easy to learn, and this game will teach them to you step by step.
--	d) Lua is extremly fast as well. In short:
--	e) Lua doesn't suck.
-- Now that you've successfully found the file and read this, go back to the game and press the "Next" button!
]]
