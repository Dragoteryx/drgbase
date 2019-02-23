
local entMETA = FindMetaTable("Entity")
local plyMETA = FindMetaTable("Player")
local npcMETA = FindMetaTable("NPC")
local physMETA = FindMetaTable("PhysObj")

function entMETA:GetDrGVar(name)
  return net.DrG_GetVar(name, self)
end

function plyMETA:DrG_IsPossessing()
  return IsValid(self:DrG_Possessing())
end
function plyMETA:DrG_Possessing()
  return DrGBase.Nextbots.Possessing(self)
end
function plyMETA:DrG_SteamAvatar(callback, onerror)
  if callback == nil then
    return drg_promise.New(function(resolve, reject)
      self:DrG_SteamAvatar(resolve, reject)
    end)
  else
    http.Fetch("https://steamcommunity.com/profiles/"..self:SteamID64().."?xml=1", function(body)
      -- fetch the avatar from the xml file
      callback(avatar)
    end, function(err)
      if isfunction(onerror) then onerror(err) end
    end)
  end
end

function physMETA:DrG_ParabolicTrajectory(pos, options)
  options = options or {}
  local vec, data = math.DrG_ParabolicTrajectory(self:GetPos(), pos, options)
  if not vec:IsZero() then
    if not options.drag then self:EnableDrag(false) end
    self:SetVelocity(vec)
  end
  return vec, data
end
function physMETA:DrG_DirectTrajectory(pos, options)
  options = options or {}
  local vec, data = math.DrG_DirectTrajectory(self:GetPos(), pos, options)
  if not vec:IsZero() then
    if not options.drag then self:EnableDrag(false) end
    self:SetVelocity(vec)
  end
  return vec, data
end

if SERVER then
  util.AddNetworkString("DrGBaseCreationID")

  function entMETA:SetDrGVar(name, value)
    return net.DrG_SetVar(name, value, self)
  end

  function entMETA:DrG_Explode(options)
    options = options or {}
    if options.remove == nil then options.remove = true end
    options.owner = self
    if options.remove then self:Remove() end
    util.DrG_Explosion(self:GetPos(), options)
  end

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

  function plyMETA:DrG_JoinFaction(faction)
    self:DrG_InitFactions()
    self._DrGBaseFactions[string.upper(faction)] = true
  end
  function plyMETA:DrG_LeaveFaction(faction)
    self:DrG_InitFactions()
    self._DrGBaseFactions[string.upper(faction)] = false
  end
  function plyMETA:DrG_IsInFaction(faction)
    self:DrG_InitFactions()
    return self._DrGBaseFactions[string.upper(faction)] or false
  end
  function plyMETA:DrG_GetFactions()
    self:DrG_InitFactions()
    local factions = {}
    for faction, joined in pairs(self._DrGBaseFactions) do
      if joined then table.insert(factions, faction) end
    end
    return factions
  end
  function plyMETA:DrG_InitFactions()
    self._DrGBaseFactions = self._DrGBaseFactions or {}
  end

  -- Hooks --

  hook.Add("OnEntityCreated", "DrGBaseCreationID", function(ent)
    net.Start("DrGBaseCreationID")
    net.WriteEntity(ent)
    net.WriteInt(ent:GetCreationID(), 32)
    net.Broadcast()
  end)

else

  net.Receive("DrGBaseCreationID", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    ent._DrGBaseCreationID = net.ReadInt(32)
  end)

  function entMETA:DrG_GetCreationID()
    return self._DrGBaseCreationID
  end

end
