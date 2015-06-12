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
-- define a variable called "variable1":
variable1 = 10
-- define a second one:
variable2 = 20

-- add the two together and store the result in variable3:
variable3 = variable1 + variable2
-- show the result in the console:
print(variable3)	-- prints 30
]])

local CODE_variables2 = parseCode([[
-- define a variable called "variable1":
variable1 = 10
-- define a second one:
variable2 = "testing"

-- the following won't work
-- (it'll give you an error when you press 'reload')
variable3 = variable1 + variable2
]])
local CODE_variables3 = parseCode([[
-- add "5.1" to the end of "Lua".
-- the result will be "Lua 5.1".
myText = "Lua " .. 5.1

variable1 = 10
variable2 = "testing"
-- append the 10 to the end of "testing":
variable3 = variable2 .. variable1
-- result: "testing10"
]])

local CODE_counter = parseCode([[
function ai.init()
	buyTrain(1,1)
	-- create variable called "counter"
	counter = 0
end

function ai.chooseDirection()
	-- count the junctions:
	counter = counter + 1
	
	-- show how many junctions we have reached:
	print("This is junction number: " .. counter)
end
]])

local CODE_functions1 = parseCode([[
function myFunction(argument1, argument2, ... )
	-- do something with the arguments
	-- possibly return something
end

-- call the function with three arguments:
myFunction(1, "test", "3")
]])

local CODE_functions2 = parseCode([[
function subtract(a, b)
	c = a - b
	return c
end

result = subtract(10, 5)
print(result)	-- will print '5'
]])

local CODE_ifthenelse1 = parseCode([[
if EXPRESSION1 then
	-- do something
elseif EXPRESSION2 then
	-- do something else
else
	-- or do a third thing
end

-- the code 'do something' will only be executed if
-- EXPRESSION is true. You'll learn what an EXPRESSION
-- is soon.
]])

local CODE_ifthenelse2 = parseCode([[
variable = 10

if variable == 10 then
	print("The variable is 10...")
elseif variable > 10000 then
	print("The variable is large!")
else
	print("Neither 10 nor very large...")
end
]])



local CODE_whileLoop = parseCode([[
width = 10
x = 0
--this will print 3, then 6, then 9, then 12.
while x < width do
	x = x + 3
	print(x)
end
]])

local CODE_whileLoop2 = parseCode([[
function ai.chooseDirection()
	-- count the junctions:
	counter = counter + 1
	
	i = 0	-- a new counting variable
	text = "" -- initialise empty string
	while i < counter do
		text = text .. "x" 
		i = i + 1
	end
	-- print the result:
	print(text)
end
]])

local CODE_forLoop = parseCode([[
-- this will print numbers from 1 to 10:
width = 10
for i = 1, width, 1 do
	print(i)
end
-- this will only print even numbers ( 2, 4, 6, 8, 10)
width = 10
for i = 2, width, 2 do
	print(i)
end
]])

local CODE_loop3 = parseCode([[
i = 1
-- go through the whole list of passengers:
while i <= #passengers do
	-- each passenger has a name, accessed by
	-- 'passenger[number].name', Find the one named Skywalker.
	if passengers[i].name == "Skywalker" then
		print("I found Luke!!")
		break	-- stop looking. End the loop!
	end
	i = i + 1
end
]])

local CODE_tables1 = parseCode([[
-- example 1:
myTable = {var1=10, var2="lol", var3="a beer"}

-- example 2: (Newlines are acceptable)
myTable = {
	x_Pos = 10,
	y_Pos = 20
}
-- example 3:
hill1 = {slope="steep", snow=true, size=20}
hill2 = {slope="steep", snow=false, size=10}
]])

local CODE_tables2 = parseCode([[
myTable = {
	x = 10,
	y = 20
}

-- calculate the average:
result = (myTable.x + myTable.y)/2
print(result)
-- will print 15, because (10+20)/2 = 15
]])

local CODE_tables3 = parseCode([[
myTable = { x = 10, y = 20 }

-- add a new element called 'z':
myTable.z = 50

-- remove the element 'x':
myTable.x = nil

-- this will throw an error because 'x' no longer exists:
a = myTable.x + 10
]])

local CODE_tables4 = parseCode([[
-- If you leave away the names, Lua will automatically
-- use the numbers [1], [2], [3] and so on:
myList = {"Apples", "Are", "Red"}

print(myList[1]) -- will print 'Apples'.

-- replace "Red" with "Green":
myList[3] = "Green"

-- will print: "ApplesAreGreen"
print(myList[1] .. myList[2] .. myList[3])

]])

local CODE_hintGoEast = parseCode([[
-- Try this:
function ai.chooseDirection()
	print("I want to go East!")
	return "E"
end
]])

local CODE_hintGoEastThenSouth = parseCode([[
function ai.init()
	buyTrain(1,1)
	counter = 0
end

function ai.chooseDirection()
	counter = counter + 1
	if counter == 1 then
		print("First junction! Go east!")
		return "E"
	else
		print("Go South!")
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
	loadingScreen.addSection("Novo Mapa")
	loadingScreen.addSubSection("Novo Mapa", "Tamanho: " .. tutMap.width .. "x" .. tutMap.height)
	loadingScreen.addSubSection("Novo Mapa", "Tempo: Dia")
	loadingScreen.addSubSection("Novo Mapa", "Tutorial 2: Esquerda ou Direita?")

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
	tutorialSteps[k].stepTitle = "Para onde ir?"
	tutorialSteps[k].message = "Bem-Vindo ao segundo Tutorial!\n\nAqui, você irá aprender:\n1) Como manusear junções\n2) Básicos de Lua\n\nInfelizmente, nós vamos ter que cobrir alguma teoria aqui - mas vai valer a pena quando chegarmos aos Tutoriais 3 e 4!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Começar Tutorial", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: Variáveis"
	tutorialSteps[k].message = "Agora eu preciso lhe ensinar como escrever o código em Lua.\nHá muita coisa que eu poderia lhe dizer; Eu tentei reduzir para o básico. Pode parecer muito, se você nunca programou antes, mas tente aguentar firme - você não precisa lembrar de tudo ainda.\nEm Lua, você pode criar variáveis simplesmente atribuíndo algum valor (a direita do '=') para um nome (esquerda do '=').\nVeja alguns exemplos na caixa de código."
	tutorialSteps[k].event = function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_variables1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Você também pode atribuir textos ou outras coisas para o nome da variável. Para dizer a Lua que algo deve ser manipulado como texto, você precisa cercar o texto por aspas (\").\n\nVocê não pode simplesmente adicionar texto e números juntos, porque Lua não sabe como 'adicionar' texto.\nNovamente, há um exemplo na caixa de código."
	tutorialSteps[k].event = function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_variables2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Info", event = additionalInformation("Se você já programou outra linguagem antes, seja cuidadoso: Lua é muito indulgente quando se trata de tipos de variáveis. Você pode colocar texto dentro de uma variáviel que antes estava armazenando um número e vice versa. Isso não irá quebrar seu programa, mas pode lhe dar problemas mais tarde."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Se você quiser acrescentar textos ou números juntos, você pode fazer isso escrevendo .. entre eles. O resultado será o texto, que você pode armazenar em outra variável, imprimir no console, ou fazer outras coisas.\n\nO exemplo, como sempre, está na caixa de código."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_variables3)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Vamos tentar!\nNós iremos escrever o código que irá contar as junções que o trem passar.\nQuando um trAIn alcançar uma junção, o jogo sempre irá tentar chamar a função 'ai.chooseDirection()' no seu código de AI. Isso significa que se seu arquivo de AI conter a função ai.chooseDirection, você poderá fazer algo toda vez que um trAIn alcançar uma junção."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Abra o recém criado TutorialAI2.lua, de dentro da mesma pasta de antes.\n\nJá tem algum código no arquivo, e é por isso que já tem um trem no mapa.\nAdicione o código na direita (substitua o ai.init que já existe), então pressione 'Recarregar'."
	tutorialSteps[k].event = eventCounter(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Info", event = additionalInformation("O código irá falhar se você esquecer a linha 'counter = 0', porque antes que você possa adicionar 1 para a variável, ela precisa ser inicializada. Desde que ai.init rode ANTES de ai.chooseDirection, então o código irá funcionar"), inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Isso parece funcionar!\n\nVeja se a AI conta as junções corretamente. Se não, modifique seu código até funcionar. Se funcionou, pressione Próximo para continuar."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: if, then, else"
	tutorialSteps[k].message = "Você irá precisar fazer decisões em seu código. Para isso, 'if-then-else' são úteis.\nUm 'if' checa se alguma EXPRESSÃO é verdadeira, se for, executa o código depois do 'then'. Depois disso, você pode prosseguir com o 'elseif', 'else' ou 'end' para finalizar o bloco de cóodigo.\nConfira o exemplo."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_ifthenelse1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Uma 'EXPRESSÃO' é um pedaço de código que Lua irá interpretar como verdadeiro ou falso. Se Lua achar que a expressão é verdadeira, irá executar o código, caso contrário, não irá executar. Os exemplos dessas expressões estão na caixa de código. Note que aqui, você não pode usar '='. Em vez, você irá precisar de '=='! Caso contrário seria uma atribuição, que não é algo para Lua checar.\nConfira 'Mais Info' para expressões válidas."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_ifthenelse2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Info", event = additionalInformation("1) A == B (A e B são iguais?)\n2) A > B (A é maior que B?)\n3) A <= B (A é menor ou igual a B?)\n4) A ~= B (A não é igual a B)"), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Uma  última nota sobre expressões: Se você já programou antes, você deve saber que A != B (A não é igual a B). Por alguma razão, Lua usa A ~= B em vez!\n\nif variable ~= 10 then\n...\nend"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: Loops"
	tutorialSteps[k].message = "While-Loops também são recursos úteis. Eles lhe permitem repetir algo até que uma EXPRESSÃO seja falsa.\n\nwhile EXPRESSION do\n(your code to repeat)\nend"
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_whileLoop)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Hora de tentar!\nNós iremos modificar o ai.chooseDirection. Em vez de imprimir um número a cada junção, nós iremos imprimir a letra 'x' o tanto de vezes que passarmos pela junção. (A primeira vez iremos imprimir 'x', a segunda vez iremos imprimir 'xx' e assim por diante.)\nPara fazer isso, nós utilizaremos a variável 'counter', assim como antes. Então adicionaremos 'x' no fim de um texto quando 'counter' estiver alta, e então imprimir o texto."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
		tutorialSteps[k].message = "... a aqui está o código. A linha de texto = \"\" cria um texto vazio (também chamado de 'string'), e i=0 começa um novo contador, então nós podemos contar quantos 'x' nós adicionamos para o texto.\nAltere sua função ai.chooseDirection, recarregue, e experimente.\n\nSe funcionar, comemore, e pressione 'Próximo'."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_whileLoop2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
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
	tutorialSteps[k].stepTitle = "Lua: Funções!"
	tutorialSteps[k].message = "Você já aprendeu um pouco sobre funções no primeiro tutorial.\nUma função é criada usando a keyword 'function', seguida pelo nome da função e os argumentos que ficam entre parênteses (). Então é no corpo da função onde seu código fica. Se você quiser, pode retornar qualquer número ou texto utilizando 'return'."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_functions1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "A função termina com a keyword 'end'.\nUma vez que a função foi definida, vodê pode chamá-la usando o nome da função e passar os argumentos."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_functions1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Aqui está outro exemplo simples.\n Quando essa função é chamada, ela retorna o número (c), que é salva diretamente em uma variável (result). Essa variável é então impressa no console."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_functions2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Nesse mapa, há um novo elemento: Uma junção. Sempre que um trem alcança um conjunto de junções, seu AI precisa decidir para onde seu trem deve ir. Há quatro direções que o trem pode se mover: norte, sul, leste e oeste. Por exemplo, a junção nesse mapa irá permitir um trem ir para o norte (cima), leste (direita) e sul (baixo).\nNo código, as direções serão chamadas de \"N\", \"S\", \"E\" e \"W\"."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Repare no trem do mapa. Quando ele chegar na junção, ele não saberá o que fazer porque não lhe dissemos ainda.\nO comportamento padrão é ir para o \"N\" se possível. Se não puder (quando vier do \"N\" ou porque a junção não possuir uma saída \"N\"), então ele irá tentar \"S\", então \"E\", então \"W\", a não ser que lhe dissermos outra coisa, que é o que iremos fazer agora."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Toda vez que o trem alcançar a junção, irá imprimir algo e então continuar.\nO próximo passo é escolhar uma direção para o trem. O comportamento padrão atual é ir para o norte ou - se não puder ir para o norte - irá para o sul.\n\nSe a função ai.chooseDirection() retornar \"E\", entã o jogo ira saber que o trem quer ir para o lest na junção. Faça sua função retornar \"E\", então recarregue."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = eventChooseEast(k)
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Dica!", event = function()
		if cBox then codeBox.remove(cBox) end
		cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_hintGoEast)
		end, inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Você conseguiu! Seu trem agora irá viajar para o leste sempre que puder...\n\nVamos tentar mais uma coisa: Agora eu quero que o trem vá para o leste na primeira vez que alcançar a junção, e então ir somente para o sul ou norte. Use o contador de junção que escrevemos antes e um 'if-then-else'. Lembre-se: para checar se uma variável é igual a algo, você precisa usar '==', não '=' ..."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = eventChooseEastThenSouth(k)
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Info", event = additionalInformation("Isso será o suficiente para dizer ao trAIn para ir ao leste na primeira vez e caso contrário ir para o sul, porque, quando estiver vindo do sul e você mandar ir para o sul, ele irá automaticamente por padrão ir para o norte (porque ele não pode ir para o sul)...\n\nHá mais de uma solução para isso. Mas seja cuidadoso: Tudo que você fizer depois do 'return' não será executado, porque quando o jogo chegar no 'return', irá terminar a função."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Dica!", event = function()
		if cBox then codeBox.remove(cBox) end
		cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_hintGoEastThenSouth)
		end, inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Funcionou!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: Tables"
	tutorialSteps[k].message = "Nós estamos quase terminando a parte teórica.\nHá mais uma coisa que precisamos, entretanto, que são Lua tables.\nTabelas são provavelmente, a funcionalidade mais poderosa que Lua tem a oferecer."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Basicamente, uma tabela é um 'container' para mais variáveis. Você definir um tabela usando colchetes { }. Dentro dos colchetes, você pode definir novamente variáveis, assim como você fez anteriormente (separando elas por vírgulas)."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_tables1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Uma vez que a tabela foi definida, você pode acessar os elementos individualmente utilizando um ponto final, como:\nTABLE.ELEMENT\nVeja o exemplo..."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_tables2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Você também pode adicionar novos elementos (atribuíndo a eles um número ou texto) e remover eles (atribuíndo 'nil')."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_tables3)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "A lista de 'passageiros' que usamos no tutorial 1 era uma tabela. Aqui, usamos número para nomear os elementos, em vez de nomes. Se você optar por fazer isso, então você pode acessar elementos individuais usando os  [ ] colchetes, como fizemos no tutorial 1."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_tables4)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Um exemplo mais complexo: Você pode terminar um loop prematuramente se alguma condição for verdadeira. Por exemplo, se você está procurando por um passageiro numa tabela e tiver que encontrá-lo, você pode pular para o fim do loop usando 'break'.\n(Um '#' em frente aos passageiros lhe dá o comprimento dessa lista. Isso só irá funcionar se você usou números para nomear os elementos.)\nNão se preocupe se isso foi um pouco rápido para você; haverá outros exemplos para isso no Tutorial3."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_loop3)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Isso é tudo que você precisa saber sobre Lua por enquanto!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Próximo", event = nextTutorialStep}
	k = k + 1
	
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Feito!"
	tutorialSteps[k].message = "Você completou o segundo tutorial, muito bem!\nClique em 'Mais Ideias' para algumas ideias do que você pode tentar sozinho antes de ir para o próximo tutorial.\n\nCom esse tutorial, nós cobrimos a teoria - os próximos tutoriais serão mais práticos."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Mais Ideias", event = additionalInformation("Você pode tentar ir para o leste, então norte, então sul, então leste novamente e assim por diante (leste, norte, sul, leste, norte, sul, leste...).\n Para fazer isso, crie uma variável em ai.init(), a chame \"dir\". Então adicione 1 para dir (dir = dir + 1) toda vez que o jogo chama ai.chooseDirection. Então retorne \"E\", \"N\" or \"S\" se dir for 1, 2 ou 3. Não se esqueça de definir dir de volta para 0 ou 1 quando for ele for maior que 3!", CODE_moreIdeas), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Vá diretamente para o próximo tutorial ou retorne para o menu."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Voltar", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Sair", event = endTutorial}
	tutorialSteps[k].buttons[3] = {name = "Próximo Tutorial", event = nextTutorial}
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
										currentTutBox.text = "Você deveria ir para o leste primeiro, então ir para o sul! Modifique seu código, então recarregue."
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
	
	love.graphics.print("Tutorial 2: Esquerda ou Direita?", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Tutorial 2: Esquerda ou Direita?")/2, y+10)
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
-- Tutorial 2: Left or Right?

-- buy a train at round start and place it in the top left corner of the map:
function ai.init( map, money )
	buyTrain(1,1)
end
]]
