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
-- вычисление расстояния между точками
-- (x1,y1) и (x2,y2):
-- и возвращение результата из функции.
function distance(x1, y1, x2, y2)
	res = sqrt( (x1-x2)^2 + (y1-y2)^2 )
	return res
end
]])

local CODE_foundPassengers1 = parseCode([[
function ai.foundPassengers( train, passengers )
	pass = nil	-- очистка после прежних вызовов
	dist = 100	-- польшое расстояние по умолчанию
	i = 1	--начинаем с первого пассажира
	while i <= #passengers do -- идём по списку
		d = distance(train.x, train.y,
			passengers[i].destX, passengers[i].destY)
		if d < dist then  -- меньшее растояние сохраняем.
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
	while i <= #passengers do -- для каждого пассажира
		...
	end
	return pass
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
	loadingScreen.addSection("Новая карта")
	loadingScreen.addSubSection("Новая карта", "Размер: " .. tutMap.width .. " на " .. tutMap.height)
	loadingScreen.addSubSection("Новая карта", "Время: день")
	loadingScreen.addSubSection("Новая карта", "Урок 4: Чем ближе, тем лучше.")

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
	tutorialSteps[k].stepTitle = "Осознанный выбор"
	tutorialSteps[k].message = "Из этого урока вы усвоите:\n\nКакого из пассажиров лучше выбрать."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Начать урок", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "На этой карте небольшая группа пассажиров. Всем им нужно в разные места. (Нажмите пробел, чтоб увидеть кому-куда). Видно, что у всех разные расстояния. Для эффективности, чтоб перевезти максимальное число пассажиров (за наименьшее время), мы научимся как выбирать пассажира с наименьшей длиной пути (расстоянием между положением пассажира и точкой назначения)."
	tutorialSteps[k].event = startCreatingPassengers(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Сначала надо научиться находить кратчайшие расстояния. Для этого давайте создадим функцию 'distance'.\nДля вычислений будем использовать известную теорему Пифагора:\na²+b² = c² или c = sqrt(a²+b²).\nВведите код из листинга в TutorialAI4.lua и переходите к следующему шагу."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_eucledianDist)
		end
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Теперь, при подъезде к клетке с пассажирами (когда вызывается ai.foundPassengers) будем просматривать список всех пассажиров и считать для них расстояние."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Код, который вы видите, сперва создаёт переменную 'dist' с большим значением (100). Оно больше любого возможного расстояния на карте (карта всего 7х7 клеток). Затем начинаем перебирать пассажиров один за одним. Для каждого посчитаем расстояние до места назначения. Если оно меньше, чем, хранящееся в 'dist', сохраним пассажира(в 'pass') и расстояние (в 'dist')."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_foundPassengers1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Доп. инфо", event = additionalInformation("Для продвинутых пользователей: конечно же этот код можно написать гораздо изящней, если использовать цикл 'for'. Для уменьшения объёма уроков, цикл 'for' не рассматривается - примеры всегда можно найти в интернете. Если вы не имеете никакого понатия, что такое цикл 'for', можете пропустить эту заметку."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "К концу цикла, пассажир с кратчайшим расстоянием будет храниться в переменной 'pass'. Это тот самый пассажир, которого нам надо взять, добавьте строчку кода в файл из листинга справа в функцию ai.foundPassengers (после цикла)."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_foundPassengers2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Доп. инфо", event = additionalInformation("Конечно, в этом методе есть недостатки. Например, расстояние до места назначения может быть наименьшим, но поезд может быть направлен в противоположную сторону, таким образом, наверняка можно сделать более оптимальный выбор.\nЕсли интересно - можете подумать позже над тем, как улучшить алгоритм."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Ну и, разумеется, нам надо высадить пассажира.\nДопишите скрипт и перезагрузите ИИ."
	tutorialSteps[k].event = handleDropOff(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Доп. инфо", event = additionalInformation("Урок продолжится, когда поезд правильно развезет четырех пассажиров.\nЕсли вы развезете их неправильно - появится новая группа пассажиров -> так что убедитесь, что каждый раз берется пассажир с самым коротким расстоянием.\nЕсли что-то пошло не так, можете вернуться, поправить код и перезапустить ИИ."), inBetweenSteps = true}
	k = k + 1
	
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Готово!"
	tutorialSteps[k].message = "Четвертый урок пройден! Можно приступать к испытаниям. Также можете устроить соревнования для ИИ, выбрав пункт 'Соревнования' в главном меню. Если есть вопросы, загляните в вики на  " .. MAIN_SERVER_IP .. "! Так же можете обратиться к документации, она находится внутри .love файла (На Windows надо скачать исходный код, если у вас сборка в виде '.exe' файла). '.love' файл можно открыть архиватором."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Когда будете уверены в своём ИИ, можете загрузить его на сайт (" .. MAIN_SERVER_IP .. ") и наблюдать за тем, как он участвует в он-лайн соревнованиях! Обязательно постарайтесь занять первое место в списке лучших игроков!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Доп. инфо", event = additionalInformation("Некоторые советы, перед тем, как вы перейдёте к испытаниям:\n1) С многими картами справится даже самый примитивный ИИ. Тем не менее, только продуманные, довольно продвинутые ИИ имеют шанс на призовые места в соревнованиях.\n2) Попробуйте создать ИИ на основе полученных из уроков знаний и посмотреть, как он покажет себя в соревнованиях. Меняйте их немного, если не получается выиграть.\n3) НИКОГДА не перевозите зомби.", CODE_moreIdeas), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Выйти в главное меню?"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Меню", event = endTutorial}
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
	
	love.graphics.print("Урок 4: Чем ближе, тем лучше.", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Урок 4: Чем ближе, тем лучше.")/2, y+10)
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
-- Урок 4: Чем ближе, тем лучше.

function ai.init()
	buyTrain(1,1, 'E')
end
]]
