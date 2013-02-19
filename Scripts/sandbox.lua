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
		arg = { ... }
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


local function safeDofile(scriptName)
	_, pos = scriptName:find(".*/")		-- find last occurrance of /
	if not pos then pos = 0 end
	path = scriptName:sub(1, pos)
	return function(fileToInclude)
		if not fileToInclude:find(".lua") then
			fileToInclude = fileToInclude .. ".lua"
		end
		dofile(path .. fileToInclude)
		
		--return f()
		--return loadfile(path  .. fileToInclude)
	end
end

function sandbox.createNew(aiID, scriptName)
	sb = {}
	
	-- list of all functions which the AI is allowed to use:
	sb.pairs = pairs
	sb.ipairs = ipairs
	sb.type = type
	sb.string = {}
	sb.string.btye = string.byte
	sb.string.char = string.char
	sb.string.find = string.find
	sb.string.format = string.format
	sb.string.gmatch = string.gmatch
	sb.string.gsub = string.gsub
	sb.string.len = string.len
	sb.string.lower = string.lower
	sb.string.match = string.match
	sb.string.rep = string.rep
	sb.string.reverse = string.reverse
	sb.string.sub = string.sub
	sb.string.upper = string.upper
	sb.table = {}
	sb.table.insert = table.insert
	sb.table.maxn = table.maxn
	sb.table.remove = table.remove
	sb.table.sort = table.sort
	sb.math = {}
	sb.math.abs = math.abs
	sb.math.acos = math.acos
	sb.math.asin = math.asin
	sb.math.atan = math.atan
	sb.math.atan2 = math.atan2
	sb.math.ceil = math.ceil
	sb.math.cos = math.cos
	sb.math.cosh = math.cosh
	sb.math.deg = math.deg
	sb.math.exp = math.exp
	sb.math.floor = math.floor
	sb.math.fmod = math.fmod
	sb.math.frexp = math.frexp
	sb.math.huge = math.huge
	sb.math.ldexp = math.ldexp
	sb.math.log = math.log
	sb.math.log10 = math.log10
	sb.math.max = math.max
	sb.math.min = math.min
	sb.math.modf = math.modf
	sb.math.pi = math.pi
	sb.math.pow = math.pow
	sb.math.rad = math.rad
	sb.math.random = math.random
	sb.math.randomseed = math.randomseed
	sb.math.sin = math.sin
	sb.math.sinh = math.sinh
	sb.math.sqrt = math.sqrt
	sb.math.tan = math.tan
	sb.math.tanh = math.tanh 
	sb.select = select
	
	sb.print = safeprint(aiID)
	sb.clearConsole = console.flush
	
	sb.error = error
	sb.pcall = pcall

	sb.random = math.random
	sb.sqrt = math.sqrt
	sb.dropPassenger = passenger.leaveTrain(aiID)
	sb.buyTrain = train.buyNew(aiID)
	sb.getMoney = stats.getMoneyAI(aiID)


	-- scriptName is used to get the path:
	sb.dofile = function(f)
		_, pos = scriptName:find(".*/")		-- find last occurrance of /
		if not pos then pos = 0 end
		local path = scriptName:sub(1, pos)
		return assert(sb.loadfile(path .. f))()
	end
	
	function sb.loadfile(file)
		if not file:find(".lua") then
			file = file .. ".lua"
		end
		local chunk, err = loadfile(file)
		if not chunk then return nil, err end
		setfenv(chunk, sb)
		return chunk
	end
	
	sb.require = sb.dofile
	return sb
end

return sandbox
