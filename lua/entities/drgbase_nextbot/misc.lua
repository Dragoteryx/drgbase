
function ENT:_Debug(text)
  DrGBase.Nextbot.Debug(self, text)
end

function ENT:Timer(delay, callback)
  timer.Simple(delay, function()
    if not IsValid(self) then return end
    callback()
  end)
end

function ENT:Height()
  local bound1, bound2 = self:GetCollisionBounds()
  if bound1.z > bound2.z then return bound1.z-bound2.z
  elseif bound1.z < bound2.z then return bound2.z-bound1.z
  else return 0 end
end

function ENT:Altitude()
  local tr = util.TraceLine({
    start = self:GetPos(),
    endpos = self:GetPos() - Vector(0, 0, 999999),
    collisiongroup = COLLISION_GROUP_IN_VEHICLE
  })
  if tr.HitWorld then return self:GetPos().z - tr.HitPos.z
  else return 0 end
end

function ENT:IsDying()
  return self:GetDrGVar("DrGBaseDying")
end

function ENT:IsDead()
  return self:IsDying() or self:GetDrGVar("DrGBaseDead")
end

function ENT:CombineBall(value)
  if CLIENT then return self:GetDrGVar("DrGBaseCombineBall")
  elseif isstring(value) then self:SetDrGVar("DrGBaseCombineBall", value)
  else return self:GetDrGVar("DrGBaseCombineBall") end
end

function ENT:AnglePos(pos)
  return DrGBase.Math.VectorsAngle(self:GetPos() + self:GetForward(), pos, self:GetPos())
end

function ENT:AngleEntity(ent)
  return self:AnglePos(ent:GetPos())
end

function ENT:DrG_EyePos()

end

if SERVER then

  function ENT:RandomPos(maxradius, minradius)
    local pos = DrGBase.Utils.RandomPos(self:GetPos(), maxradius, minradius)
    if pos == nil then return self:GetPos()
    else return pos end
  end

  function ENT:Explode(options)
    options = options or {}
    if options.remove == nil then options.remove = true end
    options.owner = self
    local pos = self:GetPos()
    if options.remove then self:Remove() end
    DrGBase.Utils.Explosion(pos, options)
  end

  function ENT:Kill(attacker, inflictor)
    local dmg = DamageInfo()
    dmg:SetDamage(self:Health())
    if attacker ~= nil then dmg:SetAttacker(attacker) end
    if inflictor ~= nil then dmg:SetInflictor(inflictor) end
    self:TakeDamageInfo(dmg)
  end

  hook.Add("PhysgunDrop", "DrGBaseNextbotPhysgunDrop", function(ply, ent)
    if not ent.IsDrGNextbot then return end
    ent:InvalidatePath()
    ent:Timer(0, function()
      ent.loco:SetVelocity(Vector(0, 0, 0))
    end)
  end)

  -- Handlers --

  function ENT:_HandleHealthRegen()
    if CurTime() < self._DrGBaseHealthRegenDelay then return end
    self._DrGBaseHealthRegenDelay = CurTime() + (1/self.HealthRegen)
    local health = self:Health() + 1
    if health < 0 then health = 0 end
    if health > self:GetMaxHealth() then health = self:GetMaxHealth() end
    self:SetHealth(health)
  end

else

  function ENT:GetRangeTo(pos)
    if type(pos) ~= "Vector" then pos = pos:GetPos() end
    return self:GetPos():Distance(pos)
  end
  function ENT:GetRangeSquaredTo(pos)
    if type(pos) ~= "Vector" then pos = pos:GetPos() end
    return self:GetPos():DistToSqr(pos)
  end

end
