-- AI --

ENT.HadEnemy = DrGBase.Deprecated(
  "ENT:HadEnemy()",
  "ENT:HasEnemy()",
  function(self)
    return self:HasEnemy()
  end)

-- Possession --

ENT.PossessorView = DrGBase.Deprecated(
  "ENT:PossessorView()",
  "ENT:PossessorEyePos() & ENT:PossessorEyeAngles()",
  function(self)
    return self:PossessorEyePos(), self:PossessorEyeAngles()
  end)

ENT.PossessorNormal = DrGBase.Deprecated(
  "ENT:PossessorNormal()",
  "ENT:PossessorEyeNormal()",
  function(self)
    return self:PossessorEyeNormal()
  end)

ENT.PossessorTrace = DrGBase.Deprecated(
  "ENT:PossessorTrace()",
  "ENT:PossessorEyeTrace()",
  function(self)
    return self:PossessorEyeTrace()
  end)

-- Misc --

ENT.EmitStep = DrGBase.Deprecated(
  "ENT:EmitStep(soundLevel, pitchPercent, volume, channel, soundFlags, dsp)",
  "ENT:EmitFootstep(soundLevel, pitchPercent, volume, channel, soundFlags, dsp)",
  function(self, ...)
    return self:EmitFootstep(...)
  end)

if SERVER then

  -- AI --

  ENT.AddPatrolPos = DrGBase.Deprecated(
    "ENT:AddPatrolPos(pos)",
    "ENT:RoamTo(pos)",
    function(self, pos)
      self:RoamTo(pos)
    end)

  -- Animations --

  ENT.PlaySequenceAndMoveAbsolute = DrGBase.Deprecated(
    "ENT:PlaySequenceAndMoveAbsolute(sequence, options, fn)",
    "ENT:PlaySequenceAndMove(sequence, {absolute = true}, fn)",
    function(self, sequence, options, fn, ...)
      if isfunction(options) then return self:PlaySequenceAndMoveAbsolute(sequence, 1, options, fn, ...) end
      if not istable(options) then options = {} end
      options.absolute = true
      return self:PlaySequenceAndMove(sequence, options, fn, ...)
    end)

  ENT.PlayClimbSequence = DrGBase.Deprecated(
    "ENT:PlayClimbSequence(sequence, height, rate, fn)",
    "ENT:PlaySequenceAndClimb(sequence, options, fn)",
    function(self, sequences, height, rate, fn)
      return self:PlaySequenceAndClimb(sequences, {
        height = height, rate = rate
      }, fn)
    end)

  -- Movements --

  -- Detection --

  ENT.HasSpotted = DrGBase.Deprecated(
    "ENT:HasSpotted(entity)",
    "ENT:HasDetected(entity)",
    function(self, ent)
      return self:HasDetected(ent)
    end)
  ENT.HasLost = DrGBase.Deprecated(
    "ENT:HasLost(entity)",
    "ENT:HasForgotten(entity)",
    function(self, ent)
      return self:HasForgotten(ent)
    end)

  ENT.SpotEntity = DrGBase.Deprecated(
    "ENT:SpotEntity(entity)",
    "ENT:DetectEntity(entity)",
    function(self, ent)
      return self:DetectEntity(ent)
    end)
  ENT.LoseEntity = DrGBase.Deprecated(
    "ENT:LoseEntity(entity)",
    "ENT:ForgetEntity(entity)",
    function(self, ent)
      return self:ForgetEntity(ent)
    end)

  ENT.IsInSight = DrGBase.Deprecated(
    "ENT:IsInSight(entity)",
    "ENT:IsAbleToSee(entity, useFOV)",
    function(self, ent)
      return self:IsAbleToSee(ent)
    end)
  ENT.GetSightFOV = DrGBase.Deprecated(
    "ENT:GetSightFOV()",
    "ENT:GetFOV()",
    function(self)
      return self:GetFOV()
    end)
  ENT.SetSightFOV = DrGBase.Deprecated(
    "ENT:SetSightFOV(fov)",
    "ENT:SetFOV(fov)",
    function(self, fov)
      return self:SetFOV(fov)
    end)
  ENT.GetSightRange = DrGBase.Deprecated(
    "ENT:GetSightRange()",
    "ENT:GetMaxVisionRange()",
    function(self)
      return self:GetMaxVisionRange()
    end)
  ENT.SetSightRange = DrGBase.Deprecated(
    "ENT:SetSightRange(range)",
    "ENT:SetMaxVisionRange(range)",
    function(self, range)
      return self:SetMaxVisionRange(range)
    end)

  -- Possession --

  ENT.Possess = DrGBase.Deprecated(
    "ENT:Possess(player)",
    "ENT:SetPossessor(player)",
    function(self, ply)
      return self:SetPossessor(ply)
    end)
  ENT.Dispossess = DrGBase.Deprecated(
    "ENT:Dispossess()",
    "ENT:StopPossession()",
    function(self)
      return self:StopPossession()
    end)

  -- Misc --

  ENT.Attack = DrGBase.Deprecated(
    "ENT:Attack(attack, fn)",
    "ENT:MeleeAttack(attack, fn)",
    function(self, attack, fn)
      if not istable(attack) then attack = {} end
      self:Timer(isnumber(attack.delay) and attack.delay or 0, function(self)
        local hit = self:MeleeAttack(attack)
        if isfunction(fn) then fn(self, hit) end
      end)
    end)

  ENT.BlastAttack = DrGBase.Deprecated(
    "ENT:BlastAttack(attack, fn)",
    "ENT:RadialAttack(attack, fn)",
    function(self, attack, fn)
      if not istable(attack) then attack = {} end
      self:Timer(isnumber(attack.delay) and attack.delay or 0, function(self)
        local hit = self:RadialAttack(attack)
        if isfunction(fn) then fn(self, hit) end
      end)
    end)

  ENT.Wait = DrGBase.Deprecated(
    "ENT:Wait(duration)",
    "ENT:Idle(duration)",
    function(self, duration)
      return self:Idle(duration)
    end)

  ENT.GetScale = DrGBase.Deprecated(
    "ENT:GetScale()",
    "ENT:GetModelScale()",
    function(self)
      return self:GetModelScale()
    end)

  ENT.SetScale = DrGBase.Deprecated(
    "ENT:SetScale(scale, deltaTime)",
    "ENT:SetModelScale(scale, deltaTime)",
    function(self, scale, deltaTime)
      return self:SetModelScale(scale, deltaTime)
    end)

  ENT.Scale = DrGBase.Deprecated(
    "ENT:Scale(scale, deltaTime)",
    "ENT:ScaleModel(scale, deltaTime)",
    function(self, scale, deltaTime)
      return self:ScaleModel(scale, deltaTime)
    end)

  ENT.SequenceEvent = DrGBase.Deprecated(
    "ENT:SequenceEvent(sequence, cycle, fn)",
    "ENT:AddAnimEventCycle(sequence, cycle, event)",
    function() end)

end