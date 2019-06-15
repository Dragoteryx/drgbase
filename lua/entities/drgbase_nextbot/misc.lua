
-- Print --

function ENT:PrintPoseParameters()
  for i = 0, self:GetNumPoseParameters() - 1 do
  	local min, max = self:GetPoseParameterRange(i)
  	print(self:GetPoseParameterName(i).." "..min.." / "..max)
  end
end
function ENT:PrintAnimations()
  for i, seq in pairs(self:GetSequenceList()) do
    print(i.." - "..seq.." / "..self:GetSequenceActivityName(i))
  end
end
function ENT:PrintBones()
  for i = 0, self:GetBoneCount() - 1 do
    local bonename = self:GetBoneName(i)
    if bonename == nil then continue end
    print(i.." => "..bonename)
  end
end
function ENT:PrintAttachments()
  for i, attach in ipairs(self:GetAttachments()) do
    print(attach.id.." => "..attach.name)
  end
end
function ENT:PrintBodygroups()
  for i, group in ipairs(self:GetBodyGroups()) do
    print(group.id.." => "..group.name.." ("..group.num.." subgroups)")
  end
end

-- Getters/setters --

function ENT:GetHealthRegen()
  return self:GetNW2Float("DrGBaseHealthRegen", 0)
end

function ENT:GetScale()
  return self:GetNW2Float("DrGBaseScale", 1)
end

function ENT:GetEyeTrace()
  return util.TraceLine({
    start = self:EyePos(),
    endpos = self:EyeAngles():Forward()*999999999,
    filter = self
  })
end
function ENT:GetEyeTraceNoCursor()
  return self:GetEyeTrace()
end

function ENT:IsDown()
  return self:GetNW2Bool("DrGBaseDown")
end
function ENT:IsDying()
  return self:GetNW2Bool("DrGBaseDying")
end
function ENT:IsDead()
  return self:GetNW2Bool("DrGBaseDead") or self:IsDying()
end

function ENT:LastTouchedEntity()
  return self:GetNW2Entity("DrGBaseLastTouchedEntity")
end

-- Functions --

function ENT:Timer(delay, callback)
  timer.Simple(delay, function()
    if not IsValid(self) then return end
    return callback(self)
  end)
end
function ENT:LoopTimer(delay, callback)
  timer.DrG_Loop(delay, function()
    if not IsValid(self) then return false end
    return callback(self)
  end)
end

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

function ENT:RandomizeBodygroup(id)
  self:SetBodygroup(id, math.random(0, self:GetBodygroupCount(id)-1))
end
function ENT:RandomizeBodygroups()
  for i, bodygroup in ipairs(self:GetBodyGroups()) do
    self:RandomizeBodygroup(bodygroup.id)
  end
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

function ENT:HasPhysics()
  return IsValid(self:GetPhysicsObject())
end

function ENT:TraceLine(vec)
  local data = {}
  local center = self:OBBCenter()
  data.start = self:GetPos() + center
  data.endpos = data.start + vec
  data.mask = self:GetSolidMask()
  data.collisiongroup = self:GetCollisionGroup()
  data.filter = {self, self:GetWeapon()}
  return util.TraceLine(data)
end

function ENT:TraceHull(vec, steps)
  local bound1, bound2 = self:GetCollisionBounds()
  if bound1.z < bound2.z then
    local temp = bound1
    bound1 = bound2
    bound2 = temp
  end
  if steps then bound2.z = self.loco:GetStepHeight() end
  local data = {}
  data.start = self:GetPos()
  data.endpos = data.start + vec
  data.mask = self:GetSolidMask()
  data.collisiongroup = self:GetCollisionGroup()
  data.filter = {self, self:GetWeapon()}
  data.maxs = bound1
  data.mins = bound2
  return util.TraceHull(data)
end

function ENT:CalcFlinchProbability(dmg)
  local perc = math.Clamp(dmg:GetDamage()/self:Health()*100, 0, 100)
  return math.random(100) < perc
end

-- Hooks --

function ENT:OnExtinguish() end
function ENT:OnWaterLevelChange() end
function ENT:OnHealthChange() end
function ENT:OnMaxHealthChange() end
function ENT:OnLandInWater() end
function ENT:OnAngleChange() end

-- Handlers --

function ENT:_InitMisc()
  self._DrGBaseLoopingSounds = {}
  self._DrGBaseSlotSounds = {}
  self._DrGBaseEmitSounds = {}
  self._DrGBaseOnFire = self:IsOnFire()
  self._DrGBaseWaterLevel = self:WaterLevel()
  self._DrGBaseHealth = self:Health()
  self._DrGBaseMaxHealth = self:GetMaxHealth()
  self:AddCallback("OnAngleChange", function(self, angles)
    if self:OnAngleChange(angles) then return end
    if CLIENT then return end
    if self:HasPhysics() then return end
    self:SetAngles(Angle(0, angles.y, 0))
  end)
  if CLIENT then return end
  self:SetNW2Bool("DrGBaseOnGround", self:IsOnGround())
  self:SetHealthRegen(self.HealthRegen)
  self:LoopTimer(1, function()
    if self:IsDead() then return end
    local regen = self:GetHealthRegen()
    if regen > 0 then
      local health = self:Health() + regen
      if health > self:GetMaxHealth() then
        self:SetHealth(self:GetMaxHealth())
      else self:SetHealth(health) end
    elseif regen < 0 then
      local dmg = DamageInfo()
      dmg:SetDamage(regen)
      dmg:SetAttacker(self)
      dmg:SetInflictor(self)
      dmg:SetDamageType(DMG_DIRECT)
      self:TakeDamageInfo(dmg)
    end
  end)
  self._DrGBaseOnContactDelay = 0
  self._DrGBaseDamageMultipliers = {}
  for type, mult in pairs(self.DamageMultipliers) do
    self:SetDamageMultiplier(type, mult)
  end
  self:SetNWVarProxy("DrGBaseOnGround", function(self, name, old, new)
    if SERVER then return end
    if old and not new then
      self:OnLeaveGround()
    elseif not old and new then
      self:OnLandOnGround()
    end
  end)
end

function ENT:_HandleMisc()
  if self._DrGBaseWaterLevel ~= self:WaterLevel() then
    self:OnWaterLevelChange(self._DrGBaseWaterLevel, self:WaterLevel())
    if not self._DrGBaseOnGround and self._DrGBaseWaterLevel == 0 then
      self:OnLandInWater()
    end
    self._DrGBaseWaterLevel = self:WaterLevel()
  end
  if self._DrGBaseOnFire and not self:IsOnFire() then
    self:OnExtinguish()
  elseif not self._DrGBaseOnFire and self:IsOnFire() then
    if CLIENT then self:OnIgnite() end
  end
  self._DrGBaseOnFire = self:IsOnFire()
  if self._DrGBaseHealth ~= self:Health() then
    if SERVER then self:SetNW2Int("DrGBaseHealth", self:Health()) end
    self:OnHealthChange(self._DrGBaseHealth, self:Health())
    self._DrGBaseHealth = self:Health()
  end
  if self._DrGBaseMaxHealth ~= self:GetMaxHealth() then
    if SERVER then self:SetNW2Int("DrGBaseMaxHealth", self:GetMaxHealth()) end
    self:OnMaxHealthChange(self._DrGBaseMaxHealth, self:GetMaxHealth())
    self._DrGBaseMaxHealth = self:GetMaxHealth()
  end
  if #self.OnIdleSounds > 0 and
  ((SERVER and not self.ClientIdleSounds) or (CLIENT and self.ClientIdleSounds)) then
    local sound = self.OnIdleSounds[math.random(#self.OnIdleSounds)]
    self:EmitSlotSound("DrGBaseIdle", SoundDuration(sound) + self.IdleSoundDelay, sound)
  end
  if SERVER then
    if self:GetNW2Bool("DrGBaseOnGround") and not self:IsOnGround() then
      self:SetNW2Bool("DrGBaseOnGround", false)
    elseif not self:GetNW2Bool("DrGBaseOnGround") and self:IsOnGround() then
      self:SetNW2Bool("DrGBaseOnGround", true)
      self:InvalidatePath()
    end
  end
end

if SERVER then

  -- Getters/setters --

  function ENT:SetHealthRegen(regen)
    self:SetNW2Float("DrGBaseHealthRegen", regen)
  end

  function ENT:SetScale(scale, delta)
    self:SetNW2Float("DrGBaseScale", scale)
    self:SetModelScale(self.ModelScale*scale, delta)
    self:_HandleSpeed()
  end
  function ENT:Scale(mult, delta)
    self:SetScale(self:GetScale()*mult, delta)
  end

  function ENT:GetDamageMultiplier(type)
    return self._DrGBaseDamageMultipliers[type] or 1
  end
  function ENT:SetDamageMultiplier(type, mult)
    if not isnumber(mult) then return end
    if mult < 0 then mult = 0 end
    if mult == 1 then mult = nil end
    self._DrGBaseDamageMultipliers[type] = mult
  end

  function ENT:GetNoTarget()
    return self:IsFlagSet(FL_NOTARGET)
  end
  function ENT:SetNoTarget(bool)
    if bool then self:AddFlags(FL_NOTARGET)
    else self:RemoveFlags(FL_NOTARGET) end
  end

  -- Functions --

  function ENT:Kill(attacker, inflictor)
    self:SetHealth(0)
    local dmg = DamageInfo()
    dmg:SetAttacker(attacker or game.GetWorld())
    dmg:SetInflictor(inflictor or attacker or game.GetWorld())
    dmg:SetDamageForce(Vector(0, 0, 1))
    self:OnKilled(dmg)
  end
  function ENT:Suicide()
    self:Kill(self)
  end

  function ENT:CollisionHulls(distance, forwardOnly)
    distance = distance or 5
    if distance < 0 then distance = 0 end
    local bound1, bound2 = self:GetCollisionBounds()
    if bound1.z < bound2.z then
      local temp = bound1
      bound1 = bound2
      bound2 = temp
    end
    bound2.z = self.loco:GetStepHeight() + 1
    local center = self:GetPos() + (bound1 + bound2)/2
    center.z = self:GetPos().z
    local data = {
      start = center,
      mask = self:GetSolidMask(),
      collisiongroup = self:GetCollisionGroup(),
      filter = {self, self:GetWeapon(), self:GetEnemy()},
      maxs = bound1, mins = bound2
    }
    data.endpos = center + self:GetForward()*distance + self:GetRight()*-distance
    local trNW = util.TraceHull(data)
    data.endpos = center + self:GetForward()*distance + self:GetRight()*distance
    local trNE = util.TraceHull(data)
    if forwardOnly then
      return {
        NorthWest = trNW,
        NorthEast = trNE
      }
    else
      data.endpos = center + self:GetForward()*-distance + self:GetRight()*distance
      local trSE = util.TraceHull(data)
      data.endpos = center + self:GetForward()*-distance + self:GetRight()*-distance
      local trSW = util.TraceHull(data)
      return {
        NorthWest = trNW,
        NorthEast = trNE,
        SouthEast = trSE,
        SouthWest = trSW
      }
    end
  end

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

  function ENT:ClearLastTouchedEntity()
    return self:SetNW2Entity("DrGBaseLastTouchedEntity", nil)
  end

  function ENT:Attack(attack, callback)
    attack = attack or {}
    attack.damage = attack.damage or 0
    attack.delay = attack.delay or 0
    attack.type = attack.type or DMG_GENERIC
    attack.force = attack.force or Vector(0, 0, 0)
    attack.delay = attack.delay or 0
    attack.viewpunch = attack.viewpunch or Angle(10, 0, 0)
    attack.range = attack.range or self.MeleeAttackRange
    attack.angle = attack.angle or 90
    self:Timer(math.Clamp(attack.delay, 0, math.huge), function(self)
      local hit = {}
      for i, ent in ipairs(ents.GetAll()) do
        if ent == self then continue end
        if not IsValid(ent) then continue end
        if self:IsPossessor(ent) then continue end
        if not self:IsEnemy(ent) then continue end
        if not self:Visible(ent) then continue end
        if not self:IsInRange(ent, attack.range) then continue end
        local angle = (self:GetPos() + self:GetForward()):DrG_Degrees(ent:GetPos(), self:GetPos())
        if angle > attack.angle/2 then continue end
        local dmg = DamageInfo()
        dmg:SetAttacker(self)
        dmg:SetDamage(isfunction(attack.damage) and attack.damage(ent) or attack.damage)
        dmg:SetDamageType(attack.type)
        dmg:SetDamagePosition(self:WorldSpaceCenter())
        dmg:SetReportedPosition(self:WorldSpaceCenter())
        local force = self:GetForward()*attack.force.x +
        self:GetRight()*attack.force.y +
        self:GetUp()*attack.force.z
        dmg:SetDamageForce(force)
        ent:SetVelocity(ent:GetVelocity()+force)
        ent:TakeDamageInfo(dmg)
        if attack.viewpunch and ent:IsPlayer() then
          ent:ViewPunch(attack.viewpunch)
        end
        table.insert(hit, ent)
      end
      if isfunction(callback) then callback(self, hit) end
    end)
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

  function ENT:DynamicLight(color, radius, brightness)
    if color == nil then color = Color(255, 255, 255) end
    if not isnumber(radius) then radius = 1000 end
    radius = math.Clamp(radius, 0, math.huge)
    if not isnumber(brightness) then brightness = 1 end
    brightness = math.Clamp(brightness, 0, math.huge)
    local light = ents.Create("light_dynamic")
  	light:SetKeyValue("brightness", tostring(brightness))
  	light:SetKeyValue("distance", tostring(radius))
    light:Fire("Color", tostring(color.r).." "..tostring(color.g).." "..tostring(color.b))
  	light:SetLocalPos(self:GetPos())
  	light:SetParent(self)
  	light:Spawn()
  	light:Activate()
  	light:Fire("TurnOn", "", 0)
  	self:DeleteOnRemove(light)
    return light
  end

  function ENT:ParticleEffect(name, follow, attachment)
    if follow then
      local pattach = attachment and PATTACH_POINT_FOLLOW or PATTACH_ABSORIGIN_FOLLOW
      ParticleEffectAttach(name, pattach, self, attachment or 1)
    else
      local pattach = attachment and PATTACH_POINT or PATTACH_ABSORIGIN
      ParticleEffectAttach(name, pattach, self, attachment or 1)
    end
  end

  -- Hooks --

  function ENT:OnDoor(door, help)
    help:Open(true)
  end

  -- Handlers --

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

  function ENT:RenderOffset(offset, origin, writeZ)
    if not isvector(offset) then return end
    origin = isvector(origin) and origin or self:GetPos()
    local vec = origin + self:GetForward()*offset.x + self:GetRight()*offset.y + self:GetUp()*offset.z
    cam.Start3D()
    render.DrawLine(origin, origin+vec, DrGBase.CLR_WHITE, writeZ)
    render.DrawWireframeSphere(origin+vec, 2*self:GetScale(), 4, 4, DrGBase.CLR_ORANGE, writeZ)
    cam.End3D()
  end

  -- Hooks --

  function ENT:OnLandOnGround() end
  function ENT:OnLeaveGround() end
  function ENT:OnIgnite() end

  -- Handlers --

end
