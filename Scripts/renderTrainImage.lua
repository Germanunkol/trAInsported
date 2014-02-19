-- to be run as a seperate thread!

local args = {...}
channelIn = args[1]
channelOut = args[2]
seed = args[3]

package.path = "Scripts/?.lua;" .. package.path

channelOut:push({key="status", "started"})
require("love.image")
require("love.filesystem")
pcall(require,"misc")
pcall(require,"Scripts/misc")
pcall(require,"TSerial")
pcall(require,"Scripts/TSerial")
pcall(require,"imageManipulation")
pcall(require,"Scripts/imageManipulation")

col = generateColour(seed) --TSerial.unpack(thisThread:demand("colour"))

trainImage = love.image.newImageData("Images/Train1.png")
trainImageLower = love.image.newImageData("Images/Train1Lower.png")

trainImagePlayerData = love.image.newImageData(trainImage:getWidth(), trainImage:getHeight())

trainImagePlayerDataLower = love.image.newImageData(trainImage:getWidth(), trainImage:getHeight())

for i=0,trainImage:getWidth()-1 do
	for j=0,trainImage:getHeight()-1 do
		r,g,b,a = trainImage:getPixel(i, j)
		bright = 2*(0.2126 *r + 0.7152 *g + 0.0722 *b)/3--(r+g+b)/3	--calc brightness (average) of pixel
		trainImagePlayerData:setPixel(i, j, bright*col.r/255+r/3, bright*col.g/255+g/3, bright*col.b/255+b/3, a)
	end
end

lowerCol = generateColour(seed .. seed, 0.5)		-- different color!

for i=0,trainImage:getWidth()-1 do
	for j=0,trainImage:getHeight()-1 do
		r,g,b,a = trainImageLower:getPixel(i, j)
		bright = 2*(0.2126 *r + 0.7152 *g + 0.0722 *b)/3--(r+g+b)/3	--calc brightness (average) of pixel
		trainImagePlayerDataLower:setPixel(i, j, lowerCol.r, lowerCol.g, lowerCol.b, a)
	end
end
trainImagePlayerData = transparentPaste(trainImagePlayerData, trainImagePlayerDataLower, 0, 0)

channelOut:push({key="image", trainImagePlayerData})
channelOut:push({key="status", "done"})
