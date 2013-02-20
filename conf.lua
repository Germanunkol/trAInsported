

--------------------------------
-- Config file for trAInsported.
--------------------------------
-- by Germanunkol

-- Options:
-- -d
-- 

function os.capture(cmd, raw)
	local f = assert(io.popen(cmd, 'r'))
	local s = assert(f:read('*a'))
	f:close()
	if raw then return s end
	s = string.gsub(s, '^%s+', '')
	s = string.gsub(s, '%s+$', '')
	s = string.gsub(s, '[\n\r]+', ' ')
	return s
end

function seperateStrings(str)
	tbl = {}
	index = 1
	
	if str:sub(#str,#str) ~= "," then		-- gfind will not capture a substring unless there's a comma following
		str = str .. ","
	end
	
	for val in string.gfind(str, ".-,") do
		tbl[index] = val:sub(1,#val-1)
		pos = #val+1
		index = index + 1
	end
	return tbl
end



-- Check if game this is running in dedicated server mode:
for k, a in pairs(arg) do
	if a == "-s" or a == "--dedicated" or a == "--server" then
		DEDICATED = true
		arg[k] = nil
		break
	end
end


-- Check if user has given a port number:
for k, a in pairs(arg) do
	if a == "-p" or a == "--port" then
		INVALID_PORT = true
		if type(k) == "number" then
			if arg[k+1] then
				p = tonumber(arg[k+1])
				if p >= 0 and p <= 65535 then
					CL_PORT = p
					INVALID_PORT = false
				end
				arg[k+1] = nil
				arg[k] = nil
			end
		end
		break
	end
end

for k, a in pairs(arg) do
	if a == "--mapsize" then
		INVALID_MAPSIZE = true
		if type(k) == "number" then
			if arg[k+1] then
				s = tonumber(arg[k+1])
				if s >= 5 and s <= 100 then
					MAP_SIZE = s
					INVALID_MAPSIZE = false
				end
				arg[k+1] = nil
				arg[k] = nil
			end
		end
		break
	end
end

for k, a in pairs(arg) do
	if a == "--directory" or a == "-d" then
		INVALID_DIRECTORY = true
		if type(k) == "number" then
			if arg[k+1] then
				if os.capture("uname") == "Linux" then
					CL_DIRECTORY = arg[k+1]
					INVALID_DIRECTORY = false;
					arg[k+1] = nil
					arg[k] = nil
				end
			end
		end
		break
	end
end

for k, a in pairs(arg) do
	if a == "--chart" then
		INVALID_CHART_DIRECTORY = true
		if type(k) == "number" then
			if arg[k+1] then
				CL_CHART_DIRECTORY = arg[k+1]
				INVALID_CHART_DIRECTORY = false;
				arg[k+1] = nil
				arg[k] = nil
			end
		end
		break
	end
end

for k, a in pairs(arg) do
	if a == "--match_time" or a == "-m" then
		INVALID_MATCH_TIME = true
		if type(k) == "number" then
			if arg[k+1] then
				t = tonumber(arg[k+1])
				if t >= 10 then
					CL_ROUND_TIME = t
					INVALID_MATCH_TIME = false
				end
				arg[k+1] = nil
				arg[k] = nil
			end
		end
		break
	end
end

for k, a in pairs(arg) do
	if a == "--cooldown" or a == "-c" then
		INVALID_DELAY_TIME = true
		if type(k) == "number" then
			if arg[k+1] then
				t = tonumber(arg[k+1])
				if t >= 0 then
					CL_TIME_BETWEEN_MATCHES = t
					INVALID_DELAY_TIME = false
				end
				arg[k+1] = nil
				arg[k] = nil
			end
		end
		break
	end
end

for k, a in pairs(arg) do
	if a == "--host" or a == "-h" or a == "--ip" then
		INVALID_IP = true
		if type(k) == "number" then
			if arg[k+1] then
				ip = arg[k+1]
				CL_SERVER_IP = ip
				INVALID_IP = false
				arg[k+1] = nil
				arg[k] = nil
			end
		end
		break
	end
end

for k, a in pairs(arg) do
	if a == "--mysql" then
		INVALID_MYSQL = true
		if type(k) == "number" then
			if arg[k+1] then
				login = seperateStrings(arg[k+1])
				if login[1] and login[2] then
					CL_MYSQL_NAME = login[1]
					CL_MYSQL_PASS = login[2]
					CL_MYSQL_HOST = login[3] or "localhost"	-- could be nil!
					CL_MYSQL_PORT = login[4]	-- could be nil!
					INVALID_MYSQL = false
				end
				arg[k+1] = nil
				arg[k] = nil
			end
		end
		break
	end
end

for k, a in pairs(arg) do
	if a == "--mysqlDB" then
		INVALID_MYSQL_DATABASE = true
		if type(k) == "number" then
			if arg[k+1] then
				ip = arg[k+1]
				CL_MYSQL_DATABASE = ip
				INVALID_MYSQL_DATABASE = false
				arg[k+1] = nil
				arg[k] = nil
			end
		end
		break
	end
end

for k, a in pairs(arg) do
	if a == "--render" then
		CL_FORCE_RENDER = true
		arg[k] = nil
		break
	end
end


if not DEDICATED then

	love.conf = function(t)
		t.screen.width = 800
		t.screen.height = 600
		t.screen.fullscreen = false
		t.title = "trAInsported"        -- The title of the window the game is in (string)
		t.author = "Germanunkol"        -- The author of the game (string)
		t.url = "http://www.indiedb.com/members/germanunkol"
	end
	
else

	love.conf = function(t)
	
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
