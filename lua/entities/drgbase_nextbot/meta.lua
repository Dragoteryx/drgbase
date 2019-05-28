

local RagdollRemove = CreateConVar("drgbase_ragdoll_remove", "-1")

local entMETA = FindMetaTable("Entity")
local nextbotMETA = FindMetaTable("NextBot")

-- Entity --

local old_EyePos = entMETA.EyePos
function entMETA:EyePos()
  if self.IsDrGNextbot then
    local bound1, bound2 = self:GetCollisionBounds()
    local eyepos = self:GetPos() + (bound1 + bound2)/2
    if isstring(self.EyeBone) then
      local boneid = self:LookupBone(self.EyeBone)
      if boneid ~= nil then
        eyepos = self:GetBonePosition(boneid)
      end
    end
    eyepos = eyepos +
    self:GetForward()*self.EyeOffset.x*self:GetModelScale() +
    self:GetRight()*self.EyeOffset.y*self:GetModelScale() +
    self:GetUp()*self.EyeOffset.z*self:GetModelScale()
    return eyepos
  else return old_EyePos(self) end
end

local old_EyeAngles = entMETA.EyeAngles
function entMETA:EyeAngles()
  if self.IsDrGNextbot then
    return self:GetAngles() + self.EyeAngle
  else return old_EyeAngles(self) end
end

local old_EmitSound = entMETA.EmitSound
function entMETA:EmitSound(soundName, soundLevel, pitchPercent, volume, channel)
  if self.IsDrGNextbot then
    local res = old_EmitSound(self, soundName, soundLevel, pitchPercent, volume, channel)
    table.insert(self._DrGBaseEmitSounds, soundName)
    return res
  else return old_EmitSound(self, soundName, soundLevel, pitchPercent, volume, channel) end
end

if SERVER then

  -- Entity --

  local old_GetVelocity = entMETA.GetVelocity
  function entMETA:GetVelocity()
    if self.IsDrGNextbot then
      return self.loco:GetVelocity()
    else return old_GetVelocity(self) end
  end

  local old_SetVelocity = entMETA.SetVelocity
  function entMETA:SetVelocity(velocity)
    if self.IsDrGNextbot then
      return self.loco:SetVelocity(velocity)
    else return old_SetVelocity(self, velocity) end
  end

  -- Nextbot --

  local old_BodyMoveXY = nextbotMETA.BodyMoveXY
  function nextbotMETA:BodyMoveXY(options)
    if self.IsDrGNextbot then
      options = options or {}
      if options.rate == nil then options.rate = true end
      if options.direction == nil then options.direction = true end
      if options.frameadvance == nil then options.frameadvance = true end
      if options.rate and options.direction and options.frameadvance and
      not self:IsPlayingAnimation() and self:IsOnGround() and not self:IsClimbing() then
        return old_BodyMoveXY(self)
      else
        if options.rate and not self:IsPlayingAnimation() and
        self:IsOnGround() and not self:IsClimbing() then
          local velocity = self:GetVelocity()
          velocity.z = 0
          if not velocity:IsZero() then
            local speed = velocity:Length()
            local seqspeed = self:GetSequenceGroundSpeed(seq)
            if seqspeed ~= 0 then self:SetPlaybackRate(speed/seqspeed) end
          end
        end
        if options.direction then
          local velocity = self.loco:GetGroundMotionVector()
          local moveX = (-(velocity:DrG_Degrees(self:GetForward())-90))/45
          if moveX > 1 then moveX = 1
          elseif moveX < -1 then moveX = -1 end
          if moveX == moveX then self:SetPoseParameter("move_x", moveX) end
          local moveY = (-(velocity:DrG_Degrees(self:GetRight())-90))/45
          if moveY > 1 then moveY = 1
          elseif moveY < -1 then moveY = -1 end
          if moveY == moveY then self:SetPoseParameter("move_y", moveY) end
        end
        if options.frameadvance then
          self:FrameAdvance()
        end
      end
    else return old_BodyMoveXY(self) end
  end

  local old_BecomeRagdoll = nextbotMETA.BecomeRagdoll
  function nextbotMETA:BecomeRagdoll(dmg)
    if self.IsDrGNextbot then
      if RagdollRemove:GetFloat() ~= 0 then
        local ragdoll
        local scale = self:GetModelScale()
        local color = self:GetColor()
        local material = self:GetMaterial()
        if self:HasPhysics() then
          ragdoll = ents.Create("prop_physics")
          ragdoll:SetModel(self:GetModel())
          ragdoll:SetModelScale(scale)
          ragdoll:SetColor(color)
          ragdoll:SetMaterial(material)
          ragdoll:SetPos(self:GetPos())
          ragdoll:SetAngles(self:GetAngles())
          ragdoll:Spawn()
        else
          ragdoll = old_BecomeRagdoll(self, dmg)
          ragdoll:SetColor(color)
          ragdoll:SetMaterial(material)
        end
        if IsValid(ragdoll) then
          if not self:OnRagdoll(ragdoll) and RagdollRemove:GetFloat() > 0 then
            timer.Simple(RagdollRemove:GetFloat(), function()
              if IsValid(ragdoll) then ragdoll:Remove() end
            end)
          end
        end
        self:Remove()
        return ragdoll
      else self:Remove() end
    else return old_BecomeRagdoll(self, dmg) end
  end
  function ENT:OnRagdoll() end

else

  local old_Health = entMETA.Health
  function entMETA:Health()
    if self.IsDrGNextbot then
      return self:GetNW2Int("DrGBaseHealth", old_Health(self))
    else return old_Health(self) end
  end

  local old_GetMaxHealth = entMETA.GetMaxHealth
  function entMETA:GetMaxHealth()
    if self.IsDrGNextbot then
      return self:GetNW2Int("DrGBaseMaxHealth", old_GetMaxHealth(self))
    else return old_GetMaxHealth(self) end
  end

end
