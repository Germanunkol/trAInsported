require("misc")


function blur( imgData, radius, thread, percentage, maxPercentage )
	radius = radius or 1
	if radius == 0 then radius = 1 end
	numPixels = (radius*2+1)^2
	
	if thread then
		percentStep = (maxPercentage-percentage)/(imgData:getWidth()*imgData:getHeight())
	end
	
	
	local imgDataBlur = love.image.newImageData(imgData:getWidth(), imgData:getHeight())
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
			if thread then
				percentage = percentage + percentStep
				thread:set("percentage", percentage)
			end
		end
	end
	
	return imgDataBlur
end

function transparentPaste(imgDataDest, imgDataSource, posX, posY, colOffset, mask)
	posX = posX or 0
	posY = posY or 0
	--imgDataResult = love.image.newImageData(imgDataDest:getWidth(), imgDataDest:getHeight())
	maxX = math.min(imgDataDest:getWidth()-1, imgDataSource:getWidth()-1+posX)
	maxY = math.min(imgDataDest:getHeight()-1, imgDataSource:getHeight()-1+posY)
	for x = posX,maxX do
		for y = posY,maxY do
			if x >= 0 and y >= 0 then
				if mask then rMask,gMask,bMask,aMask = mask:getPixel(x,y)
				else
					aMask = 10
				end
				if aMask > 0 then
					rDest,gDest,bDest,aDest = imgDataDest:getPixel(x,y)
					--if x >= posX and x-posX < imgDataSource:getWidth() and y >= posY and y-posY < imgDataSource:getHeight() then
					rSource,gSource,bSource,aSource = imgDataSource:getPixel(x-posX,y-posY)
					if colOffset then
						rSource = clamp(rSource + colOffset.r, 0, 255)
						gSource = clamp(gSource + colOffset.g, 0, 255)
						bSource = clamp(bSource + colOffset.b, 0, 255)
					end
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
				factor = math.max(0, 1 - dist/radius)*brightness
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
