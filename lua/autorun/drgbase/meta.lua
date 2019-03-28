
local entMETA = FindMetaTable("Entity")
local plyMETA = FindMetaTable("Player")
local npcMETA = FindMetaTable("NPC")
local physMETA = FindMetaTable("PhysObj")

function entMETA:DrG_FadeOut(duration, callback)
  self:SetRenderMode(RENDERMODE_TRANSCOLOR)
  local alpha = self:GetColor().a
  coroutine.DrG_Create(function()
    while IsValid(self) and self:GetColor().a > 0 do
      local color = self:GetColor()
      color.a = color.a - 1
      self:SetColor(color)
      print(self:GetColor().a)
      coroutine.wait(duration/alpha)
    end
    if IsValid(self) and isfunction(callback) then callback() end
  end)
end
function entMETA:DrG_FadeIn(duration, callback)
  self:SetRenderMode(RENDERMODE_TRANSCOLOR)
  local alpha = self:GetColor().a
  local missing = 255 - alpha
  coroutine.DrG_Create(function()
    while IsValid(self) and self:GetColor().a < 255 do
      local color = self:GetColor()
      color.a = color.a + 1
      self:SetColor(color)
      print(self:GetColor().a)
      coroutine.wait(duration/missing)
    end
    if IsValid(self) and isfunction(callback) then callback() end
  end)
end

function plyMETA:DrG_IsPossessing()
  return IsValid(self:DrG_Possessing())
end
function plyMETA:DrG_Possessing()
  return self:GetNW2Entity("DrGBasePossessing")
end
function plyMETA:DrG_SteamAvatar(callback, onerror)
  http.Fetch("https://steamcommunity.com/profiles/"..self:SteamID64().."?xml=1", function(body)
    -- fetch the avatar from the xml file
    callback(avatar)
  end, function(err)
    if isfunction(onerror) then onerror(err) end
  end)
end

function physMETA:DrG_BallisticTrajectory(pos, options)
  options = options or {}
  local vec, info = math.DrG_BallisticTrajectory(self:GetPos(), pos, options)
  if not vec:IsZero() then
    if not options.drag then self:EnableDrag(false)
    else self:EnableDrag(true) end
    if options.draw then
      debugoverlay.DrG_BallisticTrajectory(self:GetPos(), vec, 5, nil, false, {
        from = -info.duration, to = info.duration*2, colors = function(t)
          if t < 0 then return DrGBase.Colors.Green
          elseif t > info.duration then return DrGBase.Colors.Red
          else return DrGBase.Colors.White end
        end
      })
    end
    self:SetVelocity(vec)
  end
  return vec, info
end

if SERVER then
  util.AddNetworkString("DrGBaseCreationID")

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

  function entMETA:DrG_FadeThenRemove(duration)
    self:DrG_FadeOut(duration, function()
      self:Remove()
    end)
  end

  function plyMETA:DrG_JoinFaction(faction)
    self:DrG_InitFactions()
    if self:DrG_IsInFaction(faction) then return end
    self._DrGBaseFactions[string.upper(faction)] = true
    for i, nextbot in ipairs(DrGBase.Nextbots.GetAll()) do
      nextbot:UpdateRelationshipWith(self)
    end
  end
  function plyMETA:DrG_LeaveFaction(faction)
    self:DrG_InitFactions()
    if not self:DrG_IsInFaction(faction) then return end
    self._DrGBaseFactions[string.upper(faction)] = false
    for i, nextbot in ipairs(DrGBase.Nextbots.GetAll()) do
      nextbot:UpdateRelationshipWith(self)
    end
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
  function plyMETA:DrG_JoinFactions(factions)
    for i, faction in ipairs(factions) do
      self:DrG_JoinFaction(faction)
    end
  end
  function plyMETA:DrG_LeaveFactions(factions)
    for i, faction in ipairs(factions) do
      self:DrG_LeaveFaction(faction)
    end
  end
  function plyMETA:DrG_LeaveAllFactions()
    self:DrG_LeaveFactions(self:DrG_GetFactions())
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
