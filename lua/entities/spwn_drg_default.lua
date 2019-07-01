ENT.Base = "drgbase_entity"
ENT.Type = "point"
ENT.IsDrGSpawner = true

-- Misc --
ENT.PrintName = "Spawner"
ENT.Category = "DrGBase"

-- Spawner --
ENT.ToSpawn = {}
ENT.AutoRemove = true
ENT.Radius = 0
ENT.Quantity = 0
ENT.Delay = 0

if SERVER then
  AddCSLuaFile()

  -- Init/Think --

  function ENT:Initialize()
    self._DrGBaseToSpawn = {}
    self._DrGBaseRadius = 0
    self._DrGBaseQuantity = 0
    self._DrGBaseDelay = 0
    self._DrGBaseSpawnedEntities = {}
    self:SetRadius(self.Radius)
    self:SetQuantity(self.Quantity)
    self:SetDelay(self.Delay)
    self:EnableAutoRemove(self.AutoRemove)
    for class, nb in pairs(self.ToSpawn) do
      if not isnumber(nb) or nb <= 0 then continue end
      self:AddToSpawn(class, nb)
    end
  end
  function ENT:_BaseInitialize() end
  function ENT:CustomInitialize() end

  function ENT:Think()
    if #self._DrGBaseToSpawn == 0 then return end
    if #self._DrGBaseSpawnedEntities >= self:GetQuantity() then return end
    if not isnumber(self._DrGBaseLastSpawn) or CurTime() > self._DrGBaseLastSpawn + self:GetDelay() then
      local class = self._DrGBaseToSpawn[math.random(#self._DrGBaseToSpawn)]
      if self:BeforeSpawn(class) == false then return end
      local ent = ents.Create(class)
      if not IsValid(ent) then return end    
      if navmesh.IsLoaded() then
        local radius = self:GetRadius()
        local pos = self:GetPos() + Vector(math.random(-1, 1)*radius, math.random(-1, 1)*radius, math.random(-1, 1)*radius)
        ent:SetPos(navmesh.GetNearestNavArea(pos):GetClosestPointOnArea(pos) or self:GetPos())
      else ent:SetPos(self:GetPos()) end
      ent:Spawn()
      if self:AfterSpawn(ent) ~= false then
        self._DrGBaseLastSpawn = CurTime()
        table.insert(self._DrGBaseSpawnedEntities, ent)
        if self:EnableAutoRemove() then self:DeleteOnRemove(ent) end
        ent:CallOnRemove("DrGBaseSpawnerRemove", function(ent)
          if not IsValid(self) then return end
          table.RemoveByValue(self._DrGBaseSpawnedEntities, ent)
        end)
      else ent:Remove() end
    end
  end
  function ENT:_BaseThink() end
  function ENT:CustomThink() end

  -- Spawner functions --

  function ENT:AddToSpawn(class, nb)
    self:RemoveToSpawn(class)
    if not isnumber(nb) or nb < 1 then nb = 1 end
    if nb <= 0 then return end
    if istable(class) then
      for i, clas in ipairs(class) do self:AddToSpawn(clas, nb) end
    elseif isstring(class) then
      class = string.lower(class)
      for i = 1, math.floor(nb) do table.insert(self._DrGBaseToSpawn, class) end
    end
  end
  function ENT:RemoveToSpawn(class)
    if istable(class) then
      for i, clas in ipairs(class) do self:RemoveToSpawn(clas) end
    elseif isstring(class) then
      table.RemoveByValue(self._DrGBaseToSpawn, string.lower(class))
    end
  end

  function ENT:GetRadius()
    return self._DrGBaseRadius
  end
  function ENT:SetRadius(radius)
    if not isnumber(radius) then return end
    self._DrGBaseRadius = math.Clamp(radius, 0, math.huge)
  end

  function ENT:GetQuantity()
    return self._DrGBaseQuantity
  end
  function ENT:SetQuantity(quantity)
    if not isnumber(quantity) then return end
    self._DrGBaseQuantity = math.Clamp(quantity, 0, math.huge)
  end

  function ENT:GetDelay()
    return self._DrGBaseDelay
  end
  function ENT:SetDelay(delay)
    if not isnumber(delay) then return end
    self._DrGBaseDelay = math.Clamp(delay, 0, math.huge)
  end

  function ENT:EnableAutoRemove(autoremove)
    if bool == nil then return self._DrGBaseAutoRemove or false
    else self._DrGBaseAutoRemove = tobool(autoremove) end
  end

  -- Spawner hooks --

  function ENT:BeforeSpawn() end
  function ENT:AfterSpawn() end

end
