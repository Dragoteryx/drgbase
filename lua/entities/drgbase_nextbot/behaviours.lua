
if SERVER then

  -- Movement --

  function ENT:Idle(duration, callback)
    if duration == nil then return end
    if duration <= 0 then return end
    if callback == nil then callback = function() end end
    local delay = CurTime() + duration
    local targetdelay = 0
    local now = CurTime()
    while CurTime() < delay do
      if callback(CurTime() - now) then return end
      if IsValid(self:GetEnemy()) then return end
      if self:CoroutineCallbacks() then return end
      if self:IsPossessed() then return end
      coroutine.yield()
    end
  end

  function ENT:QuickJump(pos)
    if not self:IsOnGround() then return end
    if isvector(pos) then
      self:FacePos(pos)
      self.loco:JumpAcrossGap(pos, util.TraceLine({
        start = self:GetPos() + Vector(0, 0, 1),
        endpos = pos + Vector(0, 0, 1),
        collisiongroup = COLLISION_GROUP_IN_VEHICLE
      }).Normal)
    elseif isnumber(pos) then
      local jumpheight = self.loco:GetMaxJumpHeight()
      self.loco:SetJumpHeight(pos*self:GetScale())
      self.loco:Jump()
      self.loco:SetJumpHeight(jumpheight)
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
        forward = forward*options.speed*self:GetScale()
        forward.z = options.buoyancy*self:GetScale()
        self.loco:SetVelocity(forward)
      end
      jumping(options)
    end)
  end

  function ENT:Charge(speed, callback)
    if self._DrGBaseCharging then return end
    self._DrGBaseCharging = true
    local speedfetch = self:EnableSpeedFetch()
    self:EnableSpeedFetch(false)
    if speed ~= nil then self:SetSpeed(speed) end
    if callback == nil then callback = function() end end
    local now = CurTime()
    while true and not self:IsDying() do
      if callback(CurTime() - now, self._DrGBaseChargingEnt) then break end
      self:GoForward()
      coroutine.yield()
    end
    self:EnableSpeedFetch(speedfetch)
    self._DrGBaseCharging = false
    self._DrGBaseChargingEnt = nil
  end

  -- Attacks --

  function ENT:Attack(attacks, options, onattack)
    if self._DrGBaseAttacking then return end
    options = options or {}
    if options.cooldown ~= nil and options.cooldown > 0 then
      table.insert(attacks, {
        delay = options.cooldown, _cooldown = true
      })
    end
    if onattack == nil then onattack = function() end end
    table.sort(attacks, function(attack1, attack2)
      local delay1 = attack1.delay or 0
      local delay2 = attack2.delay or 0
      return delay1 < delay2
    end)
    for i, attack in ipairs(attacks) do
      self._DrGBaseAttacking = true
      attack.delay = attack.delay or 0
      attack.damage = attack.damage or 0
      attack.type = attack.type or DMG_DIRECT
      attack.force = attack.force or self:GetForward()*attack.damage
      attack.range = attack.range or self.EnemyReach
      attack.angle = attack.angle or 90
      if attack.lineofsight == nil then attack.lineofsight = true end
      self:Timer(attack.delay, function()
        if not attack._cooldown then
          local targets = ents.FindInSphere(self:GetPos(), attack.range*self:GetScale())
          local hit = {}
          for i, target in ipairs(targets) do
            if target:EntIndex() == self:EntIndex() then continue end
            if self:IsPossessed() and self:GetPossessor():EntIndex() == target:EntIndex() then continue end
            if self:IsAlly(target) and (not attack.friendlyfire or self:IsPossessed()) then continue end
            if self:AngleEntity(target) > attack.angle/2 then continue end
            if attack.lineofsight and not self:LineOfSight(target) then continue end
            local dmg = DamageInfo()
            dmg:SetAttacker(self)
            dmg:SetDamage(attack.damage)
            dmg:SetDamageType(attack.type)
            dmg:SetDamageForce(attack.force)
            target:TakeDamageInfo(dmg)
            table.insert(hit, target)
          end
          onattack(hit, i, attack)
        end
        if i == #attacks then
          self._DrGBaseAttacking = false
        end
      end)
    end
    if options.sequence ~= nil then
      if options.gesture then self:PlayGesture(options.sequence, options.rate)
      else self:PlaySequenceAndWait(options.sequence, options.rate) end
    end
  end

  function ENT:DefineAttack(name, attacks, options, onattack)
    self._DrGBaseDefinedAttacks[name] = {
      attacks = attacks,
      options = options,
      onattack = onattack
    }
  end

  function ENT:RemoveAttack(name)
    self._DrGBaseDefinedAttacks[name] = nil
  end

  function ENT:CallAttack(name)
    local attack = self._DrGBaseDefinedAttacks[name]
    if attack == nil then return end
    self:Attack(attack.attacks, attack.options, attack.onattack)
  end

  function ENT:CallRandomAttack()
    if #self._DrGBaseDefinedAttacks == 0 then return end
    local attack, name = table.Random(self._DrGBaseDefinedAttacks)
    self:CallAttack(name)
  end

else



end
