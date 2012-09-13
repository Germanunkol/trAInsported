print("file opened")

function ai.test()
	print("tested")
end
j = 0
while j < 10000 do
	print(j, _G)
	j = j+1
end

function ai.init()
	print("inited ai")
	j = 0
	while j < 100000 do
		print("haha", j)
		j = j+1
	end
end

