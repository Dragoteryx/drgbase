-- Util --

function ENT:IsInRange(pos, range)
  if isentity(pos) and not IsValid(pos) then return false end
  return self:GetHullRangeSquaredTo(pos) <= range^2
end
function ENT:GetHullRangeTo(pos)
  if isentity(pos) then pos = pos:NearestPoint(self:GetPos()) end
  return self:NearestPoint(pos):Distance(pos)
end
function ENT:GetHullRangeSquaredTo(pos)
  if isentity(pos) then pos = pos:NearestPoint(self:GetPos()) end
  return self:NearestPoint(pos):DistToSqr(pos)
end

-- Misc --

function ENT:Height()
  local bound1, bound2 = self:GetCollisionBounds()
  return math.abs(bound1.z - bound2.z)
end
function ENT:Length()
  local bound1, bound2 = self:GetCollisionBounds()
  bound1.z, bound2.z = 0, 0
  return bound1:Distance(bound2)
end

local entMETA = FindMetaTable("Entity")

local old_EyePos = entMETA.EyePos
function entMETA:EyePos()
  if self.IsDrGNextbot then
    local eyepos = self:WorldSpaceCenter()
    local eyebone = self.EyeBone
    if isstring(eyebone) then eyebone = self:LookupBone(eyebone) end
    if isnumber(eyebone) then eyepos = self:GetBonePosition(eyebone) end
    return eyepos +
      self.EyeOffset.x*self:GetForward() +
      self.EyeOffset.y*self:GetRight() +
      self.EyeOffset.z*self:GetUp()
  else return old_EyePos(self) end
end

local old_EyeAngles = entMETA.EyeAngles
function entMETA:EyeAngles()
  if self.IsDrGNextbot then
    return self:GetAngles() + self.EyeAngle
  else return old_EyeAngles(self) end
end

-- Footsteps --

local DEFAULT_FOOTSTEPS = {
  [MAT_ANTLION] = {"DrGBase.AntlionFootstep"},
  [MAT_BLOODYFLESH] = {"DrGBase.BloodyFleshFootstep"},
  [MAT_CONCRETE] = {"DrGBase.ConcreteFootstep"},
  [MAT_DIRT] = {"DrGBase.DirtFootstep"},
  [MAT_EGGSHELL] = {"DrGBase.EggShellFootstep"},
  [MAT_FLESH] = {"DrGBase.FleshFootstep"},
  [MAT_GRATE] = {"DrGBase.GrateFootstep"},
  [MAT_ALIENFLESH] = {"DrGBase.AlienFleshFootstep"},
  [MAT_SNOW] = {"DrGBase.SnowFootstep"},
  [MAT_PLASTIC] = {"DrGBase.PlasticFootstep"},
  [MAT_METAL] = {"DrGBase.MetalFootstep"},
  [MAT_SAND] = {"DrGBase.SandFootstep"},
  [MAT_FOLIAGE] = {"DrGBase.FoliageFootstep"},
  [MAT_COMPUTER] = {"DrGBase.ComputerFootstep"},
  [MAT_SLOSH] = {"DrGBase.SloshFootstep"},
  [MAT_TILE] = {"DrGBase.TileFootstep"},
  [MAT_GRASS] = {"DrGBase.GrassFootstep"},
  [MAT_VENT] = {"DrGBase.VentFootstep"},
  [MAT_WOOD] = {"DrGBase.WoodFootstep"},
  [MAT_DEFAULT] = {"DrGBase.DefaultFootstep"},
  [MAT_GLASS] = {"DrGBase.GlassFootstep"},
  [MAT_WARPSHIELD] = {"DrGBase.WarpShieldFootstep"}
}

function ENT:EmitFootstep(soundLevel, pitchPercent, volume, channel, soundFlags, dsp)
  if not self:OnGround() then return end
  local tr = self:TraceLine({start = self:GetPos()+Vector(0, 0, 10), direction = -self:GetUp()*self:Height()/2})
  local sounds = self.Footsteps[tr.MatType] or DEFAULT_FOOTSTEPS[tr.MatType]
  if not istable(sounds) then sounds = self.Footsteps[MAT_DEFAULT] or DEFAULT_FOOTSTEPS[MAT_DEFAULT] end
  if not istable(sounds) or #sounds == 0 then return end
  self:EmitSound(sounds[math.random(#sounds)], soundLevel, pitchPercent, volume, channel or CHAN_BODY, soundFlags, dsp)
end

if SERVER then

  -- Attacks --

  function ENT:DealDamage(attack, fn)
    local hit = {}
    local entities = ents.GetAll()
    for i = 1, #entities do
      local ent = entities[i]
      if not IsValid(ent) then continue end
      local dmg = DamageInfo()
      
    end
    return hit
  end

  -- Misc --

  function ENT:IsInRangeAndSight(ent, range, useFOV)
    return self:IsInRange(ent, range) and self:IsAbleToSee(ent, useFOV)
  end

  function ENT:Idle(duration)
    local delay = CurTime() + duration
    while CurTime() < delay do
      if self:HasEnemy() then return false end
      if self:IsPossessed() then return false end
      if self:YieldCoroutine(true) then return false end
    end
    return true
  end

  function ENT:DirectPoseParametersAt(pos, pitch, yaw, center)
    if not isstring(yaw) then
      return self:DirectPoseParametersAt(pos, pitch.."_pitch", pitch.."_yaw", yaw)
    elseif isentity(pos) then pos = pos:WorldSpaceCenter() end
    if isvector(pos) then
      center = center or self:WorldSpaceCenter()
      local angle = (pos - center):Angle()
      self:SetPoseParameter(pitch, math.AngleDifference(angle.p, self:GetAngles().p))
      self:SetPoseParameter(yaw, math.AngleDifference(angle.y, self:GetAngles().y))
    else
      self:SetPoseParameter(pitch, 0)
      self:SetPoseParameter(yaw, 0)
    end
  end

  -- Meta --

  local old_GetVelocity = entMETA.GetVelocity
  function entMETA:GetVelocity(...)
    if self.IsDrGNextbot then
      return self.loco:GetVelocity()
    else return old_GetVelocity(self, ...) end
  end

  local old_SetVelocity = entMETA.SetVelocity
  function entMETA:SetVelocity(velocity, ...)
    if self.IsDrGNextbot then
      return self.loco:SetVelocity(velocity)
    else return old_SetVelocity(self, velocity, ...) end
  end

  local old_GetGravity = entMETA.GetGravity
  function entMETA:GetGravity(...)
    if self.IsDrGNextbot then
      return self.loco:GetGravity()
    else return old_GetGravity(self, ...) end
  end

  local old_SetGravity = entMETA.SetGravity
  function entMETA:SetGravity(gravity, ...)
    if self.IsDrGNextbot then
      return self.loco:SetGravity(gravity)
    else return old_SetGravity(self, gravity, ...) end
  end

  local old_SetPos = entMETA.SetPos
  function entMETA:SetPos(pos, ...)
    if self.IsDrGNextbot and
    not game.SinglePlayer() and
    IsValid(self:GetPhysicsObject())then
      self:PhysicsDestroy()
      local res = old_SetPos(self, pos, ...)
      self:PhysicsInitShadow()
      return res
    else return old_SetPos(self, pos, ...) end
  end

  local nextbotMETA = FindMetaTable("NextBot")

  local old_BecomeRagdoll = nextbotMETA.BecomeRagdoll
  function nextbotMETA:BecomeRagdoll(...)
    if self.IsDrGNextbot then
      return self:DrG_BecomeRagdoll(...) -- calls self:OnRagdoll
    else return old_BecomeRagdoll(self, ...) end
  end

  -- Hooks --

  function ENT:OnRagdoll(_ragdoll, _dmg) end

else

  -- Getters --

  function ENT:GetRangeTo(pos)
    if isentity(pos) then pos = pos:GetPos() end
    return self:GetPos():Distance(pos)
  end

  function ENT:GetRangeSquaredTo(pos)
    if isentity(pos) then pos = pos:GetPos() end
    return self:GetPos():DistToSqr(pos)
  end

end