




function renderMap( map, )
	local groundData = love.graphics.newSpriteBatch( groundSheetGrass, map.width, map.height )
	local shadowData = love.graphics.newSpriteBatch( groundSheetGrass, map.width, map.height )
	local objectData = love.graphics.newSpriteBatch( groundSheetGrass, map.width, map.height )

	
	return groundData, shadowData, objectData
end
