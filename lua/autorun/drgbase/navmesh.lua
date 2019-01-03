DrGBase.Navmesh = DrGBase.Navmesh or {}

local function DrGBaseCost(start, goal)
	return start:GetCenter():DistToSqr(goal:GetCenter())
end
local function DrGBaseConstructPath(cameFrom, current)
	local path = {current}
	current = current:GetID()
	while cameFrom[current] do
		current = cameFrom[current]
		table.insert(path, navmesh.GetNavAreaByID(current))
	end
	return path
end
function DrGBase.Navmesh.Astar(vecStart, vecGoal)
	if not navmesh.IsLoaded() then return false end
  local start = navmesh.GetNearestNavArea(vecStart)
  local goal = navmesh.GetNearestNavArea(vecGoal)
  if start:GetID() == goal:GetID() then return true end
	start:ClearSearchLists()
	start:AddToOpenList()
	local cameFrom = {}
	start:SetCostSoFar(0)
	start:SetTotalCost(DrGBaseCost(start, goal))
	start:UpdateOnOpenList()
  local i = 0
	while not start:IsOpenListEmpty() and i <= 100000 do
    print(i)
    i = i+1
		local current = start:PopOpenList()
		if current == goal then return DrGBaseConstructPath(cameFrom, current) end
		current:AddToClosedList()
		for h, adjacent in ipairs(current:GetAdjacentAreas()) do
			local newCostSoFar = current:GetCostSoFar() + DrGBaseCost(current, adjacent)
			if adjacent:IsUnderwater() then continue end
			if (adjacent:IsOpen() or adjacent:IsClosed()) and adjacent:GetCostSoFar() <= newCostSoFar then
				continue
			else
				adjacent:SetCostSoFar(newCostSoFar)
				adjacent:SetTotalCost(newCostSoFar + DrGBaseCost(adjacent, goal))
				if adjacent:IsClosed() then adjacent:RemoveFromClosedList() end
				if adjacent:IsOpen() then adjacent:UpdateOnOpenList()
				else adjacent:AddToOpenList()	end
				cameFrom[adjacent:GetID()] = current:GetID()
			end
		end
	end
	return false
end

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
