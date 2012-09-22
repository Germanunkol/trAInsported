functionQueue = {}

local queue = {}

function functionQueue.new(frames, func, ...)
	table.insert(queue, {frames=frames, event=func, args=...})
end

function functionQueue.run()
	for k, f in pairs(queue) do
		if f.frames == 1 then 
			f.event(f.args)	--run
			queue[k] = nil	--forget
		else
			f.frames = f.frames - 1
		end
	end
end

return functionQueue
