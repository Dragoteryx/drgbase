if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot_new" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "NEW Test Nextbot"
ENT.Category = "DrGBase"
ENT.Models = {"models/player/gman_high.mdl"}

-- AI --
ENT.BehaviourType = AI_BEHAV_BASE
ENT.RangeAttackRange = 100
ENT.MeleeAttackRange = 0
ENT.ReachEnemyRange = 100
ENT.AvoidEnemyRange = 25

-- Relationships --
ENT.DefaultRelationship = D_LI
ENT.Factions = {FACTION_GMAN}

-- Animations --
ENT.WalkAnimation = ACT_HL2MP_WALK
ENT.RunAnimation = ACT_HL2MP_RUN_FAST
ENT.IdleAnimation = ACT_HL2MP_IDLE
ENT.JumpAnimation = ACT_HL2MP_JUMP_KNIFE

-- Movements --
ENT.WalkSpeed = -1
ENT.RunSpeed = 300

if SERVER then

  sound.Add({
    name = "DrGBase.RiseAndShine",
    sound = "vo/gman_misc/gman_riseshine.wav",
    channel = CHAN_VOICE,
    level = 60
  })

  function ENT:Initialize()
    self:SetPlayersRelationship(D_HT, 2)
    self.loco:SetDesiredSpeed(300)
    print(self:GetRelationship(Entity(1)))
  end

  function ENT:Think()
    print(self:GetEnemy())
  end

  function ENT:ShouldRun()
    return true
  end

end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)