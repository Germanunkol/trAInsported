function love.conf(t, args)
	t.screen.width = 1920*0.75
	t.screen.height = 1080*0.75
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
    
    print("args:", t)
    for k, x in pairs(t) do
    	print("", k, x)
    end
end
