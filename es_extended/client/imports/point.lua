local Point = ESX.Class()

local nearby, loop, nearbyCount = {}, nil, 0
local POINT_CHECK_MS = 200
local POINT_INSIDE_MS = 100

function Point:constructor(properties)
	self.coords = properties.coords
	self.hidden = properties.hidden
	self.enter = properties.enter
	self.leave = properties.leave
	self.inside = properties.inside
	self.handle = ESX.CreatePointInternal(properties.coords, properties.distance, properties.hidden, function()
		if not nearby[self.handle] then
			nearbyCount = nearbyCount + 1
		end
		nearby[self.handle] = self
		if self.enter then
			self:enter()
		end
		if not loop then
			loop = true
			CreateThread(function()
				while loop do
					local ped = ESX.PlayerData.ped
					if ped then
						local coords = GetEntityCoords(ped)
						for _, point in pairs(nearby) do
							if point.inside then
								local dx = coords.x - point.coords.x
								local dy = coords.y - point.coords.y
								local dz = coords.z - point.coords.z
								point:inside(math.sqrt(dx * dx + dy * dy + dz * dz))
							end
						end
					end
					Wait(POINT_INSIDE_MS)
				end
			end)
		end
	end, function()
		if nearby[self.handle] then
			nearbyCount = nearbyCount - 1
		end
		nearby[self.handle] = nil
		if self.leave then
			self:leave()
		end
		if nearbyCount == 0 then
			loop = false
		end
	end)
end

function Point:delete()
	ESX.RemovePointInternal(self.handle)
end

function Point:toggle(hidden)
	if hidden == nil then
		hidden = not self.hidden
	end
	self.hidden = hidden
	ESX.HidePointInternal(self.handle, hidden)
end

return Point