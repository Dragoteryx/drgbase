if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Antlion"
ENT.Category = "DrGBase"
ENT.Models = {"models/Antlion.mdl"}
ENT.Skins = {0, 1, 2, 3}
ENT.CollisionBounds = Vector(30, 30, 60)
ENT.BloodColor = BLOOD_COLOR_YELLOW
ENT.RagdollOnDeath = true

-- Sounds --
ENT.OnDamageSounds = {"NPC_Antlion.Pain"}

-- Stats --
ENT.SpawnHealth = 40

-- AI --
ENT.RangeAttackRange = 1000
ENT.MeleeAttackRange = 50
ENT.ReachEnemyRange = 50
ENT.AvoidEnemyRange = 0
ENT.FollowPlayers = true

-- Relationships --
ENT.Factions = {FACTION_ANTLIONS}
ENT.DefaultRelationship = D_HT

-- Movements/animations --
ENT.UseWalkframes = true
ENT.IdleAnimation = "distractidle2"
ENT.JumpAnimation = ACT_GLIDE

-- Detection --
ENT.EyeBone = "Antlion.Head_Bone"
ENT.EyeOffset = Vector(7.5, 0, 5)
ENT.EyeAngle = Angle(0, 0, 0)

if SERVER then

  function ENT:Initialize()
    --
  end

  function ENT:Think()
    --print("=========================")
    --print("desired", self:GetSpeed())
    --print("actual", self:GetVelocity():Length())
  end

  -- AI --

  function ENT:DoThink()
    while self:WaterLevel() >= 2 do
      self:PlaySequenceAndWait("drown", {gravity = false})
      --[[if self:WaterLevel() >= 2 then
        local dmg = DamageInfo()
        dmg:SetDamage(8)
        dmg:SetDamageType(DMG_DROWN)
        self:TakeDamageInfo(dmg)
      end]]
    end
  end

  function ENT:DoRangeAttack(enemy)
    if math.random(1, 500) > 1 then return end
    if self:PlaySequenceAndMove("charge_start", true) then
      self:ResetSequence("charge_run")
      self:UpdateSpeed()
      local i = 0
      local max = math.random(150, 250)
      while i < max and IsValid(enemy) and not self:IsInRange(enemy, 50) do
        if self:FollowPath(enemy) == "unreachable" then return end
        if self:YieldNoUpdate(true) then return end
        i = i+1
      end
      if IsValid(enemy) and self:IsInRange(enemy, 50) then
        self:EmitSound("NPC_Antlion.MeleeAttackSingle")
        self:PlaySequenceAndMove("charge_end", true)
      end
    end
  end
  function ENT:DoMeleeAttack()
    local rand = math.random(1, 8)
    if rand == 7 then self:PlaySequenceAndMove("pounce", true, self.FaceEnemy)
    elseif rand == 8 then self:PlaySequenceAndMove("pounce2", true, self.FaceEnemy)
    else self:PlaySequenceAndMove("attack"..rand, true, self.FaceEnemy) end
  end

  -- Damage --

  function ENT:DoTakeDamage(dmg)
    if dmg:IsDamageType(DMG_PHYSGUN) then
      self:PlaySequenceAndWait("flip1")
    end
  end

  -- Path --

  function ENT:OnComputePath(area)
    if area:IsUnderwater() then return 100000 end
  end

  -- Events --

  function ENT:OnAnimEvent()
    if self:IsAttacking() then
      if self:GetCycle() > 0.3 then
        local hit = self:Attack({
          damage = 5, range = 50, type = DMG_SLASH,
          viewpunch = Angle(10, 0, 0)
        })
        if #hit > 0 then self:EmitSound("NPC_Antlion.MeleeAttack") end
      else self:EmitSound("NPC_Antlion.MeleeAttackSingle") end
    elseif self:IsOnGround() then
      self:EmitSound("NPC_Antlion.Footstep")
    end
  end

end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)