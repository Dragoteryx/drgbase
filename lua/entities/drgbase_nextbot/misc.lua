
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
  data.endpos = self:GetPos() + center + vec
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

-- Hooks --

function ENT:OnExtinguish() end
function ENT:OnWaterLevelChange() end
function ENT:OnHealthChange() end
function ENT:OnMaxHealthChange() end
function ENT:OnLandInWater() end

-- Handlers --

function ENT:_InitMisc()
  self._DrGBaseLoopingSounds = {}
  self._DrGBaseSlotSounds = {}
  self._DrGBaseEmitSounds = {}
  self._DrGBaseOnGround = self:IsOnGround()
  self._DrGBaseOnFire = self:IsOnFire()
  self._DrGBaseWaterLevel = self:WaterLevel()
  self._DrGBaseHealth = self:Health()
  self._DrGBaseMaxHealth = self:GetMaxHealth()
  if CLIENT then return end
  self:SetHealthRegen(self.HealthRegen)
  self:LoopTimer(1, function()
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
  self:AddCallback("OnAngleChange", function(self, angles)
    if self:HasPhysics() then return end
    self:SetAngles(Angle(0, angles.y, 0))
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
  if self._DrGBaseOnGround and not self:IsOnGround() then
    if CLIENT then self:OnLeaveGround() end
  elseif not self._DrGBaseOnGround and self:IsOnGround() then
    if CLIENT then self:OnLandOnGround() end
    self:InvalidatePath()
  end
  self._DrGBaseOnGround = self:IsOnGround()
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
end

if SERVER then

  -- Getters/setters --

  function ENT:SetHealthRegen(regen)
    self:SetNW2Float("DrGBaseHealthRegen", regen)
  end

  function ENT:SetScale(scale)
    self:SetNW2Float("DrGBaseScale", scale)
    self:SetModelScale(self.ModelScale*scale)
    self:_HandleSpeed()
  end
  function ENT:Scale(mult)
    self:SetScale(self:GetScale()*mult)
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

  -- Hooks --

  function ENT:OnLandOnGround() end
  function ENT:OnLeaveGround() end
  function ENT:OnIgnite() end

  -- Handlers --

end
