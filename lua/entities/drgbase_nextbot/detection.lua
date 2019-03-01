
-- Getters --

function ENT:IsBlind()
  return self.SightFOV <= 0 or self.SightRange <= 0
end

-- Seen by entities --

function ENT:IsSeenBy(ent)
  if not ent.IsDrGNextbot then
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
    return ent:Visible(self) or ent:VisibleVec(self:WorldSpaceCenter())
  else return ent:CanSeeEntity(self) end
end
function ENT:SeenBy(ignoreallies)
  local entities = {}
  for i, ent in ipairs(self:GetTargets()) do
    if not IsValid(ent) then continue end
    if ent:EntIndex() == self:EntIndex() then continue end
    if ignoreallies and self:IsAlly(ent) then continue end
    if self:IsSeenBy(ent) then table.insert(entities, ent) end
  end
  return entities
end
function ENT:IsSeen(ignoreallies)
  return #self:SeenBy(ignoreallies) ~= 0
end

-- Eye trace --

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

-- ConVars --

local HearSounds = CreateConVar("drgbase_hear_sounds", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
local HearBullets = CreateConVar("drgbase_hear_bullets", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

if SERVER then

  -- Sight --

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
    if self:Visible(ent) or self:VisibleVec(ent:WorldSpaceCenter()) or
    (ent:IsPlayer() and self:VisibleVec(ent:EyePos())) then
      if self:OnLOSCheck(ent) ~= false then return true end
    end
    return false
  end
  function ENT:OnLOSCheck() end

  net.DrG_DefineCallback("DrGBaseNextbotCanSeeEntity", function(data)
    local nextbot = Entity(data.nextbot)
    local ent = Entity(data.ent)
    if not IsValid(nextbot) then return false end
    return nextbot:CanSeeEntity(ent)
  end)

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

  -- Handlers --

  function ENT:_HandleLineOfSight()
    if self:IsBlind() then return end
    if CurTime() < self._DrGBaseLOSCheckDelay then return end
    self._DrGBaseLOSCheckDelay = CurTime() + 0.25
    for i, ent in ipairs(self:GetTargets()) do
      if not IsValid(ent) then continue end
      if ent:IsFlagSet(FL_NOTARGET) or
      (ent:IsPlayer() and (not ent:Alive() or GetConVar("ai_ignoreplayers"):GetBool())) then
        if self._DrGBaseLineOfSight[ent:GetCreationID()] then
          self:_Debug("lost line of sight with '"..ent:GetClass().."' ("..ent:EntIndex()..").", "drgbase_debug_los")
          self._DrGBaseLineOfSight[ent:GetCreationID()] = false
          self:OnLostSight(ent)
        end
      else
        local res = self:CanSeeEntity(ent)
        if res then
          self:SpotEntity(ent)
        end
        if res ~= self._DrGBaseLineOfSight[ent:GetCreationID()] then
          if res then
            self:_Debug("line of sight with '"..ent:GetClass().."' ("..ent:EntIndex()..").", "drgbase_debug_los")
            self:OnSight(ent)
          elseif self._DrGBaseLineOfSight[ent:GetCreationID()] ~= nil then
            self:_Debug("lost line of sight with '"..ent:GetClass().."' ("..ent:EntIndex()..").", "drgbase_debug_los")
            self:OnLostSight(ent)
          end
          self._DrGBaseLineOfSight[ent:GetCreationID()] = res
        end
      end
    end
  end
  function ENT:OnSight() end
  function ENT:OnLostSight() end

  hook.Add("EntityEmitSound", "DrGBaseEntityEmitSoundHearing", function(sound)
    if not HearSounds:GetBool() then return end
    if not IsValid(sound.Entity) then return end
    if sound.Entity:IsPlayer() and
    (not sound.Entity:Alive() or GetConVar("ai_ignoreplayers"):GetBool()) then return end
    if sound.Entity:IsFlagSet(FL_NOTARGET) then return end
    for i, ent in ipairs(DrGBase.Nextbots.GetAll()) do
      if ent:EntIndex() == sound.Entity:EntIndex() then continue end
      if ent.HearingRange == nil then continue end
      if ent.HearingRange <= 0 then continue end
      if ent:GetRangeSquaredTo(sound.Entity) <= ent.HearingRange^2 then
        local heard = ent:OnSound(sound, sound.Entity)
        if heard ~= false and ent:IsTarget(sound.Entity) then ent:SpotEntity(sound.Entity) end
      end
    end
  end)
  function ENT:OnSound() end

  hook.Add("EntityFireBullets", "DrGBaseEntityFireBullets", function(ent2, bullet)
    if not HearBullets:GetBool() then return end
    if not IsValid(ent2) then return end
    if ent2:IsPlayer() and
    (not ent2:Alive() or GetConVar("ai_ignoreplayers"):GetBool()) then return end
    if ent2:IsFlagSet(FL_NOTARGET) then return end
    for i, ent in ipairs(DrGBase.Nextbots.GetAll()) do
      if ent:EntIndex() == ent2:EntIndex() then continue end
      if ent.HearingRangeBullets == nil then continue end
      if ent.HearingRangeBullets <= 0 then continue end
      if ent:GetRangeSquaredTo(ent2) <= ent.HearingRangeBullets^2 then
        local heard = ent:OnGunshot(bullet, ent2)
        if heard ~= false and ent:IsTarget(ent2) then ent:SpotEntity(ent2) end
      end
    end
  end)
  function ENT:OnGunshot() end

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
