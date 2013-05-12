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

tutMap[1][1] = "SCHOOL"
tutMap[2][1] = "SCHOOL"
tutMap[1][2] = "SCHOOL"
tutMap[2][2] = "SCHOOL"
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
	-- Beispiel: Gib den Namen des trAIns aus
	-- und den Namen des Passagiers:
	-- (passenger ist 'nil' falls kein Passagier da ist)
	if train.passenger == nil then
		print(train.name.." hat keinen Passagier.")
	else
		print(train.name.." befördert "..train.passenger.name)
	end
end
]])

local CODE_pickUpPassenger = parseCode([[
-- Code um Passagiere mitzunehmen:
function ai.foundPassengers( train, passengers )
	return passengers[1]
end
]])

local CODE_chooseDirectionWithPassenger1 = parseCode([[
function ai.chooseDirection( train, directions )
	if train.passenger == nil then
		print(train.name.." hat keinen Passagier.")
		-- fahre nach Süden, denn da sind die Passagiere!
		return "S"
	else
		print(train.name.." befördert "..train.passenger.name)
	end
end
]])

local CODE_chooseDirectionWithPassenger2 = parseCode([[
function ai.chooseDirection( train, directions )
	if train.passenger == nil then
		print(train.name.." hat keinen Passagier.")
		return "S"
	else
		print(train.name.." befördert "..train.passenger.name)
		if train.passenger.destX < train.x then
			return "W"
		else
			return "E"
		end
	end
end
]])

local CODE_dropOffPassenger = parseCode([[
-- Code zum Rauslassen der Passagiere:
function ai.foundDestination(train)
	-- lass den Passagier raus:
	dropPassenger(train)
end
]])

local CODE_enoughMoney = parseCode([[
-- diese Funktion wird aufgerufen, sobald du genug Geld hast:
function ai.enoughMoney()
	buyTrain(1,3)
end
]])


local CODE_moreIdeas = parseCode([[
-- Schau, ob es der erste trAIn ist:
if train.ID == 1 then
	...
	
-- Iteriere durch die Passagiere:
-- ACHTUNG: #passengers ist die Länge der Liste!!
i = 1
while i <= #passengers do
	...
	if ... then
		-- nimm Passagier mit
		break	-- beende die Schleife!
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
	
	--ai.backupTutorialAI(aiFileName)
	ai.createNewTutAI(aiFileName, fileContent)

	stats.start( 1 )
	tutMap.time = 0
	map.print()
	
	loadingScreen.reset()
	loadingScreen.addSection("Neue Karte")
	loadingScreen.addSubSection("Neue Karte", "Größe: " .. tutMap.width .. "x" .. tutMap.height)
	loadingScreen.addSubSection("Neue Karte", "Zeit: Tag")
	loadingScreen.addSubSection("Neue Karte", "Tutorial 3: Sei smart!")

	train.init()
	train.resetImages()
	
	ai.restart()	-- make sure aiList is reset!
	
	ok, msg = pcall(ai.new, AI_DIRECTORY .. aiFileName)
	if not ok then
		print("Fehler: " .. msg)
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
	tutorialSteps[k].message = 
		"Das dritte Tutorial zeigt Dir:\n\n"..
		"1) Wie man klügere Entscheidungen trifft, je nachdem wo deine Passagiere hin wollen\n\n"..
		"2) Den Umgang mit mehreren Zügen."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Starte Tutorial", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = 
		"Auf dieser Karte sind einige Kinder. "..
		"Wie Schüler eben sind, wollen einige in die Schule, andere lieber nicht.\n"..
		"Als trAIn-Programmierer steht es uns nicht zu, dies zu verurteilen, obwohl...\n"..
		"(Drücke die Leertaste oder klicke auf einen Passagier, um sein Ziel zu sehen)"
	tutorialSteps[k].event =  startCreatingPassengers(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = 
		"Dein Job ist es die Passagiere an ihr Ziel zu bringen.\n"..
		"Wir könnten einfach alle Richtungen ausprobieren, bis wir die des Passagieres finden, "..
		"aber dann wären wir kein guter Gegner für andere, klügere AIs.\n"..
		"Stattdessen versuchen wir herauszufinden, wo unser Passagier hin will und fahren dann entsprechend dorthin."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = 
	  "Um dies zu erreichen, fügen wir der Funktion ai.chooseDirection zwei Parameter hinzu, "..
	  "namens 'train' und 'directions'.\n Öffne Deutsch_TutorialAI3.lua und kopiere den Code aus dem Code-Kasten."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_chooseDirectionFunction1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = 
		"Der Parameter 'train' ist eine Tabelle, die den trAIn repräsentiert "..
		"Sie hat folgende Elemente: 'ID', 'name', 'x' und 'y'. "..
		"Wenn der trAIn gerade einen Passagier befördert, "..
		"ist ein weiteres Element namens 'passenger' in der Tabelle "..
		"(eine Tabelle die den Passager repräsentiert). Diese Tabelle wiederum "..
		"hat die Elemente: 'destX' und 'destY', welche das Ziel des Passagieres angeben "..
		"und 'name' - der Name unseres Passagiers. Füge den neuen Code deiner Funktion hinzu."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_chooseDirectionFunction2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = 
		"Wie in Tutorial 1, müssen wir Code hinzufügen, um einen Passagier mitzunehmen. "..
		"Füge dies deinem Script hinzu...\n\nWenn du fertig bist, lade neu und schau ob es funktioniert!"
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_pickUpPassenger)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = 
		"Nächster Schritt: Immer wenn der Zug eine Weiche erreicht und keinen Passagier "..
		"an Bord hat, soll er nach Süden fahren. Füge die Zeile Code entsprechend hinzu."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_chooseDirectionWithPassenger1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = 
		"Wenn ein Passagier an Bord ist, vergleichen wir die aktuellen X-Koordinaten "..
		"des Zuges (train.x) mit den Zielkoordinaten des Passagieres "..
		"(train.passenger.destX). Liegt das Ziel im Westen "..
		"(X des Ziels ist kleiner als X des trAIns), dann fahren wir nach Westen. "..
		"Ansonsten fahren wir nach Osten.\nErweitere deine Funktion entsprechend."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_chooseDirectionWithPassenger2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = 
		"Als Letztes müssen wir den Passagier absetzen, so wie letztes Mal\n\n"..
		"Wenn du das alles programmiert hast, lade neu und beobachte wie der trAIn die Passagiere rauslässt!\n"..
		"(Du kannst die Geschwindigkeit des Tutorials ändern indem du auf + oder - klickst"
	tutorialSteps[k].event = waitingForPassengersEvent(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mehr Info", event = additionalInformation("Das Spielt geht automatisch weiter, wenn du die Passagiere im Westen und im Osten raus gelassen hast."), inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = 
		"Du scheinst es richtig gemacht zu haben, super! Aber es würde viel viel schneller gehen, "..
		"wenn wir mehr als einen trAIn hätten. Du beginnst das Tutorial mit einem trAIn und 15 Credits. "..
		"Ein neuer trAIn kostet" .. TRAIN_COST .. " credits. Immer wenn du einen Passagier rauslässt, "..
		"verdienst du Geld (Credits). Sobald du genug Geld für einen neuen trAIn hast, "..
		"wird die Funktion 'ai.enoughMoney aufgerufen. Benutze sie, um einen neuen trAIn zu kaufen.\n"..
		"Sobald du den Code geschrieben hast, lade neu."
	tutorialSteps[k].event = enoughMoneyEvent(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = 
		"Du besitzt jetzt zwei trAIns.\nLehne dich zurück und beobachte deine trAIns dabei, "..
		"wie sie 10 Passagiere zu ihrem Ziel bringen. Gute Arbeit!\n\n"..
		"0 von 10 transportiert."
	tutorialSteps[k].event = waitFor10Passengers(k)
	tutorialSteps[k].buttons = {}
	--tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Erledigt!"
	tutorialSteps[k].message = 
		"Du hast das dritte Tutorial beendet, gute Arbeit!\n"..
		"Mit diesem Tutorial hast du die Basics gemeistert. "..
		"Klicke auf 'Mehr Ideen' für deine erste richtige Herausforderung!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mehr Ideen", event = additionalInformation(
		"Versuche, dass der erste trAIn nur Passagiere, die nach Osten wollen, transportiert. "..
		"Um dies zu erreichen:\nChecke in ai.foundPassengers ob die train.ID 1 ist. "..
		"Dann prüfe ob passengers[1]'s destX kleiner als train.x ist.\n"..
		"Wenn ja, dann nimm ihn mit, andernfalls gehe zu passengers[2] und so weiter,\n"..
		"Falls möglich, benutze eine while-Schleife für die passenger-Liste. "..
		"Sorge zuletzt dafür, dass der zweite trAIn nur Passagiere, die nach Westen wollen, mitnimmt. "..
		"ACHTUNG: #passengers ist die Größe der Liste! Denk daran: 'break' "..
		"lässt dich die Schleife beenden sobald du deinen Passagier gefunden hast.", CODE_moreIdeas), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Gehe direkt zum nächsten Tutorial oder zurück zum Menü."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Ende", event = endTutorial}
	tutorialSteps[k].buttons[3] = {name = "Nächstes Tutorial", event = nextTutorial}
	--tutorialSteps[k].buttons[3] = {name = "Weiter Tutorial", event = nextTutorial}
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
					tutorialBox.succeed()
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
						tutorialBox.succeed()
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
				currentTutBox.text = 
					"Du besitzt jetzt zwei trAIns\nLehne dich zurück, entspanne und beobachte deine trAIns, "..
					"wie sie 10 Passagiere zu ihrem Ziel bringen. Gute Arbeit!\n\n".. numPassengers .." von 10 transportiert."
				if numPassengers >= 10 then
					nextTutorialStep()
					tutorialBox.succeed()
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
	
	love.graphics.print("Tutorial 3: Sei smart!", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Tutorial 3: Sei smart!")/2, y+10)
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
			passenger.new(3,5, 1,3, kidSpeaches[math.random(#kidSpeaches)])
			goWest = nil
		else
			passenger.new(3,5, 5,3, kidSpeaches[math.random(#kidSpeaches)])
			goWest = true
		end
	end
	
end

kidSpeaches = {}
kidSpeaches[1] = "Ich werde die Mathe-Prüfung verhauen..."
kidSpeaches[2] = "Habe heute Informatik. Hörte, dass wir heute was namens 'Lua' beginnen. Egal!."
kidSpeaches[3] = "Ich hab meine Hausis vergessen."
kidSpeaches[4] = "Schwänzen oder nicht Schwänzen, das ist hier die Frage..."
kidSpeaches[5] = "Das wird mein Untergang."
kidSpeaches[6] = "Letzter Schultag!"
kidSpeaches[7] = "Siehst du diesen Sonnenschein? Er sagt: 'Neeeein... geh nicht zur Schule!'"

fileContent = [[
-- Tutorial 3: Sei smart!

function ai.init()
	buyTrain(3,1)
end
]]
