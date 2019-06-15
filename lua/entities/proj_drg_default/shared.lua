ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.IsDrGProjectile = true

-- Misc --
ENT.PrintName = "Projectile"
ENT.Category = "DrGBase"
ENT.Models = {}

-- Projectile --
ENT.Gravity = true
ENT.Physgun = false
ENT.Gravgun = false

-- Misc --
DrGBase.IncludeFile("meta.lua")

function ENT:Timer(duration, callback)
  timer.Simple(duration, function()
    if IsValid(self) then callback(self) end
  end)
end
function ENT:LoopTimer(delay, callback)
  timer.DrG_Loop(delay, function()
    if not IsValid(self) then return false end
    return callback(self)
  end)
end

function ENT:ScreenShake(amplitude, frequency, duration, radius)
  return util.ScreenShake(self:GetPos(), amplitude, frequency, duration, radius)
end

hook.Add("PhysgunPickup", "DrGBaseProjectilePhysgun", function(ply, ent)
  if ent.IsDrGProjectile then return ent.Physgun or false end
end)

if SERVER then
  AddCSLuaFile()

  function ENT:SpawnFunction(ply, tr, class)
    if not tr.Hit then return end
    local pos = tr.HitPos + tr.HitNormal*16
    local ent = ents.Create(class)
    ent:SetOwner(ply)
    ent:SetPos(pos)
    ent:Spawn()
    ent:Activate()
	  return ent
  end

  function ENT:Initialize()
    if #self.Models > 0 then
      self:SetModel(self.Models[math.random(#self.Models)])
    else self:SetModel("models/props_junk/watermelon01.mdl") end
    self._DrGBaseFilterOwner = true
    self._DrGBaseFilterAllies = false
    self:SetUseType(SIMPLE_USE)
    self:_BaseInitialize()
    self:CustomInitialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
      phys:Wake()
      phys:EnableDrag(false)
      phys:EnableGravity(tobool(self.Gravity))
    end
  end
  function ENT:_BaseInitialize() end
  function ENT:CustomInitialize() end

  function ENT:Think()
    self:_BaseThink()
    self:CustomThink()
  end
  function ENT:_BaseThink() end
  function ENT:CustomThink() end

  -- Collisions --

  function ENT:PhysicsCollide(data)
    if not data.HitEntity:IsWorld() then return end
    if not self:Filter(data.HitEntity) then return end
    self:OnContact(data.HitEntity)
  end
  function ENT:Touch(ent)
    if ent:IsWeapon() and IsValid(ent:GetOwner()) then
      local owner = ent:GetOwner()
      if not self:Filter(owner) then return end
      self:OnContact(owner)
    elseif self:Filter(ent) then
      self:OnContact(ent)
    end
  end
  function ENT:OnContact() end

  -- Filter --

  function ENT:Filter(ent)
    if not ent:IsWorld() and not IsValid(ent) then return false end
    local owner = self:GetOwner()
    if IsValid(owner) then
      if self:FilterOwner() and owner == ent then return false end
      if owner.IsDrGNextbot and self:FilterAllies() and owner:IsAlly(ent) then return false end
    end
    return self:OnFilter(ent) or false
  end
  function ENT:OnFilter(ent) return true end

  function ENT:FilterOwner(bool)
    if bool == nil then return self._DrGBaseFilterOwner
    else self._DrGBaseFilterOwner = tobool(bool) end
  end
  function ENT:FilterAllies(bool)
    if bool == nil then return self._DrGBaseFilterAllies
    else self._DrGBaseFilterAllies = tobool(bool) end
  end

  -- Helpers --

  function ENT:AimAt(target, speed)
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return Vector(0, 0, 0) end
    if not phys:IsGravityEnabled() then
      if isentity(target) then
        local aimAt = target:WorldSpaceCenter()
        local dist = self:GetPos():Distance(aimAt)
        return self:AimAt(aimAt + target:GetVelocity()*(dist/speed), speed)
      else
        local vec = self:GetPos():DrG_Direction(target):GetNormalized()*speed
        phys:SetVelocity(vec)
        return vec
      end
    else return self:ThrowAt(target, {
      magnitude = speed, recursive = true
    }) end
  end
  function ENT:ThrowAt(target, options)
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return Vector(0, 0, 0) end
    if isentity(target) then
      local vec, info = self:GetPos():DrG_CalcTrajectory(target:WorldSpaceCenter(), options)
      return self:ThrowAt(target:WorldSpaceCenter() + target:GetVelocity()*info.duration, options)
    else return phys:DrG_Trajectory(target, options) end
  end

  function ENT:DealDamage(ent, value, type)
    local dmg = DamageInfo()
    dmg:SetDamage(value)
    dmg:SetDamageForce(self:GetVelocity())
    dmg:SetDamageType(type or DMG_DIRECT)
    if IsValid(self:GetOwner()) then
      dmg:SetAttacker(self:GetOwner())
    else dmg:SetAttacker(self) end
    dmg:SetInflictor(self)
    ent:TakeDamageInfo(dmg)
  end
  function ENT:RadiusDamage(value, type, range, filter)
    for i, ent in ipairs(ents.FindInSphere(self:GetPos(), range)) do
      if not IsValid(ent) then continue end
      if isfunction(filter) and filter(ent) then continue end
      self:DealDamage(ent, value*math.Clamp((range-self:GetPos():Distance(ent:GetPos()))/range, 0, 1), type)
    end
  end

  function ENT:Explosion(damage, range, filter)
    local explosion = ents.Create("env_explosion")
    if IsValid(explosion) then
      explosion:Spawn()
      explosion:SetPos(self:GetPos())
      explosion:SetKeyValue("iMagnitude", 0)
      explosion:SetKeyValue("iRadiusOverride", 0)
      explosion:Fire("Explode", 0, 0)
    else
      local fx = EffectData()
      fx:SetOrigin(self:GetPos())
      util.Effect("Explosion", fx)
    end
    self:RadiusDamage(damage, DMG_BLAST, range, filter)
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

  -- Handlers --

  hook.Add("GravGunPickupAllowed", "DrGBaseProjectileGravgun", function(ply, ent)
    if ent.IsDrGProjectile then return ent.Gravgun or false end
  end)

else

  function ENT:Initialize()
    if self._DrGBaseInitialized then return end
    self._DrGBaseInitialized = true
    self:_BaseInitialize()
    self:CustomInitialize()
  end
  function ENT:_BaseInitialize() end
  function ENT:CustomInitialize() end

  function ENT:Think()
    self:_BaseThink()
    self:CustomThink()
  end
  function ENT:_BaseThink() end
  function ENT:CustomThink() end

  function ENT:Draw()
    self:DrawModel()
    self:_BaseDraw()
    self:CustomDraw()
  end
  function ENT:_BaseDraw() end
  function ENT:CustomDraw() end

end
