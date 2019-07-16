ENT.Base = "drgbase_entity"
ENT.IsDrGProjectile = true

-- Misc --
ENT.PrintName = "Projectile"
ENT.Category = "DrGBase"
ENT.Models = {}
ENT.ModelScale = 1

-- Physics --
ENT.Gravity = true
ENT.Physgun = false
ENT.Gravgun = false

-- Contact --
ENT.OnContactDelay = 0.1
ENT.OnContactDelete = -1
ENT.OnContactDecals = {}

-- Sounds --
ENT.LoopSounds = {}
ENT.OnContactSounds = {}
ENT.OnRemoveSounds = {}

-- Effects --
ENT.AttachEffects = {}
ENT.OnContactEffects = {}
ENT.OnRemoveEffects = {}

-- Misc --
DrGBase.IncludeFile("meta.lua")

-- Handlers --

hook.Add("PhysgunPickup", "DrGBaseProjectilePhysgun", function(ply, ent)
  if ent.IsDrGProjectile then return ent.Physgun or false end
end)

if SERVER then
  AddCSLuaFile()

  -- Init/Think --

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
    else
      self:SetModel("models/props_junk/watermelon01.mdl")
      self:SetNoDraw(true)
    end
    self:SetModelScale(self.ModelScale)
    self:SetUseType(SIMPLE_USE)
    self:SetTrigger(true)
    -- sounds/effects --
    self:CallOnRemove("DrGBaseOnRemoveSoundsEffects", function(self)
      if #self.OnRemoveSounds > 0 then
        self:EmitSound(self.OnRemoveSounds[math.random(#self.OnRemoveSounds)])
      end
      if #self.OnRemoveEffects > 0 then
        ParticleEffect(self.OnRemoveEffects[math.random(#self.OnRemoveEffects)], self:GetPos(), self:GetAngles())
      end
    end)
    if #self.LoopSounds > 0 then
      self._DrGBaseLoopingSound = self:StartLoopingSound(self.LoopSounds[math.random(#self.LoopSounds)])
      self:CallOnRemove("DrGBaseStopLoopingSound", function(self)
        self:StopLoopingSound(self._DrGBaseLoopingSound)
      end)
    end
    if #self.AttachEffects > 0 then
      self:ParticleEffect(self.AttachEffects[math.random(#self.AttachEffects)], true)
    end
    -- custom code --
    self:_BaseInitialize()
    self:CustomInitialize()
    -- physics --
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
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
    self:_HandleContact()
    self:_BaseThink()
    self:CustomThink()
    self:NextThink(CurTime() + engine.TickInterval())
    return true
  end
  function ENT:_BaseThink() end
  function ENT:CustomThink() end

  -- Collisions --

  function ENT:PhysicsCollide(data)
    local ent = data.HitEntity
    if not IsValid(ent) and not ent:IsWorld() then return end
    if ent:IsWorld() then
      if #self.OnContactDecals > 0 then
        util.Decal(self.OnContactDecals[math.random(#self.OnContactDecals)], data.HitPos+data.HitNormal, data.HitPos-data.HitNormal)
      end
    end
    self:Contact(ent)
  end
  function ENT:Touch(ent)
    self:Contact(ent)
  end
  function ENT:_HandleContact()
    local dir
    if self:GetVelocity():IsZero() then
      dir = Vector(0, 0, 0)
    else dir = self:GetVelocity():GetNormalized() end
    local mins, maxs = self:GetModelBounds()
    local tr = self:TraceHull(dir, {
      mins = mins*self:GetModelScale(), maxs = maxs*self:GetModelScale(),
      collisiongroup = COLLISION_GROUP_NPC
    })
    if IsValid(tr.Entity) then self:Contact(tr.Entity) end
  end

  function ENT:Contact(ent)
    if not IsValid(ent) and not ent:IsWorld() then return end
    if not isnumber(self._DrGBaseLastContact) or CurTime() > self._DrGBaseLastContact + self.OnContactDelay then
      self._DrGBaseLastContact = CurTime()
      if #self.OnContactSounds > 0 then
        self:EmitSound(self.OnContactSounds[math.random(#self.OnContactSounds)])
      end
      if #self.OnContactEffects > 0 then
        ParticleEffect(self.OnContactEffects[math.random(#self.OnContactEffects)], self:GetPos(), self:GetAngles())
      end
      self:OnContact(ent)
      if self.OnContactDelete == 0 then
        self:Remove()
      elseif self.OnContactDelete > 0 then
        self:Timer(self.OnContactDelete, self.Remove)
      end
    end
  end
  function ENT:OnContact() end

  -- Misc --

  function ENT:OnDealtDamage(ent, dmg)
    if dmg:IsDamageType(DMG_CRUSH) then return true end
  end

  -- Helpers --

  function ENT:AimAt(target, speed, feet)
    local phys = self:GetPhysicsObject()
    if not IsValid(phys) then return Vector(0, 0, 0) end
    if phys:IsGravityEnabled() then
      return self:ThrowAt(target, {
        magnitude = speed, recursive = true, maxmagnitude = speed
      }, feet)
    else
      if isentity(target) then
        local aimAt = feet and target:GetPos() or target:WorldSpaceCenter()
        local dist = self:GetPos():Distance(aimAt)
        return self:AimAt(aimAt + target:GetVelocity()*(dist/speed), speed, feet)
      else
        local vec = self:GetPos():DrG_Direction(target):GetNormalized()*speed
        phys:SetVelocity(vec)
        return vec
      end
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
    if ent == self then return end
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
      if ent == owner then return false end
      if not IsValid(owner) or not owner.IsDrGNextbot then return true end
      return not owner:IsAlly(ent)
    end end
    for i, ent in ipairs(ents.FindInSphere(self:GetPos(), range)) do
      if not IsValid(ent) then continue end
      if not filter(ent) then continue end
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

  hook.Add("EntityTakeDamage", "DrGBaseProjectilePhysicsDamage", function(ent, dmg)
    local inflictor = dmg:GetInflictor()
    if IsValid(inflictor) and inflictor.IsDrGProjectile then
      return inflictor:OnDealtDamage(ent, dmg)
    end
  end)

else

  function ENT:Initialize()
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
