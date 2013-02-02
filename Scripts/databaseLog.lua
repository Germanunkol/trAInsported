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

function chooseNewAIfromDB_filename()
	print("Looking for AIs in DB!")
	if MYSQL then
		-- open MYSQL environment:
		env = luasql.mysql()
		
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
					local p = (totalMatches/math.max(1,row[i].matches))
					probability = probability + p*p
					row[i].probability = probability
					print("1. Found in Database", row[i].name, row[i].owner, row[i].matches, row[i].probability, p, totalMatches)
				end
				
				
				toChoose = math.min(4, #row)
				print("Choosing " .. toChoose .. " AIs.")
				while toChoose > 0 do
					local chosen = math.random(probability)
					print("Choosing probability:", chosen)
					local i = #row
					local found = false
					while i > 0 do
						print("i",i, row[i].name, row[i].probability, row[i-1], chosen <= row[i].probability)
						if row[i] then
							if chosen <= row[i].probability then
								found = true
							end
							if not row[i].chosen and found and (not row[i-1] or chosen > row[i-1].probability) then
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

function chooseNewAIfromDB_table()
	if MYSQL then
		-- open MYSQL environment:
		env = luasql.mysql()
		
		if env then
			conn = env:connect(MYSQL_DATABASE, CL_MYSQL_NAME, CL_MYSQL_PASS, CL_MYQSL_HOST, CL_MYSQL_PORT)
			if conn then
				
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
					local p = (totalMatches/math.max(1,row[i].matches))
					probability = probability + p*p
					row[i].probability = probability
				end
				
				
				toChoose = math.min(4, #row)
				
				while toChoose > 0 do
					local chosen = math.random(math.max(probability, 1))
					local i = #row
					local found = false
					while i > 0 do
						if row[i] then
							if chosen <= row[i].probability then
								found = true
							end
							if not row[i].chosen and found and (not row[i-1] or chosen > row[i-1].probability) then
								row[i].chosen = true
								toChoose = toChoose - 1
								break
							end
						end
						i = i - 1
					end
					if i == 0 then		-- none found. Go back through the list and choose the first possible one.
						i = 1
						while i <= #row do
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
						table.insert( fileNames, {owner=row[i].owner, name=row[i].name} )
					end
				end
				
				return fileNames
			end
		end
	else
		return nil
	end
end



-- Check if there's AIs stages for a match. If so, return them, the list of staged Matches.
-- Also, make sure to add new AIs to the list.
function chooseAIfromDB(numMatches)

	returnAIs = {}
	numMatches = numMatches or 1 
	
	if MYSQL then
		-- open MYSQL environment:
		env = luasql.mysql()
		
		local found = false
		
		if env then
			conn = env:connect(MYSQL_DATABASE, CL_MYSQL_NAME, CL_MYSQL_PASS, CL_MYQSL_HOST, CL_MYSQL_PORT)
			if conn then
			
				-- first, check if the "nextMatch" table exists. If not, create it:
				cursor,err = conn:execute("SELECT * FROM nextMatch")
				if not cursor then
					cursor,err = conn:execute("CREATE TABLE nextMatch (name VARCHAR(30), owner VARCHAR(30), matchNum INT);")
					if err then
						print("Could not create 'nextMatch' table in " .. MYSQL_DATABASE ..  ":", err)
					else
						print("Created new 'nextMatch' table.")
					end
				end
				
				cursor,err = conn:execute("SELECT * FROM nextMatchTime")
				if not cursor then
					cursor,err = conn:execute("CREATE TABLE nextMatchTime (time DATETIME);")
					if err then
						print("Could not create 'nextMatchTime' table in " .. MYSQL_DATABASE ..  ":", err)
					else
						print("Created new 'nextMatchTime' table.")
					end
				else
					cursor,err = conn:execute("DELETE FROM nextMatchTime")
				end
				
				
				
			
				-- check if enough entries exist in nextMatch. If not, add them.
				print("Checking if there's " .. numMatches + 1 .. " matches in the 'nextMatch' table:")
				for count = 1, numMatches + 1 do
					cursor,err = conn:execute("SELECT name,owner FROM nextMatch WHERE matchNum=" .. count .. ";")
					
					if cursor and type(cursor) ~= "number" then
						row = cursor:fetch ({}, "a")
					end
					print(cursor, err, row)
					if not cursor or cursor == 0 or not row then
					
						newAIs = chooseNewAIfromDB_table()
						conn:setautocommit(false)
						
						for k, a in pairs(newAIs) do
							
							cursor,err = conn:execute("INSERT INTO nextMatch VALUES('" .. a.name .. "', '" .. a.owner .. "', " .. count .. ");")
						end
						
						conn:commit()		--send all at once.
						
						conn:setautocommit(true)
						print(nil, "-> not found " .. count .. ", adding!")
					else
						print(nil, "-> found " .. count)
					end
				end
				print("done")
		
				cursor,err = conn:execute("SELECT name,owner FROM nextMatch WHERE matchNum=1;")
				
				if cursor then
					row = cursor:fetch ({}, "a")
					while row do
						found = true
						table.insert(returnAIs, CL_DIRECTORY .. "/" .. row.owner .. "/" .. row.name .. ".lua")
						print("Found: " .. CL_DIRECTORY .. "/" .. row.owner .. "/" .. row.name .. ".lua")
						row = cursor:fetch ({}, "a")
					end
				end
				
				
				--move all entries up:
				conn:setautocommit(false)
				cursor,err = conn:execute("UPDATE nextMatch SET matchNum=matchNum-1;")
				cursor,err = conn:execute("DELETE FROM nextMatch WHERE matchNum<0;")
				q = "INSERT INTO nextMatchTime VALUES(NOW() + INTERVAL " .. (CL_ROUND_TIME or FALLBACK_ROUND_TIME) + TIME_BETWEEN_MATCHES .. " SECOND);"
				cursor,err = conn:execute(q)
				print(q)
				conn:commit()		--send all at once.
				
				conn:setautocommit(true)
			end
		end
	end

	if found then
		while #returnAIs > 4 do
			returnAIs[#returnAIs] = nil
		end
		print("returning AIs:", #returnAIs)
		return returnAIs
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
					cursor,err = conn:execute("SELECT name FROM ais WHERE name LIKE '" .. aiList[i].name .. "' AND owner LIKE '" .. aiList[i].owner .. "';")
					if not cursor then
						print(err)
					else
						result = cursor:fetch()
						cursor:close()
					end
					if result then
						print("Found " .. aiList[i].name .. " in Database!")
						exists = true				
					--[[else
						print("Didn't find " .. aiList[i].name .. " in Database. Attempting to add.")
						cursor, err = conn:execute("INSERT INTO ais VALUE('" .. aiList[i].name .. "','" .. aiList[i].owner .. "',0,0,0,'"  .. aiList[i].name .. ".lua', NULL);")
						if not cursor then
							print(err)
						elseif type(cursor) == "table" then
							cursor:close()
							exists = true
						end]]--
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
		
				print( conn:setautocommit(false) )
				-- create a new one:
				querry = "CREATE TABLE lastMatch (name VARCHAR(30), owner VARCHAR(30), pTransported INT, timeEnded DATETIME);"
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
					querry = "INSERT INTO lastMatch VALUE('" .. aiList[i].name .. "','" .. aiList[i].owner .. "'," .. stats.getPassengersTransported(i) .. ", NOW());"
					print(querry)
					cursor, err = conn:execute(querry)
				end
				
				conn:commit()
				
			
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
