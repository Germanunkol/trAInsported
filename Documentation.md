**trAInsported**
=====================
- - - - - - - - - - -
This is a list of all functions that your AI should use.  
  
Before you read this, check out the tutorials in-game!  

For more information, visit the website:  
[Official trAInsported Website](http://trainsportedgame.no-ip.org)

- - - - - - - - - - -
This document is split up into two parts.  
The first part lists the events which you should define. If you define them correctly, then the game will call them if certain events happen. For example, if you define "function ai.init()" then this function will be called when the round starts. Or, if your script has a function "function ai.chooseDirection()" then this function will be called whenever a train comes to a junction and wants to know which way to go.  
The second part of this document lists functions that you can call in your code, like "random", "getMoney" and "print".

Many of these are covered in the tutorials, so make sure to play them!



Callback Events
--------------------

###function ai.init(map, money)###
This event is called, at the beginning of the round. The current map is passed to it, so you can analize it, get it ready for pathfinding and search it for important junctions, Hotspots, shortest paths etc.  
**Passed Arguments:**

- map: A 2D representation of the current map. "map" has a field map.width and a field map.height to check the size of the map. It also holds information about what's on the map, which is stored by x and y coordinates. For example, to see what's at the position x=3, y=5, you only have to check map[3][5]. A map field can be filled with: "C" (Connected Rail), "H" (House), "S" (Hotspot)
- money: The amount of money that you currently have. You can use this to check how many trains you may buy (one train costs 25 credits).

**Example**

		function ai.init(map, money)
	
			-- go through the entire map and search for all hotspots:
			for x = 1, map.width, 1 do
				for y = 1, map.height, 1 do
					if map[x][y] == "S" then	-- if the field at [x][y] is "S" then print the coordinates on the screen:
						print("Hotspot found at: " .. x .. ", " .. y .. "!")
					end
				end
			end
	
			buyTrain(random(map.width), random(map.height))		-- place train at random position
		end
		
###function ai.newTrain(train)###
Called when the train you bought using buyTrain has successfully been created.  
**Passed Arguments:**

- train: a Lua table representing the train. See ai.chooseDirection for details.

**Example**

		function ai.newTrain(train)
			print("Bought new train:", train.name)
			print("Train is starting at:", train.x, train.y)
		end
		
###function ai.chooseDirection(train, possibleDirections)###
Called just before a train enters a junction. This function is essential: It lets your train tell the game where it wants to go. If this function returns a valid direction (N, E, S or W) and the direction is not blocked by another train, the train will continue in that direction.  

**Passed Arguments**

- train: a Lua table representing the train. It has the fields:
	- train.ID (an ID representing the train - number)
	- train.name (the name of the train - string)
	- train.x (x-position of the tile the train is on - number)
	- train.y (y-position of the tile the train is on - number)
	- train.passenger (table representing passenger who's currently on the train, if any - holds the fields name, destX and destY. See ai.foundPassengers for more details.)
- possibleDirections: a Lua table showing the directions which the train can choose from. One of these directions should be returned by the function, to make the train go that way. The table's indieces are the direction ("N","S","E","W") and if the value at the index is true, then this direction is one that the train can move in.

**Returns**

- The function should return a string holding one of the directions which are stored in possibleDirections ("N", "S", "E", "W" are the possible values). If a wrong value is returned, or nothing is returned then the game will automatically try the directions in the following order: N, S, E, W

**Example**

		function ai.chooseDirection(train, possibleDirections)
		
			-- let train 1 go South if possible
			if train.ID == 1 then
				if possibleDirection["S"] == true then
					return "S"
				end
			end
			
			-- let all trains go North if possible
			if possibleDirections["N"] == true then
				return "N"
			end
			
			-- if the above directions were not possible, the let the game choose a direction (i.e. choose nothing)
		end

###function ai.blocked(train, possibleDirections, prevDirection)###
Called after a train was blocked by another train and can't move in that direction. By returning the prevDirection, you can keep trying to go in the same direction. However, you should not try to keep moving in the same direction forever, because then trains could block each other for the rest of the match.  
**Passed Arguments**

- train: same as above (see ai.chooseDirection)
- possibleDirections: a Lua table showing the directions which the train can choose from. One of these directions should be returned by the function, to make the train go that way. The table's indieces are the direction ("N","S","E","W") and if the value at the index is true, then this direction is one that the train can move in.
- prevDirection: the direction that the train previously tried to move in, but was blocked.

**Returns**

- The function should return a string holding one of the directions which are stored in possibleDirections ("N", "S", "E", "W" are the possible values). If a wrong value is returned, or nothing is returned then the game will automatically try the directions in the following order: N, S, E, W

**Example**

		function ai.blocked(train, possibleDirections, prevDirection)
			if prevDirection == "N" then		-- if i've tried North before, then try South, then East, then West
				if possibleDirections["S"] == true then
					return "S"
				elseif possibleDirections["E"] == true then
					return "E"
				elseif possibleDirections["W"] == true then
					return "W"
				else return "N"
				end
			elseif prevDirection == "S" then
				if possibleDirections["E"] == true then
					return "E"
				elseif possibleDirections["W"] == true then
					return "W"
				elseif possibleDirections["N"] == true then
					return "N"
				else return "S"
				end
			elseif prevDirection == "E" then
				if possibleDirections["W"] == true then
					return "W"
				elseif possibleDirections["N"] == true then
					return "N"
				elseif possibleDirections["S"] == true then
					return "S"
				else return "E"
				end
			else
				if possibleDirections["N"] == true then
					return "N"
				elseif possibleDirections["S"] == true then
					return "S"
				elseif possibleDirections["E"] == true then
					return "E"
				else return "W"
				end
			end
		end


###function ai.foundPassengers(train, passengers)###
This function is called when a train arrives at a position where passengers are waiting to be picked up. If one of the passengers in the list is returned, then this passenger is picked up (but only if the train does not have a passenger at the moment). If you want to pick up a passenger but you're already trainsporting another passenger, you can drop the current passenger using the function 'dropPassenger'.  
**Passed Arguments:**

- train: the train which has arrived at a position where passengers are waiting. Same as above (see ai.chooseDirection)
- passengers: List of passengers which are at this position. Each passenger is a table containing:
	- name: Name of the passenger
	- destX: Destination of the passenger (X-coordinate)
	- destY: Destination of the passenger (Y-coordinate)

**Returns:**

- Passenger: The passenger in the list who is to be picked up. (i.e. passengers[1] or passengers[2])

**Example:**

		function ai.foundPassengers(train, passengers)
			print("I'll pick up passenger: " .. passengers[1].name)
			print("Taking him to: " .. passenger[1].destX .. ", " .. passenger[1].destY)
			return passengers[1]
		end
		
###function ai.foundDestination(train)###
This function is called when a train which is carrying a passenger arrives at the position where the passenger wants to go. This way, you can drop off the passenger by calling 'dropPassenger'.  
**Passed Arguments**

- train: same as above (see ai.chooseDirection)

**Returns:**

- nothing

**Example:**

		function ai.foundDestination(train)
			print("Dropping of my passenger @ " .. train.x .. ", " .. train.y)
			dropPassenger(train)
		end
		
###function ai.enoughMoney(money)###
Whenever the player earns money, the game checks if the player now has enough money to buy a new train. If that is the case, then this function is called so that the player can decide whether to buy a new train by calling buyTrain() and if so, where to place it.  
**Passed Arguments**

- money: The amount of money you now have.

**Returns:**

- nothing

**Example:**

		rememberMap = nil

		function ai.enoughMoney(money)
			x = random(rememberMap.width)	-- important! this only works because the map was stored in the global "rememberap" in ai.init()
			y = random(rememberMap.height)
			while money >= 25 do		-- 25c is cost of one train
				buyTrain(x, y)
				money = money - 25
			end
		end
		
		function ai.init(map, money)
			rememberMap = map
			buyTrain(random(map.width), random(map.height))
		end

###function ai.newPassenger(name, x, y, destX, destY)###
Will be called whenever a new passenger spawns on the map, or if a passenger has been dropped off at a place that was not his destination.  
**Passed Arguments:**

- name: name of the passenger. If the passenger is a VIP, then "[VIP]" is appended to his name.
- x, y: the x and y positions of the tile on which the passenger is standing.
- destX, destY: the x and y position of the tile to which the passenger would like to be transported. As soon as you drop him/her of at this position, you will get paid.

**Returns:**

- nothing

**Example**

		passengerList = {}	-- create an empty list to save the passengers in
		function ai.newPassenger(name, x, y, destX, destY)
		
			-- create a new table which holds the info about the new passenger:
			local passenger = {x=x, y=y, destX=destX, destY=destY}
			
			-- save the passenger into the global list, to "remember" him for later use.
			-- use the name as an index to easily find the passenger later on.
			passengerList[name] = passenger
		end

###function ai.passengerBoarded(train, passenger)###
Will be called whenever a train of another player has taken a passenger aboard. You can use this function to make sure your trains no longer try to go to that passenger, if that was their plan.  
Note: This function is NOT called when one of your own trains takes a passenger aboard!  
**Passed Arguments:**

- train: the train which has taken the passenger in. (Same as for chooseDirection)
- passenger: name of passenger who has boarded a train.

**Returns:**

- nothing

**Example**

		passengerList = {}	-- create an empty list to save the passengers in
		function ai.newPassenger(name, x, y, destX, destY)
		
			-- create a new table which holds the info about the new passenger:
			local passenger = {x=x, y=y, destX=destX, destY=destY}
			
			-- save the passenger into the global list, to "remember" him for later use.
			-- use the name as an index to easily find the passenger later on.
			passengerList[name] = passenger
		end
		
		function ai.passengerBoarded(train, passenger)
			-- set the entry in the passengerList for the passenger to nil. This is the accepted way of "deleting" the entry in Lua.
			passengerList[passenger] = nil
		end


Available Functions
--------------------
You can define your own functions inside your code.  
This is a list of functions that are already specified and which you can call at any time. Be careful not to overuse them - they all take some time to compute and your code will be aborted if it takes too long!

###print(...)###
Prints the given objects to the ingame-console (make sure it's visible by pressing 'C' in the game!)  
**Arguments:**

- ... List of objects to print

**Returns:**

- nothing

**Example:**
  
		print("Sheldon likes trains!")
		
###clearConsole()###
Clears the ingame console to make space for new Messages.  
**Arguments:**

- none

**Returns:**

- nothing

**Example:**
  
		clearConsole()


###pairs(tbl)###
The standard Lua pairs value. See a Lua documentation for more examples.  
**Arguments:**

- tbl: The Table through which you want to iterate

**Returns:**

- Iterator over the key, value pairs in the table.

**Example:**

		for k, value in pairs(map) do
			print(k, value)
		end



###type(variable)###
Returns the type of the given variable.  
**Arguments:**

- variable: variable of which you want to know the type

**Returns:**

- Type of variable. Possible Types are: "string", "number", "table", "userdata"

**Example:**

		if type(myValue) == "number" then
			print("my Value is a number!")
		elseif type(myValue) == "string" then
			print("my Value is a string!")
		else
			print("my Value is neither a number, nor a string. It's of type " .. type(myValue))
		end

  
###pcall(chunk, args)###
Will safely execute the code given by chunk (can be a function). This way, you can run code which might raise an error or might not be working correctly, without loosing control. In case there's an error in the code, you can safely handle the exception.  
**Arguments:**

- chunk: code to run, usually the name of the function
- args: any arguments that should be passed to the chunk

**Returns:**

- ok: true if the chunk ran without errors, false otherwise
- result: data returned by the chunk if it ran correctly. Otherwise, result holds the error message.

**Example:**

		function foo( argument )
			... -- do stuff in here
		end
		bar = 1
		ok, result = pcall(foo, bar)	-- call the function "foo" with the argument "bar"
		if not ok then
			print("Error in 'foo': " .. result)
		end

###error(msg)###
Throws an error. If the function in which the error is thrown is called using pcall, then the pcall will return this error as its error message. Otherwise, the error is printed in the ingame console.
  
**Arguments:**

- msg: any error message or error code.

**Example:**

		-- absolutely useless code (but works)
		function foo( b )
			a = 1
			while a < 100 do
				if b > a then
					error("b is greater than a!")
				end
				a = a + 1
			end
		end
		
		ok, msg = pcall(foo, 10)
		if not ok then
			print("Error: " .. msg)
		end
		
###table, math, string functions###
You also have access to all of Lua's table-functions: table.sort, table.insert, table.remove etc. See a Lua Documentation for details.
Same goes for math functions (math.sin, math.cos, math.floor, math.random etc) and the string functions (string.sub, string.find etc).
There is a few exceptions, but most functions in these libraries are available.

###dropPassenger(train)###
Will drop of the passenger of the train at its current position.

###buyTrain(x, y, dir)###
Will try to buy a train and place it at the position [X][Y]. If there's no rail at the given position, the game will place the train at the rail closest to [X][Y]. If the rail is blocked, the game waits until the blocking trains have left the rail. This means the train WILL be bought, but might be placed at a different position or go in a different direction than what you anticipate.

**Arguments:**

- x (The x-coordinate of the position at which to place the train)
- y (The y-coordinate of the position)
- dir (The direction in which the train should go. If an invalid direction is passed (or if it's 'nil') then the game tries to use default directions in the following order: North, South, East, West.

**Example:**

		function ai.init(map, money)
			while money > 25 do		-- check if I still have enough money to buy a train?
				money = money - 25	-- 25 is the standard cost for a train
				
				xPos = random(map.width)
				yPos = random(map.height)
				
				randomDir = random(4)
				if randomDir == 1 then
					buyTrain(xPos, yPos, "N")	-- try to buy a train, place it at the position and make it go North.
				elseif randomDir == 2
					buyTrain(xPos, yPos, "S")	-- try to buy a train, place it at the position and make it go South.
				elseif randomDir == 3
					buyTrain(xPos, yPos, "E")	-- try to buy a train, place it at the position and make it go South.
				elseif randomDir == 4
					buyTrain(xPos, yPos, "W")	-- try to buy a train, place it at the position and make it go South.
				else
					buyTrain(xPos, yPos)	-- don't care what direction to go in.
				end
			end
		end

###getMoney()###

**Arguments:**

- none

**Returns:**

- The amount of credits the player currently has at his or her disposal.

**Example:**

		myMoney = getMoney()
		if myMoney > 10 then
			print("I'm rich!")
		else
			print("I'm not so rich...")
		end
		
###require(filename), dofile(filename), loadfile(filename)###

These functions are used to add additional files to your code. There is a few things to consider:
- Paths given here are _relative_ to the main file of your AI.
- Best practice is to put all included files into a subfolder of the AI folder. This way, the subfiles will not be handled as individual AIs by the game.
- When uploading, you need to make a .zip file out of all the files the AI uses. Make sure the main AI is _at the root_ of this .zip file. To check if this is the case: Open your created .zip file in any archive manager and check if the main .lua file is right there. If it is, you're fine, if not (i.e. you have to go into a subfolder inside the archive to find it) then you need to change that.
- Your uploaded .zip file must not be larger than the file limit given by the website.
- Require is just an interface to dofile for security reasons. It can be used to include files, but don't expect it to be as complex as a proper require call is.
Check the online lua documentation for more details on the various functions.

**Arguments:**

- The file to load or run. See 

**Returns:**

- The amount of credits the player currently has at his or her disposal.

**Example:**

		myMoney = getMoney()
		if myMoney > 10 then
			print("I'm rich!")
		else
			print("I'm not so rich...")
		end
