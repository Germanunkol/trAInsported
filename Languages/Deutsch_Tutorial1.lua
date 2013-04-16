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
tutMap[1][2] = "PS"

tutorialSteps = {}
currentStep = 1

currentStepTitle = ""

currentTutBox = nil

local CODE_printHelloTrains = parseCode([[
print( "Hallo trAIns!" )
]])

local CODE_trainPlacing = parseCode([[
function ai.init()
	buyTrain( 1, 3 )
end
]])

local CODE_eventExamples = parseCode([[
-- Wird zum Rundenbeginn aufgerufen
function ai.init( map, money )

-- Wird aufgerufen wenn Zug an Kreuzung ankommt:
function ai.chooseDirection(train, possibleDirections)

-- Aufgrerufen, wenn Zug am Zielort des Passagiers ankommt.
function ai.foundPassengers(train, passengers)
]])

local CODE_pickUpPassenger1 = parseCode([[
-- Code der später den Passagier aufnehmen wird
function ai.foundPassengers( train, passengers )
	-- "Körper" der Funktion hier.
end
]])

local CODE_pickUpPassenger2 = parseCode([[
-- Code der den Passagier aufnimmt:
function ai.foundPassengers( train, passengers )
	return passengers[1]
end
]])
local CODE_dropOffPassenger = parseCode([[
function ai.foundDestination(train)
	-- Passagier absetzten:
	dropPassenger(train)
end
]])

function nextTutorialStep()
	tutorialBox.succeedOff()
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
	
	STARTUP_MONEY = 50
	timeFactor = 0.5
end

function tutorial.start()
	
	aiFileName = "TutorialAI1.lua"
	
	--ai.backupTutorialAI(aiFileName)
	ai.createNewTutAI(aiFileName, fileContent)

	stats.start( 1 )
	tutMap.time = 0
	map.print()
	
	loadingScreen.reset()
	loadingScreen.addSection("Neue Karte")
	loadingScreen.addSubSection("Neue Karte", "Größe: " .. tutMap.width .. "x" .. tutMap.height)
	loadingScreen.addSubSection("Neue Karte", "Zeit: Tag")
	loadingScreen.addSubSection("Neue Karte", "Tutorial 1: Baby Schritte")

	train.init()
	train.resetImages()
	
	ai.restart()	-- make sure aiList is reset!
	
	
	print("AI DIR:",AI_DIRECTORY)
	print("AI NAME:",aiFileName)
	
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
end


function tutorial.endRound()
	tutorial.placedFirstPassenger = nil
end

local codeBoxX, codeBoxY = 0,0
local tutBoxX, tutBoxY = 0,0

--[[
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
end]]--


function tutorial.createTutBoxes()

	CODE_BOX_X = love.graphics.getWidth() - CODE_BOX_WIDTH - 30
	CODE_BOX_Y = (love.graphics.getHeight() - TUT_BOX_HEIGHT)/2 - 50
	
	local k = 1
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Wie es begann..."
	tutorialSteps[k].message = "Willkommen bei trAInsported!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Tutorial beginnen", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Die nahe Zukunft: Vor ein paar Jahren wurde ein neues Produkt auf dem internationalen Markt veröffentlicht: Züge, die von Künstlicher Intelligenz gesteuert werden, besser bekannt als 'trAIns'."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Es gibt drei große Unterschiede zwischen normalen Zügen und trAIns. Erstens nehmen trAIns immer maximal einen Passagier auf einmal auf. Zweitens fahren sie (hoffentlich) genau dorthin, wo der Passagier hin will. Drittens werden sie komplett von Künstlicher Intelligenz (KI) gesteuert."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Theoretisch könnte dieses neue Verkehrssystem also Wunder bewirkt haben. Umweltverschmutzung ist gesunken, keiner braucht mehr eigene Fahrzeuge und es gibt keine Unfälle mehr aufgrund der hochintelligenten Systeme.\n\nEs gibt da nur ein Problem..."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Wo es Profit gibt, gibt es auch immer bald Konkurenz. Neue Unternehmen versuchen alle, im neuen Markt Fuß zu fassen. Und hier kommst du ins Spiel. Dein Job wird es sein, für dein Unternehmen die beste, effizienteste und schnellste KI zu programmieren!\nGenug geredet - fangen wir an!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Controls"
	tutorialSteps[k].message = "In diesem Tutorial lernst du:\n1) Die Bedienung des Spiels\n2) Wie man Züge kauft\n3) Wie du deinen ersten Passagier zum Ziel bringen kannst." 
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Klicke auf die Karte und Ziehe die Maus, um die Kamera zu bewegen. Mit dem Mausrad (oder Q und E) kannst du zoomen.\nDu kannst auch jederzeit F1 drücken, um die Hotkeys anzuzeigen - Versuche es!\nDanach geht das Tutorial weiter..."
	tutorialSteps[k].event = setF1Event(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Gut. Weiter im Text.\n\nDas Spiel hat einen Unterordner erstellt namens '" .. AI_DIRECTORY .. "'\n Darin findest du eine neue Datei die ich gerade erstellt habe, 'TutorialAI1.lua'. Öffne sie in einem beliebigen Text-Editor und lies den Text. "
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	if love.filesystem.getWorkingDirectory() then
		tutorialSteps[k].buttons[2] = {name = "Mehr Info", event = additionalInformation("Wenn du den Ordner nicht finden kannst, ist er möglicherweise versteckt. Suche am besten im Internet danach, wie man auf deinem System versteckte Ordner anzeigen kann, zum Beispiel: 'Windows 7 Zeige versteckte Ordner'\nAußerdem: Jeder normale Text Editor sollte genügen, aber es gibt ein paar kostenlose, die das Programmieren vereinfachen. Gute Beispiele, die man sich gerne angucken darf, sind:\nGedit, Vim (Linux)\nNotepad++ (Windows)"), inBetweenSteps = true}
		tutorialSteps[k].buttons[3] = {name = "Weiter", event = nextTutorialStep}
	else
		tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	end
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Kommunikation"
	tutorialSteps[k].message = "Okay, schreiben wir Code!\nDie erste Sache die wir lernen müssen ist wie du mit dem Spiel aus dem Code heraus kommunizieren kannst. Tippe den Code, der in der Code-Box rechts angezeigt wird ans Ende von TutorialAI1.lua. Wenn du fertig bist, speichere die Datei und klicke auf 'Neu Laden' am unteren Rand vom Spielfenster."
	tutorialSteps[k].event = firstPrint(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mehr Info", event = additionalInformation("Die 'print' Funktion druckt allen text (also alles zwischen \" Anführungszeichen) oder Variablen in die Konsole. Das wird dir später das finden von Fehlern erleichtern."), inBetweenSteps = true}
	--tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Gut gemacht.\n\n..."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Wie die KI funktioniert"
	tutorialSteps[k].message = "Es gibt bestimmte Funktionen, die die KI brauchen wird um zu funktionieren. In jeder Runde werden, wenn bestimmte Dinge passieren, passende Funktionen in deinem Code aufgerufen. Hier sind ein paar Beispiel in der Code-Box. Dein Job ist es also später, diese Funktionen mit Inhalt zu füllen."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = setCodeExamples
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Den ersten Zug kaufen!"
	tutorialSteps[k].message = "Schreibe jetzt den Code in der Code-Box unter die Zeile mit 'print', von vorher. Das wird deinen ersten Zug kaufen und ihn an die Position x=1, y=3 setzen. Die Karte ist in Quadrate eingeteilt. Halte 'M' gedrückt um die Koordinaten dieser Quadrate zu sehen. der X-Wert wird von links nach rechts größer, der Y-Wert von oben nach unten. Wenn du fertig bist, speichere wieder und wähle 'Neu Laden'."
	tutorialSteps[k].event = setTrainPlacingEvent(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mehr Info", event = additionalInformation("Achtung,\ndie Koordinaten (X und Y) laufen von 1 bis zur Breite (bzw Höhe) der Karte. Später zur mehr zur Kartenbreite bzw. -höhe.\nWenn du buyTrain mit Koordinaten aufrufst, die kein Quadrat mit Schiene beschreiben, wird das Spiel automatisch nach Schienen in der Nähe suchen und den Zug dorthin setzen."), inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Super, du hast gerade deinen ersten Zug auf die Karte gesetzt! Er wird automatisch immer weiter geradeaus fahren."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Du hast inzwischen eine einfach ai.init Funktion programmiert.\nDie Funktion 'ai.init()' ist die Funktion die später immer am Anfang des Spiels aufgerufen wird. In dieser Funktion kannst du später also die Karte analysieren, deine Vorgehensweise planen und - wie wir es eben getan haben - deinen ersten Zug kaufen."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mehr Info", event = additionalInformation("Die Funktion ai.init() wird immer mit 2 Argumenten aufgerufen, etwa so: ai.init( map, money )\nDas Erste beschreibt die momentane Karte (mehr dazu später) und das Zweite das Vermögen dass du zum Anfang schon hast. Du hast immer am Anfang genug Geld um mindestens einen Zug zu kaufen.\nAber für den Moment können wir diese Argumente vollkommen ignorieren."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Passagiere aufnehmen"
	tutorialSteps[k].message = "Ich habe eben einen Passagier auf die Karte gesetzt. Ihr Name ist GLaDOS. Halte die Leertaste gedrückt, um zu sehen wo sie hinwill!\n\nPassagiere erscheinen immer nur neben einer Schiene und wollen zu einem anderen Quadrat mit einer Schiene."
	tutorialSteps[k].event = setPassengerStart(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mehr Info", event = additionalInformation("GLaDOS will zum Kuchen-Laden. Sie hat mal Jemandem sehr wichtigem einen Kuchen versprochen, das Versprechen aber nie eingelöst.\n\n...\nDas soll sich jetzt ändern."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Dein Job ist es, den Passagier aufzunehmen und sie zu ihrem Ziel zu bringen. Dafür müssen wir die Funktion 'ai.foundPassengers' für unsere TutorialAI1 definieren. Diese Funktion wird immer dann aufgerufen, wenn einer deiner Züge ein Quadrat erreicht, auf dem mindestens ein Passagier steht."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Die Funktion ai.foundPassengers wird zwei Argumente haben: Das Erste, 'train', sagt uns, welcher Zug die Passagiere gefunden hat. Das Zweite, 'passengers', sagt uns, welche Passagiere gefunden wurden - nämlich die, die auf dem gleichen Quadrat stehen wie der Zug. Mit diesen beiden können wir gleich dem Zug sagen, welchen Passagier er aufnehmen soll."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Definieren wir zuerst unsere Funktion. Tippe den Code der in der Code-Box gezeigt wird in die .lua Datei. Du musst die Kommentare (Zeilen, die mit '- -' anfangen) nicht abtippen."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = pickUpPassengerStep1
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Du musst zwei Dinge wissen:\n1. 'passengers' ist eine Liste von allen Passagieren auf dem momentanen Quadrat.\nUm einzelne Passagiere anzusprechen kann man passengers[1], passengers[2], passenger[3] usw. verwendenen. Wenn die Funktion ai.foundPassengers einen Passagier zurückgibt - mit einem 'return' Statement -, dann wird der Zug diesen Passagier aufnehmen."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = pickUpPassengerStep1
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mehr Info", event = additionalInformation("Das heißt dass der Passagier nur dann aufgenommen wird, wenn der Zug nicht schon einen anderen Passagier befördert."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	
	tutorialSteps[k].message = "Es gibt nur einen Passagier, also ist in der Liste nur ein Passagier, der in diesem Fall durch passengers[1] angesprochen wird (ein Zweiter wäre passengers[2] usw). Wenn wir also diesen passenger[1] per 'return' zurückgeben wird GLaDOS in den Zug steigen.\nSchreibe die neue Zeile in die Funktion von eben, so wie in der Code-Box angezeigt.\nWenn du damit fertig bist, lade den Code neu und sieh zu, wie dein Zug GLaDOS aufnimmt!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = pickUpPassengerStep2(k)
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Du hast erfolgreich GLaDOS aufgenommen!\nDas Bild des Zuges hat sich verändert um anzuzeigen, dass er jetzt besetzt ist.\n\nWir sind fast fertig - wir müssen sie nur noch absetzen!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Aussteigen, bitte!"
	tutorialSteps[k].message = "Du kannst jederzeit Passagiere absetzen, indem du die Funktion dropPassenger(train) in deinem Programm aufrufst. Um die Dinge zu vereinfachen wird immer, wenn ein Zug am Ziel des Passagiers den er gerade trägt angekommen ist die Funktion ai.foundDestination() in deinem Programm aufgerufen - wenn du sie programmiert hast.\nAlso programmieren wir sie jetzt!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Schreibe die Funktion in der Code-Box ans Ende von TutorialAI1.lua.\nDann starte die Runde wieder neu und warte bis der Zug GLaDOS ans Ziel gebracht hat."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = dropOffPassengerEvent(k)
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Fertig!"
	tutorialSteps[k].message = "Yay, du hast das erste Tutorial beendet!\n\nKlicke auf 'Mehr Ideen' um ein paar Tipps zu bekommen, was du noch alles versuchen kannst bevor du mit dem nächsten Tutorial weitermachst."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	
	tutorialSteps[k].buttons[2] = {name = "Mehr Ideen", event = additionalInformation("1. Versuche etwas in die Konsole zu schreiben wenn der Zug einen Passagier aufnimmt und wenn er einen Passagier absetzt (z.B. 'Willkommen!' und 'Tschüss').\n2. Kaufe zwei Züge statt nur einem, indem du buyTrain zweimal aufrufst, in ai.init().\n3. Lass einen Zug rechts unten auf der Karte starten, statt links oben!"), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Direkt zum nächsten Tutorial oder zurück ins Menü:"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Schließen", event = endTutorial}
	tutorialSteps[k].buttons[3] = {name = "Nächstes Tutorial", event = nextTutorial}
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
						tutorialBox.succeed()	--play succeed sound!
					end
				end
			end
end


function setFirstPrintEvent(k)
	tutorial.consoleEvent = function (str)
					if str:sub(1, 13) == "[TutorialAI1]" then
						if str:upper() == string.upper("[TutorialAI1]\tHallo trAIns!") then
						
							tutorialSteps[k+1].message = "Super!\nDein Text sollte in the Konsole links erscheinen. Die Konsole zeigt dir auch, welche der KIs den Text geschriebebn hat, in diesem Fall TutorialAI1. Das wird später eine Rolle spielen, wenn mehr als eine KI im Spiel ist.\n(Wenn du den Text nicht sehen kannst, kannst du dieses Info-Fenster verschieben in dem du draufklickst und es wegziehst.)"
						else
							tutorialSteps[k+1].message = "Nicht genau der richtige Text, aber das passt schon.\n\nDein Text sollte in the Konsole links erscheinen. Die Konsole zeigt dir auch, welche der KIs den Text geschriebebn hat, in diesem Fall TutorialAI1. Das wird später eine Rolle spielen, wenn mehr als eine KI im Spiel ist.\n(Wenn du den Text nicht sehen kannst, kannst du dieses Info-Fenster verschieben in dem du draufklickst und es wegziehst.)"
						end
						tutorial.consoleEvent = nil
						if currentStep == k then
							nextTutorialStep()
							tutorialBox.succeed()
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
					tutorialBox.succeed()
				end
			end
		end
end

function setPassengerStart(k)
	return function()
		if not tutorial.placedFirstPassenger then
			passenger.new(5,4, 1,3, "Am Ende gibt es Kuchen. Und eine Party. Nein, wirklich!") 	-- place passenger at 3, 4 wanting to go to 1,3
			tutorial.placedFirstPassenger = true
			tutorial.restartEvent = function()
				print(currentStep, k)
					if currentStep >= k then	-- if I haven't gone back to a previous step
						passenger.new(5,4, 1,3, "Am Ende gibt es Kuchen. Und eine Party. Nein, wirklich!") 	-- place passenger at 3, 4 wanting to go to 1,3
						tutorial.placedFirstPassenger = true
					end
				end
		end
	end
end

function pickUpPassengerStep1()
	cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_pickUpPassenger1)
end

function pickUpPassengerStep2(k)
	return function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_pickUpPassenger2)
			tutorial.passengerPickupEvent = function()
				tutorial.passengerPickupEvent = nil
				if currentStep == k then
					nextTutorialStep()
					tutorialBox.succeed()
				end
			end
		end
end

function dropOffPassengerEvent(k)
	return function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_dropOffPassenger)
			tutorial.passengerDropoffCorrectlyEvent = function()
				tutorial.passengerDropoffCorrectlyEvent = nil
				if currentStep == k then
					nextTutorialStep()
					tutorialBox.succeed()
				end
			end
			tutorial.passengerDropoffWronglyEvent = function()		-- called when the passenger is dropped off elsewhere
				if currentTutBox then
					currentTutBox.text = "Passagier am falschen Ort abgesetzt!\n\nSchreibe die Funktion die in der Code-Box angezeigt wird in deine TutorialAI1.lua Datei!"
				end
			end
		end
end

function tutorial.roundStats()
	love.graphics.setColor(255,255,255,255)
	x = love.graphics.getWidth()-roundStats:getWidth()-20
	y = 20
	love.graphics.draw(roundStats, x, y)
	
	love.graphics.print("Tutorial 1: Baby Schritte", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Tutorial 1: Baby Schritte")/2, y+10)
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
-- Tutorial 1: Baby Schritte
-- Was du wissen solltest:
--	a) Zeilen die mit zwei Minus-Zeichen beginnen (--) sind Kommentare und werden vom Spiel ignoriert.
--	b) Alle dein Code wird in der Lua Skript-Sprache geschrieben.
--	c) Die Anfänge von Lua sind recht einfach zu lernen, und dieses Spiel wird sie dir Schritt für Schritt beibringen.
--	d) Lua ist nicht nur einfach sondern auch sehr, sehr schnell. Um es kurz zu fassen:
--	e) Lua doesn't suck.
-- Gehe jetzt wieder ins Spiel zurück und drücke dort auf den "Weiter" Knopf.
-- Noch eine Bemerkung: Es gibt Text Editoren die das Programmieren erleichtern, weil sie bestimmte Schlüsselwörter hervorherben und einfärben. Beispiel: Notepad++ oder gedit. Man findet auch viele, wenn man im Internet nach "Lua editor" sucht. Es funktioniert aber auch jedes normale Text Programm.
]]
