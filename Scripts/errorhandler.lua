
local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end

function love.errhand(msg)
	msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isCreated() then
		if not pcall(love.window.setMode, 800, 600) then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
	end
	if love.joystick then
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration() -- Stop all joystick vibrations.
		end
	end

	if love.audio then love.audio.stop() end

	--love.graphics.reset()
	--love.graphics.setBackgroundColor(BG_R, BG_G, BG_B, 255)

	love.graphics.setColor(255, 255, 255, 255)

	local trace = debug.traceback()

	love.graphics.clear()
	love.graphics.origin()

	local err = {}

	table.insert(err, msg.."\n\n")

	for l in string.gmatch(trace, "(.-)\n") do
		if not string.match(l, "boot.lua") then
			l = string.gsub(l, "stack traceback:", "Traceback:\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = string.gsub(p, "\t", "")
	p = string.gsub(p, "%[string \"(.-)\"%]", "%1")

	local width = love.graphics.getWidth() - 140
	local copied = false

	local nextSteps = LNG.error_steps or "Press [Escape] to exit."
	local errorHeader = LNG.error_header or "Oh no, there was an error!"

	local function draw()
		love.graphics.clear()
		love.graphics.setBackgroundColor(BG_R, BG_G, BG_B, 255)

		love.graphics.setFont( FONT_BUTTON )
		love.graphics.printf( errorHeader, 60, 70, width )

		love.graphics.setFont( FONT_STANDARD )
		love.graphics.printf( p, 70, 120, width )

		love.graphics.setFont( FONT_BUTTON )
		love.graphics.printf( nextSteps, 60, love.graphics.getHeight() - 250, width )

		love.graphics.present()
	end

	while true do
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return
			elseif e == "keypressed" and a == "escape" then
				return
			elseif e == "keypressed" and a == "c" then
				if copied == false then
					copied = true
					nextSteps = nextSteps .. "\n" .. LNG.error_copied
					--			reportToClipboard( p )
					love.system.setClipboardText( p )
				end
			elseif e == "keypressed" and a == "o" then
				openIssuesPage()
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end


