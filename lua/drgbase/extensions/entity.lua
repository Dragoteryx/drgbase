
local entMETA = FindMetaTable("Entity")

-- Misc --


function entMETA:DrG_IsSanic()
  --return self:IsNextBot() and
  return self.Type == "nextbot" and
  self.OnReloaded ~= nil and
  self.GetNearestTarget ~= nil and
  self.AttackNearbyTargets ~= nil and
  self.IsHidingSpotFull ~= nil and
  self.GetNearestUsableHidingSpot ~= nil and
  self.ClaimHidingSpot ~= nil and
  self.AttemptJumpAtTarget ~= nil and
  self.LastPathingInfraction ~= nil and
  self.RecomputeTargetPath ~= nil and
  self.UnstickFromCeiling ~= nil
end

function entMETA:DrG_AddListener(name, callback)
  if not isfunction(callback) then return false end
  local old_function = self[name]
  if not isfunction(old_function) then return false end
  self[name] = function(...)
    local res = callback(...)
    if res ~= nil then return res
    else return old_function(...) end
  end
  return true
end

-- Timers --

function entMETA:DrG_Timer(duration, callback, ...)
  timer.DrG_Simple(duration, function(...)
    if IsValid(self) then callback(self, ...) end
  end, ...)
end
function entMETA:DrG_LoopTimer(delay, callback, ...)
  timer.DrG_Loop(delay, function(...)
    if not IsValid(self) then return false end
    return callback(self, ...)
  end, ...)
end

-- Doors --

local DOORS = {
  ["prop_door_rotating"] = true,
  ["func_door"] = true,
  ["func_door_rotating"] = true,
  ["prop_dynamic"] = true
}
function entMETA:DrG_IsDoor()
  return DOORS[self:GetClass()] or false
end

local Door = {}
Door.__index = Door
function Door:New(nextbot, ent)
  local door = {}
  door._nextbot = nextbot
  door._door = ent
  setmetatable(door, self)
  return door
end
function Door:IsValid()
  return IsValid(self._nextbot) and IsValid(self._door)
end
function Door:Open(away)
  if not self:IsValid() then return end
  if self:IsDouble() then
    local double = self:GetDouble()
    if away then
      self._door:Fire("openawayfrom", self._nextbot:GetName())
      double:Fire("openawayfrom", self._nextbot:GetName())
    else
      self._door:Fire("open")
      double:Fire("open")
    end
  else
    if away then
      self._door:Fire("openawayfrom", self._nextbot:GetName())
    else self._door:Fire("open") end
  end
end
function Door:Close()
  if not self:IsValid() then return end
  self._door:Fire("close")
  if self:IsDouble() then
    self:GetDouble():Fire("close")
  end
end
function Door:GetDouble()
  if not self:IsValid() then return end
  local keyvalues = self._door:GetKeyValues()
  if isstring(keyvalues.slavename) then
    return ents.FindByName(keyvalues.slavename)[1]
  end
end
function Door:IsDouble()
  return IsValid(self:GetDouble())
end
function Door:SetSpeed(speed)
  if not self:IsValid() then return end
  door:Fire("setspeed", speed)
  if self:IsDouble() then
    self:GetDouble():Fire("setspeed", speed)
  end
end
function Door:GetNextbot()
  return self._nextbot
end
function Door:GetDoor()
  return self._door
end

function entMETA:DrG_DoorOpener(ent)
  if not ent.IsDrGNextbot then return end
  return Door:New(ent, self)
end

if SERVER then

  -- Misc --

  function entMETA:DrG_Dissolve(type)
    if self:IsFlagSet(FL_DISSOLVING) then return end
    local dissolver = ents.Create("env_entity_dissolver")
    if not IsValid(dissolver) then return false end
    if self:GetName() == "" then
      self:SetName("ent_"..self:GetClass().."_"..self:EntIndex().."_dissolved")
    end
    dissolver:SetKeyValue("dissolvetype", tostring(type or 0))
    dissolver:Fire("dissolve", self:GetName())
    dissolver:Remove()
    return true
  end

  function entMETA:DrG_DeathNotice(attacker, inflictor)
    if self:IsPlayer() then
      hook.Run("PlayerDeath", self, inflictor, attacker)
    else hook.Run("OnNPCKilled", self, attacker, inflictor) end
  end

  function entMETA:DrG_SearchBone(searchBone)
    for boneId = 0, (self:GetBoneCount()-1) do
      local boneName = self:GetBoneName(boneId)
      if not boneName then return end
      if boneName == "__INVALIDBONE__" then continue end
      if string.find(string.lower(boneName), string.lower(searchBone)) then
        return boneId
      end
    end
  end

  function entMETA:DrG_CreateRagdoll(dmg)
    if not util.IsValidRagdoll(self:GetModel()) then return NULL end
    local ragdoll = ents.Create("prop_ragdoll")
    if IsValid(ragdoll) then
      if not dmg then dmg = DamageInfo() end
      ragdoll:SetPos(self:GetPos())
      ragdoll:SetAngles(self:GetAngles())
      ragdoll:SetModel(self:GetModel())
      ragdoll:SetSkin(self:GetSkin())
      ragdoll:SetColor(self:GetColor())
      ragdoll:SetModelScale(self:GetModelScale())
      ragdoll:SetBloodColor(self:GetBloodColor())
      for i = 1, #self:GetBodyGroups() do
        ragdoll:SetBodygroup(i-1, self:GetBodygroup(i-1))
      end
      ragdoll:Spawn()
      if not GetConVar("ai_serverragdolls"):GetBool() then
        ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
      end
      for i = 0, (ragdoll:GetPhysicsObjectCount()-1) do
        local bone = ragdoll:GetPhysicsObjectNum(i)
        if not IsValid(bone) then continue end
        local pos, angles = self:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))
        bone:SetPos(pos)
        bone:SetAngles(angles)
      end
      local phys = ragdoll:GetPhysicsObject()
      phys:SetVelocity(self:GetVelocity())
      local force = dmg:GetDamageForce()
      local position = dmg:GetDamagePosition()
      if IsValid(phys) and isvector(force) and isvector(position) then
        phys:ApplyForceOffset(force, position)
      end
      if dmg:IsDamageType(DMG_DISSOLVE) then ragdoll:DrG_Dissolve()
      elseif self:IsOnFire() then ragdoll:Ignite(10) end
      local attacker = dmg:GetAttacker()
      if IsValid(attacker) and attacker.IsDrGNextbot then
        attacker:SpotEntity(ragdoll)
      end
      ragdoll.EntityClass = self:GetClass()
      return ragdoll
    else return NULL end
  end
  function entMETA:DrG_RagdollDeath(dmg)
    if self:IsPlayer() then
      if not self:Alive() then return NULL end
      self:KillSilent()
    else
      self:AddFlags(FL_TRANSRAGDOLL)
      self:Remove()
    end
    if dmg then self:DrG_DeathNotice(dmg:GetAttacker(), dmg:GetInflictor()) end
    local ragdoll = self:DrG_CreateRagdoll(dmg)
    if not self:IsPlayer() and IsValid(ragdoll) then
      undo.ReplaceEntity(self, ragdoll)
      cleanup.ReplaceEntity(self, ragdoll)
    end
    return ragdoll
  end

end
