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
	
	--ai.backupTutorialAI(aiFileName)
	ai.createNewTutAI(aiFileName, fileContent)

	stats.start( 1 )
	tutMap.time = 0
	map.print()
	
	loadingScreen.reset()
	loadingScreen.addSection("Novo Mapa")
	loadingScreen.addSubSection("Novo Mapa", "Tamanho: " .. tutMap.width .. "x" .. tutMap.height)
	loadingScreen.addSubSection("Novo Mapa", "Tempo: Dia")
	loadingScreen.addSubSection("Novo Mapa", "Tutorial 4: Perto é bom")

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
	tutorialSteps[k].stepTitle = "Escolha mais inteligente"
	tutorialSteps[k].message = "Esse tutorial irá lhe ensinar:\n\nComo escolher qual passageiro pegar."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Começar Tutorial", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Há um grupo de pessoas nesse mapa. Todos eles querem ir a um lugar diferente. (Mantenha pressionado Espaço para ver onde eles querem ir). Entretanto, nem todos esses lugares são próximos. Para ser eficiente e transportar o maior número possível de passageiros (no menor tempo possível), iremos aprender como escolher passageiros com a menor distância de viagem (que significa a distância entre o ponto de partida e o destino)."
	tutorialSteps[k].event = startCreatingPassengers(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Primeiramente, precisamos uma maneira de decidir a menor distância. Para fazer isso, vamos definir uma função chamada 'distance'.\nNós iremos usar o famoso teorema de pitágoras:\na²+b² = c² ou c = sqrt(a²+b²) em nosso caso.\nDigite o código da direita no arquivo TutorialAI4.lua, e então pressione Próximo."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_eucledianDist)
		end
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Agora, sempre que entrarmos num quadrado com passageiros dentro dele (ai.foundPassengers é chamada) iremos percorrer a lista de passageiros que estão dentro do quadrado e comparar a distância entre as coordenadas de partida e as coordenadas do destino."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "O código mostrado aqui irá primeiro criar a variável 'dist' com um valor muito alto (100). Isso é maior que qualquer distância que iremos encontrar nesse mapa (porque o mapa só tem 7 tiles de altura e 7 tiles de largura). Então começamos a ir entre a lista de passageiros um por um. Para cada passageiro, nós calculamos a distância para seus destinos. Se for a menor distância até agora, salvamos o passageiro (em 'pass') e a distância (em 'dist')."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_foundPassengers1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Info", event = additionalInformation("Para usuários avançados: Esse código pode ser escrito de forma mais bonita com um 'for-loop'. Para mantar esse tutorial curto, Eu não vou falar sobre for-loops aqui - há bastante exemplos online. Se você não faz ideia do que um for-loop é, ignore essa mensagem."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "No final do loop, o passageiro com a menor distância foi armazenado em 'pass'. Esse é o passageiro que queremos pegar, então adicione a linha de código mostrada nessa caixa no fim da sua função ai.foundPassengers (depois do while loop)."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_foundPassengers2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Info", event = additionalInformation("De fato, esse método está longe de ser perfeito. Por exemplo, a distância para o destino do passageiro pode ser curta, mas se o trem está direcionado na direção oposta e não pode virar, pode ser mais inteligente transportar outro passageiro.\nMas eu vou deixar isso para você descobrir - depois."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "De fato, nós ainda precisamos deixar passageiros quando chegarmos no destino.\nAdicione esse pedaço de código, então recarregue."
	tutorialSteps[k].event = handleDropOff(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Info", event = additionalInformation("O tutorial irá continuar quando você transportar 4 passageiros corretamente.\nQuando você transporta o passageiro errado, o próximo conjunto de passageiros não será criado -> então certifique-se de sempre pegar o passageiro com menor distância de viagem.\nSe algo não funcionar, é só voltar e consertar, depois recarregue."), inBetweenSteps = true}
	k = k + 1
	
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Completo!"
	tutorialSteps[k].message = "Você concluiu o quarto tutorial! Agora deve estar pronto para começar os desafios.\nVocê também pode deixar AIs competindo entrando na opção 'Nova Partida' no menu principal.\nSe você estiver emperrado, confira a wiki e a documentação completa em " .. MAIN_SERVER_IP .. "!\n"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Quando você achar que estiver preparado, faça o upload da AI para o website (" .. MAIN_SERVER_IP .. ") e assista-o competir ao vivo, partidas online! Tente chegar ao topo do highscore!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Info", event = additionalInformation("Antes de você ir aos desafios, aqui estão alguns conselhos:\n1) Muitos mapas podem ser jogados com a AI mais básica. Entretanto, somente AIs mais avançadas irão ter alguma chance numa competição.\n2) Tente não completar mapas com AIs que você já escreveu. Só mude elas se não vencerem.\n3) NUNCA pegue zumbis.", CODE_moreIdeas), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Sair para o menu ... ?"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Sair", event = endTutorial}
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
	
	love.graphics.print("Tutorial 4: Escolha sabiamente!", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Tutorial 4: Choose wisely!")/2, y+10)
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
