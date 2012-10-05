local quickHelp = {}

local helpBg = nil

local helpWidth, helpHeight = 400,200

function quickHelp.init()
	helpBg = createBoxImage(helpWidth,helpHeight,true, 10, 0,64,160,100)
end

local helpStrKeys = [[F1: 
Space:
W,A,S,D:
Cursor Keys:
C:
+:
-:
]]
local helpStr = [[Toggle this Help
Tactical Overview
Move View
Move View
Toggle Console
Speed up
Slow down
]]

function quickHelp.show()
	love.graphics.setColor(255,255,255,255)
	love.graphics.setFont(FONT_STAT_MSGBOX)
	x,y = (love.graphics.getWidth()-helpWidth)/2, (love.graphics.getHeight()-helpHeight)/2
	love.graphics.draw(helpBg, x,y )
	love.graphics.printf(helpStrKeys, x+20, y+20, 120, "right")
	love.graphics.printf(helpStr, x+150, y+20, helpWidth-170, "left")
end

function quickHelp.toggle()
	if showQuickHelp then
		showQuickHelp = false
	else
		showQuickHelp = true
	end
end

return quickHelp
