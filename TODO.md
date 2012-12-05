
To do for trAInsported:
=========================

**Map (Editor)**
- Tile map
- Random environment pieces

**Sandbox**
- Events:
	-[x] "Init"
	-[x] "chooseDirection"
	-[x] "New Passenger"	-- special argument if the passenger's a VIP.
	-[x] "Arrived at Passenger's tile"
	-[x] "Arrived at Passenger's destination"
- Functions:
	-[x] "drop off passenger"		-- removes passenger from train
	-[x] "pick up passenger"
	-[x] "Random"
	-[x] "Print"
	-[x] "New Train"

**Server**

**Security**
- Before download/upload, add a line that won't allow the scripts to be run without the game.
- Automatically replace windows line endings with unix line breaks.

**Game**
[x]	Add VIPs
[x]	Add Hotspots
- Randomize order in which players get to move
- Beautify rails	(shadows?), increase # of waypoints
[x] buy new trains
[x] rework train movement: make it pixel-independet and make it work with percentages.
- Add statistics for passengers at round end
- Make game deterministic!

**Tutorial**
tut 1: 
[x] Controls
[x] Init game, print
[x] Placing train
[x] Picking up passenger
[x] Letting passenger get off
tut 2:
[x] Junctions
- Lua control structures (while, if)
- Multiple Passengers


**Visual**
[x]	clouds
[x] trees
- water
[x]	rework all visuals
- Urban setting

**Misc**
- Add tipps
- No guarantee that game's outcome is always the same...
[x] Status message box
- make sure globals.lua is the same for server and client!


**Maybe**
- buy code lines using in-game cash
- handicapped people
