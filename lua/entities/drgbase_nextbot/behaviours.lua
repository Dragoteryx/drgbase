
if SERVER then

  function ENT:Idle(duration)
    if duration == nil then return end
    if duration <= 0 then return end
    local delay = CurTime() + duration
    local targetdelay = 0
    while CurTime() < delay do
      if IsValid(self:GetEnemy()) then return end
      if self:CoroutineCallbacks() then return
      elseif self:IsPossessed() then return end
      coroutine.yield()
    end
  end

  function ENT:Attack(attacks, onattack, cooldown)
    if self._DrGBaseAttacking then return end
    if onattack == nil then onattack = function() end end
    if cooldown ~= nil and cooldown > 0 then
      table.insert(attacks, {
        delay = cooldown, _cooldown = true
      })
    end
    table.sort(attacks, function(attack1, attack2)
      local delay1 = attack1.delay or 0
      local delay2 = attack2.delay or 0
      return delay1 < delay2
    end)
    for i, attack in ipairs(attacks) do
      self._DrGBaseAttacking = true
      attack.delay = attack.delay or 0
      attack.damage = attack.damage or 0
      attack.type = attack.damagetype or DMG_DIRECT
      attack.force = attack.force or self:GetForward()*attack.damage
      attack.reach = attack.reach or self.EnemyReach
      if attack.lineofsight == nil then attack.lineofsight = true end
      self:Timer(attack.delay, function()
        if not attack._cooldown then
          local targets = ents.FindInSphere(self:GetPos(), attack.reach)
          local hit = {}
          for i, target in ipairs(targets) do
            if (self:IsPossessed() or self:IsEnemy(target)) and
            self:GetRangeSquaredTo(target) <= math.pow(attack.reach, 2) and
            (not attack.lineofsight or self:LineOfSight(target, 90, attack.reach*2)) then
              local dmg = DamageInfo()
              dmg:SetAttacker(self)
              dmg:SetDamage(attack.damage)
              dmg:SetDamageType(attack.type)
              dmg:SetDamageForce(attack.force)
              local phys = target:GetPhysicsObject()
              if IsValid(phys) then phys:AddVelocity(attack.force) end
              target:TakeDamageInfo(dmg)
              table.insert(hit, target)
            end
          end
          onattack(hit, attack)
        end
        if i == #attacks then
          self._DrGBaseAttacking = false
        end
      end)
    end
  end

  function ENT:QuickJump(pos)
    if pos == nil then return end
    if type(pos) ~= "number" and type(pos) ~= "Vector" then pos = pos:GetPos() end
    if self:IsOnGround() then
      if type(pos) == "Vector" then
        self:FacePos(pos)
        self.loco:JumpAcrossGap(pos, util.TraceLine({
          start = self:GetPos() + Vector(0, 0, 1),
          endpos = pos + Vector(0, 0, 1),
          collisiongroup = COLLISION_GROUP_IN_VEHICLE
        }).Normal)
      elseif type(pos) == "number" then
        local jumpheight = self.loco:GetMaxJumpHeight()
        self.loco:SetJumpHeight(pos)
        self.loco:Jump()
        self.loco:SetJumpHeight(jumpheight)
      end
    end
  end

  function ENT:Jump(pos, jumping)
    self:QuickJump(pos)
    if jumping == nil then jumping = function() end end
    while not self:IsOnGround() and not self:IsDying() do
      jumping()
      coroutine.yield()
    end
  end

  function ENT:Glide(pos, options, jumping)
    options = options or {}
    if jumping == nil then jumping = function() end end
    self:Jump(pos, function()
      local velocity = self:GetVelocity()
      if velocity.z < 0 and options.buoyancy ~= nil and options.speed ~= nil then
        local forward = self:GetForward()
        forward = forward*options.speed
        forward.z = options.buoyancy + dropNullifier
        self.loco:SetVelocity(forward)
      end
      jumping(options)
    end)
  end

  function ENT:Charge(duration, callback)
    if self._DrGBaseCharging then return end
    self._DrGBaseCharging = true
    duration = duration or 3
    if duration < 0 then duration = 0 end
    if callback == nil then callback = function() end end
    if onstop == nil then onstop = function() end end
    local delay = CurTime() + duration
    local start = CurTime()
    while CurTime() < delay and not self:IsDying() do
      if callback(self._DrGBaseChargingEnt, start - CurTime(), CurTime() - delay) then break end
      self:GoForward()
      coroutine.yield()
    end
    self._DrGBaseCharging = false
  end

else



end
