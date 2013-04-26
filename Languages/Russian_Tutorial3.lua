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
	-- пример: вывод имени поезда
	-- и имени пассажира:
	-- (passenger будет 'nil', если в поезде нет пассажира)
	if train.passenger == nil then
		print(train.name.." carries no passenger.")
	else
		print(train.name.." carries "..train.passenger.name)
	end
end
]])

local CODE_pickUpPassenger = parseCode([[
-- Код взятия пассажира на борт:
function ai.foundPassengers( train, passengers )
	return passengers[1]
end
]])

local CODE_chooseDirectionWithPassenger1 = parseCode([[
function ai.chooseDirection( train, directions )
	if train.passenger == nil then
		print(train.name.." carries no passenger.")
		-- едем на юг, к пассажирам!
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
-- код высадки пассажира:
function ai.foundDestination(train)
	-- высаживаем пассажира из поезда:
	dropPassenger(train)
end
]])

local CODE_enoughMoney = parseCode([[
-- эта функция вызывается, когда денег достаточно
-- для покупки еще одного поезда
function ai.enoughMoney()
	buyTrain(1,3)
end
]])


local CODE_moreIdeas = parseCode([[
-- Проверка: :первый ли это поезд
if train.ID == 1 then
	...
	
-- пробегаем список пассажиров:
-- ВАЖНО: #passengers длина списка!
i = 1
while i <= #passengers do
	...
	if ... then
		-- берем на борт
		break	-- прерываем цикл!
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
	loadingScreen.addSection("Новая карта")
	loadingScreen.addSubSection("Новая карта", "Размер: " .. tutMap.width .. " на " .. tutMap.height)
	loadingScreen.addSubSection("Новая карта", "Время: День")
	loadingScreen.addSubSection("Новая карта", "Урок 3: Быть умным!")

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
	tutorialSteps[k].stepTitle = "Проверка!"
	tutorialSteps[k].message = "Темы третьего урока:\n\n1) Как делать правильный выбор направления движения, в зависимости от расположения пассажиров\n2) Использование нескольких поездов."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Начать урок", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "На этой карте несколько детей. Некоторые из них - ученики и они хотят в школу, а может и не очень.\nНо это не наше дело, как программиста, судить об этом...\n(Нажмите пробел, или кликните на любого из пассажиров, чтоб узнать куда им надо отправиться)"
	tutorialSteps[k].event =  startCreatingPassengers(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Ваша задача развезти пассажиров куда им надо.\nКонечно мы можем перебирать все возможные направления до тех пор, пока не приедем в нужное место, но такой ИИ вряд-ли сможет составить конкуренцию другим в живых матчах. Вместо этого мы будем проверять, место назначения пассажира и везти его прямо туда."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Чтобы достичь этого нам понадобятся некоторые параметры для функции ai.chooseDirection, это 'train' и 'directions'.\nОткрывайте TutorialAI3.lua И вводите туда код из листинга."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_chooseDirectionFunction1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Параметр 'train' автоматический заполняется таблицей, отражающей поезд. В ней содержатся следующие поля: 'ID', 'name', 'x' и 'y'. Если в поезде находится пассажир, то будет и еще один дополнительный элемент - 'passenger' (Таблица, отражающая пассажира). Таблица пассажира содержит 'destX' и 'destY' которые показывают точку назначения и 'name' - имя пассажира. Добавьте новый код в вашу функцию."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_chooseDirectionFunction2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Как в первом уроке надо добавить код посадки пассажира. Добавьте его в скрипт...\n\nКогда закончите - перезагрузите ИИ и проверьте, что всё работает!"
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_pickUpPassenger)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Следующим шагом надо реализовать вот что: всегда, когда поезд подъезжает к развилке без пассажира, он должен ехать на юг. Добавляем соответствующий код."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_chooseDirectionWithPassenger1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "В случае, если в поезде есть пассажир, надо сравнить X-координаты текущей позиции поезда (train.x) и точки назначения пассажира (train.passenger.destX). Если точка назначения лежит к западу (X точки назначения меньше, чем X поезда), то нам надо ехать на запад. В противном случае - на восток.\nДобавьте новый код в функцию."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_chooseDirectionWithPassenger2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Последний шаг - высадка пассажира, так же, как мы делали это раньше.\n\nКогда закончите, перезагрузите ИИ и смотрите, как поезд развозит пассажиров!\n(можно изменить скорость игры, нажимая  + или -, чтоб не ждать слишком долго)"
	tutorialSteps[k].event = waitingForPassengersEvent(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Доп. инфо", event = additionalInformation("Следующий шаг начнется автоматически, когда ваш поезд отвезет одного пассажира на восток и одного на запад."), inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Всё работает! Но можно ускорить процесс, если купить еще поездов. В начале урока у вас уже есть поезд и 15 кредитов. Новый поезд стоит " .. TRAIN_COST .. " кредитов. Каждый раз, высаживая пассажира, вы зарабатываете деньги. Как только у вас становится достаточно денег для покупки поезда, автоматически вызывается функция 'ai.enoughMoney'. Используйте её, чтоб купить еще поезд. Когда закончите - перезагрузите ИИ."
	tutorialSteps[k].event = enoughMoneyEvent(k)
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Теперь у пас есть 2 поезда!\nСейчас можете откинуться на спинку стула, расслабиться и ждать, пока ваши поезда развезут 10 пассажиров. Вы хорошо поработали!\n\n0 из 10 перевезено."
	tutorialSteps[k].event = waitFor10Passengers(k)
	tutorialSteps[k].buttons = {}
	--tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Готово!"
	tutorialSteps[k].message = "Вы справились с третьим уроком!\nТеперь вы знаете почти все основы. Нажмите 'Еще идеи', если хотите пройти первое самостоятельное испытание!"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Еще идеи", event = additionalInformation("Cделайте так, чтобы первый поезд возил только на запад. Для этого: В ai.foundPassengers: проверьте, что train.ID равен 1. Затем проверьте, что destX у пассажира passengers[1] меньше, чем train.x. Если это так - берите его, иначе переходите к passengers[2] и т.д. Если можете - используйте цикл while, чтоб просмотреть список пассажиров. Ну и, наконец, второй поезд должен возить на восток. ВАЖНО: #passengers - это длина списка! Помните, что с помощью 'break' можно преравть цикл, когда найдёте нужного пассажира .", CODE_moreIdeas), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Далее", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Вы можете перейти сразу к четвёртому уроку или вернуться в главное меню."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Назад", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Меню", event = endTutorial}
	tutorialSteps[k].buttons[3] = {name = "Следующий урок", event = nextTutorial}
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
				currentTutBox.text = "Теперь у пас есть 2 поезда!\nСейчас можете откинуться на спинку стула, расслабиться и ждать, пока ваши поезда развезут 10 пассажиров. Вы хорошо поработали!\n\n" .. numPassengers .. " из 10 перевезено."
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
	
	love.graphics.print("Урок 3: Быть умным!", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Урок 3: Быть умным!")/2, y+10)
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
kidSpeaches[1] = "Я провалю этот тест по математике..."
kidSpeaches[2] = "Сегодня урок программирования. Я слышал, про что-то, с названием 'Lua'. Посмотрим."
kidSpeaches[3] = "Я забыл домашнюю работу."
kidSpeaches[4] = "Прогулять, или не прогулять - вот в чём вопрос..."
kidSpeaches[5] = "Это моя судьба."
kidSpeaches[6] = "Последний день в школе!"
kidSpeaches[7] = "Видите, как светит солнце? Оно так и говорит: 'Нееет... Не надо идти в школу!'"

fileContent = [[
-- Урок 3: Быть умным!

function ai.init()
	buyTrain(3,1)
end
]]
