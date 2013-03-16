local configFile = {}

function configFile.setValue( name, value )
	if not name or not value == nil then
		print(name, value)
		error("Err: configFile.setValue got nil value or nil name.")
	end
	
	if type(value) ~= "string" then
		value = tostring(value)
	end
	
	local file = love.filesystem.newFile( CONFIG_FILE )
	local data
	if file then
		file:open('r')
		data = file:read()
		file:close()
	end
	
	if not data then
		data = ""
	end
	
	s, e = string.find(data, name .. " = [^\r\n]+\r\n")
	if s then
		data = string.gsub(data, name .. " = [^\r\n]+\r\n", name .. " = " .. value .. "\r\n")
	else
		data = data .. name .. " = " .. value .. "\r\n"
	end
	
	file = love.filesystem.newFile( CONFIG_FILE )
	if file then
		file:open('w')
		file:write(data)
		file:close()
		return true
	end
end

function configFile.getValue( name )
	local file = love.filesystem.newFile( CONFIG_FILE )
	local data
	if file then
		file:open('r')
		data = file:read()
		file:close()
	end
	if data then
		for k, v in string.gmatch(data, "([^ \r\n]+) = ([^\r\n]+)") do
			if k == name then
				return v
			end
		end
	else
		return nil
	end
end

return configFile
