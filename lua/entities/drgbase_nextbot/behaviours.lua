
-- Getters/setters --

function ENT:IsIdling()
  return self:GetNW2Bool("DrGBaseIdling")
end
function ENT:IsAttacking()
  return self:GetNW2Bool("DrGBaseAttacking")
end

if SERVER then

  -- Functions --

  function ENT:Idle(duration, callback)
    if duration <= 0 then return end
    if callback == nil then callback = function() end end
    self:SetNW2Bool("DrGBaseIdling", true)
    local delay = CurTime() + duration
    local targetdelay = 0
    local now = CurTime()
    while CurTime() < delay do
      if self:CoroutineCalls() then break end
      if self:IsPossessed() then break end
      if self:HasEnemy() then break end
      if callback(CurTime() - now) then break end
      --if self:IsFlying() then self:FlightHover() end
      coroutine.yield()
    end
    self:SetNW2Bool("DrGBaseIdling", false)
  end

  function ENT:QuickJump(pos)
    if not self:IsOnGround() then return end
    if isvector(pos) then
      self:FacePos(pos)
      self.loco:JumpAcrossGap(pos, self:GetForward())
    elseif isnumber(pos) then
      local jumpheight = self.loco:GetMaxJumpHeight()
      self.loco:SetJumpHeight(pos*self:GetScale())
      self.loco:Jump()
      self.loco:SetJumpHeight(jumpheight)
    else self:QuickJump(self.loco:GetJumpHeight()) end
  end

  function ENT:Jump(pos, callback)
    self:QuickJump(pos)
    if callback == nil then callback = function() end end
    while not self:IsOnGround() and not self:IsDying() do
      if callback() then return end
      coroutine.yield()
    end
  end

  function ENT:Glide(pos, options, callback)
    options = options or {}
    if callback == nil then callback = function() end end
    self:Jump(pos, function()
      local velocity = self:GetVelocity()
      if velocity.z < 0 and options.pitch ~= nil and options.speed ~= nil then
        local forward = self:GetForward()
        forward.z = -math.tan(math.rad(options.pitch))
        forward:Normalize()
        self:SetVelocity(forward*options.speed*self:GetScale())
      end
      return callback(options)
    end)
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
    if #self.OnAttackSounds > 0 then
      self:EmitSound(self.OnAttackSounds[math.random(#self.OnAttackSounds)])
    end
    for i, attack in ipairs(attacks) do
      self:SetNW2Bool("DrGBaseAttacking", true)
      attack.delay = attack.delay or 0
      if attack.delay < 0 then attack.delay = 0 end
      attack.damage = attack.damage or 0
      attack.type = attack.type or DMG_GENERIC
      attack.force = attack.force or Vector(150, 0, 0)
      attack.range = attack.range or self.EnemyReach
      attack.angle = attack.angle or 90
      self:Timer(attack.delay, function()
        if not attack._cooldown then
          local hit = {}
          for i, target in ipairs(attack.collateral and ents.GetAll() or self:ConsideredEntities()) do
            if target == self then continue end
            if not self:IsInRange(target, attack.range) then continue end
            if self:IsPossessed() and self:GetPossessor() == target then continue end
            if not attack.friendlyfire and not self:IsPossessed() and self:IsAlly(target)  then continue end
            local angle = (self:GetPos() + self:GetForward()):DrG_Degrees(target:GetPos(), self:GetPos())
            if angle > attack.angle/2 then continue end
            if not self:Visible(target) then continue end
            local dmg = DamageInfo()
            dmg:SetAttacker(self)
            dmg:SetDamage(isfunction(attack.damage) and attack.damage(target) or attack.damage)
            dmg:SetDamageType(attack.type)
            dmg:SetDamagePosition(self:WorldSpaceCenter())
            dmg:SetReportedPosition(self:WorldSpaceCenter())
            local force = self:GetForward()*attack.force.x +
            self:GetRight()*attack.force.y +
            self:GetUp()*attack.force.z
            dmg:SetDamageForce(force)
            if target.Type == "nextbot" then
              local jumpheight = target.loco:GetJumpHeight()
              target.loco:SetJumpHeight(1)
              target.loco:Jump()
              target.loco:SetJumpHeight(jumpheight)
              target.loco:SetVelocity(target.loco:GetVelocity() + force)
            else
              target:SetVelocity(target:GetVelocity() + force)
              local phys = target:GetPhysicsObject()
              if IsValid(phys) then phys:AddVelocity(force) end
            end
            target:TakeDamageInfo(dmg)
            if attack.viewpunch and target:IsPlayer() then
              target:ViewPunch(attack.viewpunch)
            end
            table.insert(hit, target)
          end
          if #hit > 0 and #self.OnHitSounds > 0 then
            self:EmitSound(self.OnHitSounds[math.random(#self.OnHitSounds)])
          elseif #self.OnMissSounds > 0 then
            self:EmitSound(self.OnMissSounds[math.random(#self.OnMissSounds)])
          end
          onattack(hit, i, attack)
        end
        if i == #attacks then
          self:SetNW2Bool("DrGBaseAttacking", false)
        end
      end)
    end
    if options.animation ~= nil then
      local animation = options.animation
      if istable(animation) then
        if #animation == 0 then return end
        animation = animation[math.random(#animation)]
      end
      if options.gesture then self:PlayAnimation(animation, options.rate, options.callback)
      elseif options.movement then self:PlayAnimationAndMove(animation, options.rate, options.callback)
      else self:PlayAnimationAndWait(animation, options.rate, options.callback) end
    end
  end

  function ENT:DefineAttack(name, attacks, options, onattack)
    self._DrGBaseDefinedAttacks = self._DrGBaseDefinedAttacks or {}
    self._DrGBaseDefinedAttacks[name] = {
      attacks = attacks,
      options = options,
      onattack = onattack
    }
  end
  function ENT:RemoveAttack(name)
    self._DrGBaseDefinedAttacks = self._DrGBaseDefinedAttacks or {}
    self._DrGBaseDefinedAttacks[name] = nil
  end

  function ENT:CallAttack(name)
    self._DrGBaseDefinedAttacks = self._DrGBaseDefinedAttacks or {}
    local attack = self._DrGBaseDefinedAttacks[name]
    if attack == nil then return end
    return self:Attack(attack.attacks, attack.options, attack.onattack)
  end
  function ENT:CallRandomAttack()
    self._DrGBaseDefinedAttacks = self._DrGBaseDefinedAttacks or {}
    if table.Count(self._DrGBaseDefinedAttacks) == 0 then return end
    local attack, name = table.Random(self._DrGBaseDefinedAttacks)
    return self:CallAttack(name)
  end

  -- Hooks --

  -- Handlers --

end
