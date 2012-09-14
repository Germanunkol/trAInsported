local sandbox = {}

function restrictAITable(table)
   return setmetatable({}, {
     __index = table,
     __newindex = function(t, key, value)
     	if (key == "init" or key == "run") then
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

function sandbox.print(...)
	str = "\t["
	for k, v in ipairs(arg) do
		if not v then print("trying to print nil value!")
		else
			str = str .. "\t".. v
		end
	end
	str = str .. "\t]"
	print(str)
end

return sandbox
