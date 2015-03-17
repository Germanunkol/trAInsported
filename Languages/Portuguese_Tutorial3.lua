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
	-- example: print the name of the train
	-- and the name of the passenger:
	-- (passenger is 'nil' if there is no passenger)
	if train.passenger == nil then
		print(train.name.." carries no passenger.")
	else
		print(train.name.." carries "..train.passenger.name)
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
		print(train.name.." carries no passenger.")
		-- go South because that's where the passengers are!
		return "S"
	else
		print(train.name.." carries "..train.passenger.name)
	end
end
]])

local CODE_chooseDirectionWithPassenger2 = parseCode([[
function ai.chooseDirection( train, directions )
	if train.passenger == nil then
		print(train.name.." carries no passenger.")
		return "S"
	else
		print(train.name.." carries "..train.passenger.name)
		if train.passenger.destX < train.x then
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
while i <= #passengers do
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
	
	--ai.backupTutorialAI(aiFileName)
	ai.createNewTutAI(aiFileName, fileContent)

	stats.start( 1 )
	tutMap.time = 0
	map.print()
	
	loadingScreen.reset()
	loadingScreen.addSection("Novo Mapa")
	loadingScreen.addSubSection("Novo Mapa", "Tamanho: " .. tutMap.width .. "x" .. tutMap.height)
	loadingScreen.addSubSection("Novo Mapa", "Tempo: Dia")
	loadingScreen.addSubSection("Novo Mapa", "Tutorial 3: Seja Inteligente!")

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
	tutorialSteps[k].message = "O terceiro Tutorial irá lhe ensinar:\n\n1) Como fazer escolhas mais inteligentes dependendo de onde seus passageiros querem ir\n2) Usando múltiplos trens."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Começar Tutorial", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Nesse mapa, há algumas crianças. Como são estudantes, alguns querem ir para a escola, alguns preferem não ir.\nComo programadores de trAIn, não é nosso trabalho julgar isso...\n(Segure a barra de espaço ou clique nos passageiros para ver seus destinos)"
	tutorialSteps[k].event =  startCreatingPassengers(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Seu trabalho é deslocar os passageiros para onde eles querem ir.\nNós poderiamos simplesmente tentar todas as direções até que cheguemos ao destino do passageiro, porém não seríamos muito competitivos para as outras AIs mais inteligentes. Em vez disso, nós iremos checar onde os passageiros querem ir e então deslocá-los conformemente."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Para fazer isso, iremos adicionar dois parâmetros para a função ai.chooseDirection, chamado de 'train' e 'directions'.\nAbra TutorialAI3.lua e adicione o código da caixa de código."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_chooseDirectionFunction1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "O parâmetro 'train' irá automaticamente ser preenchido com uma tabela representando o trem. A tabela tem os seguintes elementos: 'ID', 'name', 'x' e 'y'. Se o trem já estiver transportando um passageiro, então haverá mais um elemento na tabela chamado 'passenger' (uma tabela representando o passageiro). Essa tabela, novamente, tem os elementos 'destX' e 'destY' que armazenam o destino do passageiro e 'name' - o nome do passageiro. Adicione o novo código para sua função."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_chooseDirectionFunction2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Como no Tutorial1, nós precisamos adicionar o código para pegar o passageiro. Adicione-o para seu script...\n\nQuando você terminar, recarreque e veja se funcionou!"
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_pickUpPassenger)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "O próximo passo será: Sempre que o trem alcançar a junção e não houver passageiros a bordo, ele deverá ir para o sul. Adicione a linha de código conforme."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_chooseDirectionWithPassenger1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Se houver um passageiro a bordo, iremos comparar as coordenadas X da posição atual do trem (train.x) com a do destino do passageiro (train.passenger.destX). Se o destino for para o Oeste (destino X é menor que o X do trem) então iremos para o Oeste. Se não, iremos para o Leste.\nAdicione as novas partes na sua função."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_chooseDirectionWithPassenger2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "O último passo é largar o passageiro como fizemos antes.\n\nLogo que terminar todo o código, recarregue e observe se o trem larga os passageiros!\n(Você pode mudar a velocidade do tutorial pressionando + ou - )"
	tutorialSteps[k].event = waitingForPassengersEvent(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Info", event = additionalInformation("O jogo irá automaticamente para o próximo passo quando você largar um passageiro no Leste e o outro no Oeste."), inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Parece que você fez tudo certo, muito bem! Mais isso iria muito mais rápido se tivéssemos mais de um trem. Você começa o tutorial com um trem e 15 créditos. Um novo trem custa " .. TRAIN_COST .. " créditos. Sempre que você largar um passageiro, você ganhará dinheiro. Quando você tiver dinheiro suficiente para um novo trem, a função 'ai.enoughMoney' é chamada. Use-a para comprar um novo trem.\nQuando você terminar de escrever o código, recarregue."
	tutorialSteps[k].event = enoughMoneyEvent(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Agora você possui dois trens!\nAgora sente-se, relaxe e assista seus trens transportarem 10 passageiros para seus destinos. Você fez um bom trabalho!\n\n0 de 10 transportados."
	tutorialSteps[k].event = waitFor10Passengers(k)
	tutorialSteps[k].buttons = {}
	--tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Feito!"
	tutorialSteps[k].message = "Você completou o terceiro tutorial, muito bem!\nCom esse tutorial, você viu todo o básico. Clique em 'Mais Ideias' para seu primeiro desafio de verdade!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Ideias", event = additionalInformation("Tente fazer seu primeiro trem carregar somente os passageiros que querem ir para o Leste. Para fazer isso:\nNo ai.foundPassengers: cheque se train.ID é 1. Então, cheque se passengers[1] destX é maior que train.x.\nSe esse for o caso, pegue-o, caso não, vá para o passengers[2] e assim por diante. \nSe possível, use um while loop para ir através da lista de passageiros. Finalmente, faça seu segundo trem pegar somente os passageiros que querem ir para o Oeste. IMPORTANTE: #passengers é o comprimento da lista! Lembre-se 'break' lhe permite encerrar um loop quando encontrar um passageiro.", CODE_moreIdeas), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Vá diretamente para o próximo tutorial ou retorne para o menu."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Sair", event = endTutorial}
	tutorialSteps[k].buttons[3] = {name = "Próximo Tutorial", event = nextTutorial}
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
				currentTutBox.text = "Agora você possui dois trens!\nAgora sente-se, relaxe e assista seus trens transportarem 10 passageiros para seus destinos. Você fez um bom trabalho!\n\n" .. numPassengers .. " de 10 transportados."
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
	
	love.graphics.print("Tutorial 3: Seja Inteligente!", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Tutorial 3: Seja Inteligente!")/2, y+10)
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
kidSpeaches[1] = "Eu devo ter sido reprovado no teste de matemática..."
kidSpeaches[2] = "Tive aula de programação hoje. Ouvi dizer que iremos começar com algo chamado 'Lua'. Whatever."
kidSpeaches[3] = "Eu esqueci meu dever de casa."
kidSpeaches[4] = "Passar ou não passar, eis a questão..."
kidSpeaches[5] = "Isso será minha desgraça."
kidSpeaches[6] = "Último dia de aula!"
kidSpeaches[7] = "Tá vendo a luz do sol? Está dizendo: 'Nãããoooo... não vá para a escola!'"

fileContent = [[
-- Tutorial 3: Be smart!

function ai.init()
	buyTrain(3,1)
end
]]
