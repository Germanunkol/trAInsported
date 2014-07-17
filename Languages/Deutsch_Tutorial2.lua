tutorial = {}

tutMap = {}
tutMap.width = 5
tutMap.height = 5

for i = 0, tutMap.width+1 do
	tutMap[i] = {}
end

tutMap[1][1] = "C"
tutMap[2][1] = "C"
tutMap[2][2] = "C"
tutMap[2][3] = "C"
tutMap[3][2] = "C"
tutMap[4][2] = "C"
tutMap[5][2] = "C"


tutorialSteps = {}
currentStep = 1

currentStepTitle = ""

currentTutBox = nil

local CODE_variables1 = parseCode([[
-- definiere eine Variable "variable1":
variable1 = 10
-- definiere eine zweite Variable:
variable2 = 20

-- addiere die beiden und speichere das Ergebnis als variable3:
variable3 = variable1 + variable2
-- zeige das Ergebnis in der Konsole an:
print(variable3)	-- zeigt "30" an
]])

local CODE_variables2 = parseCode([[
-- definiere eine Variable "variable1":
variable1 = 10
-- definiere eine zweite Variable:
variable2 = "test"

-- das hier wird nicht funktionieren:
-- (es wird dir eine Fehlermeldung anzeigen, wenn du neu lädst)
variable3 = variable1 + variable2
]])
local CODE_variables3 = parseCode([[
-- füge "5.1" am Ende von "Lua" hinzu.
-- Das Ergebnis wird "Lua 5.1" sein.
myText = "Lua " .. 5.1

variable1 = 10
variable2 = "test"
-- füge die 10 an das Ende von "test" an:
variable3 = variable2 .. variable1
-- Ergebnis: "test10"
]])

local CODE_counter = parseCode([[
function ai.init()
	buyTrain(1,1)
	-- erstelle eine Variable "zaehler"
	zaehler = 0
end

function ai.chooseDirection()
	-- zähle die Kreuzungen:
	zaehler = zaehler + 1
	
	-- zeige an, wie vile Kreuzungen bereits befahren wurden:
	print("Dies ist die Kreuzung Nummer " .. zaehler)
end
]])

local CODE_functions1 = parseCode([[
function myFunction(argument1, argument2, ... )
	-- mach etwas mit den Argumenten
	-- gib eventuell etwas zurück
end

-- rufe die Funktion mit diesen Argumenten auf::
myFunction(1, "test", "3")
]])

local CODE_functions2 = parseCode([[
function subtraktion(a, b)
	c = a - b
	return c
end

ergebnis = subtraktion(10, 5)
print(ergebnis)	-- gibt '5' aus
]])

local CODE_ifthenelse1 = parseCode([[
if EXPRESSION1 then
	-- mach etwas
elseif EXPRESSION2 then
	-- mach etwas anderes
else
	-- mach eine dritte Sache
end

-- die Zeile 'mach etwas' wird nur ausgeführt, wenn
-- EXPRESSION1 wahr ist. Du wirst bald erfahren,
-- was eine EXPRESSION ist.
]])

local CODE_ifthenelse2 = parseCode([[
variable = 10

if variable == 10 then
	print("Die Variable ist 10...")
elseif variable > 10000 then
	print("Die Variable ist groß!")
else
	print("Weder 10 noch groß...")
end
]])



local CODE_whileLoop = parseCode([[
breite = 10
x = 0
--Dies wird 3, dann 6, dann 9, dann 12 ausgeben.
while x < breite do
	x = x + 3
	print(x)
end
]])

local CODE_whileLoop2 = parseCode([[
function ai.chooseDirection()
	-- zähle die Kreuzungen:
	zaehler = zaehler + 1
	
	i = 0	-- eine neue Zählvariable
	text = "" -- initialisiert ein leeres string
	while i < zaehler do
		text = text .. "x" 
		i = i + 1
	end
	-- zeige das Ergebnis an:
	print(text)
end
]])

local CODE_forLoop = parseCode([[
-- dies wird Zahlen von 1 bis 10 anzeigen:
breite = 10
for i = 1, breite, 1 do
	print(i)
end
-- das hier wird nur gerade Zahlen ausgeben ( 2, 4, 6, 8, 10)
width = 10
for i = 2, width, 2 do
	print(i)
end
]])

local CODE_loop3 = parseCode([[
i = 1
-- gehe durch die gesamte liste an Passagieren:
while i <= #passengers do
	-- jeder Passagier hat einen Namen, welcher über
	-- 'passenger[number].name' erreicht wird.
	-- finde den mit dem Namen 'Skywalker'.
	if passengers[i].name == "Skywalker" then
		print("Ich habe Luke gefunden!!")
		break	-- Hör auf zu suchen. Beende die Schleife!
	end
	i = i + 1
end
]])

local CODE_tables1 = parseCode([[
-- Beispiel 1:
myTable = {var1=10, var2="lol", var3="ein Bier"}

-- Beispiel 2: (Zeilenumbrueche sind erlaubt)
myTable = {
	x_Pos = 10,
	y_Pos = 20
}
-- Beispiel 3:
Huegel1 = {gefaelle="steil", schnee=true, hoehe=20}
Huegel2 = {gefaelle="steil", schnee=false, hoehe=10}
]])

local CODE_tables2 = parseCode([[
myTable = {
	x = 10,
	y = 20
}

-- berechne den Durchschnitt:
ergebnis = (myTable.x + myTable.y)/2
print(ergebnis)
-- wird 15 anzeigen, da (10+20)/2 = 15
]])

local CODE_tables3 = parseCode([[
myTable = { x = 10, y = 20 }

-- füge ein neues Element mit dem Namen 'z' hinzu:
myTable.z = 50

-- lösche das Element 'x':
myTable.x = nil

-- Das hier wird dir einen Fehler anzeigen,
-- da 'x' nicht mehr existiert:
a = myTable.x + 10
]])

local CODE_tables4 = parseCode([[
-- Wenn du die Namen weglässt, wird Lua automatisch
-- die Nummern [1], [2], [3] usw. benutzen:
myList = {"Aepfel", "Sind", "Rot"}

print(myList[1]) -- wird 'Aepfel' ausgeben.

-- ersetze "Rot" durch "Grün":
myList[3] = "Gruen"

-- wird ausgeben: "AepfelSindGruen"
print(myList[1] .. myList[2] .. myList[3])

]])

local CODE_hintGoEast = parseCode([[
-- Probier mal das:
function ai.chooseDirection()
	print("Ich will nach Osten!")
	return "E"
end
]])

local CODE_hintGoEastThenSouth = parseCode([[
function ai.init()
	buyTrain(1,1)
	zaehler = 0
end

function ai.chooseDirection()
	zaehler = zaehler + 1
	if zaehler == 1 then
		print("Erste Kreuzung! Geh nach Osten!")
		return "E"
	else
		print("Geh nach Süden!")
		return "S"
	end
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
			end
			l = l - 1
		end
	end
		
	currentTutBox = tutorialBox.new( TUT_BOX_X, TUT_BOX_Y, tutorialSteps[currentStep].message, tutorialSteps[currentStep].buttons )
end

function startThisTutorial()

	--define buttons for message box:
	if currentTutBox then tutorialBox.remove(currentTutBox) end
	currentTutBox = tutorialBox.new( TUT_BOX_X, TUT_BOX_Y, tutorialSteps[1].message, tutorialSteps[1].buttons )
	
	STARTUP_MONEY = 25
	timeFactor = 0.5
end

function tutorial.start()
	
	aiFileName = "TutorialAI2.lua"
	
	--ai.backupTutorialAI(aiFileName)
	ai.createNewTutAI(aiFileName, fileContent)

	stats.start( 1 )
	tutMap.time = 0
	map.print()
	
	loadingScreen.reset()
	loadingScreen.addSection("Neue Karte")
	loadingScreen.addSubSection("Neue Karte", "Größe: " .. tutMap.width .. "x" .. tutMap.height)
	loadingScreen.addSubSection("Neue Karte", "Zeit: Tag")
	loadingScreen.addSubSection("Neue Karte", "Tutorial 2: Links oder Rechts?")

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
end


function tutorial.endRound()

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
end
]]--


function tutorial.createTutBoxes()

	CODE_BOX_X = love.graphics.getWidth() - CODE_BOX_WIDTH - 30
	CODE_BOX_Y = (love.graphics.getHeight() - TUT_BOX_HEIGHT)/2 - 50
	
	local k = 1
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Wohin?"
	tutorialSteps[k].message = "Willkommen im zweiten Tutorial!\n\nHier wirst du lernen:\n1) Wie man mit Kreuzungen umgeht\n2) Lua basics\n3) Was man mit mehreren Passagieren macht\n4) Was VIPs sind"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Tutorial beginnen", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: Variablen"
	tutorialSteps[k].message = "Nun darf ich dir beibringen wie man mit Lua programmiert.\nIch habe versucht es auf die Grundlagen herunterzubrechen. Es mag viel sein, wenn du noch nie programmiert hast, aber halte durch - du musst dir jetzt noch nicht alles merken.\nIn Lua kannst du Variablen erzeugen, indem du einfach einem Namen (links von '=') einen Wert (rechts von '=') zuweist. Siehe die Beispiele in der Text Box."
	tutorialSteps[k].event = function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_variables1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Du kannst einer Variablen auch Texte oder andere Sachen zuordnen. Um Lua zu erklären, dass es sich bei etwas um einen Text handelt, musst du den Text mit Anführungszeichen (\") markieren.\n\nDu kannst Zahlen und Text nicht einfach miteinander verrechnen, da Lua nicht weiß, wie man einen Text 'addiert'.\nWieder gibt es in der Text-Box Beispiele."
	tutorialSteps[k].event = function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_variables2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mehr Info", event = additionalInformation("Gib Acht wenn du schon einmal in einer anderen Sprache programmiert hast: Lua verzeiht dir viel, wenn es um Variablen geht. Du kannst Text zu einer Variablen hinzufügen, die vorher Zahlen enthalten hat und umgekehrt. Es wird dein Programm nicht zum Abstürzen bringen, aber kann später Probleme verursachen."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Wenn du Text und Zahlen anneinanderfügen willst, kannst du dies tun, indem du .. zwischen sie schreibst. Das Ergebnis ist ein Text, welchen du als neue Variable speichern, in der Konsole ausgeben, oder mit dem du andere Sachen machen kannst.\n\nBeispiele, gibt es wie immer in der Text-Box."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_variables3)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Komm, wir probieren's mal aus!\nWir wollen einen Code schreiben, der die überquerten Kreuzungen zählt.\nWenn ein trAIn eine Kreuzung erreicht, wird das Spiel versuchen die Funktion 'ai.chooseDirection()' in deiner AI aufzurufen. Das bedeutet, dass - wenn deine AI eine Funktion ai.chooseDirection besitzt - wir jedesmal Code ausführen können, wenn ein trAIn eine Kreuzung anfährt."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Öffne die neu erstellte TutorialAI2.lua, aus dem gleichen Ordner wie zuvor.\n\nDie Datei enthält bereits Code, was der Grund dafür ist, dass es bereits einen trAIn auf der Karte gibt.\nGib den Text zu deiner Rechten ein (Du musst die bereits vorhandene ai.init ersetzen) und drücke dann auf 'Neu Laden'."
	tutorialSteps[k].event = eventCounter(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mehr Info", event = additionalInformation("Der Code wird nicht funktionieren, wenn du die Zeile 'zaehler = 0' weglässt, da die Variable erst initialisiert werden muss, bevor du ihr 1 hinzufügen kannst. Da ai.init immer VOR ai.chooseDirection aufgerufen wird, wird deine AI funktionieren."), inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Es scheint geklappt zu haben!\n\nLass uns mal sehen ob es die Kreuzungen richtig zählt. Wenn dies nicht der Fall ist, solltest du deinen Code weiter modifizieren bevor du weitermachst. Hat es geklappt, drücke auf 'Weiter' um fortzufahren."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: if, then, else"
	tutorialSteps[k].message = "Du wirst in deinem Code Entscheidungen treffen müssen. Hierfür sind 'if-then-else'-Statements nützlich.\nEin 'if'-Statement schaut ob eine EXPRESSION wahr, also true, ist und wenn dies der Fall ist, führt es den Code nach dem 'then'-Statement aus. Danach kannst du mit 'elseif', 'else' oder 'end' weitermachen, um den Codeblock zu beenden.\nSieh dir die Beispiele an."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_ifthenelse1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Eine 'EXPRESSION' ist ein Stück Text, welches Lua als entweder wahr, also true, oder falsch, also false, erkennen wird. Wenn Lua die EXPRESSION für wahr hält, wird sie den Code ausführen, andererseits wird sie ihn überspringen. Beispiele von EXPRESSIONS sind in der Text-Box aufgeführt. Beachte, dass du hier nicht das '=' benutzen darfst, sondern ein '==' benutzen musst! Sonst wäre es eine Zuweisung, anstelle eines Vergleichs.\nSiehe 'Mehr Info' für gültige EXPRESSIONS."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_ifthenelse2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mehr Info", event = additionalInformation("1) A == B (sind A und B gleich?)\n2) A > B (ist A größer als B?)\n3) A <= B (ist A kleiner oder gleich groß wie B?)\n4) A ~= B (ist A ungleich B?)"), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Beachte bei EXPRESSIONS noch folgendes: Wenn du schon einmal programmiert hast, wirst du wahrscheinlich die A != B (A ungleich B) EXPRESSION kennen. Aus irgendeinem Grund, benutzt Lua A ~= B anstelle von !=\n\nif variable ~= 10 then\n...\nend"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: Schleifen"
	tutorialSteps[k].message = "While-Schleifen sind ein ziemlich praktischer Bestandteil von Lua. Sie lassen dich etwas wiederholen, bis eine EXPRESSION falsch ist.\n\nwhile EXPRESSION do\n(Dein sich wiederhohlender Code)\nend"
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_whileLoop)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Zeit, das Gelernte auszuprobieren!\nWir werden nun unsere ai.chooseDirection-Funktion modifizieren. Anstelle einer Nummer an jeder Kreuzung, werden wir den Buchstaben 'x' sooft anzeigen, wie wir an der Kreuzung vorbeigefahren sind. (Das Erste mal werden wir 'x' ausgeben, das zweite mal 'xx' und so weiter.)\nDafür werden wir sooft 'x' an das Ende das Textes anfügen, wie 'zaehler' gerade groß ist und dann den Text ausgeben."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "... und hier ist der Code. Die Zeile = \"\" kreiert einen leeren Text (auch 'string' genannt) und i=0 startet einen neuen Zähler, damit wir zählen können, wie viele 'x' wir dem Text anhängen.\nÄndere deine ai.chooseDirection Funktion ab, lade neu und probier's aus.\n\nWenn es funktioniert, Glückwunsch! Drücke auf 'Weiter'."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_whileLoop2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	--[[
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "For-Loops let you do something a certain number of times. They work like this:\nfor i = START, END, STEP do\n(your code to repeat)\nend\nThis will count from START to END (using STEP as a stepsize)"
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_forLoop)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("There's also the 'generic' for loop which this tutorial won't cover. That's a very nice feature as well, check out the Lua documentation online for details."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	]]--
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: Funktionen!"
	tutorialSteps[k].message = "Du hast bereits im ersten Tutorial etwas über Funktionen gelernt.\nEine Funktion wir mit dem Schlüsselwort 'function' angefangen, gefolgt von ihrem Namen und ihren Argumenten in Klammern (). Darunter ist der Funktions-Körper, in dem dein Code steht. Wenn du willst, kannst du via 'return' Zahlen, Texte und mehr zurückgeben."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_functions1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Die Funktion endet mit 'end'.\nHast du die Funktion einmal definiert, kannst du die Funktion über ihren Namen aufrufen und Argumente weitergeben."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_functions1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Hier ist ein weiteres Beispiel.\n Wenn eine Funktion aufgerufen wird, gibt sie eine Nummer (c) zurück, welche sofort als Variable (ergebnis) gespeichert wird. Die Variable wird dann an die Konsole gegeben."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_functions2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Auf dieser Karte gibt es zum ersten Mal eine Kreuzung. Immer wenn ein trAIn eine Kreuzung erreicht, muss deine AI entscheiden, in welche Richtung der Zug fahren soll. Es gibt vier Richtungen: Nord (north), Süd (south), Ost (east) und West (west). Die Kreuzung auf dieser Karte zum Beispiel erlaubt es deinem Zug Richtung Norden, Osten und Süden zu fahren. Im Code werden die Richtungen \"N\", \"S\", \"E\" und \"W\" genannt."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1

	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Beachte den Zug auf der Karte. Wenn er eine Kreuzung erreicht, weiß er nicht was er tun soll, da wir es ihm bis jetzt noch nicht gesagt haben.\nDas voreingestellte Verhalten sagt dem Zug, dass er, wenn möglich, nach \"N\" fahren soll. Wenn nicht möglich (weil der Zug bereits von \"N\" kommt, oder weil die Kreuzung gar keine \"N\" Abzweigung hat), versucht er \"S\", dann \"E\", dann \"W\"."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Jedes Mal, wenn der Zug eine Kreuzung erreicht, gibt die AI etwas aus. Als nächstes müssen wir dem Zug sagen, in welche Richtung er fahren soll.\nWenn die Funktion ai.chooseDirection() \"E\" zurückgibt, wird das Spiel wissen, dass der Zug an der Kreuzung nach Osten fahren will. Lass nun deine Funktion \"E\" zurückgeben und lade dann neu."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = eventChooseEast(k)
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Tipp!", event = function()
		if cBox then codeBox.remove(cBox) end
		cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_hintGoEast)
		end, inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Du hast es geschafft! Dein Zug wird nun nach Osten abbiegen, wann immer es möglich ist...\n\nLass uns noch eine Sache probieren: Ich möchte, dass der Zug beim ersten Kreuzen der Kreuzung nach Osten fährt und sonst nur nach Norden oder Süden. Benutze den Kreuzungs-Zähler von vorhin mit einem 'if-then-else'-Statement. Nicht vergessen: um zwei Variablen zu vergleichen, benötigst du '==', nicht '=' ..."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = eventChooseEastThenSouth(k)
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mehr Info", event = additionalInformation("Du musst deinem Zug sagen, das erste Mal nach Osten, und sonst immer nach Süden zu gehen, da, wenn er von Süden kommt und du ihm sagst, er soll nach Süden gehen, wird er automatisch nach Norden gehen (da er nicht nach Süden gehen kann)...\n\nEs gibt mehr als eine Lösung hierfür. Aber sei vorsichtig: Alles was du nach dem 'return'-Statement tust, wird nicht ausgeführt, da das Spiel die Funktion beendet, sobald das 'return'-Statement erreicht wurde."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Tipp!", event = function()
		if cBox then codeBox.remove(cBox) end
		cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_hintGoEastThenSouth)
		end, inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Es hat geklappt!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: Tables"
	tutorialSteps[k].message = "Wir sind mit dem theoretischem Teil fast fertig.\nEs gibt eine weitere Sache die wir brauchen werden: die Lua-Tables.\nTables sind wahrscheinlich das Beste an Lua."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Eigentlich sind Tables eine Art 'Container' für mehrere Variablen. Du definierst Tables mit geschweiften Klammern { }. In den geschweiften Klammern wiederrum, kannst du Variablen genau wie zuvor definieren (trenne sie mit Kommata)."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_tables1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Hast du einmal ein Table definiert, kannst du die einzelnen Elemente mit Punkten erreichen. So wie hier:\nTABLE.ELEMENT\nSiehe Beispiele..."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_tables2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Du kannst auch neue Elemente hinzufügen (indem du ihnen eine Zahl oder einen Text zuweist) und alte löschen (indem du ihnen 'nil' zuweist)."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_tables3)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Die 'passengers'-Liste aus Tutorial 1 war auch ein Table. Hier haben wir Zahlen genutzt, um die Elemente aufzurufen, anstatt von Namen. Wenn du das tun willst, kannst du die Elemente mittels eckiger Klammern anwählen [ ], genau wie in Tutorial 1."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_tables4)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Noch ein Beispiel: Du kannst eine Schleife abbrechen, wenn eine EXPRESSION wahr ist. Zum Beispiel kannst du, wenn einen Passagier in einer Table gefunden hast, zum Ende der Schleife mithilfe von 'break' springen.\n(Ein '#' vor 'passengers' gibt dir die Länge der Liste. Dies funktioniert nur wenn du Nummern statt Namen verwendet hast.)\nMach dir keine Sorgen wenn das jetzt ein bisschen zu schnell ging; In Tutorial 3 darfst du es ausprobieren."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_loop3)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Das ist Alles, was du über Lua bis jetzt wissen musst!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Fertig!"
	tutorialSteps[k].message = "Du hast das zweite Tutorial absolviert, gut gemacht!\nKlicke auf 'Mehr Ideen' für ein paar Dinge die du mal allein probieren kannst, bevor du mit dem nächsten Tutorial weitermachst.\n\nMit diesem Tutorial haben wir den größten Teil der trockenen Theorie hinter uns - Die nächsten Tutorials werden etwas praktischer werden."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mehr Ideen", event = additionalInformation("Du kannst versuchen, nach Osten, dann nach Norden, dann nach Süden, und dann wieder nach Osten und so weiter zu fahren (Osten, Norden, Süden, Osten, Norden, Süden, Osten ...).\n Erzeuge hierzu ein Variable \"dir\" in ai.init(). Dann füge ihr immer 1 hinzu (dir = dir + 1) wenn die Funktion ai.chooseDirection aufgerufen wird. Dann gib \"E\", \"N\" oder \"S\" zurück, wenn dir 1, 2 oder 3 ist. Vergiss nicht dir wieder auf 1 zu setzten wenn es größer als 3 ist!", CODE_moreIdeas), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Weiter", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Gehe zum nächsten Tutorial oder zurück ins Menü."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Zurück", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Schließen", event = endTutorial}
	tutorialSteps[k].buttons[3] = {name = "Nächstes Tutorial", event = nextTutorial}
	k = k + 1
end


function eventCounter(k)
	return function()
			local count = 0
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_counter)
			tutorial.consoleEvent = function( str )
					
					if str:sub(1, 13) == "[TutorialAI2]" then
						count = count + 1
						if count == 2 then
							tutorial.consoleEvent = nil
							if currentStep == k then
								nextTutorialStep()
								tutorialBox.succeed()
							end
						end
					end
				end
		end
end

function eventFirstChooseDirection(k)
	return function()
			tutorial.chooseDirectionEvent = function()
				tutorial.consoleEvent = function (str)
						if str:sub(1, 13) == "[TutorialAI2]" then
							tutorial.consoleEvent = nil
							tutorial.chooseDirectionEvent = nil
							tutorial.chooseDirectionEventCleanup = nil
							if currentStep == k then
								nextTutorialStep()
								tutorialBox.succeed()
							end
						end
					end
				end
			tutorial.chooseDirectionEventCleanup = function()
					tutorial.consoleEvent = nil
				end
		end
end

function eventChooseEast(k)
	return function()
			tutorial.reachedNewTileEvent = function(x, y)
					if x == 3 and y == 2 then
						tutorial.reachedNewTileEvent = nil
						if currentStep == k then
							nextTutorialStep()
							tutorialBox.succeed()
						end
					end
				end
		end
end

function eventChooseEastThenSouth(k)
	junctionCount = 0
	local beenEast, beenSouth = false, false
	return function()
	
			tutorial.restartEvent = function()
					junctionCount = 1
					beenEast = true
					tutorial.reachedNewTileEvent = function(x, y)
						if x == 3 and y == 2 and beenEast == false and beenSouth == false then
							beenEast = true
						end
						if x == 2 and y == 3 then
							beenSouth = true
							if beenEast == true then
								tutorial.reachedNewTileEvent = nil
								tutorial.restartEvent = nil
								if currentStep == k then
									nextTutorialStep()
									tutorialBox.succeed()
								end
							else
								if currentStep == k then
									if currentTutBox then
										currentTutBox.text = "Du solltest zuerst nach Osten gehen und dann nach Süden! Bearbeite den Code und lade dann neu."
									end
								end
							end
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
	menu.executeTutorial("Tutorial3.lua")
end

function tutorial.roundStats()
	love.graphics.setColor(255,255,255,255)
	x = love.graphics.getWidth()-roundStats:getWidth()-20
	y = 20
	love.graphics.draw(roundStats, x, y)
	
	love.graphics.print("Tutorial 2: Links oder Rechts?", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Tutorial 2: Links oder Rechts?")/2, y+10)
	love.graphics.print(currentStepTitle, x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth(currentStepTitle)/2, y+30)
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
-- Tutorial 2: Links oder Rechts?

-- kaufe zu Beginn der Runde einen Zug und platziere ihn am oberen rechten Rand des Spielfelds:
function ai.init( map, money )
	buyTrain(1,1)
end
]]
