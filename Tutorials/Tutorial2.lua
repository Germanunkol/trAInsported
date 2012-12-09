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

-- append the "10" to the end of "testing":
variable3 = variable2 .. variable1
]])

local CODE_functions1 = parseCode([[
function name(argument1, argument2, argument3, ... )
	-- do something with the arguments
	-- possibly return something
end

-- call the function with three arguments:
name(1, "test", "3")
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

local CODE_tables1 = parseCode([[
-- example 1:
myTable = {var1=10, var2="lol", var3="a beer"}

-- example 2:
myTable = {
	x_Pos = 10,
	y_Pos = 20
}
-- example 3:
hill = {slope="steep", snow=true, size=20}
]])

local CODE_tables2 = parseCode([[
myTable = {
	x = 10,
	y = 20
}

-- calculate the average:
result = (myTable.x + myTable.y)/2
print(result)	-- will print 15
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

local CODE_hintPrint = parseCode([[
-- Try this:
function ai.chooseDirection()
	print("Where should I go?")
end
]])

local CODE_hintGoEast = parseCode([[
function ai.chooseDirection()
	print("I want to go East!")
	return "E"
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
	
	ai.backupTutorialAI(aiFileName)
	ai.createNewTutAI(aiFileName, fileContent)

	stats.start( 1 )
	tutMap.time = 0
	map.print()
	
	loadingScreen.reset()
	loadingScreen.addSection("New Map")
	loadingScreen.addSubSection("New Map", "Size: " .. tutMap.width .. "x" .. tutMap.height)
	loadingScreen.addSubSection("New Map", "Time: Day")
	loadingScreen.addSubSection("New Map", "Tutorial 2: Left or Right?")

	train.init()
	train.resetImages()
	
	
	ai.restart()	-- make sure aiList is reset!
	
	ok, msg = pcall(ai.new, "AI/" .. aiFileName)
	if not ok then
		print("Err: " .. msg)
	else
		stats.setAIName(1, aiFileName:sub(1, #aiFileName-4))
		train.renderTrainImage(aiFileName:sub(1, #aiFileName-4), 1)
	end
	
	tutorial.noTrees = true		-- don't render trees!
	
	map.new(nil,nil,1,tutMap)
	
	tutorial.createTutBoxes()
	
	tutorial.mapRenderingDoneCallback = startThisTutorial	
	
	menu.exitOnly()
end


function tutorial.endRound()

end

local codeBoxX, codeBoxY = 0,0
local tutBoxX, tutBoxY = 0,0

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

function tutorial.createTutBoxes()

	CODE_BOX_X = love.graphics.getWidth() - CODE_BOX_WIDTH - 30
	CODE_BOX_Y = (love.graphics.getHeight() - TUT_BOX_HEIGHT)/2 - 50
	
	local k = 1
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Where to go?"
	tutorialSteps[k].message = "Welcome to the second Tutorial!\n\nHere, you'll learn:\n1) How to handle junctions\n2) Lua basics\n3) What to do with multiple passengers\n4) What VIPs are"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Start Tutorial", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: Variables"
	tutorialSteps[k].message = "I now need to teach you some basics about Lua.\nIn Lua, you can create variables simply by assigning some value to a name.\nSee examples in the code box."
	tutorialSteps[k].event = function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_variables1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "You can also assign text or other things to a variable name. To tell Lua that something should be considered text, you need to surround the text by quotes (\").\nYou can't just add text and numbers together, because Lua doesn't know how to 'add' text.\nAgain, there's an example in the code box."
	tutorialSteps[k].event = function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_variables2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("If you've programmed another language before, be careful: Lua is very forgiving when it comes to variable types. You can put text into a variable that was holding a number before and vice versa. This won't crash your program, but might give you problems later on."), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "If you want to append text or numbers together, you can do this by writing .. between them. The result will be text, which you can store in a new variable, print to the console, or do other things with.\n\nExample, as always, in the code box."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_variables3)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: if, then, else"
	tutorialSteps[k].message = "You'll need to make decisions in your code. For this, 'if-then-else' statements are useful.\nAn 'if' statement checks if some EXPRESSION is true and if so, executes the code following the 'then' statement. After that, you can either follow by 'elseif', 'else' or 'end' to end the code block.\nCheck out the example."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_ifthenelse1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "An 'EXPRESSION' is a piece of code that Lua will interpret as either true or false. If Lua finds the expression to be true, it'll execute the code, otherwise it won't. Examples of expressions are presented in the code box. Note that here, you can't use '='. Instead, you'll need '=='! Otherwise it would be an assignment, not something for Lua to check.\nCheck out 'More Info' for valid expressions."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_ifthenelse2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("1) A == B (are A and B equal?)\n2) A > B (A greater than B?)\n3) A <= B (Is A smaller or Equal to B?)\n4) A ~= B (A does not equal B)"), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "A last note on expressions: If you've programmed before, you might know the A != B (A does not equal B) expression. For some reason, Lua uses A ~= B instead!\n\nif variable ~= 10 then\n...\nend"
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: Loops"
	tutorialSteps[k].message = "While-Loops are also a handy feature. They let you repeat something until an EXPRESSION is false.\nwhile EXPRESSION do\n(your code to repeat)\nend"
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_whileLoop)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
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
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: Functions!"
	tutorialSteps[k].message = "You already learned a bit about functions in the first tutorial.\nA function is introduced by using the keyword 'function', followed by the function name and the arguments it takes in parantheses (). Then there's the function body where your code goes. If you want to, pass back any numbers or text using the 'return' statement."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_functions1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "The function ends with the 'end' keyword.\nOnce the function has been defined, you can call it using the function name and pass arguments to it."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_functions1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Here's another simple example.\n Then this function is called, it returns a number, which is saved directly into a variable. This variable is then printed to the console."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_functions2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Lua: Tables"
	tutorialSteps[k].message = "We're almost done with the theoretical part.\nThere's one more thing we need, though, which is Lua tables.\nTables are the probably the most powerful functionality Lua has."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Basically, a table is a 'container' for more variables. You can define a table using curly brackets { }. Inside the curly brackets, you can again define variables, just like you did before (seperate them by commas)."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_tables1)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Once a table has been defined, you can access the individual elements by using a fullstop, like this:\nTABLE.ELEMENT\nSee the example..."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_tables2)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "You can also add new elements (by assigning them a number) and remove them (by assigning 'nil')."
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_tables3)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "That's all you need to know about Lua for now!"
	tutorialSteps[k].event =  function()
			cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_tables3)
		end
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "On this map, there's a new element: A junction. Whenever a train reaches a junction-square, your AI needs to decide where the train should go. There's four directions that the train can move in: north, south, east and west. For example, the junction on this map will allow a train to go north (up), east (right) and south (down).\nIn the code, the directions will be called \"N\", \"S\", \"E\" and \"W\"."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Notice the train on the map. When it reaches the junction, it doesn't know what to do because we have not told it yet.\nThe default behaviour is to go \"N\" if it can. If it can't (because it's coming from \"N\" or because the junction doesn't have a \"N\" exit), then it'll try \"S\", then \"E\", then \"W\", unless we tell it otherwise, which we'll do now."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Open up the newly created TutorialAI2.lua, from inside the same folder as before.\n\nThere's already some code in the file, which is why there's already a train on the map."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Go East!"
	tutorialSteps[k].message = "When a train reaches a junction, it will always try to call the function 'ai.chooseDirection()' in your AI's code. Write this function now inside the tutorialAI2.lua.\nRemember to start the function with the 'function' keyword and end it with 'end'. Don't forget the empty () parentheses. Then make the function print 'Where should I go?' every time it is called. If you're stuck, press 'Help'. When done, press 'Reload' and wait until the train reaches the junction."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = eventFirstChooseDirection(k)
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Help!", event = function() cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_hintPrint) end, inBetweenSteps = true}
	--tutorialSteps[k].buttons[2] = {name = "Help!", event = additionalInformation("Try this:\nfunction ai.chooseDirection()\n     print(\"Where should I go?\")\nend"), inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Well done!\nNotice that every time the train reaches the junction, it will print something and then continue.\nThe next step is to choose a direction for the train. The current default behaviour is to go North or South.\nIf the function ai.chooseDirection() returns \"E\", then the game will know that the train wants to go East at the junction. Make your function return \"E\", then reload."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].event = eventChooseEast(k)
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Hint!", event = function() cBox = codeBox.new(CODE_BOX_X, CODE_BOX_Y, CODE_hintGoEast) end, inBetweenSteps = true}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "You did it! Your train will now travel East whenever it can..."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].stepTitle = "Done!"
	tutorialSteps[k].message = "You've completed the second tutorial, well done!\nClick 'More Info' for some ideas of what you can try on your own before going to the next tutorial."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "More Info", event = additionalInformation("You can try to go East, then North, then South, then East again and so on. To do this, create a variable in ai.init(), call it \"dir\". Then add 1 to dir (dir = dir + 1) every time it calls ai.chooseDirection. Then return \"N\", \"S\" or \"E\" if dir is 1, 2 or 3. Don't forget to set dir back to 0 or 1 when it's greater than 3!"), inBetweenSteps = true}
	tutorialSteps[k].buttons[3] = {name = "Next", event = nextTutorialStep}
	k = k + 1
	
	tutorialSteps[k] = {}
	tutorialSteps[k].message = "Go directly to the next tutorial or return to the menu."
	tutorialSteps[k].buttons = {}
	tutorialSteps[k].buttons[1] = {name = "Back", event = prevTutorialStep}
	tutorialSteps[k].buttons[2] = {name = "Quit", event = endTutorial}
	tutorialSteps[k].buttons[3] = {name = "Next Tutorial", event = nextTutorial}
	k = k + 1
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
	x = love.graphics.getWidth()-roundStats:getWidth()-20
	y = 20
	love.graphics.draw(roundStats, x, y)
	
	love.graphics.print("Tutorial 2: Left or Right?", x + roundStats:getWidth()/2 - FONT_STAT_MSGBOX:getWidth("Tutorial 2: Left or Right?")/2, y+10)
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
