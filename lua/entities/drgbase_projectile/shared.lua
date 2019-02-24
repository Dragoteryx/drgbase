ENT.Type = "anim"
ENT.Base = "base_entity"
ENT.IsDrGProjectile = true

ENT.PrintName = "DrGBase Base Projectile"
ENT.Category = "DrGBase"

DrGBase.IncludeFile("meta.lua")

if SERVER then
  AddCSLuaFile("shared.lua")

  function ENT:Initialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetUseType(SIMPLE_USE)
    local phys = self:GetPhysicsObject()
    if IsValid(phys) then
      phys:Wake()
      phys:EnableDrag(false)
    end
  end
  function ENT:Think()
    return self:ProjThink()
  end
  function ENT:ProjThink() end

  -- Collisions --

  function ENT:PhysicsCollide(data)
    if not data.HitEntity:IsWorld() then return end
    if not self:ProjFilter(data.HitEntity) then return end
    self:ProjContact(data.HitEntity)
  end
  function ENT:Touch(ent)
    if not self:ProjFilter(ent) then return end
    if ent:IsWeapon() then
      if IsValid(ent:GetOwner()) then self:ProjContact(ent:GetOwner())
      else self:ProjContact(ent) end
    else self:ProjContact(ent) end
  end
  function ENT:ProjFilter() return true end
  function ENT:ProjContact() end

  -- Misc --

  function ENT:Use(activator, caller, useType, value)
    return self:ProjUse(activator, caller, useType, value)
  end
  function ENT:ProjUse() end
  function ENT:OnTakeDamage(dmg)
    return self:ProjDamage(dmg)
  end
  function ENT:ProjDamage() end
  function ENT:OnRemove()
    self:ProjRemove()
  end
  function ENT:ProjRemove() end

  -- Helpers --

  function ENT:ParabolicTrajectory(pos, options)
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return Vector(0, 0, 0)
    else return phys:DrG_ParabolicTrajectory(pos, options) end
  end

  function ENT:DirectTrajectory(pos, options)
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return Vector(0, 0, 0)
    else return phys:DrG_DirectTrajectory(pos, options) end
  end

  function ENT:DealDamage(ent, value, type)
    local dmg = DamageInfo()
    dmg:SetDamage(value)
    dmg:SetDamageForce(self:GetVelocity())
    dmg:SetDamageType(type or DMG_DIRECT)
    if IsValid(self._DrGBaseNextbot) then
      dmg:SetAttacker(self._DrGBaseNextbot)
    else dmg:SetAttacker(game.GetWorld()) end
    dmg:SetInflictor(self)
    ent:TakeDamageInfo(dmg)
  end

else

  function ENT:Draw()
    self:DrawModel()
  end

end
