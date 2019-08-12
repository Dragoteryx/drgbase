if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Headcrab"
ENT.Category = "DrGBase"
ENT.Models = {"models/headcrabclassic.mdl"}
ENT.CollisionBounds = Vector(10, 10, 15)
ENT.BloodColor = BLOOD_COLOR_GREEN

-- Stats --
ENT.SpawnHealth = 40

-- Sounds --
ENT.OnSpawnSounds = {}
ENT.OnIdleSounds = {}
ENT.IdleSoundDelay = 2
ENT.ClientIdleSounds = false
ENT.OnDamageSounds = {}
ENT.DamageSoundDelay = 0.25
ENT.OnDeathSounds = {}
ENT.OnDownedSounds = {}
ENT.Footsteps = {}

-- AI --
ENT.RangeAttackRange = 150
ENT.MeleeAttackRange = 0
ENT.ReachEnemyRange = 125
ENT.AvoidEnemyRange = 100

-- Relationships --
ENT.Factions = {FACTION_ZOMBIES}

-- Animations --
ENT.WalkAnimation = ACT_RUN
ENT.RunAnimation = ACT_RUN
ENT.IdleAnimation = ACT_IDLE
ENT.JumpAnimation = ACT_IDLE

-- Movements --
ENT.UseWalkframes = true

-- Detection --
ENT.EyeBone = "HeadcrabClassic.SpineControl"
ENT.EyeOffset = Vector(4, 0, 0)

-- Possession --
ENT.PossessionEnabled = true
ENT.PossessionViews = {
  {
    offset = Vector(0, 10, 10),
    distance = 50
  },
  {
    offset = Vector(7.5, 0, 0),
    distance = 0,
    eyepos = true
  }
}
ENT.PossessionBinds = {}

if SERVER then

  -- Init/Think --

  function ENT:CustomInitialize()
    self:SetDefaultRelationship(D_HT)
  end
  function ENT:CustomThink() end

  -- AI --

  function ENT:OnRangeAttack(enemy)
    self:FaceTo(enemy)
    self:PlaySequence("jumpattack_broadcast")
    self:PauseCoroutine(0.5)
    self.CanBite = true
    self:Leap(enemy:EyePos(), 400)
    self.CanBite = false
  end
  function ENT:OnContact(ent)
    if self.CanBite and
    (self:IsPossessed() or ent == self:GetEnemy()) then
      self.CanBite = false
      local dmg = DamageInfo()
      dmg:SetDamage(20)
      dmg:SetAttacker(self)
      dmg:SetInflictor(self)
      dmg:SetDamageType(DMG_SLASH)
      ent:TakeDamageInfo(dmg)
    end
  end

  function ENT:OnReachedPatrol(pos)
    self:Wait(math.random(3, 7))
  end
  function ENT:OnIdle()
    self:AddPatrolPos(self:RandomPos(1500))
  end

end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
