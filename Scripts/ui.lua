STND_BUTTON_WIDTH = 120
STND_BUTTON_HEIGHT = 35

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


function blur( imgData, radius )
	radius = radius or 1
	if radius == 0 then radius = 1 end
	numPixels = (radius*2+1)^2
	
	local imgDataBlur = love.image.newImageData(imgData:getWidth(), imgData:getHeight())
	print("radius:", radius, numPixels)
	for x = 0, imgData:getWidth()-1 do
		for y = 0,imgData:getHeight()-1 do
			r,g,b,a = 0,0,0,0
			for i = -radius,radius do
				for j = -radius,radius do
					if x+i >= 0 and x+i < imgData:getWidth() and y+j >= 0 and y+j < imgData:getHeight() then		-- if in range
						r2,g2,b2,a2 = imgData:getPixel(x+i, y+j)
						r = r + r2
						g = g + g2
						b = b + b2
						a = a + a2
					end
				end
			end
			r = r/numPixels
			g = g/numPixels
			b = b/numPixels
			a = a/numPixels
			imgDataBlur:setPixel(x,y, r,g,b,a)
		end
	end
	
	return imgDataBlur
end

function transparentPaste(imgDataDest, imgDataSource, posX, posY)
	posX = posX or 0
	posY = posY or 0
	--imgDataResult = love.image.newImageData(imgDataDest:getWidth(), imgDataDest:getHeight())
	maxX = math.min(imgDataDest:getWidth()-1, imgDataSource:getWidth()-1+posX)
	maxY = math.min(imgDataDest:getHeight()-1, imgDataSource:getHeight()-1+posY)
	for x = posX,maxX do
		for y = posY,maxY do
			rDest,gDest,bDest,aDest = imgDataDest:getPixel(x,y)
			--if x >= posX and x-posX < imgDataSource:getWidth() and y >= posY and y-posY < imgDataSource:getHeight() then
			rSource,gSource,bSource,aSource = imgDataSource:getPixel(x-posX,y-posY)
			if aSource > 0 then
				rSource,gSource,bSource,aSource = rSource/255,gSource/255,bSource/255,aSource/255
				--r = rDest/255*aDest + rSource/255*aSource
				--g = gDest/255*aDest + gSource/255*aSource
				--b = bDest/255*aDest + bSource/255*aSource
			
			
				rDest,gDest,bDest,aDest = rDest/255,gDest/255,bDest/255,aDest/255
			
				--r = rDest*aDest + rSource*aSource*(1-aDest) --math.min(255, rSource + rDest)
				--g = gDest*aDest + gSource*aSource*(1-aDest) --math.min(255, gSource + gDest)
				--b = bDest*aDest + bSource*aSource*(1-aDest) --math.min(255, bSource + bDest)
				--a = math.min(1, aSource + aDest)
			
				--r = rDest*aDest + rSource*aSource*(1-aDest) --math.min(255, rSource + rDest)
				--g = gDest*aDest + gSource*aSource*(1-aDest) --math.min(255, gSource + gDest)
				--b = bDest*aDest + bSource*aSource*(1-aDest) --math.min(255, bSource + bDest)
				a = aSource + aDest*(1-aSource)
				if a > 0 then
					r = (rSource*aSource+rDest*aDest*(1-aSource))/a
					g = (gSource*aSource+gDest*aDest*(1-aSource))/a
					b = (bSource*aSource+bDest*aDest*(1-aSource))/a
				else
					r,g,b = 0,0,0
				end
			
				r,g,b,a = r*255,g*255,b*255,a*255
			
				imgDataDest:setPixel(x, y, r, g, b, a)
			end
		end
	end
	return imgDataDest
end

--[[ Old:

function transparentPaste(imgDataDest, imgDataSource, posX, posY)
	posX = posX or 0
	posY = posY or 0
	imgDataResult = love.image.newImageData(imgDataDest:getWidth(), imgDataDest:getHeight())
	for x = 0,imgDataDest:getWidth()-1 do
		for y = 0,imgDataDest:getHeight()-1 do
			rDest,gDest,bDest,aDest = imgDataDest:getPixel(x,y)
			if x >= posX and x-posX < imgDataSource:getWidth() and y >= posY and y-posY < imgDataSource:getHeight() then
				rSource,gSource,bSource,aSource = imgDataSource:getPixel(x-posX,y-posY)
			else
				rSource,gSource,bSource,aSource = 0,0,0,0
			end
			--r = rDest/255*aDest + rSource/255*aSource
			--g = gDest/255*aDest + gSource/255*aSource
			--b = bDest/255*aDest + bSource/255*aSource
			r = math.min(255, rSource + rDest)
			g = math.min(255, gSource + gDest)
			b = math.min(255, bSource + bDest)
			a = math.min(255, aSource + aDest)
			imgDataResult:setPixel(x, y, r, g, b, a)
		end
	end
	return imgDataResult
end

--]]

function fill(imgData, fillR, fillG, fillB, fillA)
	fillOn = false
	for x = 0, imgData:getWidth()-1 do
		fillOn = false
		for y = 0,imgData:getHeight()-1 do
			r,g,b,a = imgData:getPixel(x,y)
			if a ~= 0 then
				if fillOn then fillOn = false
				else
					if y < imgData:getHeight()-1 then
						r,g,b,a = imgData:getPixel(x,y+1)
						if a == 0 then		-- check if there's another closing point somewhere down the line.
							for y2 = y+1,imgData:getHeight()-1 do
								r,g,b,a = imgData:getPixel(x,y2)
								if a ~= 0 then
									fillOn = true
									break
								end
							end
						end
					end
				end
			else
				if fillOn then
					imgData:setPixel(x,y,fillR,fillG,fillB,fillA)
				end
			end
		end
	end
	return imgData
end

function outline(imgData, verts, r, g, b, a)
	for k = 3,#verts-1,2 do
		dy = verts[k+1]-verts[k-1]
		dx = verts[k]-verts[k-2]
		length = math.sqrt(dx^2+dy^2)
		dx = dx/length
		dy = dy/length
		dist = 0
		while dist <= length do
			pixelX = verts[k-2] + dx*dist
			pixelY = verts[k-1] + dy*dist
			if pixelX - math.floor(pixelX) > 0.5 then
				pixelX = math.ceil(pixelX)
			else pixelX = math.floor(pixelX)
			end
			if pixelY - math.floor(pixelY) > 0.5 then
				pixelY = math.ceil(pixelY)
			else pixelY = math.floor(pixelY)
			end
			imgData:setPixel(pixelX,pixelY, r, g, b, a)
			dist = dist + 1
		end
	end
	return imgData
end

function gradient(imgData, centerX, centerY, radius, brightness)
	brightness = brightness or 25
	radius = radius or 100
	for x = 0, imgData:getWidth()-1 do
		for y = 0,imgData:getHeight()-1 do
			r,g,b,a = imgData:getPixel(x,y)
			if a > 0 then
				dist = math.sqrt((x-centerX)^2+(y-centerY)^2)
				factor = math.max(0, 1 - dist/radius)*25
				a = clamp(a + factor, 0, 255)
				r = clamp(r + factor, 0, 255)
				g = clamp(g + factor, 0, 255)
				b = clamp(b + factor, 0, 255)
				
				imgData:setPixel(x,y,r,g,b,a)
			end
		end
	end
	return imgData
end

function createBoxImage(width, height, shadow, shadowOffsetX, shadowOffsetY)
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
	
	local imgDataTopLayer = love.image.newImageData(width, height)
	imgDataTopLayer = outline(imgDataTopLayer, verts, 64,160,100,150)
	imgDataTopLayer = fill(imgDataTopLayer, 64,164,100,150)
	imgDataTopLayer = gradient(imgDataTopLayer, width, 0, width, 235)
	
	imgDataTopLayer:encode("toplayer.png")
	
	if shadow then
	
		imgDataShadow = love.image.newImageData(width+10, height+10)
		tmpData = love.image.newImageData(width, height)
		tmpData = outline(tmpData, verts, 0,0,0,90)
		imgDataShadow:paste(tmpData, 5,5)
		imgDataShadow = fill(imgDataShadow, 0,0,0,90)
	
		imgDataShadow = blur(imgDataShadow, 2)
		
		imgDataShadow:encode("shadow.png")
		
		tmpData = transparentPaste(imgDataShadow, imgDataTopLayer, shadowOffsetX, shadowOffsetY)
		tmpData:encode("full.png")
		return love.graphics.newImage(tmpData)
	end
	
	return love.graphics.newImage(imgDataTopLayer)
end
