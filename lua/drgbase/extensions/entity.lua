
local entMETA = FindMetaTable("Entity")

-- Misc --

function entMETA:DrG_IsSanic()
  return self.OnReloaded ~= nil and
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

  function entMETA:DrG_Ragdoll()
    if not self.IsDrGNextbot then
      return NULL
    else return self:BecomeRagdoll() end
  end

end
