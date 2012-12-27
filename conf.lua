

--------------------------------
-- Config file for trAInsported.
--------------------------------
-- by Germanunkol


-- Check if game this is running in dedicated server mode:
for k, a in pairs(arg) do
	if a == "-D" or a == "--dedicated" or a == "--server" then
		DEDICATED = true
		break
	end
end

if not DEDICATED then

	love.conf = function(t)
		t.screen.width = 1960*0.8
		t.screen.height = 1024*0.8
		t.screen.fullscreen = false
		t.title = "trAInsported"        -- The title of the window the game is in (string)
		t.author = "Germanunkol"        -- The author of the game (string)
		t.url = "http://www.indiedb.com/members/germanunkol"
	end
	

else

	for k, a in pairs(arg) do
		if a == "-t" then
			if type(k) == "number" and arg[k+1] and arg[k+1] then
				TIME_BETWEEN_MATCHES = tonumber(arg[k+1])
				break
			end
		end
	end

	love.conf = function(t)
	
		if not TIME_BETWEEN_MATCHES then
			TIME_BETWEEN_MATCHES = 60
		end
	
		t.screen.width = 50
		t.screen.height = 25
		t.screen.fullscreen = false
		t.title = "trAInsported"        -- The title of the window the game is in (string)
		t.author = "Germanunkol"        -- The author of the game (string)
		t.url = "http://www.indiedb.com/members/germanunkol"
	
		t.modules.joystick = false   -- Enable the joystick module (boolean)
		t.modules.audio = false      -- Enable the audio module (boolean)
		t.modules.keyboard = true   -- Enable the keyboard module (boolean)
		t.modules.event = true      -- Enable the event module (boolean)
		t.modules.image = false      -- Enable the image module (boolean)
		t.modules.graphics = false   -- Enable the graphics module (boolean)
		t.modules.timer = true      -- Enable the timer module (boolean)
		t.modules.mouse = false      -- Enable the mouse module (boolean)
		t.modules.sound = false      -- Enable the sound module (boolean)
		t.modules.physics = false    -- Enable the physics module (boolean)
	end
end
