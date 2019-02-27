
function ENT:IsBlind()
  return self.SightFOV <= 0 or self.SightRange <= 0
end

function ENT:IsSeenBy(ent)
  if ent.IsDrGNextbot then
    return ent:CanSeeEntity(self)
  else
    local fov = 75
    if ent:IsPlayer() then
      if GetConVar("ai_ignoreplayers"):GetBool() or
      ent:DrG_IsPossessing() then return false end
      fov = ent:GetFOV()
    end
    local eyepos = ent:EyePos()
    if math.DrG_DegreeAngle(eyepos + ent:EyeAngles():Forward(), self:WorldSpaceCenter(), eyepos) > fov then
      return false
    end
    return ent:Visible(self)
  end
end
function ENT:SeenBy(ignoreallies)
  local entities = {}
  for i, ent in ipairs(self:GetTargets()) do
    if not IsValid(ent) then continue end
    if ent:EntIndex() == self:EntIndex() then continue end
    if self:IsSeenBy(ent) and not (ignoreallies and self:IsAlly(ent)) then
      table.insert(entities, ent)
    end
  end
  return entities
end
function ENT:IsSeen(ignoreallies)
  return #self:SeenBy(ignoreallies) ~= 0
end

function ENT:GetEyeTrace()
  if self:IsPossessed() then return self:PossessorTrace()
  else return util.TraceLine({
    start = self:EyePos(),
    endpos = self:EyePos() + self:EyeAngles():Forward()*999999999,
    filter = {self, self:GetWeapon()}
  }) end
end
function ENT:GetEyeTraceNoCursor()
  return self:GetEyeTrace()
end

local HearSounds = CreateConVar("drgbase_hear_sounds", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
local HearBullets = CreateConVar("drgbase_hear_bullets", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

if SERVER then

  function ENT:HasSpottedEntity(ent)
    if not IsValid(ent) then return false end
    if self.Omniscient then return true end
    if self.CommunicateWithAllies and self:IsAlly(ent) then return true end
    self._DrGBaseSpotted[ent:GetCreationID()] = self._DrGBaseSpotted[ent:GetCreationID()] or {
      time = -1, pos = nil
    }
    if self._DrGBaseSpotted[ent:GetCreationID()].time < 0 then return false end
    return CurTime() < self._DrGBaseSpotted[ent:GetCreationID()].time + self.PursueTime
  end

  local onspotentity = false
  function ENT:SpotEntity(ent)
    if not IsValid(ent) then return end
    if self:EntIndex() == ent:EntIndex() then return end
    if ent:IsPlayer() and (not ent:Alive() or GetConVar("ai_ignoreplayers"):GetBool()) then return end
    if not self:HasSpottedEntity(ent) then
      if ent.IsVJBaseSNPC then self:_NotifyVJ(ent) end
      self:_Debug("spotted entity '"..ent:GetClass().."' ("..ent:EntIndex()..").")
      if not onspotentity then
        onspotentity = true
        if self.CommunicateWithAllies then
          for i, ally in ipairs(self:GetAllies()) do
            if ally.IsDrGNextbot then ally:SpotEntity(ent) end
          end
        end
        self:OnSpotEntity(ent)
        onspotentity = false
      end
    end
    self._DrGBaseSpotted[ent:GetCreationID()] = {
      time = CurTime(), pos = ent:GetPos()
    }
  end
  function ENT:OnSpotEntity() end

  function ENT:ForgetEntity(ent)
    if not IsValid(ent) then return end
    self:_Debug("spotted entity '"..ent:GetClass().."' ("..ent:EntIndex()..").")
    self._DrGBaseSpotted[ent:GetCreationID()] = {
      time = -1, pos = nil
    }
  end

  hook.Add("PostPlayerDeath", "DrGBaseNextbotPostPlayerDeathForget", function(ply)
    for i, ent in ipairs(DrGBase.Nextbots.GetAll()) do
      ent:ForgetEntity(ply)
    end
  end)

  -- Helpers --

  function ENT:CanSeeEntity(ent)
    if not IsValid(ent) then return false end
    if self:EntIndex() == ent:EntIndex() then return false end
    if self:IsBlind() then return false end
    local range = self.SightRange*self:GetScale()
    if range <= 0 then return false end
    if self:EyePos():DistToSqr(ent:GetPos()) > range^2 then return false end
    local fov = self.SightFOV
    if fov > 360 then fov = 360 end
    if fov <= 0 then return false end
    local eyepos = self:EyePos()
    local center = ent:WorldSpaceCenter()
    local angle = math.DrG_DegreeAngle(eyepos + self:EyeAngles():Forward(), center, eyepos)
    if angle > fov/2 then return false end
    local los = false
    if ent:IsPlayer() then
      local tr = util.TraceLine({
        start = eyepos,
        endpos = ent:EyePos()
      })
      los = IsValid(tr.Entity) and tr.Entity:EntIndex() == ent:EntIndex()
    end
    if self:Visible(ent) or los then
      local res = self:OnSeeEntity(ent)
      if res ~= false then return true end
    end
    return false
  end

  net.DrG_DefineCallback("DrGBaseNextbotCanSeeEntity", function(data)
    local nextbot = Entity(data.nextbot)
    local ent = Entity(data.ent)
    if not IsValid(nextbot) then return false end
    return nextbot:CanSeeEntity(ent)
  end)

  -- Handlers --

  function ENT:_HandleLineOfSight()
    if self:IsBlind() then return end
    if CurTime() < self._DrGBaseLOSCheckDelay then return end
    self._DrGBaseLOSCheckDelay = CurTime() + 1
    for i, ent in ipairs(self:GetTargets()) do
      if ent:IsPlayer() and (not ent:Alive() or GetConVar("ai_ignoreplayers"):GetBool()) then continue end
      if self:CanSeeEntity(ent) then
        self:SpotEntity(ent)
      end
    end
  end
  function ENT:OnSeeEntity() end

  hook.Add("EntityEmitSound", "DrGBaseEntityEmitSoundHearing", function(sound)
    if not HearSounds:GetBool() then return end
    if not IsValid(sound.Entity) then return end
    if sound.Entity:IsPlayer() and
    (not sound.Entity:Alive() or GetConVar("ai_ignoreplayers"):GetBool()) then return end
    for i, ent in ipairs(DrGBase.Nextbots.GetAll()) do
      if ent:EntIndex() == sound.Entity:EntIndex() then continue end
      if ent.HearingRange == nil then continue end
      if ent.HearingRange <= 0 then continue end
      if ent:GetRangeSquaredTo(sound.Entity) <= ent.HearingRange^2 then
        local heard = ent:OnHearEntity(sound.Entity, sound)
        if heard ~= false and ent:IsTarget(sound.Entity) then ent:SpotEntity(sound.Entity) end
      end
    end
  end)
  function ENT:OnHearEntity() end

  hook.Add("EntityFireBullets", "DrGBaseEntityFireBullets", function(ent2, bullet)
    if not HearBullets:GetBool() then return end
    if not IsValid(ent2) then return end
    if ent2:IsPlayer() and
    (not ent2:Alive() or GetConVar("ai_ignoreplayers"):GetBool()) then return end
    for i, ent in ipairs(DrGBase.Nextbots.GetAll()) do
      if ent:EntIndex() == ent2:EntIndex() then continue end
      if ent.HearingRangeBullets == nil then continue end
      if ent.HearingRangeBullets <= 0 then continue end
      if ent:GetRangeSquaredTo(ent2) <= ent.HearingRangeBullets^2 then
        local heard = ent:OnHearGunshot(ent2, bullet)
        if heard ~= false and ent:IsTarget(ent2) then ent:SpotEntity(ent2) end
      end
    end
  end)
  function ENT:OnHearGunshot() end

  -- Hooks --

  local ignoreplayers = false
  hook.Add("Think", "DrGBaseNextbotIgnorePlayers", function()
    if not ignoreplayers and GetConVar("ai_ignoreplayers"):GetBool() then
      for i, ent in ipairs(DrGBase.Nextbots.GetAll()) do
        for h, ply in ipairs(player.GetAll()) do
          ent:ForgetEntity(ply)
        end
      end
    end
    ignoreplayers = GetConVar("ai_ignoreplayers"):GetBool()
  end)

else

  function ENT:CanSeeEntity(ent, callback)
    if IsValid(ent) then
      net.DrG_UseCallback("DrGBaseNextbotCanSeeEntity", {
        nextbot = self:EntIndex(), ent = ent:EntIndex()
      }, function(res)
        if not IsValid(self) then return end
        if not IsValid(ent) then callback(false)
        else callback(res) end
      end)
    else callback(false) end
  end

end
