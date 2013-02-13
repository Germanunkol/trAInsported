tutorial = {}

tutMap = {}
tutMap.width = 5
tutMap.height = 5

for i = 0, tutMap.width+1 do
	tutMap[i] = {}
end

tutMap[1][3] = "C"
tutMap[2][3] = "C"
tutMap[3][3] = "C"
tutMap[4][3] = "C"
tutMap[5][3] = "C"
tutMap[3][1] = "C"
tutMap[3][2] = "C"
tutMap[3][4] = "C"
tutMap[3][5] = "C"

tutMap[1][2] = "SC"
tutMap[5][2] = "PL"
tutMap[2][5] = "HO"

tutorialSteps = {}
currentStep = 1

currentStepTitle = ""

currentTutBox = nil

local CODE_chooseDirectionFunction1 = parseCode([[
function ai.chooseDirection( train, directions )

end
]])

local CODE_chooseDirectionFunction2 = parseCode([[
function ai.chooseDirection( train, directions )
	-- example: print the name of the train
	-- and the name of the passenger:
	-- (passenger is 'nil' if there is no passenger)
	if train.passenger == nil then
		print( train.name .. " carries no passenger." )
	else
		print( train.name .. " carries " .. train.passenger )
	end
end
]])

local CODE_pickUpPassenger = parseCode([[
-- code to pick up passengers:
function ai.foundPassengers( train, passengers )
	return passengers[1]
end
]])

local CODE_chooseDirectionWithPassenger1 = parseCode([[
function ai.chooseDirection( train, directions )
	if train.passenger == nil then
		print( train.name .. " carries no passenger." )
		-- go South because that's where the passengers are!
		return "S"
	else
		print( train.name .. " carries " .. train.passenger )
	end
end
]])

local CODE_chooseDirectionWithPassenger2 = parseCode([[
function ai.chooseDirection( train, directions )
	if train.passenger == nil then
		print( train.name .. " carries no passenger." )
		return "S"
	else
		print( train.name .. " carries " .. train.passenger )
		if train.passengerX < train.x then
			return "W"
		else
			return "E"
		end
	end
end
]])

local CODE_dropOffPassenger = parseCode([[
-- code to drop off passengers:
function ai.foundDestination(train)
	-- drop off train's passenger:
	dropPassenger(train)
end
]])

local CODE_enoughMoney = parseCode([[
-- this function is called when you've earned enough cash:
function ai.enoughMoney()
	buyTrain(1,3)
end
]])


local CODE_moreIdeas = parseCode([[
-- check if this is the first train:
if train.ID == 1 then
	...
	
-- loop through passengers:
-- IMPORTANT: #passengers is the length of the list!!
i = 1
while i < #passengers do
	...
	if ... then
		-- pick up passenger
		break	-- finish the loop!
	end
	i = i + 1
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
	
	aiFileName = "TutorialAI3.lua"
	
	ai.backupTutorialAI(aiFileName)
	ai.createNewTutAI(aiFileName, fileContent)

	stats.start( 1 )
	tutMap.time = 0
	map.print()
	
	loadingScreen.reset()
	loadingScreen.addSection("New Map")
	loadingScreen.addSubSection("New Map", "Size: " .. tutMap.width .. "x" .. tutMap.height)
	loadingScreen.addSubSection("New Map", "Time: Day")
	loadingScreen.addSubSection("New Map", "Tutorial 3: Be smart!")

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

--[[
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
		end
		if not cBox then
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, code)
		end
	end
end
]]--

function tutorial.createTutBoxes()

	CODE_BOX_X = love.graphics.getWidth() - CODE_BOX_WIDTH - 30
	CODE_BOX_Y = (love.graphics.getHeight() - TUT_BOX_HEIGHT)/2 - 50
	
	local k = 1
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Check!"
	tutorialSteps[k].message = "The third Tutorial will teach you:\n\n1) How to make smarter choices depending on where your passengers want to go\n2) Using multiple trains."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Start Tutorial", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "On this map, there are some kids. As it is with students, some want to go to school, some would rather not.\nAs trAIn programmers, it is not our job to judge that, though...\n(Press space bar to see their destinations)"
	tutorialSteps[k].event =  startCreatingPassengers(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Your job is to move the passengers where they want to go.\nWe could just try out all the directions until we reach the passenger's destination, but then we wouldn't be much of a competition for other, smarter AIs. Instead, we'll try to check where our passengers want to go and then move accordingly."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "To do this, we will add two parameters to function ai.chooseDirection, called 'train' and 'directions'.\nOpen up TutorialAI3.lua and add the code in the code box."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_chooseDirectionFunction1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "The 'train' parameter will be automatically filled with a table representing the train. It has the following elements: 'ID', 'name', 'x' and 'y'.\nIf the train is currently transporting a passenger, then there's three more elements in the table called:\n'passenger' (the name of the passenger), 'passengerX' and 'passengerY' (the coordinates of where the passenger wants to go).\nAdd the code in the code box to your function."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_chooseDirectionFunction2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "As in Tutorial1, we need to add code to pick up a passenger. Add it to your script...\n\nWhen you're done, reload and see if it works!"
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_pickUpPassenger)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "The next step will be: Whenever the train reaches the junction and has no passenger on board, it should go south. Add the code line accordingly."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_chooseDirectionWithPassenger1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "If there is a passenger on board, we'll compare the X-coordinates of the train's current position (train.x) and the passenger's destination (train.passengerX). If the destination lies in the West (destination X is smaller than the train's X) then we'll go West. Otherwise, we'll go East.\nAdd the new parts to your function."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_chooseDirectionWithPassenger2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "The last step is to drop the passenger off as we did before.\n\nOnce you've coded all of that, reload and watch the train drop off passengers!\n(You can change the speed of the tutorial by pressing + or - )"
	tutorialSteps[k].event = waitingForPassengersEvent(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("The game will automatically go to the next step when you've dropped of one passenger in the East and one in the West."), inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "You seem to be getting it right, well done! But this would go much, much faster if we had more than one train. You start the tutorial with one train and 15 credits. A new train costs " .. TRAIN_COST .. " credits. Whenever you drop off a passenger, you earn money. Once you have enough money for a new train, the function 'ai.enoughMoney' is called. Use it to buy a new train.\nOnce you have written the code, reload."
	tutorialSteps[k].event = enoughMoneyEvent(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "You now own two trains!\nNow sit back, relax and watch your trains carry 10 passengers to their destination. You've done a good job!\n\n0 out of 10 transported."
	tutorialSteps[k].event = waitFor10Passengers(k)
	tutorialSteps[k].buttons = {}
	--tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Done!"
	tutorialSteps[k].message = "You've completed the third tutorial, well done!\nWith this tutorial, you've covered all the basics. Click 'More Ideas' for your first real challenge!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Ideas", event = additionalInformation("Try to make the first train only transport passengers who want to go to the East. To do this:\nIn ai.foundPassengers: check if train.ID is 1. Then, check if passengers[1]'s destX is smaller than train.x.\nIf that's the case, pick him up, otherwise go on to passengers[2] and so on. \nIf possible, use a while loop to go through the passenger list. Finally, make the second train only pickup passengers who want to go West. IMPORTANT: #passengers is the length of the list! Remember 'break' lets you end a loop when you've found your passenger.", CODE_moreIdeas), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Go directly to the next tutorial or return to the menu."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Quit", event = endTutorial}
	tutorialSteps[k].buttons[3] = {name = "Next Tutorial", event = nextTutorial}
	--tutorialSteps[k].buttons[3] = {name = "Next Tutorial", event = nextTutorial}
	k = k + 1
end

function startCreatingPassengers(k)
	createPassengers = k
	tutorial.restartEvent = function()
			if currentStep >= k then	-- if I haven't gone back to a previous step
				createPassengers = k
				tutorial.passengersEnRoute = 0
			end
		end
end

function waitingForPassengersEvent(k)
	return function()
		
		cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_dropOffPassenger)
	
		tutorial.reachedNewTileEvent = function(x, y)
			if x == 5 then
				tutorial.reachedEast = true
			elseif x == 1 then
				tutorial.reachedWest = true
			end
			if tutorial.reachedEast and tutorial.reachedWest then
				if currentStep == k then	-- if I haven't gone back to a previous step
					-- tutorial.reachedNewTileEvent = nil
					nextTutorialStep()
				end
			end
		end
	end
end

function enoughMoneyEvent(k)
	return function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_enoughMoney)
			local numOfTrains = 0
			tutorial.trainPlacingEvent = function()
				numOfTrains = numOfTrains + 1
				if numOfTrains >= 2 then
					if currentStep >= k then	-- if I haven't gone back to a previous step
						tutorial.trainPlacingEvent = nil
						nextTutorialStep()
					end
				end
			end
		end
end

function waitFor10Passengers(k)
	return function()
		numPassengers = 0
		tutorial.passengerDropoffCorrectlyEvent = function()
		
			tutorial.passengersEnRoute = tutorial.passengersEnRoute - 1
			numPassengers = numPassengers + 1
			if currentStep == k then
				currentTutBox.text = "You now own two trains!\nNow sit back, relax and watch your trains carry 10 passengers to their destination. You've done a good job!\n\n" .. numPassengers .. " out of 10 transported."
				if numPassengers >= 10 then
					nextTutorialStep()
				end
			end
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
	menu.executeTutorial("Tutorial4.lua")
end



function tutorial.roundStats()
	love.graphics.setColor(255,255,255,255)
	x = love.graphics.getWidth()-roundStats:getWidth()-20
	y = 20
	love.graphics.draw(roundStats, x, y)
	
	love.graphics.print("Tutorial 3: Be smart!", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Tutorial 3: Be smart!")/2, y+10)
	love.graphics.print(currentStepTitle, x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth(currentStepTitle)/2, y+30)
end


function tutorial.handleEvents(dt)

	newTrainQueueTime = newTrainQueueTime + dt*timeFactor
	if newTrainQueueTime >= .1 then
		train.handleNewTrains()
		newTrainQueueTime = newTrainQueueTime - .1
	end
	
	if tutorial.passengersEnRoute <= 5 and createPassengers and currentStep >= createPassengers then
		tutorial.passengersEnRoute = tutorial.passengersEnRoute + 1
		if goWest then
			passenger.new(3,5, 1,3)
			goWest = nil
		else
			passenger.new(3,5, 5,3)
			goWest = true
		end
	end
	
end

fileContent = [[
-- Tutorial 3: Be smart!

function ai.init()
	buyTrain(3,1)
end
]]
