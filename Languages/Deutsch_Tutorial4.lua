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
-- Berechnet die Distanz zwischen zwei Punkten
-- Punkte sind: (x1,y1) und (x2,y2):
-- Gibt das Ergebnis zurück
function distance(x1, y1, x2, y2)
	res = sqrt( (x1-x2)^2 + (y1-y2)^2 )
	return res
end
]])

local CODE_foundPassengers1 = parseCode([[
function ai.foundPassengers( train, passengers )
	pass = nil	-- zurücksetzen, fall schon gesetzt
	dist = 100	-- mit einer hohen Distanz anfangen
	i = 1	-- beginne beim ersten Passagier
	while i <= #passengers do -- ... Schleife für alle Passagiere
		d = distance(train.x, train.y,
			passengers[i].destX, passengers[i].destY)
		if d < dist then  -- Falls diese Distanz die bis jetzt kleinste ist...
			dist = d		-- ... speichere sie.
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
-- Passagier absetzen
function ai.foundDestination(train)
	-- setze den Passagier ab, den 'train' gerade trägt.
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
	
	--ai.backupTutorialAI(aiFileName)
	ai.createNewTutAI(aiFileName, fileContent)

	stats.start( 1 )
	tutMap.time = 0
	map.print()
	
	loadingScreen.reset()
	loadingScreen.addSection("Neue Karte")
	loadingScreen.addSubSection("Neue Karte", "Größe: " .. tutMap.width .. "x" .. tutMap.height)
	loadingScreen.addSubSection("Neue Karte", "Zeit: Tag")
	loadingScreen.addSubSection("Neue Karte", "Tutorial 4: Näher ist besser!")

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
	tutorialSteps[k].stepTitle = "Schlauere Wahl"
	tutorialSteps[k].message = "In diesem Tutorial lernst du:\n\nWie man den Passagier wählt, den man aufnehmen will."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Beginne Tutorial", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Auf dieser Karte ist eine Gruppe von Passagieren. " ..
								"Alle davon wollen zu unterschiedlichen Zielen. (Leertaste zeigt die Ziele an). " ..
								"Aber nicht alle Ziele sind in der Nähe. " ..
								"Um so viele Passagiere so schnell wie möglich zu transportieren, "..
								"zeige ich dir jetzt, wie du den Passagier mit dem nächsten Ziel auswählst."
	-- tutorialSteps[k].message = "There is a group of people on this map. All of them want to go to different places. (Hold down Space to see where they want to go). However, not all of these places are nearby. To be efficient and transport as many passengers as possible (in as little time as possible), we'll learn how to choose the passenger with the shortest travel distance (meaning the distance between his start and destination points)."
	tutorialSteps[k].event = startCreatingPassengers(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Zuerst müssen wir berechnen, welcher Weg der kürzeste ist. " ..
								"Hierfür programmieren wir die Funktion 'distance'.\n"..
								"Wir benutzen den Satz des Pythagoras: \na²+b² = c² bzw. c = sqrt(a²+b²)"..
								"Tippe den Code in der Code-Box ab, dann drücke auf 'Weiter'."
	--tutorialSteps[k].message = "First, we need a way to decide which distance is the shortest. To do this, let's define a function called 'distance'.\nWe'll use the well-known pythagorian theorem:\na²+b² = c² or c = sqrt(a²+b²) in our case.\nType the code on the left into TutorialAI4.lua, then press Next."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_eucledianDist)
		end
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	--tutorialSteps[k].message = "Now whenever we enter a square with passengers on it (ai.foundPassengers is called) we will go through the list of passengers which are on the square and compare the distance between their starting coordinates and their end coordinates."
	tutorialSteps[k].message = "Immer, wenn wir auf ein Quadrat mit Passagieren fahren (also wenn ai.foundPassengers aufgerufen wird)"..
								"gehen wir durch die Liste von Passagieren und vergleichen die Distanz zwischen ihren Start- und Ziel-Koordinaten."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	--tutorialSteps[k].message = "The code shown here will first create a variable 'dist' with a very high value (100). This is larger than any distance we'll encounter on this map (because the map is only 7 tiles high and 7 tiles wide). Then we start going through the list of passengers one by one. For each passenger, we calculate the distance to their destination. If it is the smallest distance so far, we save the passenger (in 'pass') and the distance (in 'dist')."
	tutorialSteps[k].message = "Der hier gezeigte Code erstellt zunächst die Variable 'dist' und gibt ihr eine hohe Anfangszahl. "..
								"Diese Zahl ist höher als die größtmögliche Distanz. (Weil die Karte nur 7 auf 7 Quadrate groß ist. "..
								"Für jeden Passagier berechnen wir dann die Distanz von Start zu Ziel. "..
								"Wenn eine berechnete Distanz kürzer ist als die Distanzen, die wir zuvor berechnet haben, speichern wir die " ..
								"neue Distanz und den Passagier ab."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_foundPassengers1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	--tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("For advanced users: This code could of course be written more beautifully with a 'for-loop'. To keep the tutorial short, I won't cover for-loops here - there's plenty of examples online. If you have no idea what a for-loop is, ignore this message."), inBetweenSteps = true}
	tutorialSteps[k].buttons[2] = {name = "Mehr Info", event = additionalInformation("Für Fortgeschrittene: Man könnte diesen Code auch mit einem for-loop schreiben. Um das Tutorial kurz zu halten werden for-loops hier nicht erklärt; es gibt genug gute Beispiele online. Wenn dir 'for-loop' nichts sagt, ignoriere diesen Text einfach."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	--tutorialSteps[k].message = "At the end of the loop, the passenger with the shortest distance has been stored in 'pass'. This is the passenger we want to pick up, so add the line of code shown in the code box to the end of your function ai.foundPassengers (after the while loop)."
	tutorialSteps[k].message = "Am Ende der Schleife ist der Passagier mit der kürzesten Distanz in 'pass' gespeichert. Das ist der Passagier, den wir befördern wollen. Schreibe also die neue Zeile ans Ende der Funktion, um ihn aufzunehmen."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_foundPassengers2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	--tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("Of course, this method is still far from perfect. For example, the distance to a passenger's destination might be short, but if the train is headding in the wrong direction and can't turn around, it might still be wiser to transport another passenger.\nBut I'll leave this for you to figure out - later."), inBetweenSteps = true}
	tutorialSteps[k].buttons[2] = {name = "Mehr Info", event = additionalInformation("Natürlich ist diese Methode noch lange nicht perfekt. Zum Beispiel kann in einem echten Szenario die Distanz zu einem Ziel kurz sein, aber wenn der Zug gerade in die falsche (entgegengesetzte Richtung) fährt, kann es trotzdem sein, dass es besser wäre einen anderen Passagier zu befördern.\nDie Lösung hierfür kannst du dir aber selbst überlegen - später."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	--tutorialSteps[k].message = "Of course, we still need to drop off passengers when've reached the destination.\nAdd this final piece of code, then reload."
	tutorialSteps[k].message = "Wir müssen wieder die Passagiere absetzen, wenn wir ans Ziel kommen.\nHier ist wieder der Code dafür... nichts Neues dabei."
	tutorialSteps[k].event = handleDropOff(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	--tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("The tutorial will continue when you've transported 4 passengers correctly.\nWhen you transport the wrong passenger, the next set of passengers won't be created -> so make sure to always pick up the one with the shortes traveling distance.\nIf something doesn't work yet, just go back and fix it, then reload."), inBetweenSteps = true}
	tutorialSteps[k].buttons[2] = {name = "Mehr Info", event = additionalInformation("Das Tutorial springt weiter, sobald du 4 Passagiere richtig transportiert hast.\nSolltest du den falschen Passagier befördern, wird kein neuer generiert -> also nimm immer den richtigen auf.\nWenn etwas noch nicht richtig funktioniert, gehe zurück, ändere den Code und lade dann neu."), inBetweenSteps = true}
	k = k + 1
	
	
	tutorialSteps[k] = {}
	--tutorialSteps[k].stepTitle = "Done!"
	tutorialSteps[k].stepTitle = "Fertig!"
	--tutorialSteps[k].message = "You've completed the fourth tutorial! Now you should be ready to start the challenges.\nYou can also let specific AIs compete using the 'New Match' entry in the main menu.\nIf you're stuck, check out the wiki on " .. MAIN_SERVER_IP .. "!\nThere is also a full Documentation of all the ai functions available in the .love file (you'll have to download the Source of the game on Windows if you only downloaded the Executable up to now). Simply use a zip-program to extract it!"
	tutorialSteps[k].message = "Viertes Tutorial bestanden! Jetzt solltest du vorbereited sein, um das Spiel eigenständig weiterzuspielen.\nDu kannst über das 'Wettstreit'-Menü KIs gegeneinander antreten lassen.\nWenn du mal nicht weiter weißt, sieh dir das Wiki auf " .. MAIN_SERVER_IP .. " an!\nEs ist auch eine volle Doku online oder in der .love-version des Spieles (Wenn du die .exe Version hast, lade dir die .love-Datei von der Webseite herunter). Mit einem .zip Programm kannst du die .love entpacken."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Wenn deine KI fertig ist, lade sie auf die Webseite (" .. MAIN_SERVER_IP .. ") hoch und beobachte sie live dabei, wie sie gegen andere KIs antritt. Versuche, die High-Score-Listen zu rocken!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mehr Info", event = additionalInformation("Bevor du mit den Herausforderungen beginnst, hier ein paar Tipps:\n1) Viele Karten können von den einfachsten KIs gemeistert werden. Aber nur intelligente KIs haben eine Chance gegen online-Gegner.\n2) Versuche, Karten mit KIs zu spielen, die du schon fertig hast. Ändere die KIs nur dann, wenn sie nicht gewinnen.\n3) Transportiere NIEMALS Zombies.", CODE_moreIdeas), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Exit to the menu ... ?"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Beenden", event = endTutorial}
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
	
	love.graphics.print("Tutorial 4: Näher ist besser!", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Tutorial 4: Näher ist besser!")/2, y+10)
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
-- Tutorial 4: Näher ist besser!

function ai.init()
	buyTrain(1,1, 'E')
end
]]
