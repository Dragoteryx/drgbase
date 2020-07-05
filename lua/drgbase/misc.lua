-- Astar --

local NodeList = {}
NodeList.__index = NodeList
function NodeList:New()
  local list = {}
  list._nodes = {}
  list._size = 0
  setmetatable(list, self)
  return list
end
function NodeList:Insert(node, cost)
  if self:Has(node) then return self end
  self._nodes[tostring(node)] = {pos = node, cost = cost}
  self._size = self._size+1
  return self
end
function NodeList:Update(node, cost)
  if self:Has(node) then
    self._nodes[tostring(node)].cost = cost
    return self
  else return self:Insert(node, cost) end
end
function NodeList:Fetch()
  local node = table.DrG_Fetch(self._nodes, function(node1, node2)
    return node1.cost < node2.cost
  end)
  if not node then return end
  self._nodes[tostring(node.pos)] = nil
  self._size = self._size-1
  return node.pos
end
function NodeList:Has(node)
  return self._nodes[tostring(node)] ~= nil
end
function NodeList:Empty()
  return self._size == 0
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
    if coroutine.running() and i == 5 then
      i = 1
      coroutine.yield()
    else i = i+1 end
    local current = openList:Fetch()
    if not isvector(current) then return {}, false end
    debugoverlay.Sphere(current, 2, 0.1, DrGBase.CLR_WHITE, true)
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
          debugoverlay.Line(current, next, 0.1, DrGBase.CLR_GREEN, true)
          costSoFar[nextID] = newCost
          cameFrom[nextID] = current
          local heuristic = isfunction(options.heuristic) and options.heuristic(next, goal) or next:Distance(goal)
          openList:Update(next, newCost + heuristic)
        else debugoverlay.Line(current, next, 0.1, DrGBase.CLR_RED, true) end
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
      return next:DrG_ManhattanDistance(goal)*1.05
    end
  }, callback)
  table.remove(path, #path)
  table.insert(path, goal)
  return path, success
end

-- Misc --

local RANGE_MELEE = {
  ["melee"] = true,
  ["melee2"] = true,
  ["fist"] = true,
  ["knife"] = true
}
function DrGBase.IsMeleeWeapon(weapon)
  local holdType = weapon:GetHoldType()
  if RANGE_MELEE[holdType] or RANGE_MELEE[weapon.HoldType] then return true end
  return weapon.DrGBase_Melee or string.find(holdType, "melee") ~= nil
end

if SERVER then

  -- Misc --

  function DrGBase.CreateProjectile(model, binds)
    local proj = ents.Create("proj_drg_default")
    if not IsValid(proj) then return NULL end
    if istable(model) and #model > 0 then model = model[math.random(#model)] end
    if isstring(model) then proj:SetModel(model) end
    binds = binds or {}
    if isfunction(binds.Init) then proj.CustomInitialize = binds.Init end
    if isfunction(binds.Think) then proj.CustomThink = binds.Think end
    if isfunction(binds.Contact) then proj.OnContact = binds.Contact end
    if isfunction(binds.Use) then proj.Use = binds.Use end
    if isfunction(binds.DealtDamage) then proj.OnDealtDamage = binds.DealtDamage end
    if isfunction(binds.TakeDamage) then proj.OnTakeDamage = binds.TakeDamage end
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
    ["replicator_queen_hive"] = true,
    ["npc_antlion_grub"] = true
  }
  function DrGBase.IsTarget(ent)
    if not IsValid(ent) then return false end
    local class = ent:GetClass()
    if TARGET_BLACKLIST[class] then return false end
    if TARGET_WHITELIST[class] then return true end
    if ent.DrGBase_Target then return true end
    if ent:IsNextBot() then return true end
    if ent:IsPlayer() then return true end
    if ent:IsNPC() then return true end
    return false
  end

  function DrGBase.CanAttack(ent)
    if not IsValid(ent) then return false end
    if ent:IsPlayer() and ent:DrG_IsPossessing() then return false end
    if DrGBase.IsTarget(ent) then return true end
    local phys = ent:GetPhysicsObject()
    return IsValid(phys)
  end

  local BlindData = {}
  BlindData.__index = BlindData
  function BlindData:New()
    local blind = {}
    blind._duration = 3
    blind._attacker = NULL
    blind._inflictor = NULL
    setmetatable(blind, self)
    return blind
  end
  function BlindData:GetDuration()
    return self._duration
  end
  function BlindData:SetDuration(duration)
    if not isnumber(duration) then return end
    self._duration = math.max(0, duration)
  end
  function BlindData:ScaleDuration(scale)
    if not isnumber(scale) or scale < 0 then return end
    self:SetDuration(self:GetDuration()*scale)
  end
  function BlindData:GetAttacker()
    return self._attacker
  end
  function BlindData:SetAttacker(attacker)
    if not isentity(attacker) then return end
    self._attacker = attacker
  end
  function BlindData:GetInflictor()
    return self._inflictor
  end
  function BlindData:SetInflictor(inflictor)
    if not isentity(inflictor) then return end
    self._inflictor = inflictor
  end

  function DrGBase.Blind()
    return BlindData:New()
  end

  -- Astar --

  function DrGBase.NavmeshAstar(pos, goal, callback)
    local closest = navmesh.GetNearestNavArea(pos)
    local toreach = navmesh.GetNearestNavArea(goal)
    local path, success = DrGBase.Astar(closest:GetCenter(), toreach:GetCenter(), {
      neighbours = function(pos)
        local area = navmesh.GetNearestNavArea(pos)
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
        --local from = Vector(12014.925781, -4885.867676, -7935.968750 + 60)
        --local to = Vector(-14160.027344, 14420.491211, -10087.968750)
        --gm_construct:
        local from = Vector(0, 0, 100)
        local to = Entity(1):GetPos()
        local path, success = DrGBase.NodegraphAstar(from, to, 50)
        if success then
          print("success")
          debugoverlay.Line(from, path[1], 1, DrGBase.CLR_RED, true)
          for i = 1, #path do
            if path[i+1] then debugoverlay.Line(path[i], path[i+1], 1, DrGBase.CLR_WHITE, true) end
          end
        else print("failure") end
      end)
    else
      local ok, args = coroutine.resume(DrGBase.NavmeshAstarTest)
      if not ok then ErrorNoHalt(args, "\n") end
    end
  end)

else

  -- Misc --

  local MATERIALS = {}
  function DrGBase.Material(name, ...)
    if not MATERIALS[name] then
      local material = Material(name, ...)
      MATERIALS[name] = material
      return material
    else return MATERIALS[name] end
  end

end
