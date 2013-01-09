----------------------------------------
-- Attempt to connect to MySQL Database to store match results.

if CL_MYSQL_NAME then
	ok, msg = pcall(require, "luasql.mysql")

	if not ok then
		print("Could not load mysql. If you want to use MySQL logging, make sure the lua extension luasql is installed! Otherwise, ignore this warning.")
	else
		print("MYSQL driver loaded.")
		MYSQL = true
		luasql = msg
	end
end

function chooseAIfromDB()
	print("Looking for AIs in DB!")
	if MYSQL then
		-- open MYSQL environment:
		env = luasql.mysql()
		math.randomseed(time())
		if env then
			conn = env:connect(MYSQL_DATABASE, CL_MYSQL_NAME, CL_MYSQL_PASS, CL_MYQSL_HOST, CL_MYSQL_PORT)
			if conn then
				print("Connected to DB.")
				
				result = false
				exists = false
				cursor,err = conn:execute("SELECT name,owner,matches FROM ais ORDER BY matches;")
				local row, fileNames = {}, {}
				local i = 1
				local probability = 0
				local totalMatches = 0
				if cursor then
					row[i] = cursor:fetch ({}, "a")
					while row[i] do
						totalMatches = totalMatches + row[i].matches		-- count all matches
						i = i + 1
						row[i] = cursor:fetch ({}, "a")
					end
				end
				for i = 1,#row do 
					probability = probability + 100-100*row[i].matches/totalMatches
					row[i].probability = probability
					print("1. Found in Database",row[i].name, row[i].owner,row[i].matches, row[i].probability)
				end
				
				
				toChoose = math.min(4, #row)
				print("Choosing " .. toChoose .. " AIs.")
				while toChoose > 0 do
					local chosen = math.random(probability)
					print("Choosing probability:", chosen)
					local i = #row
					while i > 0 do
						if row[i] then
							if row[i].probability < chosen and not row[i].chosen then
								row[i].chosen = true
								toChoose = toChoose - 1
								break
							end
						end
						i = i - 1
					end
					if i == 0 then		-- none found. Go back through the list and choose the first possible one.
						i = 1
						while i < #row do
							if not row[i].chosen then
								row[i].chosen = true
								toChoose = toChoose - 1
								break
							end
							i = i + 1
						end
					end
				end
				for i = 1,#row do 
					if row[i].chosen then
						table.insert( fileNames, CL_DIRECTORY .. "/" .. row[i].owner .. "/" .. row[i].name .. ".lua" )
					end
				end
				
				for i = 1, #fileNames do
					print(i, fileNames[i])
				end
				return fileNames
			end
		end
	else
		return nil
	end
end

log = {}

function log.matchResults()
	print("attempting to log match")
	if MYSQL then
		print("mysql found")
		-- open MYSQL environment:
		env = luasql.mysql()
		
		if env then
			print("loaded mysql driver!")
			conn = env:connect(MYSQL_DATABASE, CL_MYSQL_NAME, CL_MYSQL_PASS, CL_MYQSL_HOST, CL_MYSQL_PORT)
			if conn then
				print("connection successful!")
				
				querry = "UPDATE ais SET matches=matches+1"
				
				first = true
				for i = 1,#aiList do
					result = false
					exists = false
					cursor,err = conn:execute("SELECT name FROM ais WHERE name LIKE '" .. aiList[i].name .. "';")
					if not cursor then
						print(err)
					else
						result = cursor:fetch()
						cursor:close()
					end
					if result then
						print("Found " .. aiList[i].name .. " in Database!")
						exists = true				
					else
						print("Didn't find " .. aiList[i].name .. " in Database. Attempting to add.")
						cursor, err = conn:execute("INSERT INTO ais VALUE('" .. aiList[i].name .. "','" .. aiList[i].owner .. "',0,0,0,'"  .. aiList[i].name .. ".lua', NULL);")
						if not cursor then
							print(err)
						elseif type(cursor) == "table" then
							cursor:close()
							exists = true
						end
					end
					if exists then
						if first then
							first = false
							querry = querry .. " WHERE (name LIKE '" .. aiList[i].name .. "' AND owner LIKE '" .. aiList[i].owner .. "')"
						else
							querry = querry .. " OR (name LIKE '" .. aiList[i].name .. "' AND owner LIKE '" .. aiList[i].owner .. "')"
						end
					end
				end				
				
				querry = querry .. ";"
				
				print("Querry:", querry)
				
				cursor,err = conn:execute(querry)
				if not cursor then
					print(err)
				elseif type(cursor) == "table" then
					print("result:")
					printTable(cursor)
					cursor:close()
				else
					print("result",cursor)
				end
				
				if winnerID and aiList[winnerID] then
					querry = "UPDATE ais SET wins=wins+1 WHERE name LIKE '" .. aiList[winnerID].name .. "' AND owner LIKE '" .. aiList[winnerID].owner .. "';"
				
					cursor,err = conn:execute(querry)
					if not cursor then
						print(err)
					elseif type(cursor) == "table" then
						cursor:close()
					else
						print("result",cursor)
					end
				end
				
				
				-- add a table holding the last match:
				-- drop previous one:
				querry = "DROP TABLE lastMatch;"
				cursor,err = conn:execute(querry)
				if not cursor then
					print(err)
				end
		
				-- create a new one:
				querry = "CREATE TABLE lastMatch (name VARCHAR(30), owner VARCHAR(30), pTransported INT);"
				cursor,err = conn:execute(querry)
				if not cursor then
					print(err)
				elseif type(cursor) == "table" then
					cursor:close()
				else
					print("result",cursor)
				end
		
				-- fill the table:
				for i = 1,#aiList do
					querry = "INSERT INTO lastMatch VALUE('" .. aiList[i].name .. "','" .. aiList[i].owner .. "'," .. stats.getPassengersTransported(i) .. ");"
					print(querry)
					cursor, err = conn:execute(querry)
					if not cursor then
						print(err)
					elseif type(cursor) == "table" then
						cursor:close()
					else
						print("result",cursor)
					end
				end
				
			
				conn:close()
			else
				print("Error connecting to MySQL. Does the database exist?")
			end
			
			env:close()
		else
			print("Error opening MySQL environment.")
		end
	end
end

function log.findTable()
	if MYSQL then
	
		env = luasql.mysql()
		
		if env then
			conn = env:connect(MYSQL_DATABASE, CL_MYSQL_NAME, CL_MYSQL_PASS, CL_MYQSL_HOST, CL_MYSQL_PORT)
			if conn then
				cursor = conn:execute("SHOW TABLES LIKE 'ais';")		-- see if the "ais" table exists. if not, attempt to create it:
				result = nil
				if cursor then
					result = cursor:fetch()
					cursor:close()
				end
				if result then
					found = true
					print("Found table 'ais'. Success!")
				else
					cursor = conn:execute("CREATE TABLE ais (name VARCHAR(30), owner VARCHAR(30), matches INT, wins INT, cash INT, scriptName VARCHAR(40), timeCreated DATETIME);")		-- see if the "ais" table exists. if not, attempt to create it:
					if cursor then
						found = true
						print("Created table 'ais' in " .. MYSQL_DATABASE .. ".")
						if type(cursor) == "table" then
							cursor:close()
						end
					end
				end
				conn:close()
			else
				print("Error connecting to MySQL. Does the database exist?")
			end
		end
		
		if not found then
			MYSQL = false
			print("Could not find nor create table 'ais' in '" .. MYSQL_DATABASE .. "'... disabling MySQL logging.")
		end
		
	end
end

return log
