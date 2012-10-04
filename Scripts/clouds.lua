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
	MAX_NUM_CLOUDS = math.floor(curMap.width+curMap.height-3)
	for i = 1, MAX_NUM_CLOUDS/2 do
	
		s = 2.5+math.random()*1.5
		cloudList[i] = {alpha=0, r=math.random()*math.pi, x=math.random(-2, curMap.width+2)*TILE_SIZE, y=math.random(-2, curMap.height+2)*TILE_SIZE, scale=2.5+math.random(), height=math.random()*3+1, img=IMAGE_CLOUD01, imgShadow=IMAGE_CLOUD01_SHADOW}
		numClouds = numClouds + 1
	end
end


function clouds.renderShadows(dt)
	if not curMap then return end
	
	if nextCloudIn <= 0 then
		if numClouds < MAX_NUM_CLOUDS then
			nextCloudIn = math.random(25)
			s = 2.5+math.random()*1.5
			for j = 1, MAX_NUM_CLOUDS do
				if cloudList[j] == nil then
					cloudList[j] = {alpha=0, r=math.random()*math.pi, x=-TILE_SIZE*2, y=math.random(-2, curMap.height+2)*TILE_SIZE, scale=s, height=math.random()*3+1, img=IMAGE_CLOUD01, imgShadow=IMAGE_CLOUD01_SHADOW}
					numClouds = numClouds + 1
					break
				end
			end
		end
	else
		nextCloudIn = nextCloudIn - dt*timeFactor
	end
	
	for k, cl in pairs(cloudList) do
		cl.x = cl.x + dt*timeFactor*cl.height*5
		if cl.x >= (curMap.width+2)*TILE_SIZE then
			cloudList[k] = nil
			numClouds = numClouds - 1
		else
			cl.alpha = math.min(0.8, 1+cl.x/(TILE_SIZE*2), 1+(curMap.width*TILE_SIZE-cl.x)/(TILE_SIZE*2))
			love.graphics.setColor(0,0,0,55*cl.alpha)
			love.graphics.draw(cl.imgShadow, cl.x-30-cl.height*30, cl.y+30+cl.height*30,  cl.r, cl.scale, cl.scale, cl.img:getWidth()/2, cl.img:getHeight()/2)
		end
	end
end

function clouds.render()
	print(camZ)
	for k, cl in pairs(cloudList) do
		love.graphics.setColor(255,255,255,135*cl.alpha*math.max(0.8-camZ,0))
		love.graphics.draw(cl.img, cl.x,cl.y, cl.r, cl.scale, cl.scale, cl.img:getWidth()/2, cl.img:getHeight()/2)
	end
end

return clouds
