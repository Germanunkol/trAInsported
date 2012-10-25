thisThread = love.thread.getThread()

while true do
	if thisThread:get("getInput") then
		input = io.read()
		if input then
			thisThread:set("input", input)
		end
	end
end
