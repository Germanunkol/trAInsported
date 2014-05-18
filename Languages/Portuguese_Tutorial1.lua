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
print( "Hello trAIns!" )
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
	loadingScreen.addSection("Novo Mapa")
	loadingScreen.addSubSection("Novo Mapa", "Tamanho: " .. tutMap.width .. "x" .. tutMap.height)
	loadingScreen.addSubSection("Novo Mapa", "Tempo: Dia")
	loadingScreen.addSubSection("Novo Mapa", "Tutorial 1: Passos de bebê")

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
	tutorialSteps[k].stepTitle = "Como tudo começou..."
	tutorialSteps[k].message = "Bem-vindo ao trAInsported!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Começar Tutorial", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "O futuro próximo:\nHá alguns anos atrás, um novo produto foi introduzido ao mercado internacional: O AI-controlled-Train, também conhecido como 'trAIn'."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Há três grandes diferenças entre 'trAIns' e suas irmãs mais velhas, os trens. Em primeiro lugar, eles sempre pegam somente um passageiro por vez. Em segundo lugar, eles vão exatamente onde seus passageiros querem ir. Em terceiro lugar, eles são controlados por inteligência artificial."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Em teoria, este novo sistema de tráfego poderia fazer maravilhas. A poluição diminuiu, a necessidade de veículos particulares de foi e não houve mais acidentes devido à tecnologia altamente avançada. \n\nHá apenas um problema... "
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Onde há lucro, sempre há competição. Novas empresas estão tentando ganhar o controle do mercado. E é aí que você entra. Seu trabalho aqui é controlar os trAIns da sua empresa - escrevendo a melhor inteligência artificial para eles.\nChega de conversa, vamos começar!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Controles"
	tutorialSteps[k].message = "Neste Tutorial, você irá aprender:\n1) Controles do jogo\n2) Comprar trens\n3) Transportar seu primeiro passageiro" 
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Você pode clicar e arrastar qualquer ponto do mapa para mover o ponto de vista. Use a roda do mouse (ou Q e E) para o zoom.\nA qualquer momento, você pode pressionar F1 para ver uma tela de ajuda mostrando-lhe os controles. Experimente!"
	tutorialSteps[k].event = setF1Event(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Boa. Vamos continuar.\nAbra a pasta onde todos os seus Scripts serão armazenados pressionando o botão 'Abrir pasta'. Nela, você irá encontrar o arquivo TutorialAI1.lua. Abra com qualquer editor de texto e leia.\nSe o botão não funcionar, você também pode encontrar a pasta aqui: " .. AI_DIRECTORY
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	if love.filesystem.getWorkingDirectory() then
		tutorialSteps[k].buttons[2] = {name = "Mais Informações", event = additionalInformation("Se você não consegue encontrar a pasta, ela pode estar oculta. Digite o caminho da pasta no seu gerenciador de arquivos ou pesquise na internet por 'mostrar arquivos ocultos [nome do seu sistema operacional]'. Por exemplo: 'mostrar arquivos ocultos Windows 7'\nAlém disso, qualquer editor de texto normal deve fazer isso, mas há alguns que irão lhe ajudar a escrever o código.\n\nAlguns editores gratuitos:\nGedit, Vim (Linux)\nNotepad++ (Windows)"), inBetweenSteps = true}
		tutorialSteps[k].buttons[3] = {name = "Próximo", event = nextTutorialStep}
	else
		tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	end
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Comunicação"
	tutorialSteps[k].message = "Agora, vamos escrever algum código!\nA primeira coisa que você tem de fazer é aprender a comunicar-se com o jogo. Digite o código mostrado à direita no final do seu arquivo TutorialAI1.lua. Feito isso, salve e pressione o botão 'Recarregar' na parte inferior da janela."
	tutorialSteps[k].event = firstPrint(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Informações", event = additionalInformation("A função print permite imprimir qualquer texto na tela (imprime tudo que está dentro das aspas) ou variáveis do console do jogo. Isso permite que você depure facilmente seu código mais tarde. Experimente e você verá o que eu quero dizer."), inBetweenSteps = true}
	--tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Muito bem.\n\n..."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Funcionalidades gerais da AI"
	tutorialSteps[k].message = "Há certas funções que o sua AI vai precisar. Durante cada round, quando certas coisas acontecem, essas funções serão chamadas. Há alguns exemplos mostrados na caixa de código. Seu trabalho será para preencher essas funções com o conteúdo."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = setCodeExamples
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Comprando o primeiro trem!"
	tutorialSteps[k].message = "Agora, adicione o código à direita abaixo do \"print\" que você escreveu. Isso irá comprar o seu primeiro trem e colocá-lo na posição x=1, y=3. O mapa é dividido em quadrados (você pode ter que aumentar o zoom para vê-los).\nX (da esquerda para a direita) e Y (de cima para baixo) são as coordenadas.\n(Pressione e segure 'M' para ver todas as coordenadas!)\nFeito isso, salve e clique em 'Recarregar'."
	tutorialSteps[k].event = setTrainPlacingEvent(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Informações", event = additionalInformation("Nota:\n-As coordenadas (X e Y) vão de 1 para a largura do mapa (or altura). Você vai aprender mais sobre a largura e altura máxima do mapa mais tarde.\n-Se você chamar buyTrain com coordenadas que não condizem com os trilhos, o jogo vai colocar o trem no trilho mais próximo que ele encontrar."), inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Yay, você acabou de colocar o seu primeiro trAIn no mapa! Ele se movimentará para frente automaticamente."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Você programou a simples função ai.init\nA função 'ai.init()' é a função em seu script que será sempre chamada quando da rodada começar. Nesta função, você será capaz de planejar o movimento de seus trens e - assim como você fez - comprar seus primeiros trens e colocá-los no mapa."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Informações", event = additionalInformation("A função ai.init() geralmente é chamada com 2 argumentos, tipo assim:\nfunction ai.init( map, money )\nO primeiro contém o mapa atual (mais sobre isso mais tarde) e o segundo tem a quantidade de dinheiro que você possui. Dessa forma, você pode verificar quantos trens você pode comprar. Você sempre terá dinheiro suficiente para comprar pelo menos um trem no início rodada.\nPor enquanto, podemos simplesmente ignorar esses argumentos."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Pegando um passageiro"
	tutorialSteps[k].message = "Acabei de colocar um passageiro no mapa. O nome dela é GLaDOS. Pressione e segure a barra de espaço no seu teclado para ver uma linha para onde ela quer ir!\n\nOs passageiros serão sempre gerados perto de um trilho. Seu destino também está sempre perto de um trilho."
	tutorialSteps[k].event = setPassengerStart(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Informações", event = additionalInformation("GLaDOS quer ir para a loja de tortas. Ela prometeu um bolo à alguém muito especial.\n\n...\nE ela quer manter essa promessa."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Seu trabalho agora é para pegar o passageiro e levá-la para onde ela quer ir. Para isso, nós precisamos definir a função 'ai.foundPassengers' no nosso TutorialAI1. Esta função é iniciada sempre que um de seus trens chega a uma praça em que um ou mais passageiros estão em pé."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "A função ai.foundPassengers terá dois argumentos: O primeiro, 'train', diz quais dos seus trens encontrou o passageiro. O segundo, 'passengers', fala sobre os passageiros que estão na masma posição do trem e poderá ser pego. Usando isso, você pode dizer ao trem qual passageiro pegar."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Primeiro, vamos definir nossa função. Digite o código mostrado na caixa de código em seu arquivo .lua. Você não precisa copiar os comentários (to=udo depois de '- -'), eles estão lá apenas para esclarecer as coisas, mas são ignorados pelo jogo."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = pickUpPassengerStep1
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "O que você precisa saber é duas coisas:\n1. 'passengers' é uma lista de todos os passageiros.\nPara acessar passageiros individuais, use passengers[1], passengers[2], passengers[3] etc.\n2. Se a função ai.foundPassengers retorna um destes passageiros usando o 'return', então o jogo sabe que você quer pegar esse passageiro e vai fazer isso por você, se possível."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = pickUpPassengerStep1
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Informações", event = additionalInformation("Isso significa que o passageiro SÓ vai ser pego se o trem não possuir um outro passageiro."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Como temos apenas um passageiro no momento, só pode haver um passageiro na lista, que será representado por passengers[1] (se houvesse um segundo passageiro, esse passageiro seria passengers[2]). Então, se retornarmos passengers[1], GLaDOS será pega.\nAdicione a nova linha de código dentro da função que acabamos de definir, como mostrado na caixa de código.\nFeito isso, clique em Reload e veja seu trem pegar GLaDOS!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = pickUpPassengerStep2(k)
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Você pegou GLaDOS com sucesso!\nNote que a imagem do trem foi altera para mostrar que passou a deter um passageiro.\n\nEstamos quase terminando, agora só precisamos deixá-la perto da loja de tortas."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Larga ela!"
	tutorialSteps[k].message = "Você pode deixar seu passageiro a qualquer momento chamando a função dropPassenger(train) em algum lugar no seu código. Para tornar as coisas mais fáceis para você, sempre que um trem chega na praça que o passageiro quer ir, a função ai.foundDestination() no seu código irá ser chamada, se você tiver escrito.\nVamos fazer isso!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Adicione a função mostrada na caixa de código no final do seu TutorialAI1.lua.\nEm seguida, recarregue o código novamente e aguarde até que o trem pegue GLaDOS e chegue na loja de tortas."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = dropOffPassengerEvent(k)
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Boa!"
	tutorialSteps[k].message = "Você completou o primeiro tutorial, muito bem!\n\nClique em 'Mais Ideias' para algumas idéias do que você pode tentar fazer antes de ir para o próximo tutorial."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Ideias", event = additionalInformation("1. Tente imprimir algo para o console usando a função print quando o trem pega o passageiro e quando ele a deixa (por exemplo: 'Bem-vindo!' e 'Adeus').\n2. Compre dois trens em vez de um, chamando a função buyTrain duas vezes no ai.init()\n3. Faça o trem iniciar na parte inferior direita, ao invés da parte superior esquerda."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Ir diretamente para o próximo tutorial ou voltar ao menu."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Sair", event = endTutorial}
	tutorialSteps[k].buttons[3] = {name = "Próximo Tutorial", event = nextTutorial}
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
							tutorialSteps[k+1].message = "Muito bem.\n\nO texto impresso agora deve aparecer no console do jogo do lado esquerdo. O console também mostra que AI é impressa no texto, neste caso, TutorialAI1. Isto irá desempenhar um papel importante quando você desafiar outros AIs mais tarde.\n\n(Se você não consegue ver o texto, mova esta janela clicando nela e arrastando para outro lugar.)"
						else
							tutorialSteps[k+1].message = "Não é bem o texto certo, mas você pegou a ideia.\n\nO texto impresso deve agora aparecer no console do jogo do lado esquerdo. O console também mostra que AI é impressa no texto, neste caso, TutorialAI1. Isto irá desempenhar um papel importante quando você desafiar outros AIs mais tarde.\n\n(Se você não consegue ver o texto, mova esta janela clicando nela e arrastando para outro lugar.)"
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
			passenger.new(5,4, 1,3, "Haverá um bolo no final. E uma festa. No, really.") 	-- place passenger at 3, 4 wanting to go to 1,3
			tutorial.placedFirstPassenger = true
			tutorial.restartEvent = function()
				print(currentStep, k)
					if currentStep >= k then	-- if I haven't gone back to a previous step
						passenger.new(5,4, 1,3, "There will be a cake at the end. And a party. Não, sério.") 	-- place passenger at 3, 4 wanting to go to 1,3
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
					currentTutBox.text = "Você deixou um passageiro em um lugar errado!\n\nAdicione a função mostrada na caixa de código no final do seu TutorialAI1.lua"
				end
			end
		end
end

function tutorial.roundStats()
	love.graphics.setColor(255,255,255,255)
	x = love.graphics.getWidth()-roundStats:getWidth()-20
	y = 20
	love.graphics.draw(roundStats, x, y)
	
	love.graphics.print("Tutorial 1: Passos de bebê", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Tutorial 1: Passos de bebê")/2, y+10)
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
