

function blurAlpha( img )
	local alpha,a
	local dest = love.image.newImageData(img:getWidth()+10, img:getHeight()+10)
	for i = 1, dest:getWidth()-1 do
		for j = 1, dest:getHeight()-1 do
			alpha = 0
			for x = -2, 2 do
				for y = -2, 2 do
					if i+x >= 1 and j+y >= 1 and i+x < img:getWidth()-1 and j+y < img:getHeight()-1 then
						_,_,_,a = img:getPixel(i+x, j+y)
						alpha = alpha + a
					end
				end
			end
			alpha = alpha/25		--average of alpha
			
			if alpha ~= 0 then print(alpha) end
			r,g,b = 0,0,0
			if i>5 and j>5 and i-5 < img:getWidth() and j-5 < img:getHeight() then
				r,g,b = img:getPixel(i-5, j-5)
			end
			dest:setPixel(i, j, r,g,b, alpha)
		end
	end
	return dest
end

function createMsgBoxBG(width, height, text)
	local ang = 0
	local verts = {}
	local r = 10 -- math.max(math.min(width, height)/6, 10)
	for ang = 0,90,10 do
		verts[#verts+1] = -2 + width -r + math.sin(ang/180*math.pi)*r
		verts[#verts+1] = -2 + height -r + math.cos(ang/180*math.pi)*r
	end
	for ang = 90,180,10 do
		verts[#verts+1] = -2 + width - r + math.sin(ang/180*math.pi)*r
		verts[#verts+1] = 2 + r + math.cos(ang/180*math.pi)*r
	end
	for ang = 180,270,10 do
		verts[#verts+1] = 2 + r + math.sin(ang/180*math.pi)*r
		verts[#verts+1] = 2 + r + math.cos(ang/180*math.pi)*r
	end
	for ang = 270,360,10 do
		verts[#verts+1] = 2 + r + math.sin(ang/180*math.pi)*r
		verts[#verts+1] = -2 + height - r + math.cos(ang/180*math.pi)*r
	end
	
	local shadowVerts = {}
	for i = 1, #verts, 2 do
		shadowVerts[i] = verts[i] --+ 7
		shadowVerts[i+1] = verts[i+1]
		verts[i] = verts[i]+5
		--verts[i+1] = verts[i+1]
	end
	
	c = love.graphics.newCanvas()
	love.graphics.setCanvas(c)
	
	love.graphics.setColor(0,0,0,200)
	love.graphics.polygon( "fill", shadowVerts)
	
	local shadow = love.image.newImageData(width, height)
	shadow:paste(c:getImageData(), 0, 0, 0, 0, width, height)
	--shadow = blurAlpha(shadow)
	--shadow = blurAlpha(shadow)
	--shadow = blurAlpha(shadow)
	
	local shadowImg = love.graphics.newImage(shadow)
	
	c = love.graphics.newCanvas()
	love.graphics.setCanvas(c)
	
	
	love.graphics.setColor(255,255,255,255)
	love.graphics.draw(shadowImg,0,10)
	
	love.graphics.setColor(55,78,125,255)
	love.graphics.polygon( "fill", verts)
	
	love.graphics.setColor(30,60,100,255)
	love.graphics.setLine(1, "smooth")
	love.graphics.polygon( "line", verts)
	love.graphics.setFont(FONT_BUTTON)
	love.graphics.setColor(180,200,255,255)
	for i = 1, #text, 1 do
		love.graphics.print(text[i], 25, 10 + (i-1)*FONT_BUTTON:getHeight())
	end
	
	love.graphics.setCanvas()
	return c
end


function createButtonOff(width, height, label)
	local ang = 0
	local verts = {}
	local r = 10 -- math.max(math.min(width, height)/6, 10)
	for ang = 0,90,10 do
		verts[#verts+1] = -2 + width -r + math.sin(ang/180*math.pi)*r
		verts[#verts+1] = -2 + height -r + math.cos(ang/180*math.pi)*r
	end
	for ang = 90,180,10 do
		verts[#verts+1] = -2 + width - r + math.sin(ang/180*math.pi)*r
		verts[#verts+1] = 2 + r + math.cos(ang/180*math.pi)*r
	end
	for ang = 180,270,10 do
		verts[#verts+1] = 2 + r + math.sin(ang/180*math.pi)*r
		verts[#verts+1] = 2 + r + math.cos(ang/180*math.pi)*r
	end
	for ang = 270,360,10 do
		verts[#verts+1] = 2 + r + math.sin(ang/180*math.pi)*r
		verts[#verts+1] = -2 + height - r + math.cos(ang/180*math.pi)*r
	end
	
	local shadowVerts = {}
	for i = 1, #verts, 2 do
		shadowVerts[i] = verts[i] -- 4
		shadowVerts[i+1] = verts[i+1] + 6
	end
	
	c = love.graphics.newCanvas()
	love.graphics.setCanvas(c)
	
	love.graphics.setColor(0,0,0,120)
	love.graphics.polygon( "fill", shadowVerts)
	
	love.graphics.setColor(60,98,155,240)
	love.graphics.polygon( "fill", verts)
	love.graphics.setColor(30,60,100,255)
	love.graphics.setLine(1, "smooth")
	love.graphics.polygon( "line", verts)
	love.graphics.setFont(FONT_BUTTON)
	love.graphics.setColor(180,200,255,255)
	love.graphics.print(label, (width-FONT_BUTTON:getWidth(label))/2, (height-FONT_BUTTON:getHeight())/2)
	
	love.graphics.setCanvas()
	return c
end

function createButtonOver(width, height, label)
	local ang = 0
	local verts = {}
	local r = 10 -- math.max(math.min(width, height)/6, 10)
	for ang = 0,90,10 do
		verts[#verts+1] = -2 + width -r + math.sin(ang/180*math.pi)*r
		verts[#verts+1] = -2 + height -r + math.cos(ang/180*math.pi)*r
	end
	for ang = 90,180,10 do
		verts[#verts+1] = -2 + width - r + math.sin(ang/180*math.pi)*r
		verts[#verts+1] = 2 + r + math.cos(ang/180*math.pi)*r
	end
	for ang = 180,270,10 do
		verts[#verts+1] = 2 + r + math.sin(ang/180*math.pi)*r
		verts[#verts+1] = 2 + r + math.cos(ang/180*math.pi)*r
	end
	for ang = 270,360,10 do
		verts[#verts+1] = 2 + r + math.sin(ang/180*math.pi)*r
		verts[#verts+1] = -2 + height - r + math.cos(ang/180*math.pi)*r
	end
	
	local shadowVerts = {}
	for i = 1, #verts, 2 do
		shadowVerts[i] = verts[i] -- 7
		shadowVerts[i+1] = verts[i+1] + 9
	end
	
	
	
	c = love.graphics.newCanvas()
	love.graphics.setCanvas(c)
	
	love.graphics.setColor(0,0,0,120)
	love.graphics.polygon( "fill", shadowVerts)
	
--	love.graphics.setColor(120,140,175,250)
	love.graphics.setColor(60,98,155, 250)
	love.graphics.polygon( "fill", verts)
	
	love.graphics.setColor(240,240,255,250)
	love.graphics.setLine(1, "smooth")
	love.graphics.polygon( "line", verts)
	
	love.graphics.setFont(FONT_BUTTON)
	love.graphics.print(label, (width-FONT_BUTTON:getWidth(label))/2, (height-FONT_BUTTON:getHeight())/2)
	
	love.graphics.setCanvas()
	return c
end



function createBoxImage(width, height, shadow, shadowOffsetX, shadowOffsetY, colR, colG, colB)

	-- set defaults
	colR = colR or 0
	colG = colG or 0
	colB = colB or 0
	shadowOffsetX = shadowOffsetX or 0
	shadowOffsetY = shadowOffsetY or 0
	
	local ang = 0
	local verts = {}
	local r = 10 -- math.max(math.min(width, height)/6, 10)
	for ang = 0,90,10 do
		verts[#verts+1] =  width -r + math.sin(ang/180*math.pi)*r - 1
		verts[#verts+1] =  height -r + math.cos(ang/180*math.pi)*r - 1
	end
	for ang = 90,180,10 do
		verts[#verts+1] =  width - r + math.sin(ang/180*math.pi)*r - 1
		verts[#verts+1] =  r + math.cos(ang/180*math.pi)*r
	end
	for ang = 180,270,10 do
		verts[#verts+1] =  r + math.sin(ang/180*math.pi)*r
		verts[#verts+1] =  r + math.cos(ang/180*math.pi)*r
	end
	for ang = 270,360,10 do
		verts[#verts+1] =  r + math.sin(ang/180*math.pi)*r
		verts[#verts+1] =  height - r + math.cos(ang/180*math.pi)*r - 1
	end
	
	--close loop:
	verts[#verts+1] = verts[1]
	verts[#verts+1] = verts[2]
	
	local shadowVerts = {}
	for i = 1, #verts, 2 do
		shadowVerts[i] = verts[i] -- 7
		shadowVerts[i+1] = verts[i+1] + 9
	end
--	64,160,100
	--debug.debug()
	local imgDataTopLayer = love.image.newImageData(width, height)
	--imgDataTopLayer = outline(imgDataTopLayer, verts, colR, colG, colB, 150)
	imgDataTopLayer = outline(imgDataTopLayer, verts, 0,0,0, 255)
	imgDataTopLayer = fill(imgDataTopLayer, colR, colG, colB, 150)
	imgDataTopLayer = gradient(imgDataTopLayer, width, 0, width, 235)
	
	if shadow then
	
		imgDataShadow = love.image.newImageData(width+10, height+10)
		tmpData = love.image.newImageData(width, height)
		tmpData = outline(tmpData, verts, 0,0,0,90)
		imgDataShadow:paste(tmpData, 5,5)
		imgDataShadow = fill(imgDataShadow, 0,0,0,90)
	
		imgDataShadow = blur(imgDataShadow, 2)
		
		
		tmpData = transparentPaste(imgDataShadow, imgDataTopLayer, shadowOffsetX, shadowOffsetY)
		return love.graphics.newImage(tmpData)
	end
	
	return love.graphics.newImage(imgDataTopLayer)
end
