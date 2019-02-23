
if SERVER then

  -- Movement --

  function ENT:IsIdling()
    return self._DrGBaseIdling or false
  end
  function ENT:Idle(duration, callback)
    if duration == nil then return end
    if duration <= 0 then return end
    if callback == nil then callback = function() end end
    local delay = CurTime() + duration
    local targetdelay = 0
    local now = CurTime()
    self._DrGBaseIdling = true
    while CurTime() < delay do
      if callback(CurTime() - now) then break end
      if IsValid(self:GetEnemy()) then break end
      if self:CoroutineCallbacks() then break end
      if self:IsPossessed() then break end
      if self:IsFlying() then self:FlightHover() end
      coroutine.yield()
    end
    self._DrGBaseIdling = false
  end

  function ENT:QuickJump(pos)
    if not self:IsOnGround() then return end
    pos = pos or self.loco:GetMaxJumpHeight()
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
      if velocity.z < 0 and options.pitch ~= nil and options.speed ~= nil then
        local forward = self:GetForward()
        forward.z = -math.tan(math.rad(options.pitch))
        forward:Normalize()
        self:SetVelocity(forward*options.speed*self:GetScale())
      end
      jumping(options)
    end)
  end

  function ENT:IsCharging()
    return self._DrGBaseCharging or false
  end
  function ENT:Charge(speed, callback)
    if self:IsFlying() then return end
    if self:IsCharging() then return end
    self._DrGBaseCharging = true
    local speedfetch = self:EnableUpdateSpeed()
    self:EnableUpdateSpeed(false)
    local blockyaw = self:PossessionBlockYaw()
    self:PossessionBlockYaw(true)
    if speed ~= nil then self:SetSpeed(speed) end
    if callback == nil then callback = function() end end
    local now = CurTime()
    while true and not self:IsDying() do
      if callback(CurTime() - now, self._DrGBaseChargingEnt) then break end
      self._DrGBaseChargingEnt = nil
      self:GoForward()
      coroutine.yield()
    end
    self:EnableUpdateSpeed(speedfetch)
    self:PossessionBlockYaw(blockyaw)
    self._DrGBaseChargingEnt = nil
    self._DrGBaseCharging = false
  end

  -- Attacks --

  function ENT:IsAttacking()
    return self._DrGBaseAttacking or false
  end
  function ENT:Attack(attacks, options, onattack)
    if self:IsAttacking() then return end
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
      if attack.delay < 0 then attack.delay = 0 end
      attack.damage = attack.damage or 0
      attack.type = attack.type or DMG_GENERIC
      attack.force = attack.force or Vector(attack.damage)
      attack.range = attack.range or self.EnemyReach
      attack.angle = attack.angle or 90
      self:Timer(attack.delay, function()
        if not attack._cooldown then
          local hit = {}
          local collateral = {}
          for i, target in ipairs(ents.FindInSphere(self:GetPos(), attack.range*self:GetScale())) do
            if target:EntIndex() == self:EntIndex() then continue end
            if self:IsPossessed() and self:GetPossessor():EntIndex() == target:EntIndex() then continue end
            if self:IsAlly(target) and (not attack.friendlyfire or self:IsPossessed()) then continue end
            if self:AngleEntity(target) > attack.angle/2 then continue end
            if not self:Visible(target) then continue end
            local damage
            if attack.healthpercentage ~= nil then damage = target:Health()*attack.healthpercentage end
            if damage == nil or damage < attack.damage then damage = attack.damage end
            local dmg = DamageInfo()
            dmg:SetAttacker(self)
            dmg:SetDamage(damage)
            dmg:SetDamageType(attack.type)
            dmg:SetReportedPosition(self:WorldSpaceCenter())
            if attack.viewpunch and target:IsPlayer() then
              target:ViewPunch(attack.viewpunch)
            end
            local force = self:GetForward()*attack.force.x +
            self:GetRight()*attack.force.y +
            self:GetUp()*attack.force.z
            dmg:SetDamageForce(force)
            target:SetVelocity(target:GetVelocity() + force)
            local phys = target:GetPhysicsObject()
            if IsValid(phys) then phys:AddVelocity(force) end
            target:TakeDamageInfo(dmg)
            if self:IsTarget(target) then table.insert(hit, target)
            else table.insert(collateral, target) end
          end
          onattack(hit, i, attack, collateral)
        end
        if i == #attacks then
          self._DrGBaseAttacking = false
        end
      end)
    end
    if options.animation ~= nil then
      local animation = options.animation
      if istable(animation) then
        if #animation == 0 then return end
        animation = animation[math.random(#animation)]
      end
      if options.gesture then self:PlayAnimation(animation, options.rate)
      elseif options.movement then self:PlayAnimationAndMove(animation, options.rate)
      else self:PlayAnimationAndWait(animation, options.rate) end
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
    if table.Count(self._DrGBaseDefinedAttacks) == 0 then return end
    local attack, name = table.Random(self._DrGBaseDefinedAttacks)
    self:CallAttack(name)
  end
  
end
