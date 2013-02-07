
To do for trAInsported:
=========================

**Map (Editor)**
- Tile map
[x] Random environment pieces

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
- Randomize order in which players get to move?
[x] increase # of waypoints
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
[x] Lua control structures (while, if)
[x] Junctions
tut 3:
- Multiple Passengers
- Smart choosing of directions (depending on passenger's dest)
tut 4:
- euclidean distance

**Visual**
[x]	clouds
[x] trees
- water
- Urban setting
- weather?
- Seasons change graphics?
- rails with sidewalks
- speed controls
- don't let passengers stand on the rails.

**Misc**
- Add tipps?
- No guarantee that game's outcome is always the same...
[x] Status message box
[x] make sure globals.lua is the same for server and client!
[x] train movment on client is now no longer allowing overshoot -> same for server!
[x] possibly make server and client use the same files?!
[x] tooltips
- rewards!!
[x] Make "Last Match" loggin use only one querry...
[x] Log Date along with "Last Match" and display on website
- screen resolution set at first start!


**Maybe**
- buy code lines using in-game cash?
- handicapped people
- option to transport multiple passengers?
- modify payment method in-game?
- two or three rail types?
- game mode where map is NOT passed to ai.init? (Fog of war?)
- Repair costs?
- Split up rendering of map images into multiple threads?

**Website**
- rank of players?

**Bugs**
[x] generator can generate empty maps?
- default resolution... how to change?
- sometimes Simulation does not render new map for some reason.
