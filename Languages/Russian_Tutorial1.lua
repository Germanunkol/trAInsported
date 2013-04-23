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
-- Вызывается каждый раз при старте раунда:
function ai.init( map, money )

-- Вызывается, когда поезд подъезжает к развязке:
function ai.chooseDirection(train, possibleDirections)

-- Вызывается, при приближении к месту назначения:
function ai.foundPassengers(train, passengers)
]])

local CODE_pickUpPassenger1 = parseCode([[
-- Код посадки пассажира:
function ai.foundPassengers( train, passengers )
	-- Здесь, будет размещаться тело функции.
end
]])

local CODE_pickUpPassenger2 = parseCode([[
-- Код посадки пассажира:
function ai.foundPassengers( train, passengers )
	return passengers[1]
end
]])
local CODE_dropOffPassenger = parseCode([[
-- Код высадки пассажира:
function ai.foundDestination(train)
	-- Высадить текущего пассажира:
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
	loadingScreen.addSection("Новая карта")
	loadingScreen.addSubSection("Новая карта", "Размер: " .. tutMap.width .. " на " .. tutMap.height)
	loadingScreen.addSubSection("Новая карта", "Время: День")
	loadingScreen.addSubSection("Новая карта", "Урок 1: Первые шаги")

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
	tutorialSteps[k].stepTitle = "Как всё начиналось..."
	tutorialSteps[k].message = "Добро пожаловать в trAInsported!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Начать Урок", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "В скором будущем:\nНесколько лет назад на международном рынке появился новый продукт: поезда, контролируемые с помощью Искуственного Интеллекта."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Есть три основных отличия между новыми ИИ-поездами и их старшими братьями - обычными поездами. Первое - они могут перевозить пассажиров только по одному. Второе - они едут прямо туда, куда нужно попасть пассажиру. И, наконец, третье - они управляются с помощью Искусственного Интеллекта."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "В теории эта новая система должна отлично работать. Загрязнение уменьшается, ушла необходимость иметь личный транспорт и эта новая продвинутая техгнология позволила забыть что такое аварии. \n\nНо есть одна проблема... "
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Там где прибыль - всегда рождается конкурренция. В новом бизнесе каждый пытается отхватить как можно большую часть рынка. И вот в этом месте появляетесь вы. Ваша работа заключается в том, чтобы управлять поездами, создавая для них лучший искусственный интеллект.\nВсё, хватит болтать, пора переходить к делу!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Упраление"
	tutorialSteps[k].message = "Из этого урока вы узнаете:\n1) Клавиши управления игрой\n2) Как покупать поезда\n3) Доставите до места назначения вашего первого пассажира" 
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Для того, чтоб перемещаться по карте вы можете нажать левую кнопку мыши в любом месте и провести мышью. Для изменения масштаба используйте колёсико (или клавиши Q и E).\nВ любое время можете нажать F1, для того чтобы получить справку по горячим клавишам. Попробуйте прямо сейчас!"
	tutorialSteps[k].event = setF1Event(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Хорошо. Едем дальше.\n\nИгра создала поддиректорию с названием 'AI' в папке '" .. AI_DIRECTORY .. "'\nВ ней вы найдёте только-что сгенерированный файл с названием 'TutorialAI1.lua'.\nОткройте его в любом текстовом редакторе и прочитайте."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	if love.filesystem.getWorkingDirectory() then
		tutorialSteps[k].buttons[2] = {name = "Доп. инфо", event = additionalInformation("Если вы не можете найти директорию, возможно она скрыта. Вы можете набрать путь до дитектории вручную в адресной строке или воспользоваться поисковой системой в интернете набрав, например: 'Показать скрытые файлы Windows 7'\nТак же вам следует позаботиться об удобном текстовом редакторе.\nВот несколько хороших примеров:\nGedit, Vim (Linux)\nNotepad++ (Windows)"), inBetweenSteps = true}
		tutorialSteps[k].buttons[3] = {name = "Далее", event = nextTutorialStep}
	else
		tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	end
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Взаимодействие"
	tutorialSteps[k].message = "Итак, давайте напишем немного кода!\nПервое, что вам следует усвоить - как взаимодействовать с игрой. Используя текстовый редактор, в файле 'TutorialAI1.lua', наберите код, показанный справа. Когда закончите, сохраните его и нажмите кнопку 'Рестарт' В нижнем правом углу этого окна."
	tutorialSteps[k].event = firstPrint(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Доп. инфо", event = additionalInformation("Функция print Позволяет вам выводить любой текст (имеется ввиду текст между \"\" кавычек) или значения переменных в игровую консоль. Это позволит вам в дальнейшем искать и устранять ошибки в коде. Попробуйте прямо сейчас, и вы поймёте, о чём шла речь."), inBetweenSteps = true}
	--tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Неплохо.\n\n..."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Основной функционал ИИ"
	tutorialSteps[k].message = "Вот несколько функций, которые могут вам понадобиться. Они будут вызываться в каждом раунде, при определенных событиях. Несколько примеров можете посмотреть в листинге справа. Ваша задача в будущем - заполнять эти функции содержимым."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = setCodeExamples
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Покупаем первый поезд!"
	tutorialSteps[k].message = "А теперь добавьте код из листинга к себе в файл, после вызова print. Он купит для вас первый поезд и разместит в точке x=1, y=3. Карта разделена на клетки.\nКоординаты на карте нумеруются так: X - слева на право и Y - сверху вниз.\n(Нажмите 'М' для того чтоб увидить всю сетку!)\nКогда закончите с кодом, нажмите 'Рестарт'."
	tutorialSteps[k].event = setTrainPlacingEvent(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Доп. инфо", event = additionalInformation("Заметка:\n-Координаты (X и Y) начинаются с 1 и заканчиваются значением ширины(высоты) карты. Чуть позже вы узнаете еще кое-что о размерах карты.\n-Если вызвать функцию buyTrain с неправильными значениями координат, игра автоматически поместит поезд на ближайшие к указаному месту пути."), inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Ну вот! Вы купили свой первый поезд! Теперь он автоматически будет двигаться вперед."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Вы запрорграммировали простую функцию ai.init.\nЭта функция в вашем скрипте будет вызываться при каждом старте раунда. В ней вы можете запланировать часть действий вашего ИИ, и - как вы только что сделали - Купить первый поезд и разместить его на карте."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Доп. инфо", event = additionalInformation("Обычно функция ai.init() вызывается с двумя параметрами, примерно так:\nfunction ai.init( map, money )\nВ первом содержится карта (об этом чуть позже), а во втором - количество доступных на начало раунда денег. Таким образом можно определить - сколько поездов вы можете купить. В любом случае, этих денег будет достаточно, чтоб купить один поезд.\nПока что мы можем пропустить их за ненадобностью."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Берем на борт пассажира"
	tutorialSteps[k].message = "Я только что поместил пассажира на карту. Её зовут GLaDOS. Для того, чтобы увидеть, куда ей надо добраться нажим пробел!\n\nНовые пассажиры всегда будут появляться рядом с рельсами. Их пункт назначения так же около рельс."
	tutorialSteps[k].event = setPassengerStart(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Доп. инфо", event = additionalInformation("GLaDOS надо попасть в кондитерскую. Она однажды пообещала кое-кому тортик.\n\n...\nИ она очень хочет сдержать обещание."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Сейчас ваша задача - это взять пассажира на борт и доставить до места назначеня. Для этого нам необходимо описать функцию 'ai.foundPassengers' в нашем файле со скриптом ИИ. Эта функция будет вызываться каждый раз, когда один из ваших поездов будет подъездать к клетке с одним или несколькими пассажирами."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "У функции ai.foundPassengers два аргумента: первый, 'train', говорит о том, какой из ваших поездов приближается к точке. Второй, 'passengers', описывает пассажиров, которые находятся на клетке, куда подъезжает поезд. Используя эти параметры можно запрограммировать - какого из пассажиров взять на борт."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Для начала давайте объявим нашу функцию. Напишите код, который видите справа в ваш .lua файл. Комментарии копировать не обязательно (комментарии - это всё, что после '- -'), они используются только для удобства программиста и игнорируются самой игрой."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = pickUpPassengerStep1
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Всё, что вам нужно знать - это две вещи:\n1. 'passengers' - это список всех пассажиров.\nДля того, чтоб получить доступ к нужному пассажиру, используйте passengers[1], passengers[2], passengers[3] и т.д.\n2. Если функция ai.foundPassengers возвращает одно из этих значений при помощи ключевого слова 'return', тогда игра понимает, что надо взять этого пассажира и делает это для вас, если это возможно."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = pickUpPassengerStep1
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Доп. инфо", event = additionalInformation("Это значит, что пассажир будет взят на борт в том случае, если в поезде уже нет другого пассажира."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Пока что у нас только один пассажир, доступ к его данным можно получить через passengers[1] (если бы рядом был еще один, к нему бы обращались через passengers[2]). Итак, если мы вернем passengers[1] из нашей функции, GLaDOS сядет в поезд.\nДобавьте еще одну строку кода в файл, которую мы недавно описали, как это показано в листинге справа.\nКогда закончите, нажмите 'Перезагрузить', чтобы увидеть как ваш пезд подобрал GLaDOS!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = pickUpPassengerStep2(k)
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Всё получилось! GLaDOS села в поезд!\nЗаметьте, что изображение поезда изменилось, таким образом можно визуально отличить поезда с пассажирами и без.\n\nНу вот, мы почти закончили, осталось только высадить GLaDOS возле кондитерской."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Высади её!"
	tutorialSteps[k].message = "Вы можете высадить пассажира в любое время с помощью функции dropPassenger(train) в любом месте вашего кода. Для того, чтобы упростить вам жизнь существует функция ai.foundDestination(), которая автоматически вызывается, если поезд подъезжает к точке назначения текущего пассажира.\nДавайте опишем её!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Добавте код из листинга справа в конец вашего файла TutorialAI1.lua.\nЗатем перезагрузите ИИ и дождитесь, когда GLaDOS сядет на поезд и доедет до кондитерской."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = dropOffPassengerEvent(k)
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Готово!"
	tutorialSteps[k].message = "Вы закончили первый урок, неплохо!\n\nНажмите 'Еще идеи' чтоб посмотреть, что бы еще можно было сделать, перед тем, как переходить к следующему уроку."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Еще идеи", event = additionalInformation("1. Попробовать вывести сообщения на консоль с помощью функции print, когда поезд подбирает и высаживает пассажира (Например: 'Добро пожаловать!' и 'До свидания!').\n2. Купить два поезда, вместо одного с помощью вызова функции buyTrain дважды в ai.init()\n3. Сделать так, чтоб поезд начинал движение в противоположном конце карты."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Вы можете перейти сразу ко второму уроку или вернуться в главное меню."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Меню", event = endTutorial}
	tutorialSteps[k].buttons[3] = {name = "Следующий урок", event = nextTutorial}
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
							tutorialSteps[k+1].message = "Неплохо.\nВаш текст теперь должен быть слева-снизу. Также в консоли отображается к какому ИИ относятся сообщения, в данном случае это TutorialAI1. Это будет особенно важно в соревнованиях между несколькими ИИ.\n(Если это окно мешает обзору, можете его перетащить в любую часть экрана.)"
						else
							tutorialSteps[k+1].message = "Это не совсем тот текст, но я думаю вы поняли идею.\nВаш текст теперь должен быть слева-снизу. Также в консоли отображается к какому ИИ относятся сообщения, в данном случае это TutorialAI1. Это будет особенно важно в соревнованиях между несколькими ИИ.\n(Если это окно мешает обзору, можете его перетащить в любую часть экрана.)"
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
			passenger.new(5,4, 1,3, "В конце будет тортик. И вечеринка. Нет, правда!") 	-- place passenger at 3, 4 wanting to go to 1,3
			tutorial.placedFirstPassenger = true
			tutorial.restartEvent = function()
				print(currentStep, k)
					if currentStep >= k then	-- if I haven't gone back to a previous step
						passenger.new(5,4, 1,3, "В конце будет тортик. И вечеринка. Нет, правда!") 	-- place passenger at 3, 4 wanting to go to 1,3
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
					currentTutBox.text = "Вы высадили пассажира не совсем в том месте, где надо!\n\nДобавте текст из листинга справа в конец вашего скрипта в TutorialAI1.lua"
				end
			end
		end
end

function tutorial.roundStats()
	love.graphics.setColor(255,255,255,255)
	x = love.graphics.getWidth()-roundStats:getWidth()-20
	y = 20
	love.graphics.draw(roundStats, x, y)
	
	love.graphics.print("Урок 1: Первые шаги", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Урок 1: Первые шаги")/2, y+10)
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
-- Урок 1: Первые шаги
-- Что вы узнаете:
--	a) Линии, начинающиеся с двух тире(знак минус "-") - это комментарии, они игнорируются игрой.
--	b) Все ваши инструкции пишутся на скриптовом языке Lua.
--	c) Lua очень простой язык и игра поможет вам легко его освоить шаг за шагом.
--	d) Lua - очень быстрый язык. Если коротко:
--	e) Lua рулит!
-- Сейчас, когда вы нашли файл и прочитали всё это, вернитесь в игру и нажмите "Далее"!
-- Заметка: Существуют текстовые редакторы, которые могут подсвечивать синтаксис языка Lua. Можете просто поискать редакторы для Lua в интернете. Подсветка синтаксиса делает код гораздо более читаемым и наглядным и я советую вам этм воспользоваться, но, разумеется, это не является обязательным моментом.
]]
