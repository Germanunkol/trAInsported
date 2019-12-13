trainRailSound = love.audio.newSource("TrainOnTracks.wav", "stream")


function playTrainSound()
	love.audio.play(trainRailSound)
end
