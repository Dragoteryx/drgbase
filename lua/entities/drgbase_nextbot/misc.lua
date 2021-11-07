-- Util --

function ENT:IsInRange(pos, range)
  if isentity(pos) and not IsValid(pos) then return false end
  return self:GetHullRangeSquaredTo(pos) <= (range*self:GetModelScale())^2
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
function entMETA:EyePos(...)
  if self.IsDrGNextbot then
    local eyepos = self:WorldSpaceCenter()
    local eyebone = self.EyeBone
    if isstring(eyebone) then eyebone = self:LookupBone(eyebone) end
    if isnumber(eyebone) then eyepos = self:GetBonePosition(eyebone) end
    return eyepos +
      self.EyeOffset.x*self:GetForward() +
      self.EyeOffset.y*self:GetRight() +
      self.EyeOffset.z*self:GetUp()
  else return EyePos(self, ...) end
end

local EyeAngles = entMETA.EyeAngles
function entMETA:EyeAngles(...)
  if self.IsDrGNextbot then
    return self:GetAngles() + self.EyeAngle
  else return EyeAngles(self, ...) end
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

  function ENT:MeleeAttack(attack, fn)
    local hit = {}
    if not istable(attack) then attack = {} end
    if not isnumber(attack.angle) then attack.angle = 90 end
    if not isnumber(attack.range) then attack.range = self.MeleeAttackRange end
    if not istable(attack.relationships) then
      if self:IsPossessed() then
        attack.relationships = {D_LI, D_HT, D_FR}
      else attack.relationships = {D_HT, D_FR} end
    end
    local iterators = {}
    if table.HasValue(attack.relationships, D_LI) then
      table.insert(iterators, self:AllyIterator()) end
    if table.HasValue(attack.relationships, D_HT) then
      table.insert(iterators, self:EnemyIterator()) end
    if table.HasValue(attack.relationships, D_FR) then
      table.insert(iterators, self:AfraidOfIterator()) end
    if table.HasValue(attack.relationships, D_NU) then
      table.insert(iterators, self:NeutralIterator()) end
    for ent in util.DrG_MergeIterators(iterators) do
      if not self:Visible(ent) then continue end
      if attack.angle < 360 and self:GetPos():DrG_Degrees(self:GetPos() + self:GetForward(), ent:GetPos()) > attack.angle then continue end
      if self:GetHullRangeSquaredTo(ent) > attack.range^2 then continue end
      local dmg = DamageInfo()
      dmg:SetAttacker(self)
      dmg:SetInflictor(attack.inflictor or self)
      dmg:SetDamagePosition(self:GetPos())
      dmg:SetReportedPosition(self:GetPos())
      if isnumber(attack.damage) then dmg:SetDamage(attack.damage) end
      if isnumber(attack.type) then dmg:SetDamageType(attack.type) end
      if isvector(attack.force) then dmg:SetDamageForce(Vector(
        attack.force.x*self:GetForward(),
        attack.force.y*self:GetRight(),
        attack.force.z*self:GetUp()
      ):GetNormalized()*attack.force:Length()) end
      if not isfunction(fn) or fn(self, ent, dmg) ~= false then
        if isangle(attack.viewpunch) and ent:IsPlayer() then ent:ViewPunch(attack.viewpunch) end
        if attack.push then
          if ent:IsPlayer() then ent:SetVelocity(dmg:GetDamageForce())
          else ent:SetVelocity(ent:GetVelocity() + dmg:GetDamageForce()) end
        end
        ent:TakeDamageInfo(dmg)
        table.insert(hit, ent)
      end
    end
    return hit
  end

  function ENT:RadialAttack(attack, fn)
    if not istable(attack) then attack = {} end
    attack.angle = 360
    return self:MeleeAttack(attack, function(self, ent, dmg)
      local fallOff = math.Clamp(1 - self:GetHullRangeTo(ent)/attack.range, 0, 1)
      dmg:SetDamage(dmg:GetDamage()*fallOff)
      dmg:SetDamageForce(dmg:GetDamageForce()*fallOff)
      if isfunction(fn) then return fn(self, ent, dmg) end
    end)
  end

  -- Misc --

  function ENT:IsInRangeAndSight(ent, range, useFOV)
    return self:IsInRange(ent, range) and self:IsAbleToSee(ent, useFOV)
  end

  function ENT:Idle(duration, fn, ...)
    local delay = CurTime() + duration
    while CurTime() < delay do
      if self:HasEnemy() then return false end
      if self:IsPossessed() then return false end
      if self:IsAIDisabled() then return false end
      if isfunction(fn) then
        local res = fn(self,...)
        if res ~= nil then return res end
      end
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

  function ENT:LeaveGround()
    if not self:IsOnGround() then return end
    local height = self.loco:GetJumpHeight()
    self.loco:SetJumpHeight(1)
    LocoJump(self)
    self.loco:SetJumpHeight(height)
  end

  function ENT:Jump(target, fn, ...)
    if not self:IsOnGround() then return false end
    if isnumber(target) then
      local height = self.loco:GetJumpHeight()
      self:SetJumpHeight(target)
      LocoJump(self)
      self:SetJumpHeight(height)
    elseif isvector(target) or isentity(target) then
      local vel, info = self:GetPos():DrG_CalcBallisticTrajectory(target, {magnitude = 1, gravity = self:GetGravity()}, true)
      if vel.z < 0 then
        vel, info = self:GetPos():DrG_CalcBallisticTrajectory(target, {magnitude = 1, gravity = self:GetGravity(), highest = true}, true)
      end
      DrG_DebugTrajectory(self:GetPos(), vel, info)
      self:SetVelocity(vel)
    else return LocoJump(self) end
    local args, n = table.DrG_Pack(...)
    local function Jumping(self)
      while not self:IsOnGround() do
        if isfunction(fn) then
          local res = fn(self, table.DrG_Unpack(args, n))
          if res ~= nil then return res end
        end
        if self:InCoroutine() then
          if self:YieldCoroutine(true) then return false end
        else coroutine.yield() end
      end
    end
    if not self:InCoroutine() then
      self:ParallelCoroutine(Jumping)
      return true
    else return Jumping(self) end
  end

  function ENT:Glide(vel, fn, ...)
    local gravity = self:GetGravity()
    self:SetGravity(0)
    while not self:IsOnGround() do
      self:SetVelocity((
        self:GetForward()*vel.x +
        self:GetRight()*vel.y +
        self:GetUp()*vel.z
      ):GetNormalized()*vel:Length())
      if isfunction(fn) then
        local res = fn(self, ...)
        if res ~= nil then
          self:SetGravity(gravity)
          return res
        end
      end
      if self:YieldCoroutine(true) then
        self:SetGravity(gravity)
        return false
      end
    end
    self:SetGravity(gravity)
    return true
  end

  function ENT:JumpThenGlide(jump, glide, fn, ...)
    local res = self:Jump(jump, function(self, ...)
      if self:GetVelocity().z < 0 then return "glide" end
      if isfunction(fn) then return fn(self, ...) end
    end, ...)
    if res == "glide" then
      return self:Glide(glide, fn, ...)
    else return res end
  end

  -- Meta --

  local SetPos = entMETA.SetPos
  function entMETA:SetPos(pos, ...)
    if self.IsDrGNextbot and not game.SinglePlayer()
    and IsValid(self:GetPhysicsObject()) then
      self:PhysicsDestroy()
      local res = SetPos(self, pos, ...)
      self:PhysicsInitShadow()
      return res
    else return SetPos(self, pos, ...) end
  end

  local nbMETA = FindMetaTable("NextBot")

  local BecomeRagdoll = nbMETA.BecomeRagdoll
  function nbMETA:BecomeRagdoll(...)
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