if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot2" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.Name = "DrGBase Test Nextbot"
ENT.Class = "npc_drgbase_test"
ENT.Category = "DrGBase"
ENT.Models = {"models/player/gman_high.mdl"}

-- AI --
ENT.EnemyReach = 250
ENT.EnemyStop = 125
ENT.EnemyAvoid = 50

-- Movements/animations --
ENT.WalkAnimation = ACT_HL2MP_WALK
ENT.RunAnimation = ACT_HL2MP_RUN
ENT.IdleAnimation = ACT_HL2MP_IDLE
ENT.JumpAnimation = ACT_HL2MP_JUMP_KNIFE

-- Detection --
ENT.EyeBone = "ValveBiped.Bip01_Head1"
ENT.EyeOffset = Vector(5, 0, 2.5)
ENT.EyeAngle = Angle(75, 0, 0)

-- Possession --
ENT.PossessionEnabled = true
ENT.PossessionViews = {
  {
    offset = Vector(0, 30, 20),
    distance = 100
  },
  {
    offset = Vector(7.5, 0, 0),
    distance = 0,
    eyepos = true
  }
}
ENT.PossessionBinds = {
  {
    bind = IN_JUMP,
    coroutine = true,
    onkeydown = function(self)
      self:QuickJump(100)
    end
  }
}

if SERVER then

  function ENT:CustomInitialize()
    self:SetPlayersRelationship(D_HT)
    self:DefineSequenceCallback({
      self:SelectRandomSequence(self.RunAnimation),
      self:SelectRandomSequence(self.WalkAnimation)
    }, {0.3, 0.8}, function()
      self:EmitFootstep()
    end)
  end

  function ENT:FetchDestination()
    return self:RandomPos(1500)
  end
  function ENT:EnemyInRange(enemy)
    self:FaceTowardsEntity(enemy)
    self:PlayAnimation(ACT_GMOD_GESTURE_DISAGREE)
  end

  function ENT:OnTakeDamage(dmg)
    local attacker = dmg:GetAttacker()
    if not IsValid(attacker) then return end
    if self:IsEnemy(attacker) and self:HasSpottedEntity(attacker) then
      self:SpotEntity(attacker)
      return true
    else
      self:SetEntityRelationship(attacker, D_HT)
      self:SpotEntity(attacker)
    end
  end

  function ENT:OnDeath(dmg)
    return dmg:GetDamageForce():Length() < 10000
  end
  function ENT:DoOnDeath(dmg)
    local deaths = {
      "death_01", "death_02", "death_03", "death_04"
    }
    self:PlaySequenceAndWait(deaths[math.random(#deaths)])
  end

end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.Nextbots.Load({
  Name = ENT.Name,
  Class = ENT.Class,
  Category = ENT.Category,
  Killicon = ENT.Killicon,
  Models = ENT.Models
})
