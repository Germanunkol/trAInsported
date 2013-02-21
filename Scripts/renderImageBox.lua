thisThread = love.thread.getThread()

package.path = "Scripts/?.lua;" .. package.path

require("love.image")
require("love.filesystem")
pcall(require, "imageManipulation")
pcall(require, "Scripts/imageManipulation")
pcall(require, "misc")
pcall(require, "Scripts/misc")

thisThread:set("percentage", 0)

width = thisThread:demand("width")
thisThread:set("status", "got width")
height = thisThread:demand("height")
shadow = thisThread:demand("shadow")
shadowOffsetX = thisThread:demand("shadowOffsetX")
shadowOffsetY = thisThread:demand("shadowOffsetY")
colR = thisThread:demand("colR")
colG = thisThread:demand("colG")
colB = thisThread:demand("colB")
brightness = thisThread:get("brightness")
alpha = thisThread:get("alpha")
if not brightness then
	brightness = 35
end
if not alpha then
	alpha = 150
end

--function createBoxImage(width, height, shadow, shadowOffsetX, shadowOffsetY, colR, colG, colB)

--set defaults
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
thisThread:set("percentage", 10)

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
thisThread:set("percentage", 20)
imgDataTopLayer = fill(imgDataTopLayer, colR, colG, colB, alpha)
thisThread:set("percentage", 30)
imgDataTopLayer = gradient(imgDataTopLayer, width, 0, width, brightness)
thisThread:set("percentage", 40)

if shadow then

	imgDataShadow = love.image.newImageData(width+10, height+10)
	tmpData = love.image.newImageData(width, height)
	tmpData = outline(tmpData, verts, 0,0,0,90)
	thisThread:set("percentage", 50)
	imgDataShadow:paste(tmpData, 5,5)
	imgDataShadow = fill(imgDataShadow, 0,0,0,90)

	thisThread:set("percentage", 60)
	imgDataShadow = blur(imgDataShadow, 2, thisThread, 60, 97)
	
	thisThread:set("percentage", 98)
	tmpData = transparentPaste(imgDataShadow, imgDataTopLayer, shadowOffsetX, shadowOffsetY)
	thisThread:set("imageData", tmpData)
else
	thisThread:set("imageData", imgDataTopLayer)
end
thisThread:set("percentage", 100)
thisThread:set("status", "done")
return

