ENT.Base = "drgbase_entity"
ENT.IsDrGProjectile = true

-- Misc --
ENT.PrintName = "Projectile"
ENT.Category = "DrGBase"
ENT.Models = {}
ENT.ModelScale = 1

-- Projectile --
ENT.Gravity = true
ENT.CollisionDamage = true
ENT.Physgun = false
ENT.Gravgun = false

-- Misc --
DrGBase.IncludeFile("meta.lua")

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
    self:SetModelScale(self.ModelScale)
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

  function ENT:AimAt(target, speed, feet)
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return Vector(0, 0, 0) end
    if not phys:IsGravityEnabled() then
      if isentity(target) then
        local aimAt = feet and target:GetPos() or target:WorldSpaceCenter()
        local dist = self:GetPos():Distance(aimAt)
        return self:AimAt(aimAt + target:GetVelocity()*(dist/speed), speed, feet)
      else
        local vec = self:GetPos():DrG_Direction(target):GetNormalized()*speed
        phys:SetVelocity(vec)
        return vec
      end
    else
      return self:ThrowAt(target, {
        magnitude = speed, recursive = true, maxmagnitude = speed
      }, feet)
    end
  end
  function ENT:ThrowAt(target, options, feet)
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return Vector(0, 0, 0) end
    if isentity(target) then
      local aimAt = feet and target:GetPos() or target:WorldSpaceCenter()
      local vec, info = self:GetPos():DrG_CalcTrajectory(aimAt, options)
      return self:ThrowAt(aimAt + target:GetVelocity()*info.duration, options, feet)
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
    local owner = self:GetOwner()
    if not isfunction(filter) then filter = function(ent)
      if ent == owner then return true end
      if not IsValid(owner) or not owner.IsDrGNextbot then return false end
      return owner:IsAlly(ent)
    end end
    for i, ent in ipairs(ents.FindInSphere(self:GetPos(), range)) do
      if not IsValid(ent) then continue end
      if filter(ent) then continue end
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

  -- Handlers --

  hook.Add("GravGunPickupAllowed", "DrGBaseProjectileGravgun", function(ply, ent)
    if ent.IsDrGProjectile then return ent.Gravgun or false end
  end)

  hook.Add("EntityTakeDamage", "DrGBaseProjCollisionDamage", function(ent, dmg)
    local inflictor = dmg:GetInflictor()
    if not inflictor.IsDrGProjectile then return end
    if dmg:GetDamageType() == DMG_CRUSH and not inflictor.CollisionDamage then
      return true
    end
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
