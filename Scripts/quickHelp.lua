local quickHelp = {}

local helpBg = nil

local HELP_WIDTH, HELP_HEIGHT = 400,300

local helpStrKeys = [[Space :
W,A,S,D :
Cursor Keys :
Arrow Keys :
Q,E :
C :
+ :
- :
m :
F5 :
F1 :
h :
]]
local helpStr = [[Tactical overlay
Move view
Move view
Move view
Zoom view
Toggle console
Speed up
Slow down
Toggle map coordinates
Screenshot
Toggle this Help
Hide AI stats
]]

function quickHelp.show()
	love.graphics.setColor(255,255,255,255)
	love.graphics.setFont(FONT_STAT_MSGBOX)
	x,y = love.graphics.getWidth()-HELP_WIDTH-20, roundStats:getHeight() + 30
	love.graphics.draw(helpBg, x,y )
	love.graphics.printf(helpStrKeys, x+20, y+20, 120, "right")
	love.graphics.printf(helpStr, x+150, y+20, HELP_WIDTH-170, "left")
end

function quickHelp.toggle()
	if showQuickHelp then
		showQuickHelp = false
	else
		showQuickHelp = true
		if tutorial and tutorial.f1Event then
			tutorial.f1Event()
		end
	end
end

function quickHelp.setVisibility(vis)
	if vis then
		showQuickHelp = true
	else
		showQuickHelp = false
	end
end

local helpBgThread

function quickHelp.init(maxNumThreads)
	helpBg = love.graphics.newImage( "Images/helpBg.png" )
end

return quickHelp
