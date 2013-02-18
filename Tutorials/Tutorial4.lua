tutorial = {}

tutMap = {}
tutMap.width = 7
tutMap.height = 7

for i = 0, tutMap.width+1 do
	tutMap[i] = {}
end

tutMap[1][1] = "C"
tutMap[1][2] = "C"
tutMap[1][3] = "C"
tutMap[1][4] = "C"
tutMap[1][5] = "C"
tutMap[1][6] = "C"
tutMap[1][7] = "C"

tutMap[7][1] = "C"
tutMap[7][2] = "C"
tutMap[7][3] = "C"
tutMap[7][4] = "C"
tutMap[7][5] = "C"
tutMap[7][6] = "C"
tutMap[7][7] = "C"

tutMap[2][1] = "C"
tutMap[3][1] = "C"
tutMap[4][1] = "C"
tutMap[5][1] = "C"
tutMap[6][1] = "C"

tutMap[2][7] = "C"
tutMap[3][7] = "C"
tutMap[4][7] = "C"
tutMap[5][7] = "C"
tutMap[6][7] = "C"

tutorialSteps = {}
currentStep = 1

currentStepTitle = ""

currentTutBox = nil

local CODE_eucledianDist = parseCode([[
-- calculate the distance between the two points
-- given by (x1,y1) and (x2,y2):
-- then return the result.
function distance(x1, y1, x2, y2)
	res = sqrt( (x1-x2)^2 + (y1-y2)^2 )
	return res
end
]])

local CODE_foundPassengers1 = parseCode([[
function ai.foundPassengers( train, passengers )
	pass = nil	-- reset from earlier calls
	dist = 100	-- start with a high distance
	i = 1	--start with first passenger
	while i <= #passengers do -- for every passenger
		d = distance(train.x, train.y,
			passengers[i].destX, passengers[i].destY)
		if d < dist then  -- if it's the shorted dist so far, save it.
			dist = d
			pass = passengers[i]
		end
		i = i + 1
	end
end
]])

local CODE_foundPassengers2 = parseCode([[
function ai.foundPassengers( train, passengers )
	...
	while i <= #passengers do -- for every passenger
		...
	end
	return pass
end
]])

local CODE_dropOffPassenger = parseCode([[
-- code to drop off passengers:
function ai.foundDestination(train)
	-- drop off train's passenger:
	dropPassenger(train)
end
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
	
	if tutorialSteps[currentStep].stepTitle then
		currentStepTitle = tutorialSteps[currentStep].stepTitle
	else
		local l = currentStep - 1
		while l > 0 do
			if tutorialSteps[l] and tutorialSteps[l].stepTitle then
				currentStepTitle = tutorialSteps[l].stepTitle
				break
			end
			l = l - 1
		end
	end
		
	currentTutBox = tutorialBox.new( TUT_BOX_X, TUT_BOX_Y, tutorialSteps[currentStep].message, tutorialSteps[currentStep].buttons )
end

function startThisTutorial()

	--define buttons for message box:
	print("tutorialSteps[1].buttons", tutorialSteps[1].buttons[1].name)
	if currentTutBox then tutorialBox.remove(currentTutBox) end
	currentTutBox = tutorialBox.new( TUT_BOX_X, TUT_BOX_Y, tutorialSteps[1].message, tutorialSteps[1].buttons )
	
	STARTUP_MONEY = TRAIN_COST + 15
	timeFactor = 0.5
	
	tutorial.passengersEnRoute = 0
end

function tutorial.start()
	
	aiFileName = "TutorialAI4.lua"
	
	ai.backupTutorialAI(aiFileName)
	ai.createNewTutAI(aiFileName, fileContent)

	stats.start( 1 )
	tutMap.time = 0
	map.print()
	
	loadingScreen.reset()
	loadingScreen.addSection("New Map")
	loadingScreen.addSubSection("New Map", "Size: " .. tutMap.width .. "x" .. tutMap.height)
	loadingScreen.addSubSection("New Map", "Time: Day")
	loadingScreen.addSubSection("New Map", "Tutorial 4: Close is good")

	train.init()
	train.resetImages()
	
	ai.restart()	-- make sure aiList is reset!
	
	ok, msg = pcall(ai.new, AI_DIRECTORY .. aiFileName)
	if not ok then
		print("Err: " .. msg)
	else
		stats.setAIName(1, aiFileName:sub(1, #aiFileName-4))
		train.renderTrainImage(aiFileName:sub(1, #aiFileName-4), 1)
	end
	
	tutorial.noTrees = true		-- don't render trees!
	
	map.generate(nil,nil,1,tutMap)
	
	tutorial.createTutBoxes()
	
	tutorial.mapRenderingDoneCallback = startThisTutorial	
	
	menu.exitOnly()
	
	tutorial.passengersEnRoute = 0
	tutorial.passengerDropoffCorrectlyEvent = function()
			tutorial.passengersEnRoute = tutorial.passengersEnRoute - 1
		end
		
	MAX_NUM_PASSENGERS = 50 	-- overwrite default!
end

function tutorial.endRound()
	tutorial.passengersEnRoute = 0
	tutorial.reachedEast = false
	tutorial.reachedWest = false
end

local codeBoxX, codeBoxY = 0,0
local tutBoxX, tutBoxY = 0,0
function tutorial.createTutBoxes()

	CODE_BOX_X = love.graphics.getWidth() - CODE_BOX_WIDTH - 30
	CODE_BOX_Y = (love.graphics.getHeight() - TUT_BOX_HEIGHT)/2 - 50
	
	local k = 1
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Smarter Choice"
	tutorialSteps[k].message = "This tutorial will teach you:\n\nHow to choose which passenger to pick up."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Start Tutorial", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "There is a group of people on this map. All of them want to go to different places. (Hold down Space to see where they want to go). However, not all of these places are nearby. To be efficient and transport as many passengers as possible (in as little time as possible), we'll learn how to choose the passenger with the shortest travel distance (meaning the distance between his start and destination points)."
	tutorialSteps[k].event = startCreatingPassengers(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "First, we need a way to decide which distance is the shortest. To do this, let's define a function called 'distance'.\nWe'll use the well-known pythagorian theorem:\na²+b² = c² or c = sqrt(a²+b²) in our case.\nType the code on the left into TutorialAI4.lua, then press Next."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_eucledianDist)
		end
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Now whenever we enter a square with passengers on it (ai.foundPassengers is called) we will go through the list of passengers which are on the square and compare the distance between their starting coordinates and their end coordinates."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "The code shown here will first create a variable 'dist' with a very high value (100). This is larger than any distance we'll encounter on this map (because the map is only 7 tiles high and 7 tiles wide). Then we start going through the list of passengers one by one. For each passenger, we calculate the distance to their destination. If it is the smallest distance so far, we save the passenger (in 'pass') and the distance (in 'dist')."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_foundPassengers1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("For advanced users: This code could of course be written more beautifully with a 'for-loop'. To keep the tutorial short, I won't cover for-loops here - there's plenty of examples online. If you have no idea what a for-loop is, ignore this message."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "At the end of the loop, the passenger with the shortest distance has been stored in 'pass'. This is the passenger we want to pick up, so add the line of code shown in the code box to the end of your function ai.foundPassengers (after the while loop)."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_foundPassengers2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("Of course, this method is still far from perfect. For example, the distance to a passenger's destination might be short, but if the train is headding in the wrong direction and can't turn around, it might still be wiser to transport another passenger.\nBut I'll leave this for you to figure out - later."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Of course, we still need to drop off passengers when've reached the destination.\nAdd this final piece of code, then reload."
	tutorialSteps[k].event = handleDropOff(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("The tutorial will continue when you've transported 4 passengers correctly.\nWhen you transport the wrong passenger, the next set of passengers won't be created -> so make sure to always pick up the one with the shortes traveling distance.\nIf something doesn't work yet, just go back and fix it, then reload."), inBetweenSteps = true}
	k = k + 1
	
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Done!"
	tutorialSteps[k].message = "You've completed the fourth tutorial! Now you should be ready to start the challenges.\nYou can also let specific AIs compete using the 'New Match' entry in the main menu.\nIf you're stuck, check out the wiki on " .. MAIN_SERVER_IP .. "!\nThere is also a full Documentation of all the ai functions available in the .love file. Simply use a zip-program to extract it!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "When you think you're ready, make sure to upload the AI to the website (" .. MAIN_SERVER_IP .. ") and watch it compete in live, online matches! Make sure to get to the top of the highscore list!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("Before you go on to the challenges, here's some advice:\n1) Many maps can be played with the most basic AI. However, only more advanced AIs will stand a chance against competition.\n2) Try to beat maps with AIs you already coded. Only change them if they don't win.\n3) NEVER pick up zombies.", CODE_moreIdeas), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Exit to the menu ... ?"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Quit", event = endTutorial}
	--tutorialSteps[k].buttons[3] = {name = "Next Tutorial", event = nextTutorial}
	k = k + 1
end


function startCreatingPassengers(k)

	return function()
		passenger.new(6,1, 7,3)
		passenger.new(6,1, 7,4)
		passenger.new(6,1, 7,5)
		passenger.new(6,1, 7,6)
		passenger.new(6,1, 7,7)


	tutorial.restartEvent = function()
			if currentStep >= k then	-- if I haven't gone back to a previous step
				passenger.new(6,1, 7,3)
				passenger.new(6,1, 7,4)
				passenger.new(6,1, 7,5)
				passenger.new(6,1, 7,6)
				passenger.new(6,1, 7,7)
			end
		end
	end
end

function handleDropOff(k)
	pCount = 0
	return function()
		cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_dropOffPassenger)
		tutorial.passengerDropoffCorrectlyEvent = function(x, y)
			print("dropped off @", x, y)
			pCount = pCount + 1
			if pCount >= 4 then
				if currentStep == k then
					passengerDropoffCorrectlyEvent = nil
					nextTutorialStep()
					tutorialBox.succeed()
				end
			end
			passenger.printAll()
			passenger.clearList()
			if x == 7 and y == 3 then
				passenger.new(7,6, 1,7)
				passenger.new(7,6, 2,7)
				passenger.new(7,6, 3,7)
				passenger.new(7,6, 4,7)
				passenger.new(7,6, 5,7)
			elseif x == 5 and y == 7 then
				passenger.new(3,7, 1,1)
				passenger.new(3,7, 1,2)
				passenger.new(3,7, 1,3)
				passenger.new(3,7, 1,4)
				passenger.new(3,7, 1,5)
			elseif x == 1 and y == 5 then
				passenger.new(1,3, 3,1)
				passenger.new(1,3, 4,1)
				passenger.new(1,3, 5,1)
				passenger.new(1,3, 6,1)
				passenger.new(1,3, 7,1)
			elseif x == 3 and y == 1 then
				passenger.new(6,1, 7,3)
				passenger.new(6,1, 7,4)
				passenger.new(6,1, 7,5)
				passenger.new(6,1, 7,6)
				passenger.new(6,1, 7,7)
			end
			print("dropped off done.")
			passenger.printAll()
		end
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
	--menu.executeTutorial("Tutorial4.lua")
end



function tutorial.roundStats()
	love.graphics.setColor(255,255,255,255)
	x = love.graphics.getWidth()-roundStats:getWidth()-20
	y = 20
	love.graphics.draw(roundStats, x, y)
	
	love.graphics.print("Tutorial 4: Choose wisely!", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Tutorial 4: Choose wisely!")/2, y+10)
	love.graphics.print(currentStepTitle, x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth(currentStepTitle)/2, y+30)
end


function tutorial.handleEvents(dt)

	newTrainQueueTime = newTrainQueueTime + dt*timeFactor
	if newTrainQueueTime >= .1 then
		train.handleNewTrains()
		newTrainQueueTime = newTrainQueueTime - .1
	end
	
end

fileContent = [[
-- Tutorial 4: Close is good!

function ai.init()
	buyTrain(1,1, 'E')
end
]]
