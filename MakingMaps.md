**trAInsported - Challenge Maps**
=====================
- - - - - - - - - - -
This document will teach you how to create your own challenge maps.

When you're happy with your challenge, make sure to upload the challenge to the official website, so other players can download and play them!
- - - - - - - - - - -

To make a new map, do the following:
- Open up the folder where your AIs are stored
- Navigate one folder up
- Open the "Maps" Folder
- Copy and paste the "ExampleChallenge.lua". Then rename it to the name of your Challenge (for example: "AwesomeChallenge.lua").
- Edit the new Lua file.

Once done, save the Lua file and it should show up in the "Challenge" menu of the game.

**IMPORTANT:** To give players the most flexibility possible, these challenge files are NOT run in a protected environment, like the AI is. This means you can do anything inside this code - the game won't stop you from, for example, writing and deleting files or executing programs. Also, when your code is taking too long to compute, it won't be stopped, instead the game will get slow. And when there's an error in your code, the game will crash and display the error message.  
This is why uploaded challenge maps will not display for download immediately - they will be reviewed and tested before they'll be available for others to download.

**ALSO IMPORTANT:** Please make all your variables local. Otherwise they might interfere with the rest of the program. Just put the word "local" infront of the code line that generates them and you'll be fine. Check the ExampleChallenge.lua to see how.  
Test the reload button on your map as well, and see if it still behaves the way it should. If not, you probably didn't make something local!

Structure
--------------------

Each challenge should follow a predefined structure:

		local ch = {}
		
		function ch.start()
			...
		end
		
		return ch

The first and last line here are important, otherwise the map won't run.  
Just like you did with the AIs, there are certain functions which you should implement. These functions will be called when certain events happen (i.e. the map is started or a passenger has been dropped off).

Event functions
--------------------

###function ch.start()###
This event is called at the beginning of the round. Use it to set up the first message of the game.  
**Passed Arguments:**

- none

**Example:**

		function ch.start()
			challenge.setMessage("Prepare to trAIn!")
		end

###function ch.newTrain(train)###
Called when a player has bought a new train.  
**Passed Arguments:**

- train: A table representing the train. Do not edit this table! For speed reasons, the game gives the original train to you - not just a copy. This means if you edit this table, you might break the game. Also note that here, the train's x and y position on the map are represented in the following way: train.tileX and train.tileY show the tile the train is currently on and train.x and train.y show the position (in pixels) ON that tile. This is different from the trains getting passed to the AIs.

**Example:**

		function ch.newTrain(train)
			print("New train created at:", train.x, train.y)
		end

###function ch.update(time)###
Called once every frame. Don't do many heavy calculations in here, it will slow down the game!  
If this function returns "lost", then the player has lost the round and the round will end. If it returns "won" then the player has won and the round will also end.
**Passed Arguments:**

- time: the time that has passed since round start - this is updated every frame. Don't use os.time() (or similar) to determine times, because the player can speed up the game time and then os.time() won't be the correct map time any more.

**Returns:**

- "lost": Player has lost the round
- "won": Player has won the round
- "msg": This second, optional parameter is a string which describes why you lost or won - it will displayed on the "You win!" or "You failed!" screens.

**Example:**

		function ch.update(time)
			challenges.setStatus( math.floor(5-time) .. " seconds remaining.")
			if math.floor(5-time) == 0 then
				return "lost", "Time is up!"
			end
		end


###function ch.passengerBoarded(train, passenger)###
Called when a train is in the process of picking up a passenger.  
**Passed Arguments:**

- train: The train that has picked up the passenger
- passenger: Table containing the new passenger

**Example:**

		function ch.passengerBoarded(train, passenger)
			if train.ID == 1 then
				console.add("Train 1 has picked up the passenger, well done!", {r=255,g=255,b=255})
			end
		end
		
###function ch.passengerDroppedOff(train, passenger)###
Called when a train has dropped off a passenger.  
Note: this does not necessarily mean that the passenger has reached his/her destination!  
**Passed Arguments:**

- train: The train that has dropped off the passenger
- passenger: Table containing the passenger

**Example:**

		function ch.passengerDroppedOff(tr, p)
			if tr.tileX == p.destX and tr.tileY == p.destY then		
				passengersRemaining = passengersRemaining - 1
				console.add("Yes, that's where the passenger wanted to go!", {r=255,g=255,b=255})
			end
		end


Others
--------------------
These are functions you can call and strings/values you can set:

###challenges.setStatus(msg)###
Use to set the status message at the top right corner.  
You can use special characters like "\n" to break the lines.  
**Passed Arguments:**

- msg: A string that will be displayed.

**Example:**

		function ch.update()
			challenges.setStatus("Map by Germanunkol\nThe system time is: " .. os.time())
		end
		
###challenges.setMessage(msg)###
Use to fill the game information field.  
You can use special characters like "\n" to break the lines.  
**Passed Arguments:**

- msg: A string that will be displayed.

**Example:**

		function ch.start()
			challenges.setMessage("Welcome to the new Challenge by Germanunkol!")
		end
		
###challenges.removeMessage()###
Removes the current message box.  

###passenger.new( x, y, destX, destY )###
Call this to create a new passenger on the map.  
If you don't give x and y or if you don't give destX and destY, these parameters will be chosen randomly.  
**Passed Arguments:**

- x, y: Coordinates of the place where the passenger should spawn
- destX, destY: Coordinates of where the passenger should go.

###ai.mapEvent(aiID, ... )###
This function is very useful. It allows you to pass your own messages and events to an AI at any time.  
The player's AI must implement the function ai.mapEvent as well (see the AI Documentation for that), so you should tell them so using challenges.setMessage().  
For an example of this, check out the Smalltown3 Challenge map.  
**Passed Arguments:**

- aiID: (Number) The ID of the AI, in challenge maps there's only one AI, so this ID is 1.
- ... any other arguments you want to pass. Make sure the players know which arguments they should expect! If you want to give the ai a copy of the train, use createTrainCopy() (see below).

###createTrainCopy(train)###
This will create a copy of the train which you can then pass to a user, using ai.mapEvent. This way, the user can't modify the train directly and he/she always gets the train in the same, known format.  
Again, for an example, check out the Smalltown3 challenge map.
**Passed Arguments:**

- train: The way it is implemented internally by the game

**Returns:**

- tr: A table showing the train the way it is usually given to the user.


###ch.name###
String that can be set to display a nicer name than the filename.  
(not used yet)

		ch.name = "Some Name"

###ch.version###
String that can be set to give the user a warning when using a different version to run this map.  
Check the title screen of the game to see what version you're making the map for.  

		ch.version = "1"
		
		
###ch.maxTrains###
The maximum amount of trains per player.  

		ch.maxTrains = 3	-- no more than 3 trains allowed per player on this map.

###ch.startMoney###
The money the player starts with.  
	
		ch.startMoney = 50	-- enough to buy two trains
		
###console.add(message, color)###
Use this to print something to the in-game console.  
**Passed Arguments:**

- message: Text
- color: A table containing r,g and b values (red, green and blue). Console message will be displayed in this color.

		console.add("Beware of Zombies!", {r=255,g=50,b=50})

