if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

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
ENT.DefaultRelationship = D_HT
ENT.Factions = {FACTION_GMAN}

-- Animations --
ENT.WalkAnimation = ACT_HL2MP_WALK
ENT.RunAnimation = ACT_HL2MP_RUN_FAST
ENT.IdleAnimation = ACT_HL2MP_IDLE
ENT.JumpAnimation = ACT_HL2MP_JUMP_KNIFE

-- Movements --
ENT.WalkSpeed = -1
ENT.RunSpeed = 300

-- Climbing --
ENT.ClimbLedges = true
ENT.ClimbProps = true
ENT.ClimbLedgesMaxHeight = math.huge
ENT.ClimbLadders = true
ENT.ClimbSpeed = 60
ENT.ClimbUpAnimation = ACT_ZOMBIE_CLIMB_UP
ENT.ClimbOffset = Vector(-14, 0, 0)

if SERVER then

  sound.Add({
    name = "DrGBase.RiseAndShine",
    sound = "vo/gman_misc/gman_riseshine.wav",
    channel = CHAN_VOICE,
    level = 60
  })

  function ENT:Initialize()
    self.loco:SetDesiredSpeed(300)
  end

  function ENT:Think()
    --print(self:GetEnemy())
  end

  function ENT:OnSight(ent)
    print("sight", ent)
  end
  function ENT:OnLostSight(ent)
    print("lostsight", ent)
  end

  function ENT:OnComputePath(area)
    local mat = area:DrG_GetMaterialType()
    if mat == MAT_CONCRETE then return 10000000 end
  end

end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)