
-- Astar --

local NodeList = {}
NodeList.__index = NodeList
function NodeList:New()
  local list = {}
  list._nodes = {}
  list._has = {}
  setmetatable(list, self)
  return list
end
function NodeList:Insert(pos, cost)
  if self:Has(pos) then return self end
  local id = tostring(pos)
  self._has[id] = true
  table.insert(self._nodes, {
    pos = pos, cost = cost
  })
  table.sort(self._nodes, function(node1, node2)
    return node1.cost < node2.cost
  end)
  return self
end
function NodeList:Update(pos, cost)
  if self:Has(pos) then
    local id = tostring(pos)
    table.sort(self._nodes, function(node1, node2)
      if tostring(node1) == id then node1.cost = cost end
      if tostring(node2) == id then node2.cost = cost end
      return node1.cost < node2.cost
    end)
    return self
  else return self:Insert(pos, cost) end
end
function NodeList:Fetch()
  local node = table.remove(self._nodes, 1)
  self._has[tostring(node.pos)] = false
  return node.pos
end
function NodeList:Has(pos)
  return self._has[tostring(pos)] or false
end
function NodeList:Empty()
  return #self._nodes == 0
end

function DrGBase.Astar(pos, goal, options, callback)
  if not options then return {}, false end
  local goalID = tostring(goal)
  local openList = NodeList:New():Insert(pos, 0)
  local cameFrom = {}
  local costSoFar = {}
  costSoFar[tostring(pos)] = 0
  local i = 1
  while not openList:Empty() do
    if coroutine.running() and i == 1 then
      i = 1
      coroutine.yield()
    else i = i+1 end
    local current = openList:Fetch()
    if not isvector(current) then return {}, false end
    debugoverlay.Sphere(current, 2, 0.2, DrGBase.CLR_WHITE, true)
    local currentID = tostring(current)
    if currentID == goalID then
      local path = {current}
      while cameFrom[currentID] do
        local parent = cameFrom[currentID]
        table.insert(path, parent)
        current = parent
        currentID = tostring(current)
      end
      return table.Reverse(path), true
    elseif isfunction(options.neighbours) then
      for next in options.neighbours(current) do
        local nextID = tostring(next)
        local newCost = costSoFar[currentID] + current:Distance(next)
        if not costSoFar[nextID] or newCost < costSoFar[nextID] then
          if isfunction(callback) and callback(current, next) == false then continue end
          debugoverlay.Line(current, next, 0.2, DrGBase.CLR_WHITE, true)
          costSoFar[nextID] = newCost
          cameFrom[nextID] = current
          local heuristic = isfunction(options.heuristic) and options.heuristic(next, goal) or next:Distance(goal)
          openList:Update(next, newCost + heuristic)
        end
      end
    end
  end
  return {}, false
end

function DrGBase.GridAstar(pos, goal, grid, callback)
  grid = math.Round(grid)
  local half = grid/2
  local multX = math.Round(goal.x/grid)
  local multY = math.Round(goal.y/grid)
  local multZ = math.Round(goal.z/grid)
  local toreach = Vector(multX*grid, multY*grid, multZ*grid)
  local path, success = DrGBase.Astar(pos, toreach, {
    neighbours = function(pos)
      local nexts = {
        Vector(grid, 0, 0), Vector(-grid, 0, 0),
        Vector(0, grid, 0), Vector(0, -grid, 0),
        Vector(0, 0, grid), Vector(0, 0, -grid)
      }
      local i = 1
      return function()
        while i <= #nexts do
          local next = nexts[i]
          i = i+1
          if isvector(next) then
            next = next+pos
            if tostring(next) == tostring(toreach) or not util.TraceHull({
              start = pos, endpos = next,
              mins = Vector(-half, -half, -half),
              maxs = Vector(half, half, half)
            }).HitWorld then return next end
          end
        end
      end
    end,
    heuristic = function(next, goal)
      return next:DrG_ManhattanDistance(goal)
    end
  }, callback)
  table.remove(path, #path)
  table.insert(path, goal)
  return path, success
end

if SERVER then

  -- Misc --

  function DrGBase.CreateProjectile(model, binds, class)
    local proj = ents.Create(class or "proj_drg_default")
    if not IsValid(proj) then return NULL end
    if istable(model) and #model > 0 then model = model[math.random(#model)] end
    if isstring(model) then proj:SetModel(model) end
    binds = binds or {}
    if isfunction(binds.Init) then proj.CustomInitialize = binds.Init end
    if isfunction(binds.Think) then proj.CustomThink = binds.Think end
    if isfunction(binds.Filter) then proj.OnFilter = binds.Filter end
    if isfunction(binds.Contact) then proj.OnContact = binds.Contact end
    if isfunction(binds.Use) then proj.Use = binds.Use end
    if isfunction(binds.Damage) then proj.OnTakeDamage = binds.Damage end
    if isfunction(binds.Remove) then proj.OnRemove = binds.Remove end
    proj:Spawn()
    return proj
  end

  local TARGET_BLACKLIST = {
    ["npc_bullseye"] = true,
    ["npc_grenade_frag"] = true,
    ["npc_tripmine"] = true,
    ["npc_satchel"] = true
  }
  local TARGET_WHITELIST = {
    ["replicator_melon"] = true,
    ["replicator_worker"] = true,
    ["replicator_queen"] = true,
    ["replicator_queen_hive"] = true
  }
  function DrGBase.IsTarget(ent)
    if not IsValid(ent) then return false end
    local class = ent:GetClass()
    if TARGET_BLACKLIST[class] then return false end
    if TARGET_WHITELIST[class] then return true end
    if ent.DrGBase_Target then return true end
    if ent:IsPlayer() then return true end
    if ent:IsNPC() then return true end
    if ent.Type == "nextbot" then return true end
    if ent:IsFlagSet(FL_OBJECT) then return true end
    if string.StartWith(class, "npc_") then return true end
    return false
  end

  -- Astar --

  function DrGBase.NavmeshAstar(pos, goal, callback)
    local closest = navmesh.GetNearestNavArea(pos)
    local toreach = navmesh.GetNearestNavArea(goal)
    local path, success = DrGBase.Astar(closest:GetCenter(), toreach:GetCenter(), {
      neighbours = function(pos)
        local area = navmesh.DrG_GetAreaFromCenter(pos)
        if area then
          local i = 1
          local adjacent = area:GetAdjacentAreas()
          return function()
            if not adjacent or #adjacent == 0 then return end
            local next = adjacent[i]
            i = i+1
            if next then return next:GetCenter() end
          end
        else return function() end end
      end
    }, isfunction(callback) and function(pos1, pos2, cost, heuristic)
      local area1 = navmesh.GetNearestNavArea(pos1)
      local area2 = navmesh.GetNearestNavArea(pos2)
      return callback(area1, area, cost, heuristic)
    end)
    if success then
      path[0] = pos
      local path2 = {}
      for i = 1, #path do
        local area = navmesh.GetNearestNavArea(path[i-1])
        local vec = i < #path and path[i] or goal
        table.insert(path2, area:GetClosestPointOnArea(vec))
      end
      table.remove(path2, 1)
      table.insert(path2, goal)
      return path2, success
    else return path, success end
  end

  local testAstar = false
  DrGBase.NavmeshAstarTest = nil
  hook.Add("Think", "DrGBaseAstarTest", function()
    if not testAstar then return end
    if not DrGBase.NavmeshAstarTest or coroutine.status(DrGBase.NavmeshAstarTest) == "dead" then
      DrGBase.NavmeshAstarTest = coroutine.create(function()
        if not GetConVar("developer"):GetBool() then return end
        print("=======")
        --gm_fork:
        local from = Vector(12014.925781, -4885.867676, -7935.968750 + 60)
        local to = Vector(-14160.027344, 14420.491211, -10087.968750)
        --gm_construct:
        --local from = Vector(0, 0, 0)
        --local to = Entity(1):GetPos()
        local path, success = DrGBase.NodegraphAstar(from, to, 50)
        if success then
          print("success")
          debugoverlay.Line(from, path[1], 1, DrGBase.CLR_RED, true)
          for i = 1, #path do
            if path[i+1] then debugoverlay.Line(path[i], path[i+1], 1, DrGBase.CLR_GREEN, true) end
          end
        else print("failure") end
      end)
    else
      local ok, args = coroutine.resume(DrGBase.NavmeshAstarTest)
      if not ok then ErrorNoHalt(args, "\n") end
    end
  end)

end
