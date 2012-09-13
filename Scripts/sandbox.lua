local sandbox = {}

function sandbox.print(...)
	str = "\t["
	for k, v in ipairs(arg) do
		str = str .. "\t".. v
	end
	str = str .. "\t]"
	print(str)
end


return sandbox
