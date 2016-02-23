-- Should succeed
-- User created tables can have their metatables changed
setmetatable({},{})

-- Should fail
protectedTables = {
	string,
	math,
	string,
	table,
	math,
	coroutine,
	os,
}

function modifyProtectedTable(t)
	setmetatable(t, {})
end

for _, t in ipairs(protectedTables) do
	local code, msg = pcall(modifyProtectedTable, t)
	if(code ~= false or msg:match("cannot change a protected metatable$") == nil) then
		print("ERROR: Protected table was modified!")
	end
end