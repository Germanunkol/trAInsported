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
-- объявление переменной "variable1":
variable1 = 10
-- а у этой имя variable2:
variable2 = 20

-- складываем их значения и записываем в variable3:
variable3 = variable1 + variable2
-- отображаем результат в консоли:
print(variable3)	-- выведет 30
]])

local CODE_variables2 = parseCode([[
-- объявление переменной "variable1":
variable1 = 10
-- еще одна:
variable2 = "testing"

-- так не сработает
-- (такой код выдаст ошибку при загрузке)
variable3 = variable1 + variable2
]])
local CODE_variables3 = parseCode([[
-- добавление "5.1" к концу строки "Lua".
-- в результате получится "Lua 5.1".
myText = "Lua " .. 5.1

variable1 = 10
variable2 = "testing"
-- добавляем 10 в конец строки "testing":
variable3 = variable2 .. variable1
-- результат: "testing10"
]])

local CODE_counter = parseCode([[
function ai.init()
	buyTrain(1,1)
	-- создаём переменную "counter"
	counter = 0
end

function ai.chooseDirection()
	-- считаем развилки:
	counter = counter + 1
	
	-- выводим номер текущей развилки:
	print("Junction number: " .. counter)
end
]])

local CODE_functions1 = parseCode([[
function myFunction(argument1, argument2, ... )
	-- обрабатываем полученные аргументы
	-- и возможно возвращаем какое-то значение
end

-- вызываем функцию с тремя аргументами:
myFunction(1, "test", "3")
]])

local CODE_functions2 = parseCode([[
function subtract(a, b)
	c = a - b
	return c
end

result = subtract(10, 5)
print(result)	-- должно напечатать '5'
]])

local CODE_ifthenelse1 = parseCode([[
if EXPRESSION1 then
	-- действия
elseif EXPRESSION2 then
	-- еще действия 
else
	-- другие действия
end

-- код 'действия' будет выполняться только если
-- EXPRESSION1 принимает значение истины. 
-- Скоро вы узнаете что такое EXPRESSION.
]])

local CODE_ifthenelse2 = parseCode([[
variable = 10

if variable == 10 then
	print("Значение переменной 10...")
elseif variable > 10000 then
	print("Значение переменной - большое число!")
else
	print("Значение не 10 но и не очень большое...")
end
]])



local CODE_whileLoop = parseCode([[
width = 10
x = 0
--это выведет 3, затем 6, дальше 9, потом 12.
while x < width do
	x = x + 3
	print(x)
end
]])

local CODE_whileLoop2 = parseCode([[
function ai.chooseDirection()
	-- считаем развилки:
	counter = counter + 1
	
	i = 0	-- новая числовая пременная
	text = "" -- инициализируем пустую строку
	while i < counter do
		text = text .. "x" 
		i = i + 1
	end
	-- выводим результат:
	print(text)
end
]])

local CODE_forLoop = parseCode([[
-- следующий код выведет числа от 1 до 10:
width = 10
for i = 1, width, 1 do
	print(i)
end
-- а так - только чётные ( 2, 4, 6, 8, 10)
width = 10
for i = 2, width, 2 do
	print(i)
end
]])

local CODE_loop3 = parseCode([[
i = 1
-- просматриваем список пассажиров:
while i <= #passengers do
	-- у каждого есть имя, доступ к которому даёт
	-- 'passengers[i].name', найдём одного с именем Скайвокер.
	if passengers[i].name == "Скайвокер" then
		print("Я нашел Люка!!")
		break	-- прерываем цикл!
	end
	i = i + 1
end
]])

local CODE_tables1 = parseCode([[
-- пример 1:
myTable = {var1=10, var2="lol", var3="a bear"}

-- пример 2: (допустимы переносы строк)
myTable = {
	x_Pos = 10,
	y_Pos = 20
}
-- пример 3:
hill1 = {slope="steep", snow=true, size=20}
hill2 = {slope="steep", snow=false, size=10}
]])

local CODE_tables2 = parseCode([[
myTable = {
	x = 10,
	y = 20
}

-- считаем среднее значение:
result = (myTable.x + myTable.y)/2
print(result)
-- должно вывести 15, потому, что (10+20)/2 = 15
]])

local CODE_tables3 = parseCode([[
myTable = { x = 10, y = 20 }

-- добавляем элемент с именем 'z':
myTable.z = 50

-- удаляем элемент с именем 'x':
myTable.x = nil

-- а это приведет к ошибке, потому, что 'x' уже нет:
a = myTable.x + 10
]])

local CODE_tables4 = parseCode([[
-- если вы опускаете имена полей, Lua автоматически
-- использует номера [1], [2], [3] и т.д.:
myList = {"Apples", "Are", "Red"}

print(myList[1]) -- выведет 'Apples'.

-- меняем "Red" на "Green":
myList[3] = "Green"

-- выведет: "ApplesAreGreen"
print(myList[1] .. myList[2] .. myList[3])

]])

local CODE_hintGoEast = parseCode([[
-- Попробуйте так:
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
		print("First junction! Go East!")
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
	loadingScreen.addSection("Новая карта")
	loadingScreen.addSubSection("Новая карта", "Размер: " .. tutMap.width .. " на " .. tutMap.height)
	loadingScreen.addSubSection("Новая карта", "Время: День")
	loadingScreen.addSubSection("Новая карта", "Урок 2: Направо или налево?")

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
	tutorialSteps[k].stepTitle = "Куда едем?"
	tutorialSteps[k].message = "Добро пожаловать во второй урок!\n\nЗдесь вы выучите:\n1) Как проезжать развилки\n2) Основы Lua\n3) Что делать с несколькими пассажирами\n"
	--4) What VIPs are"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Начать урок", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: Переменные"
	tutorialSteps[k].message = "Сейчас мы будем учиться программровать на Lua.\nТема довольно обширная, но я постараюсь приподнести всё сжато. Может показаться, что тут сразу очень иного информации для новичка, но не пугайтесь - не обязательно запоминать всё сразу...\n\tВ Lua вы можете создавать переменные, просто присваивая значения (справа от знака '=') имени (слева от '='). Посмотрите на пример в листинге."
	tutorialSteps[k].event = function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_variables1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "В переменных так же, можно хранить текст. Чтоб сказать Lua что строка должна обрабатываться как текст, вы должны заключить её в кавычки(\").\n\nСтоит заметить, что нельзя складывать текстовые данные с числами, потому, что Lua не знает как 'прибавлять' текст.\nКак всегда - смотрите пример в листинге справа."
	tutorialSteps[k].event = function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_variables2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Доп. инфо", event = additionalInformation("Если вы программировали на других языках прежде, будте осторожны: Lua очень некритично относится к типам переменных. Вы можете присвоить числовое значение переменной, в которой до этого был текст и наоборот. Это не будет ошибкой, но вы сами можете потом запутаться."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Дальше", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Если вы хотите соединить текст и строку вместе, следует поместить '..' между ними. В результате получится строка, которую можно хранить в другой переменной, выводить на консоль, или еще что-нибудь.\n\nКак всегда - пример в листинге."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_variables3)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Давайте попробуем это на практике!\nНапишем код, который будет считать развилки.\nКогда поезд подъезжает к развилке игра всегда пытается вызвать функцию 'ai.chooseDirection()' из вашего кода. Это значит, что если у вас в коде описана функция ai.chooseDirection, вы можете выполнять какие-то действия когда поезд подъезжает к развилке."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Открывайте только что созданный TutorialAI2.lua из той же папки, что и раньше.\n\nФайл уже содержит немного кода, именно поэтому у вас уже есть один поезд.\nДобавьте код из листина в ваш файл (существующий ai.init следует заменить), затем нажмите 'Рестарт'."
	tutorialSteps[k].event = eventCounter(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Доп. инфо", event = additionalInformation("Код не будет работать, если вы забудете строчку 'counter = 0', потому, что перед тем, как добавлять 1 к счётчику, следует его инициализировать. Т.к. ai.init всегда вызывается ПЕРЕД ai.chooseDirection, всё будет работать корректно."), inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Вроде работает!\n\nПроверьте, правильно ли ИИ считает развилки. Если что-то не так - поправьте код. Ну а если всё как надо - жмите Далее."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: if, then, else"
	tutorialSteps[k].message = "В коде вам обязательно придётся принимать решения. В этом вам поможет конструкция 'if-then-else'.\n'if' проверяет истинность выражения EXPRESSION, и, если оно истинно выполняет действия, указанные после 'then'. Дальше вы можете использовать 'elseif', 'else' или 'end' для завершения блока кода.\nПосмотрите пример."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_ifthenelse1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "'EXPRESSION' - условное выражение, которое Lua принимает за истину или ложь. Если Lua вычислил его как истинное, код будет выполнен, в противном случае - нет. Примеры использования можно посмотреть в листинге. Заметьте, что здесь нельзя использовать знак '='. Вместо него должен быть '=='! Иначе это будет простое присваивание, а не условное выражение.\nНажмите 'Доп. инфо', чтоб посмотреть примеры."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_ifthenelse2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Доп. инфо", event = additionalInformation("1) A == B (A и B равны?)\n2) A > B (A больше, чем B?)\n3) A <= B (A меньше или равна B?)\n4) A ~= B (A не равна B)"), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Последняя заметка об условных выражениях: Если вы программировали до этого, то, наверняка, встречали запись A != B (A не равно B). По определенным причинам в Lua используется именно A ~= B\n\nif variable ~= 10 then\n...\nend"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: Циклы"
	tutorialSteps[k].message = "Циклы - очень полезная вещь. Например, цикл while позволяет вам повторять некоторые действия, пока условие EXPRESSION принимает ложное значение.\n\nwhile EXPRESSION do\n(повторяющийся код)\nend"
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_whileLoop)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Пора попробовать!\nДавайте изменим функцию ai.chooseDirection. Вместо количества посещений, будем выводить символ 'x' столько раз, сколько мы были на развилке. (На первой выведем 'x', на второй - 'xx' и т.д.)\nДля этого используем переменную 'counter'. Затем будем дописывать 'x' к концу строки 'counter' количество раз, и в конце выведем полученную строку на консоль."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "... А вот и код. Линия text = \"\" создаёт пустую строку, а i=0 инициализирует еще один счётчик, теперь можно следить сколько 'x' мы добавили к строке.\nПоправьте функцию ai.chooseDirection, перезапустите, и смотрите, что получится.\n\nЕсли всё работает - ура, жмите 'Далее'."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_whileLoop2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
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
	tutorialSteps[k].stepTitle = "Lua: Функции!"
	tutorialSteps[k].message = "Вы уже знаете кое-что о функциях из первого урока.\nФункция объявляется с помощью ключевого слова 'function', дальше следует имя функции и передаваемые параметры в круглых скобках. Дальше описывается тело функции - то, что она будет выполнять. Функция может вернуть какие-либо значения при помощи ключевого слова 'return'."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_functions1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "В конце функции должно стоять ключевое слово 'end'.\nПосле объявления, функция может быть вызвана по имени и с нужными параметрами."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_functions1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Вот еще простой пример.\n При вызове функция возвращает число (c), которое сохраняется в переменную (result). после этого переменная выводится на консоль."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_functions2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "На этой карте есть один новый элемент: развилка. Каждый раз, когда поезд подъезжает к развилке, ИИ должен выбрать направление дальнейшего движения. Всего есть четыре направления: север, юг, восток и запад. Например, на этой карте развилка позволяет ехать на север(вверх), восток (направо) и юг (вниз).\nВ коде эти направления обозначаются: \"N\", \"S\", \"E\" и \"W\"."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Сейчас поезд движется по карте и, при встрече развилки не знает куда ему ехать, потому, что мы ещё это не запрограммировали.\nПо умолчанию поезд выберет \"N\", если возможно. Если нет (потому, что он приехал с севера или у развилки нет выхода на север), тогда он будет пробовать \"S\", затем \"E\", потом \"W\", до тех пор, пока мы не скажем ему куда ехать."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Сейчас поезд на развилках только выводит текст.\nСледующим шагом будет выбор нового направления. Сейчас поезд выбирает значения по умолчанию - Север, или если нет возможности ехать на север - Юг.\n\nЕсли функция ai.chooseDirection() вернет \"E\", тогда игра будет знать, что поезд хочет ехать на Восток после развилки. Сделайте, чтоб ваша функция возвращала \"E\" и перезагрузите ИИ."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = eventChooseEast(k)
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Подсказка!", event = function()
		if cBox then codeBox.remove(cBox) end
		cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_hintGoEast)
		end, inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "У вас получилось! Теперь поезд едет на восток всегда, когда может...\nДавайте еще кое-что попробуем: сейчас сделайте так, чтоб поезд поехал сначала на восток на развязке, а потом ездил только на север и юг. Для того, чтоб это осуществить используйте счётчик и конструкцию 'if-then-else'. Помните: чтобы проверить равенство переменной и значения надо использовать '==', а не '=' ..."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = eventChooseEastThenSouth(k)
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Доп. инфо", event = additionalInformation("Вудет достаточно сказать поезду ехать на восток, а затем на юг, потому, что если поезд едет с юга и ему говорят ехать на юг, то он автоматически поедет на север (Потому, что на юг нельзя)...\n\nДля решения этой задачи есть несколько решений. Будте осторожны: все команды посте слова 'return' не будут выполняться, потому, что 'return' это команда выхода из функции."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Подсказка!", event = function()
		if cBox then codeBox.remove(cBox) end
		cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_hintGoEastThenSouth)
		end, inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Работает!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: Таблицы"
	tutorialSteps[k].message = "Мы почти закончили с теоретической частью.\nДумаю, последнее, что нам нужно - это таблицы Lua.\nТаблицы - это, наверное, самая мощная и полезная вещь, которая  есть в Lua."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "По-сути таблица, это контейнер для других переменных. Объявляются таблицы с помощью фигурных скобок { }. Внутри скобок вы опять можете объявлять переменные, так же, как делали это прежде (только надо разделять их запятыми)."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_tables1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "После того, как таблица объявлена, вы можете получить доступ к полям при помощи такой записи:\nTABLE.ELEMENT\nПосмотрите пример..."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_tables2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Вы можете добавлять в таблицу новые поля (присваивая им текст или числа) и удалять (присваивая 'nil')."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_tables3)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Список 'passengers', который мы использовали в первом уроке был, как раз, таблицей. Мы обращаемся к элементам по номеру, а не по имени. Для обращения к элементу надо использовать квадратные [ ] скобки, как это было в первом уроке."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_tables4)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Более сложный пример - прерывание цикла. Например, найдя нужного пассажира в списке, следует прекратить выполнение цикла с помощью ключевого слова 'break'. ('#passengers' - размер списка пассажиров. Но учтите, это работает, только если в качестве индексов используются числа.)\nНе переживайте, если это кажется слишком сложным; В третьем уроке будет подробный пример."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_loop3)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Ну вот и всё, этих знаний о Lua вам пока достаточно!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Готово!"
	tutorialSteps[k].message = "Отлично, вы закончили второй урок!\nНажмите 'Еще идеи' чтоб посмотреть что еще такого вы можете сделать перед тем, как перейти к следующему уроку.\n\nВ этом уроке мы выучили много сухой теории, следующее занятие будет более практическим."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Еще идеи", event = additionalInformation("вы можете попробовать двигаться на восток, потом на север, потом на юг и снова на восток и так далее (E, N, S, E, N, S, E ...).\n чтобы это сделать зоздайте переменную в ai.init(), назовите её \"dir\". Затем каждый раз прибавляйте к ней 1 (dir = dir + 1) внутри функции ai.chooseDirection. Потом возвращайте \"E\", \"N\" или \"S\" если значение dir равняется 1, 2 или 3. Не забывайте сбрасывать переменную dir обратно в 0 или 1, когда она становится больше, чем 3!", CODE_moreIdeas), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Вы можете перейти сразу к третьему уроку или вернуться в главное меню."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Меню", event = endTutorial}
	tutorialSteps[k].buttons[3] = {name = "Следующий урок", event = nextTutorial}
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
										currentTutBox.text = "По плану было, чтоб  поезд ехал на восток, а затем на юг! Поправьте код и перезагрузите ИИ."
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
	
	love.graphics.print("Урок 2: Направо или налево?", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Урок 2: Направо или налево?")/2, y+10)
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
-- Урок 2: Направо или налево?

-- Покупаем поезд в начале раунда и размещаем его в верхнем левом углу:
function ai.init( map, money )
	buyTrain(1,1)
end
]]
