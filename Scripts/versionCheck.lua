local versionCheck = {}
local versionMatch

function versionCheck.start()

	versionMatch = nil

	v = configFile.getValue("version")
	if v == VERSION then
		versionMatch = true
	else
		configFile.setValue("version", VERSION)
	end
	
end

function versionCheck.getMatch()
	return versionMatch
end

return versionCheck
