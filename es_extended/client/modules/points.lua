local points, nextHandle = {}, 1
local POINT_CHECK_MS = 200
local pointsLoopRunning = false

function ESX.CreatePointInternal(coords, distance, hidden, enter, leave)
	local point = {
		coords = coords,
		distance = distance,
		hidden = hidden,
		enter = enter,
		leave = leave,
		resource = GetInvokingResource()
	}
	local handle = nextHandle
	nextHandle = nextHandle + 1
	points[handle] = point
	return handle
end

function ESX.RemovePointInternal(handle)
	points[handle] = nil
end

function ESX.HidePointInternal(handle, hidden)
	if points[handle] then
		points[handle].hidden = hidden
	end
end

function StartPointsLoop()
	if pointsLoopRunning then
		return
	end

	pointsLoopRunning = true
	CreateThread(function()
		while true do
			local sleep = 1000
			local ped = ESX.PlayerData.ped
			if ped then
				local coords = GetEntityCoords(ped)
				for handle = 1, nextHandle - 1 do
					local point = points[handle]
					if point and not point.hidden then
						sleep = POINT_CHECK_MS
						local dx = coords.x - point.coords.x
						local dy = coords.y - point.coords.y
						local dz = coords.z - point.coords.z
						local distanceSquared = dx * dx + dy * dy + dz * dz
						local isNearby = distanceSquared <= point.distance * point.distance

						if isNearby and not point.nearby then
							point.nearby = true
							if point.enter then
								point.enter()
							end
						elseif not isNearby and point.nearby then
							point.nearby = false
							if point.leave then
								point.leave()
							end
						end
					elseif point and point.nearby then
						point.nearby = false
						if point.leave then
							point.leave()
						end
					end
				end
			end
			Wait(sleep)
		end
	end)
end

AddEventHandler('onResourceStop', function(resource)
	for handle = 1, nextHandle - 1 do
		local point = points[handle]
		if point and point.resource == resource then
			points[handle] = nil
		end
	end
end)