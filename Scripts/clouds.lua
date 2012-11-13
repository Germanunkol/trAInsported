local clouds = {}

local IMAGE_CLOUD01 = love.graphics.newImage("Images/Cloud01.png")
local IMAGE_CLOUD01_SHADOW = love.graphics.newImage("Images/Cloud01_Shadow.png")

local MAX_NUM_CLOUDS = 10

local cloudList = {}
local nextCloudIn = 0
local numClouds = 0

function clouds.restart()
	cloudList = {}
	numClouds = 0
	local width, height = 0,0
	if curMap then
		width = curMap.width
		height = curMap.height
	elseif simulationMap then
		width = simulationMap.width
		height = simulationMap.height
	end
	MAX_NUM_CLOUDS = 2*math.floor(width+height-3)
	for i = 1, MAX_NUM_CLOUDS do
		s = 2+math.random()*2
		cloudList[i] = {a=0.5+math.random()*0.5, alpha=0, r=math.random()*math.pi, x=math.random(-2, width+2)*TILE_SIZE, y=math.random(-2, height+2)*TILE_SIZE, scale=2.5+math.random(), height=math.random()*3+1, img=IMAGE_CLOUD01, imgShadow=IMAGE_CLOUD01_SHADOW}
		numClouds = numClouds + 1
	end
end


function clouds.renderShadows(dt)
	if not curMap and not simulationMap then return
	elseif curMap then
		width = curMap.width
		height = curMap.height
	else
		width = simulationMap.width
		height = simulationMap.height
	end
	
	if nextCloudIn <= 0 then
		while numClouds < MAX_NUM_CLOUDS do
			nextCloudIn = math.random(3)
			s = 2+math.random()*2
			for j = 1, MAX_NUM_CLOUDS do
				if cloudList[j] == nil then
					cloudList[j] = {a=0.5+math.random()*0.5, alpha=0, r=math.random()*math.pi, x=-TILE_SIZE*2, y=math.random(-2, height+2)*TILE_SIZE, scale=s, height=math.random()*3+1, img=IMAGE_CLOUD01, imgShadow=IMAGE_CLOUD01_SHADOW}
					numClouds = numClouds + 1
					break
				end
			end
		end
	else
		nextCloudIn = nextCloudIn - dt
	end
	
	for k, cl in pairs(cloudList) do
		if not roundEnded then cl.x = cl.x + dt*cl.height*15 end
		if cl.x >= (width+2)*TILE_SIZE then
			cloudList[k] = nil
			numClouds = numClouds - 1
		else
			cl.alpha = math.min(0.8, 1+cl.x/(TILE_SIZE*2), 1+(width*TILE_SIZE-cl.x)/(TILE_SIZE*2))
			love.graphics.setColor(0,0,0,35*cl.alpha*cl.a)
			love.graphics.draw(cl.imgShadow, cl.x-30-cl.height*30, cl.y+30+cl.height*30,  cl.r, cl.scale, cl.scale, cl.img:getWidth()/2, cl.img:getHeight()/2)
		end
	end
end

local fade = 0

function clouds.render()
	fade = math.max(0.6-camZ,0)
	for k, cl in pairs(cloudList) do
		love.graphics.setColor(255,255,255,135*cl.alpha*fade*cl.a)
		love.graphics.draw(cl.img, cl.x,cl.y, cl.r, cl.scale, cl.scale, cl.img:getWidth()/2, cl.img:getHeight()/2)
	end
end

return clouds
