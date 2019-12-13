local statusMsg = {}

local currentMsg = ""
local currentErr = nil
local currentTime = 0

errorSound = love.audio.newSource("Sound/wobble_alert.wav", "stream")


function statusMsg.init( )
	statusErrBox = love.graphics.newImage( "Images/statusErrBox.png" )
	toolTipBox = love.graphics.newImage( "Images/toolTipBox.png" )
	statusMsgBox = love.graphics.newImage( "Images/statusMsgBox.png" )
end

function statusMsg.new(txt, err)
	currentErr = err
	currentMsg = txt
	currentTime = 6
	if err then
		errorSound:seek(0)
		errorSound:play()
	end
end

function statusMsg.display(dt)
	if currentTime < 3 and toolTip then
		currentTime = 0
	end
	if currentTime > 0 then
		currentTime = currentTime - dt
		love.graphics.setColor(255,255,255,255)
		love.graphics.setFont(FONT_STANDARD)
		if currentErr then
			love.graphics.draw(statusErrBox, (love.graphics.getWidth() - statusMsgBox:getWidth())/2 -10, love.graphics.getHeight() - statusMsgBox:getHeight())
		else
			love.graphics.draw(statusMsgBox, (love.graphics.getWidth() - statusMsgBox:getWidth())/2 -10, love.graphics.getHeight() - statusMsgBox:getHeight())
		end
		love.graphics.printf(currentMsg, (love.graphics.getWidth() - statusMsgBox:getWidth())/2, love.graphics.getHeight() - statusMsgBox:getHeight() + 5, statusMsgBox:getWidth()-30, "center")
	elseif toolTip then
		love.graphics.setColor(255,255,255,255)
		love.graphics.setFont(FONT_STANDARD)
		love.graphics.draw(toolTipBox, (love.graphics.getWidth() - toolTipBox:getWidth())/2 -10, love.graphics.getHeight() - toolTipBox:getHeight())
		love.graphics.printf(toolTip, (love.graphics.getWidth() - toolTipBox:getWidth())/2, love.graphics.getHeight() - toolTipBox:getHeight() + 5, toolTipBox:getWidth()-30, "center")
	end
end

return statusMsg
