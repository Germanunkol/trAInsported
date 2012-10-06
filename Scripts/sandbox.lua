local sandbox = {}
--[[
function restrictAITable(table)
   return setmetatable({}, {
     __index = table,
     __newindex = function(t, key, value)
     	if (key == "init" or key == "chooseDirection" or key == "blocked" or key == "foundPassengers" or key == "foundDestination") then
     		if type(value) == "function" then
	     		rawset(t, key, value )
	     	else
	     		error("ai." .. key .. " may only hold a function value!")
	     	end
     	else
			error("Restricted access to table. Can't add: '" .. key .. "' (" .. type(value) .. ")")
		end
	end,
     __metatable = false
   });
end
]]--
local function safeprint(aiID)
	return function (...)
		str = "[" .. ai.getName(aiID) .. "]"
		for k, v in ipairs(arg) do
			if not v then print("trying to print nil value!")
			else
				str = str .. "\t".. tostring(v)
			end
		end
		if aiID == 1 then console.add(str, PLAYERCOLOUR1_CONSOLE)
		elseif aiID == 2 then console.add(str, PLAYERCOLOUR2_CONSOLE)
		elseif aiID == 3 then console.add(str, PLAYERCOLOUR3_CONSOLE)
		elseif aiID == 4 then console.add(str, PLAYERCOLOUR4_CONSOLE)
		else console.add(str)
		end
	end
end


function sandbox.createNew(aiID)
	sb = {}
	
	-- list of all functions which the AI is allowed to use:
	sb.pairs = pairs
	sb.ipairs = ipairs
	sb.table = table
	sb.type = type
	
	sb.print = safeprint(aiID)
	sb.error = error
	sb.pcall = pcall

	sb.random = math.random
	sb.dropPassenger = passenger.leaveTrain(aiID)
	return sb
end

return sandbox
