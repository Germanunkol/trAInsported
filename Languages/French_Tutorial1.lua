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
print( "Bonjour trAIns !" )
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

local CODE_pickUpPassenger1 = parseCode([[
-- code to pick up passengers:
function ai.foundPassengers( train, passengers )
	-- function body will go here later.
end
]])

local CODE_pickUpPassenger2 = parseCode([[
-- code to pick up passengers:
function ai.foundPassengers( train, passengers )
	return passengers[1]
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
	loadingScreen.addSection("Nouvelle carte")
	loadingScreen.addSubSection("Nouvelle carte", "Taille: " .. tutMap.width .. "x" .. tutMap.height)
	loadingScreen.addSubSection("Nouvelle carte", "Heure: Jour")
	loadingScreen.addSubSection("Nouvelle carte", "Tutoriel 1: Mes premiers pas !")

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
	tutorialSteps[k].stepTitle = "Comment tout a commencé..."
	tutorialSteps[k].message = "Bienvenue à trAInsported !"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Lancer le tutoriel", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "L'avenir proche:\nIl y a quelques années, un nouveau produit a été introduit sur le marché international: Le RER AI contrôlé, également connu sous le nom de 'trAIn'."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Il y a trois différences majeures entre les 'trAIns' et leurs sœurs plus âgées, les trains. D'une part, ils ne jamais ramasser un passager à la fois. Deuxièmement, ils vont exactement où leurs passagers veulent qu'ils aillent. Troisièmement, ils sont contrôlés par l'intelligence artificielle."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "En théorie, ce nouveau système de trafic pourrait faire des merveilles. La pollution a diminué, la nécessité pour les véhicules privés est parti et il n'y a pas plus d'accidents dus à une technologie très avancée. \n\nIl y a juste un problème ... "
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Là où il y a profit, la concurrence est jamais loin. Les nouvelles entreprises tentent de prendre le contrôle du marché. Et vous devez intervenir. Votre travail ici est de contrôler les trAIns de votre entreprise, en écrivant la meilleure intelligence artificielle pour eux\n\nAssez parlé, nous allons commencer !"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Contrôles"
	tutorialSteps[k].message = "Dans ce tutoriel, vous apprendrez:\n1) Les contrôles du jeu\n2) Achetez des trains\n3) Transporter vos premiers passagers" 
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Vous pouvez cliquez et faire glissez la vue partout sur la carte pour déplacez la vue. Utilisez la molette de la souris (ou Q et E) pour zoomez et dézoomez.\nEn tout temps, vous pouvez appuyez sur F1 pour obtenir un écran d'aide vous montrant les contrôles. Essayez-le !"
	tutorialSteps[k].event = setF1Event(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Bien continuons !\nOuvrez le dossier dans lequel tous vos scripts seront stockés en appuyant sur le bouton 'Ouvrir le dossier'. Dans ce document, vous trouverez le fichier TutorialA1.lua. Ouvrez-le avec un éditeur de texte pour le lire.\nSi le bouton ne fonctionne pas, vous pouvez également trouvez le dossier ici: " .. AI_DIRECTORY
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	if love.filesystem.getWorkingDirectory() then
		tutorialSteps[k].buttons[2] = {name = "Plus d'informations", event = additionalInformation("Si vous ne trouvez pas le dossier, il se peut qu'il soit caché. Tapez le chemin du dossier dans votre navigateur de fichier ou effectuez une recherche sur Internet pour «Afficher les fichiers cachés [nom de votre système d'exploitation]». Par exemple: 'Afficher les fichiers cachés sous Windows 7 '\nEn outre, un éditeur de texte normal devrait le faire, mais il y en a certains qui vous aidera lors de l'écriture du code.\n\nLes bons éditeurs libres à utilisez sont: Gedit, Vim(Linux) \ Notepad++(Windows)"), inBetweenSteps = true}
		tutorialSteps[k].buttons[3] = {name = "Suivant", event = nextTutorialStep}
	else
		tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	end
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "La communication"
	tutorialSteps[k].message = "Maintenant, nous allons écrire un peu de code !\nLa première chose que vous devez apprendre est comment communiquer avec le jeu. Tapez le code affiché sur la droite en bas de TutorialA1.lua. Une fois terminé, enregistrez-le et appuyez sur le bouton 'Rechargez' au bas de cette fenêtre."
	tutorialSteps[k].event = firstPrint(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Plus d'informations", event = additionalInformation("La fonction d'impression vous permet d'imprimez tout textes (Ce qui signifie quelque chose entre "("guillemets")" ou des variables à la console dans le jeu. Cela vous permettra de déboguer facilement votre code plus tard. Essayez-le tout de suite, vous verrez ce que je veux dire."), inBetweenSteps = true}
	--tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Bien joué !\n\n..."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Fonctionnalité d'IA générale"
	tutorialSteps[k].message = "Il y a certaines fonctions que votre IA aura besoin. Au cours de chaque tour, quand certaines choses se produisent, ces fonctions seront appelés. Il y a quelques exemples présentés dans la zone de code. Votre travail sera de remplir ces fonctions avec le contenu."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = setCodeExamples
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Acheter le premier train !"
	tutorialSteps[k].message = "Maintenant, ajoutez le code en bas à droite de votre appel d'impression. Cela va acheter votre premier train et le placer à la position x = 1, y = 3. La carte est divisée en carrés (vous pourriez avoir à zoomer pour les voir).\nX va de gauche à droite (c'est l'axe de l'abscisse) et Y de haut en bas (c'est l'axe de l'ordonnée) sont les coordonnées.\n(Appuyez et maintenez 'M' pour voir toutes les coordonnées !)\nLorsque vous avez terminé, enregistrez et cliquez sur «Rechargez»."
	tutorialSteps[k].event = setTrainPlacingEvent(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Plus d'informations", event = additionalInformation("Remarque:\n--les coordonnées (X et Y) va de 1 à la largeur (ou hauteur) de la carte. Vous en apprendrez plus sur la largeur et la hauteur maximum de la carte plus tard.\n--Si Vous appelez buyTrain avec des coordonnées qui ne décrivent pas un rail, le jeu placera le train sur le rail le plus proche qu'il peut trouver."), inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Oui, vous venez de placer votre premier train sur la carte ! Il continura à avancez automatiquement."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "You have programmed a simple ai.init function.\nThe function 'ai.init()' is the function in your script which will always be called when the round starts. In this function, you will be able to plan your train movement and - as you just did - buy your first trains and place them on the map."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Plus d'informations", event = additionalInformation("The function ai.init() is usually called with 2 argument, like so:\nfunction ai.init( map, money )\nThe first one holds the current map (more on that later) and the second one holds the amount of money you currently own. This way, you can check how many trains you can buy. You will always have enough money to buy at least one train at round start.\nFor now, we can just ignore these arguments, though."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Picking up a passenger"
	tutorialSteps[k].message = "I've just placed a passenger on the map. Her name is GLaDOS. Hold down the Space bar on your keyboard to see a line showing where she wants to go!\n\nPassengers will always be spawned near a rail. Their destination is also always near a rail."
	tutorialSteps[k].event = setPassengerStart(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Plus d'informations", event = additionalInformation("GLaDOS wants to go to the pie-store. She once promised a very special someone a cake.\n\n...\nAnd she wants to hold that promise."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Your job now is to pick up the passenger and take her where she wants to go. For this, we need to define a function 'ai.foundPassengers' for our TutorialAI1. This function is started whenever one of your trains reaches a square on which one or more passengers are standing."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "The function ai.foundPassengers will have two arguments: The first one, 'train', tells you which of your trains found the passenger. The second one, 'passengers', tells you about the passengers who are on the train's current position and could be picked up. Using these, you can tell the train which passenger to pick up."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "First, let's define our function. Type the code shown in the code box into your .lua file. You don't need to copy the comments (everything after the '- -'), they're just there to clarify things but are ignored by the game."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = pickUpPassengerStep1
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "What you need to know is two things:\n1. 'passengers' is a list of all passengers.\nTo access individual passengers, use passengers[1], passengers[2], passengers[3] etc.\n2. If the function ai.foundPassengers returns one of these passengers using the 'return' statement, then the game knows that you want to pick up this passenger and will do it for you, if possible."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = pickUpPassengerStep1
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("This means that the passenger will ONLY be picked up if the train does not currently hold another passenger."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Since we only have one passenger right now, there can only be one passenger in the list, who will be represented by passengers[1] (if there was a second passenger on the tile, that passenger would be passengers[2]). So, if we return this passengers[1], GLaDOS will be picked up.\nAdd the new line of code inside the function we just defined, as shown in the code box.\nOnce done, click Reload and watch your train pick up GLaDOS!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = pickUpPassengerStep2(k)
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "You successfully picked up GLaDOS!\nNote that the train's image changed to show that it now holds a passenger.\n\nWe're almost done, now we just need to place her down near the pie-store."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Drop 'er off!"
	tutorialSteps[k].message = "You can drop off your passenger at any time by calling the function dropPassenger(train) somewhere in your code. To make things easier for you, whenever a train arrives at the square which the current passenger wants to go to, the function ai.foundDestination() in your code will be called, if you have written it.\nLet's do that!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Add the function shown in the code box to the bottom of your TutorialAI1.lua.\nThen reload the code again and wait until the train has picked up GLaDOS and reached the pie store."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = dropOffPassengerEvent(k)
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Done!"
	tutorialSteps[k].message = "You've completed the first tutorial, well done!\n\nClick 'More Ideas' for some ideas of what you can try on your own before going to the next tutorial."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Ideas", event = additionalInformation("1. Try to print something to the console using the print function when the train picks up the passenger and when it drops her off (for example: 'Welcome!' and 'Good bye').\n2. Buy two trains instead of one, by calling buyTrain twice in ai.init()\n3. Make the train start on the bottom right instead of the top left."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Suivant", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Go directly to the next tutorial or return to the menu."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Retour", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Quit", event = endTutorial}
	tutorialSteps[k].buttons[3] = {name = "Tutoriel suivant", event = nextTutorial}
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
						if str:upper() == string.upper("[TutorialAI1]\tHello trAIns!") then
							tutorialSteps[k+1].message = "Well done.\n\nThe text you printed should now show up in the in-game console on the left. The console also shows which AI printed the text, in this case, TutorialAI1. This will play a role when you challenge other AIs later on.\n\n(If you can't see the text, move this info-window by clicking on it and dragging it somewhere else.)"
						else
							tutorialSteps[k+1].message = "Not quite the right text, but you get the idea.\n\nThe text you printed should now show up in the in-game console on the left. The console also shows which AI printed the text, in this case, TutorialAI1. This will play a role when you challenge other AIs later on.\n\n(If you can't see the text, move this info-window by clicking on it and dragging it somewhere else.)"
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
			passenger.new(5,4, 1,3, "There will be a cake at the end. And a party. No, really.") 	-- place passenger at 3, 4 wanting to go to 1,3
			tutorial.placedFirstPassenger = true
			tutorial.restartEvent = function()
				print(currentStep, k)
					if currentStep >= k then	-- if I haven't gone back to a previous step
						passenger.new(5,4, 1,3, "There will be a cake at the end. And a party. No, really.") 	-- place passenger at 3, 4 wanting to go to 1,3
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
					currentTutBox.text = "You dropped off the passenger at a wrong place!\n\nAdd the function shown in the code box to the bottom of your TutorialAI1.lua"
				end
			end
		end
end

function tutorial.roundStats()
	love.graphics.setColor(255,255,255,255)
	x = love.graphics.getWidth()-roundStats:getWidth()-20
	y = 20
	love.graphics.draw(roundStats, x, y)
	
	love.graphics.print("Tutorial 1: Baby Steps", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Tutorial 1: Baby Steps")/2, y+10)
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
-- Tutorial 1: Baby Steps
-- What you should know:
--	a) Lines starting with two dashes (minus signs) are comments, they will be ignored by the game.
--	b) All your instructions will be written in the Lua scripting language.
--	c) The basics of Lua are very easy to learn, and this game will teach them to you step by step.
--	d) Lua is extremly fast as well. In short:
--	e) Lua doesn't suck.
-- Now that you've successfully found the file and read this, go back to the game and press the "Next" button!
-- Note: There are text editors which highlight the keywords for the Lua language. Just search for Lua editors on the internet. This makes scripting easier but is NOT needed - any old text editor should do.
]]
