local clouds = {}

local IMAGE_CLOUD01 = love.graphics.newImage("Images/Cloud01.png")
local IMAGE_CLOUD01_SHADOW = love.graphics.newImage("Images/Cloud01_Shadow.png")

local MAX_NUM_CLOUDS = 10

local cloudList = {}
local nextCloudIn = 0

function clouds.init()
	
end

function clouds.restart()
	cloudList = {}
	MAX_NUM_CLOUDS = math.floor(curMap.width+curMap.height)
	
	for i = 1, MAX_NUM_CLOUDS/2 do
	
		table.insert(cloudList, {x=math.random(curMap.width)*TILE_SIZE, y=math.random(curMap.height)*TILE_SIZE, scale=1+math.random(), height=math.random()*3+1, img=IMAGE_CLOUD01, imgShadow=IMAGE_CLOUD01_SHADOW})
	end
end

function clouds.showAll(dt)
	if not curMap then return end
	
	if nextCloudIn <= 0 then
		if #cloudList < MAX_NUM_CLOUDS/2 then
			nextCloudIn = math.random(25)
			table.insert(cloudList, {x=-TILE_SIZE*3, y=math.random(curMap.height)*TILE_SIZE, scale=1+math.random(), height=math.random()*3+1, img=IMAGE_CLOUD01, imgShadow=IMAGE_CLOUD01_SHADOW})
		end
	else
		nextCloudIn = nextCloudIn - dt*timeFactor
	end
	
	for k, cl in pairs(cloudList) do
		cl.x = cl.x + dt*timeFactor*cl.height*5
		if cl.x > (curMap.width+3)*TILE_SIZE then
			table.remove(cloudList, k)
		else
			if cl.x < 0 then
				love.graphics.setColor(0,0,0,55+55*(cl.x)/(TILE_SIZE*3))
			elseif cl.x > curMap.width*TILE_SIZE then
				love.graphics.setColor(0,0,0,55-55*(cl.x-curMap.width*TILE_SIZE)/(TILE_SIZE*3))
			else love.graphics.setColor(0,0,0,55)
			end
			
			love.graphics.draw(cl.imgShadow, cl.x-30-cl.height*30, cl.y+30+cl.height*30, 0, cl.scale, cl.scale)
		end
	end
	love.graphics.setColor(255,255,255,75)
	for k, cl in pairs(cloudList) do
		if cl.x < 0 then
			love.graphics.setColor(255,255,255,75+(cl.x)*75/(TILE_SIZE*3))
		elseif cl.x > curMap.width*TILE_SIZE then
			love.graphics.setColor(255,255,255,75-(cl.x-curMap.width*TILE_SIZE)*75/(TILE_SIZE*3))
		else love.graphics.setColor(255,255,255,75)
		end
		love.graphics.draw(cl.img, cl.x, cl.y, 0, cl.scale, cl.scale)
	end
end

return clouds
