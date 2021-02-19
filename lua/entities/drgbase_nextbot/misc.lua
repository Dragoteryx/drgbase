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

function ENT:ScaleModel(mult, delta)
  self:SetModelScale(self:GetModelScale()*mult, delta)
end

local entMETA = FindMetaTable("Entity")

local EyePos = entMETA.EyePos
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
  else return EyePos(self) end
end

local EyeAngles = entMETA.EyeAngles
function entMETA:EyeAngles()
  if self.IsDrGNextbot then
    return self:GetAngles() + self.EyeAngle
  else return EyeAngles(self) end
end

-- Footsteps --

ENT.Footsteps = {
  [MAT_ANTLION] = "DrGBase.AntlionFootstep",
  [MAT_BLOODYFLESH] = "DrGBase.BloodyFleshFootstep",
  [MAT_CONCRETE] = "DrGBase.ConcreteFootstep",
  [MAT_DIRT] = "DrGBase.DirtFootstep",
  [MAT_EGGSHELL] = "DrGBase.EggShellFootstep",
  [MAT_FLESH] = "DrGBase.FleshFootstep",
  [MAT_GRATE] = "DrGBase.GrateFootstep",
  [MAT_ALIENFLESH] = "DrGBase.AlienFleshFootstep",
  [MAT_SNOW] = "DrGBase.SnowFootstep",
  [MAT_PLASTIC] = "DrGBase.PlasticFootstep",
  [MAT_METAL] = "DrGBase.MetalFootstep",
  [MAT_SAND] = "DrGBase.SandFootstep",
  [MAT_FOLIAGE] = "DrGBase.FoliageFootstep",
  [MAT_COMPUTER] = "DrGBase.ComputerFootstep",
  [MAT_SLOSH] = "DrGBase.SloshFootstep",
  [MAT_TILE] = "DrGBase.TileFootstep",
  [MAT_GRASS] = "DrGBase.GrassFootstep",
  [MAT_VENT] = "DrGBase.VentFootstep",
  [MAT_WOOD] = "DrGBase.WoodFootstep",
  [MAT_DEFAULT] = "DrGBase.DefaultFootstep",
  [MAT_GLASS] = "DrGBase.GlassFootstep",
  [MAT_WARPSHIELD] = "DrGBase.WarpShieldFootstep"
}

function ENT:OnFootstep(matType)
  return self.Footsteps[matType]
end

function ENT:EmitFootstep(soundLevel, pitchPercent, volume, channel, soundFlags, dsp)
  if not self:OnGround() then return end
  local tr = self:TraceLine({start = self:WorldSpaceCenter(), direction = -self:GetUp()*self:Height()})
  local footstep = self:OnFootstep(tr.MatType)
  if not isstring(footstep) and not istable(footstep) then footstep = self:OnFootstep(MAT_DEFAULT) end
  if istable(footstep) and #footstep > 0 then
    self:EmitSound(footstep[math.random(#footstep)], soundLevel, pitchPercent, volume, channel or CHAN_BODY, soundFlags, dsp)
  elseif isstring(footstep) then
    self:EmitSound(footstep, soundLevel, pitchPercent, volume, channel or CHAN_BODY, soundFlags, dsp)
  end
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
      if self:IsAIDisabled() then return false end
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

  -- Jump --

  local function LocoJump(self)
    local seq = self:GetSequence()
    local cycle = self:GetCycle()
    self.loco:Jump()
    self:ResetSequence(seq)
    self:SetCycle(cycle)
  end
  local function LocoJumpGap(self, pos)
    local seq = self:GetSequence()
    local cycle = self:GetCycle()
    self.loco:JumpAcrossGap(pos, self:GetForward())
    self:ResetSequence(seq)
    self:SetCycle(cycle)
  end

  function ENT:LeaveGround()
    if not self:IsOnGround() then return end
    local height = self.loco:GetJumpHeight()
    self.loco:SetJumpHeight(1)
    LocoJump(self)
    self.loco:SetJumpHeight(height)
  end

  function ENT:Jump(height, fn, ...)
    if not self:IsOnGround() then return end
    if isnumber(height) then
      local oldHeight = self.loco:GetJumpHeight()
      self.loco:SetJumpHeight(height)
      LocoJump(self)
      self.loco:SetJumpHeight(oldHeight)
    elseif isvector(height) then
      LocoJumpGap(self, height)
    else LocoJump(self) end
    local args, n = table.DrG_Pack(...)
    local function Jumping(self)
      while not self:IsOnGround() do
        if isfunction(fn) and fn(self, table.DrG_Unpack(args, n)) then break end
        if self:InCoroutine() and self:YieldCoroutine(true) then break
        else coroutine.yield() end
      end
    end
    if not self:InCoroutine() then
      self:ParallelCoroutine(Jumping)
    else Jumping(self) end
  end

  -- Meta --

  local SetPos = entMETA.SetPos
  function entMETA:SetPos(pos, ...)
    if self.IsDrGNextbot and
    not game.SinglePlayer() and
    IsValid(self:GetPhysicsObject())then
      self:PhysicsDestroy()
      local res = SetPos(self, pos, ...)
      self:PhysicsInitShadow()
      return res
    else return SetPos(self, pos, ...) end
  end

  local nextbotMETA = FindMetaTable("NextBot")

  local BecomeRagdoll = nextbotMETA.BecomeRagdoll
  function nextbotMETA:BecomeRagdoll(...)
    if self.IsDrGNextbot then
      return self:DrG_BecomeRagdoll(...) -- calls self:OnRagdoll
    else return BecomeRagdoll(self, ...) end
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