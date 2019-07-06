
-- Convars --

local RemoveRagdolls = CreateConVar("drgbase_remove_ragdolls", "-1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
local RagdollFadeOut = CreateConVar("drgbase_ragdoll_fadeout", "3", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
local PossessTargetAll = CreateConVar("drgbase_possession_targetall", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

-- Getters/setters --

function ENT:IsInRange(pos, range)
  return self:GetHullRangeSquaredTo(pos) <= math.pow(range*self:GetScale(), 2)
end
function ENT:GetHullRangeTo(pos)
  if isentity(pos) then pos = pos:NearestPoint(self:GetPos()) end
  return self:NearestPoint(pos):Distance(pos)
end
function ENT:GetHullRangeSquaredTo(pos)
  if isentity(pos) then pos = pos:NearestPoint(self:GetPos()) end
  return self:NearestPoint(pos):DistToSqr(pos)
end

-- Functions --

function ENT:ScreenShake(amplitude, frequency, duration, radius)
  local res = util.ScreenShake(self:GetPos(), amplitude, frequency, duration, radius)
  if CLIENT then return res end
  for i, ent in ipairs(DrGBase.GetNextbots()) do
    if ent == self then continue end
    if self:IsAIDisabled() then continue end
    if self:GetRangeSquaredTo(ent) > radius^2 then continue end
    ent:OnShake(self, amplitude, frequency, duration, radius)
  end
  return res
end

function ENT:EmitSlotSound(slot, duration, soundName, soundLevel, pitchPercent, volume, channel)
  local lastSlot = self._DrGBaseSlotSounds[slot]
  if lastSlot == nil or CurTime() > lastSlot then
    self._DrGBaseSlotSounds[slot] = CurTime() + duration
    self:EmitSound(soundName, soundLevel, pitchPercent, volume, channel)
  end
end

function ENT:EmitStep(soundLevel, pitchPercent, volume, channel)
  if not self:OnGround() then return end
  local tr = util.TraceLine({
    start = self:GetPos(),
    endpos = self:GetPos() - self:GetUp()*999,
    filter = self
  })
  local sounds = self.Footsteps[tr.MatType] or DrGBase.DefaultFootsteps[tr.MatType]
  if not istable(sounds) or #sounds == 0 then sounds = self.Footsteps[MAT_DEFAULT] end
  if not istable(sounds) or #sounds == 0 then return false end
  self:EmitSound(sounds[math.random(#sounds)], soundLevel, pitchPercent, volume, channel or CHAN_BODY)
end
function ENT:EmitFootstep(...)
  return self:EmitStep(...)
end

function ENT:CalcPosDirection(pos, subs)
  local direction = "N"
  if subs then
    local angle = math.AngleDifference(self:GetAngles().y + 202.5, (pos - self:GetPos()):Angle().y) + 180
    if angle > 45 and angle <= 90 then direction = "NE"
    elseif angle > 90 and angle <= 135 then direction = "E"
    elseif angle > 135 and angle <= 180 then direction = "SE"
    elseif angle > 180 and angle <= 225 then direction = "S"
    elseif angle > 225 and angle <= 270 then direction = "SW"
    elseif angle > 270 and angle <= 315 then direction = "W"
    elseif angle > 315 and angle <= 360 then direction = "NW" end
    return direction, angle
  else
    local angle = math.AngleDifference(self:GetAngles().y + 225, (pos - self:GetPos()):Angle().y) + 180
    if angle > 90 and angle <= 180 then direction = "E"
    elseif angle > 180 and angle <= 270 then direction = "S"
    elseif angle > 270 and angle <= 360 then direction = "W" end
    return direction, angle
  end
end

function ENT:CalcFlinchProbability(dmg)
  local perc = math.Clamp(dmg:GetDamage()/self:Health()*100, 0, 100)
  return math.random(100) < perc
end

function ENT:CalcOffset(vec)
  return self:GetForward()*vec.x + self:GetRight()*vec.y + self:GetUp()*vec.z
end

function ENT:Height()
  local bound1, bound2 = self:GetCollisionBounds()
  return math.abs(bound1.z - bound2.z)
end

function ENT:RandomizeBodygroup(id)
  self:SetBodygroup(id, math.random(0, self:GetBodygroupCount(id)-1))
end
function ENT:RandomizeBodygroups()
  for i, bodygroup in ipairs(self:GetBodyGroups()) do
    self:RandomizeBodygroup(bodygroup.id)
  end
end

-- Hooks --

function ENT:OnAngleChange() end

-- Handlers --

function ENT:_InitMisc()
  self._DrGBaseSlotSounds = {}
  self:AddCallback("OnAngleChange", function(self, angles)
    if self:OnAngleChange(angles) then return end
    if CLIENT then return end
    self:SetAngles(Angle(0, angles.y, 0))
  end)
end

-- Meta --

local entMETA = FindMetaTable("Entity")

local old_EyePos = entMETA.EyePos
function entMETA:EyePos()
  if self.IsDrGNextbot then
    local bound1, bound2 = self:GetCollisionBounds()
    local eyepos = self:GetPos() + (bound1 + bound2)/2
    local boneid
    if isstring(self.EyeBone) then boneid = self:LookupBone(self.EyeBone) end
    if boneid ~= nil then eyepos = self:GetBonePosition(boneid) end
    eyepos = eyepos + self:CalcOffset(self.EyeOffset)
    return eyepos
  else return old_EyePos(self) end
end

local old_EyeAngles = entMETA.EyeAngles
function entMETA:EyeAngles()
  if self.IsDrGNextbot then
    --[[if isstring(self.EyeBone) then
      local boneid = self:LookupBone(self.EyeBone)
      if boneid ~= nil then
        local pos, angles = self:GetBonePosition(boneid)
        return self:GetAngles() + angles + self.EyeAngle
      end
    end]]
    return self:GetAngles() + self.EyeAngle
  else return old_EyeAngles(self) end
end

if SERVER then

  -- Getters/setters --

  -- Functions --

  function ENT:GroundDistance(pos, generator)
    if isentity(pos) then pos = pos:GetPos() end
    local path = Path("Follow")
    path:Compute(self, pos, generator)
    if not IsValid(path) then return -1
    else return path:GetLength() end
  end

  function ENT:RandomPos(min, max)
    if not isnumber(max) then
      max = min
      min = 0
    end
    if not navmesh.IsLoaded() then return self:GetPos() end
    local areas = {}
    for i, area in ipairs(navmesh.Find(self:GetPos(), max, max, max)) do
      local distsqr = self:GetRangeSquaredTo(area:GetCenter())
      if distsqr >= min^2 then table.insert(areas, area) end
    end
    if #areas == 0 then return self:GetPos()
    else return areas[math.random(#areas)]:GetRandomPoint() end
  end

  function ENT:Attack(attack, callback)
    attack = attack or {}
    attack.damage = attack.damage or 0
    attack.delay = attack.delay or 0
    attack.type = attack.type or DMG_GENERIC
    attack.force = attack.force or Vector(0, 0, 0)
    attack.viewpunch = attack.viewpunch or Angle(10, 0, 0)
    attack.range = attack.range or self.MeleeAttackRange
    attack.angle = attack.angle or 90
    if attack.relationships == nil then
      if self:IsPossessed() and PossessTargetAll:GetBool() then
        attack.relationships = {D_LI, D_HT, D_FR}
      else attack.relationships = {D_HT} end
    end
    if not istable(attack.relationships) then attack.relationships = {attack.relationships} end
    self:Timer(math.Clamp(attack.delay, 0, math.huge), function(self)
      local hit = {}
      for h, rel in ipairs(attack.relationships) do
        for i, ent in ipairs(self:EntitiesInCone(attack.angle, attack.range, rel)) do
          if ent == self then continue end
          if not IsValid(ent) then continue end
          if ent:IsPlayer() and ent:DrG_IsPossessing() then continue end
          if not self:Visible(ent) then continue end
          local dmg = DamageInfo()
          dmg:SetAttacker(self)
          dmg:SetDamage(isfunction(attack.damage) and attack.damage(ent) or attack.damage)
          dmg:SetDamageType(attack.type)
          dmg:SetDamagePosition(self:WorldSpaceCenter())
          dmg:SetReportedPosition(self:WorldSpaceCenter())
          if not attack.groundforce or ent:IsOnGround() then
            dmg:SetDamageForce(self:PushEntity(ent, attack.force))
          end
          ent:TakeDamageInfo(dmg)
          if attack.viewpunch and ent:IsPlayer() then
            ent:ViewPunch(attack.viewpunch)
          end
          table.insert(hit, ent)
        end
      end
      if isfunction(callback) then callback(self, hit) end
    end)
  end

  function ENT:BlastAttack(attack, callback)
    attack = attack or {}
    attack.angle = attack.angle or 360
    attack.range = attack.range or self.MeleeAttackRange
    if isnumber(attack.damage) then
      local damage = attack.damage
      attack.damage = function(ent)
        return damage*math.Clamp((attack.range-self:GetRangeTo(ent))/attack.range, 0, 1)
      end
    end
    return self:Attack(attack, callback)
  end

  function ENT:IsAttacking()
    if self:IsAttack(self:GetSequence()) then return true end
    for seq, playing in pairs(self._DrGBaseCurrentGestures) do
      if playing and self:IsAttack(seq) then return true end
    end
    return false
  end
  function ENT:IsAttack(seq)
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return false end
    if seq == -1 then return false end
    return self._DrGBaseAnimAttacks[seq] or false
  end
  function ENT:SetAttack(seq, attack)
    if isstring(seq) then seq = self:LookupSequence(seq)
    elseif not isnumber(seq) then return false end
    if seq ~= 1 then
      self._DrGBaseAnimAttacks[seq] = tobool(attack)
    end
  end

  function ENT:SequenceAttack(seq, cycle, attack, callback)
    if istable(seq) then
      for i, se in ipairs(seq) do self:SetAttack(se, true) end
    else self:SetAttack(seq, true) end
    self:SequenceEvent(seq, cycle, function(self)
      self:Attack(attack, callback)
    end)
  end

  function ENT:CreateProjectile(model, binds, class)
    local proj = DrGBase.CreateProjectile(model, binds, class)
    if not IsValid(proj) then return NULL end
    proj:SetOwner(self)
    return proj
  end

  function ENT:CollisionHulls(distance, forwardOnly)
    distance = distance or 5
    if distance < 0 then distance = 0 end
    local NW = self:TraceHull((self:GetForward()-self:GetRight()):GetNormalized()*distance, true)
    local NE = self:TraceHull((self:GetForward()+self:GetRight()):GetNormalized()*distance, true)
    if forwardOnly then
      return {
        NorthWest = NW,
        NorthEast = NE
      }
    else
      local SW = self:TraceHull((-self:GetForward()-self:GetRight()):GetNormalized()*distance, true)
      local SE = self:TraceHull((-self:GetForward()+self:GetRight()):GetNormalized()*distance, true)
      return {
        NorthWest = NW,
        NorthEast = NE,
        SouthWest = SW,
        SouthEast = SE
      }
    end
  end

  function ENT:EntitiesInCone(angle, distance, disp)
    local entities = {}
    local selfpos = self:GetPos()
    local forward = self:GetForward()
    for i, ent in ipairs(isnumber(disp) and self:GetEntities(disp) or ents.GetAll()) do
      if ent == self then continue end
      if not self:IsInRange(ent, distance) then continue end
      if (selfpos + forward):DrG_Degrees(ent:GetPos(), selfpos) <= angle/2 then
        table.insert(entities, ent)
      end
    end
    return entities
  end
  function ENT:AlliesInCone(angle, distance)
    return self:EntitiesInCone(angle, distance, D_LI)
  end
  function ENT:EnemiesInCone(angle, distance)
    return self:EntitiesInCone(angle, distance, D_HT)
  end
  function ENT:AfraidOfInCone(angle, distance)
    return self:EntitiesInCone(angle, distance, D_FR)
  end
  function ENT:NeutralInCone(angle, distance)
    return self:EntitiesInCone(angle, distance, D_NU)
  end

  function ENT:Kill(attacker, inflictor, type)
    local dmg = DamageInfo()
    dmg:SetDamage(math.huge)
    dmg:SetDamageType(type or DMG_DIRECT)
    dmg:SetDamageForce(Vector(0, 0, 1))
    dmg:SetAttacker(attacker or game.GetWorld())
    dmg:SetInflictor(inflictor or attacker or game.GetWorld())
    self:OnKilled(dmg)
  end
  function ENT:Suicide(type)
    self:Kill(self, self, type)
  end

  -- Hooks --

  function ENT:OnRagdoll() end

  -- Handlers --

  -- Meta --

  local entMETA = FindMetaTable("Entity")

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

  local nextbotMETA = FindMetaTable("NextBot")

  local old_BecomeRagdoll = nextbotMETA.BecomeRagdoll
  function nextbotMETA:BecomeRagdoll(dmg)
    if self.IsDrGNextbot then
      if util.IsValidRagdoll(self:GetModel()) and
      not dmg:IsDamageType(DMG_REMOVENORAGDOLL) and
      not self:IsDissolving() then
        local ragdoll = ents.Create("prop_ragdoll")
        if IsValid(ragdoll) then
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
          undo.ReplaceEntity(self, ragdoll)
          cleanup.ReplaceEntity(self, ragdoll)
          if not GetConVar("ai_serverragdolls"):GetBool() then
            ragdoll:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
          end
          for i = 1, self:GetBoneCount() do
        		local bone = ragdoll:GetPhysicsObjectNum(i-1)
        		if not IsValid(bone) then continue end
      			local pos, angles = self:GetBonePosition(self:TranslatePhysBoneToBone(i-1))
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
          elseif self:IsOnFire() or dmg:IsDamageType(DMG_BURN) then ragdoll:Ignite(10) end
          if not self.OnRagdoll(ragdoll, dmg) and RemoveRagdolls:GetFloat() >= 0 then
            ragdoll:Fire("fadeandremove", math.Clamp(RagdollFadeOut:GetFloat(), 0, math.huge), RemoveRagdolls:GetFloat())
          end
          self:Remove()
          return ragdoll
        else
          self:Remove()
          return NULL
        end
      else
        self:Remove()
        return NULL
      end
    else return old_BecomeRagdoll(self, dmg) end
  end

else

  -- Getters/setters --

  function ENT:GetRangeTo(pos)
    if isentity(pos) then pos = pos:GetPos() end
    return self:GetPos():Distance(pos)
  end

  function ENT:GetRangeSquaredTo(pos)
    if isentity(pos) then pos = pos:GetPos() end
    return self:GetPos():DistToSqr(pos)
  end

  -- Functions --

  function ENT:RenderOffset(offset, origin, color, writeZ)
    if not isvector(offset) then return end
    origin = isvector(origin) and origin or self:GetPos()
    local vec = self:CalcOffset(offset)
    render.DrawLine(origin, origin+vec, color, writeZ)
    render.DrawWireframeSphere(origin+vec, 2*self:GetScale(), 4, 4, color, writeZ)
  end

  -- Hooks --

  -- Handlers --

  local entMETA = FindMetaTable("Entity")

  local old_tostring = entMETA.__tostring
  function entMETA:__tostring()
    if self.IsDrGNextbot then
      return "NextBot ["..self:EntIndex().."]["..self:GetClass().."]"
    else return old_tostring(self) end
  end

end
