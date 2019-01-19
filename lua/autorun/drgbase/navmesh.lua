DrGBase.Navmesh = DrGBase.Navmesh or {}

local function CalcCost(from, to)
	return DrGBase.Math.ManhattanDistance(from:GetCenter(), to:GetCenter())
end
local function GeneratePath(cameFrom, current)
	local total_path = { current }
	current = current:GetID()
	while ( cameFrom[ current ] ) do
		current = cameFrom[ current ]
		table.insert( total_path, navmesh.GetNavAreaByID( current ) )
	end
	return total_path
end

local astarCoroutines = {}
function DrGBase.Navmesh.Astar(vecStart, vecGoal, callback)
	if not navmesh.IsLoaded() then return false end
	local start = navmesh.GetNearestNavArea(vecStart)
	local goal = navmesh.GetNearestNavArea(vecGoal)
	if start:GetID() == goal:GetID() then
		callback({vecStart, vecGoal}, 0)
		return true
	else
		table.insert(astarCoroutines, coroutine.create(function()
			local i = 1
			local ecarts = 100
			local lastPause = i
			local openList = {}
			local inOpenList = {}
			local inClosedList = {}
			local costs = {}
			local heuristics = {}
			local cameFrom = {}
			table.insert(openList, start)
			costs[start:GetID()] = 0
			while #openList > 0 and i < 10000 do
				print(i)
				local current = table.remove(openList, 1)

				if current:GetID() == goal:GetID() then
					PrintTable(cameFrom)
					callback(cameFrom, i)
					return
				else
					inClosedList[current:GetID()] = true
					for h, neighbour in ipairs(current:GetAdjacentAreas()) do
						local cost = costs[current:GetID()] + CalcCost(current, neighbour)
						-- if underwater etc
						if (inClosedList[neighbour:GetID()] or table.HasValue(openList, neighbour)) and
						costs[neighbour:GetID()] <= cost then continue
						else
							costs[neighbour:GetID()] = cost
							heuristics[neighbour:GetID()] = cost + CalcCost(neighbour, goal)
							if not table.HasValue(openList, neighbour) then
								table.insert(openList, neighbour)
							end
							table.sort(openList, function(nav1, nav2)
								return heuristics[nav1:GetID()] < heuristics[nav2:GetID()]
							end)
							cameFrom[neighbour:GetID()] = current:GetID()
						end
					end
					i = i+1
					if i == lastPause + ecarts then
						lastPause = i
						coroutine.yield()
					end
				end
			end
			callback(nil, i)
		end))
		return true
	end
end

hook.Add("Think", "DrGBaseAstarCoroutines", function()
	for i, co in ipairs(astarCoroutines) do
		local status = coroutine.status(co)
		if status == "suspended" then
			coroutine.resume(co)
		elseif status == "dead" then
			table.RemoveByValue(astarCoroutines, co)
		end
	end
end)

function DrGBase.Navmesh.ComputePath(path, nextbot, pos, generator)
	nextbot._DrGBaseLastComputeInfraction = nextbot._DrGBaseLastComputeInfraction or 0
	if CurTime() < nextbot._DrGBaseLastComputeInfraction + 2 then return false end
	local now = CurTime()
	local compute = path:Compute(nextbot, pos, generator)
	if CurTime() - now > 0.005 then
		nextbot._DrGBaseLastComputeInfraction = CurTime()
	end
	return compute
end
