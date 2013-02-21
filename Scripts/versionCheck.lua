local versionCheck = {}


function versionCheck.start()

	versionMatch = nil

	exists = love.filesystem.exists( CONFIG_FILE )
	if exists then
		local file = love.filesystem.newFile( CONFIG_FILE )
		file:open('r')
		local data = file:read()
		--print("config file:", data)
		s, e = data:find("version = ")
		if s then 
			local tmp = data:sub(e+1, #data)
			s2, e2 = tmp:find("\r\n")
			if s2 then
				v = tmp:sub(1, s2-1)
				print("Config file is version: " .. v, "Game version: " .. VERSION)
				if v == VERSION then
					versionMatch = true
					print("\tVersions match!")
				end
			end
		end
	end
	
	if not versionMatch then
		local data = ""
		data = data .. "version = " .. VERSION .. "\r\n"
		love.filesystem.write( CONFIG_FILE, data )
	end
end

function versionCheck.getMatch()
	return versionMatch
end

return versionCheck
