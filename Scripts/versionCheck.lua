local versionCheck = {}
local versionMatch

function versionCheck.start()

	versionMatch = nil

	v = configFile.getValue("version")
	if v == VERSION then
		versionMatch = true
	else
		-- remove previous image files:
		love.filesystem.remove("bgBox.png")
		love.filesystem.remove("bgBoxSmall.png")
		love.filesystem.remove("buttonOff.png")
		love.filesystem.remove("buttonOver.png")
		love.filesystem.remove("buttonOffSmall.png")
		love.filesystem.remove("buttonOverSmall.png")
		love.filesystem.remove("codeBoxBG.png")
		love.filesystem.remove("helpBg.png")
		love.filesystem.remove("msgBoxBG.png")
		love.filesystem.remove("pSpeachBubble.png")
		love.filesystem.remove("roundStats.png")
		love.filesystem.remove("statBoxNegative.png")
		love.filesystem.remove("statBoxPositive.png")
		love.filesystem.remove("statBoxStatus.png")
		love.filesystem.remove("statusErrBox.png")
		love.filesystem.remove("statusMsgBox.png")
		love.filesystem.remove("toolTipBox.png")
		love.filesystem.remove("tutorialBoxBG.png")
		love.filesystem.remove("tutorialBoxCheckMark.png")

		-- set to new version:
		configFile.setValue("version", VERSION)
	end
end

function versionCheck.getMatch()
	return versionMatch
end

return versionCheck
