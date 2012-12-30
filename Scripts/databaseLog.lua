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


log = {}

function log.neWinner(ID)
	if MYSQL then
		if aiList[ID].name then
			-- open MYSQL environment:
			env = luasql.mysql()
			
			if env then
				conn = env:connect("trAInsported", CL_MYSQL_NAME, CL_MYSQL_PASS, CL_MYQSL_HOST, CL_MYSQL_PORT)
				if conn then
					print("connection successful!")
					result = conn:execute("SELECT name FROM ais WHERE name LIKE '" .. aiList[ID].name .. "';")
					print(result:fetch())
					printTable(result:fetch())
					result:close()
					conn:close()
					
				else
					print("Error connecting to MySQL.")
				end
				env:close()
			else
				print("Error opening MySQL environment.")
			end
		end
	end
end

return log
