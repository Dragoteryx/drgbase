if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Antlion"
ENT.Category = "DrGBase"
ENT.Models = {"models/Antlion.mdl"}
ENT.Skins = {0, 1, 2, 3}
ENT.CollisionBounds = Vector(25, 25, 60)
ENT.BloodColor = BLOOD_COLOR_YELLOW
ENT.RagdollOnDeath = true

-- Sounds --
ENT.OnDamageSounds = {"NPC_Antlion.Pain"}

-- Stats --
ENT.SpawnHealth = 40

-- AI --
ENT.RangeAttackRange = 0
ENT.MeleeAttackRange = 50
ENT.ReachEnemyRange = 50
ENT.AvoidEnemyRange = 0

-- Relationships --
ENT.Factions = {"FACTION_ANTLIONS"}
ENT.DefaultRelationship = D_HT

-- Movements/animations --
ENT.UseWalkframes = true
ENT.JumpAnimation = ACT_GLIDE

-- Locomotion --
ENT.MaxYawRate = 175

-- Detection --
ENT.EyeBone = "Antlion.Head_Bone"
ENT.EyeOffset = Vector(7.5, 0, 5)

-- Possession --
ENT.PossessionEnabled = true
ENT.PossessionMove = POSSESSION_MOVE_8DIR
ENT.PossessionViews = {
  {auto = true},
  {
    offset = Vector(7.5, 0, 10),
    eyepos = true
  }
}

if SERVER then

  function ENT:Initialize()
    self:SetClassRelationship("prop_thumper", D_FR, 1)
    print(#DrGBase.GetNextbots())
  end

  -- AI --

  function ENT:DoThink()
    while self:WaterLevel() >= 2 do
      self:PlaySequenceAndWait("drown", {gravity = false})
      if self:WaterLevel() >= 2 then
        local dmg = DamageInfo()
        dmg:SetDamage(8)
        dmg:SetDamageType(DMG_DROWN)
        self:TakeDamageInfo(dmg)
      end
    end
  end

  function ENT:DoMeleeAttack()
    local rand = math.random(1, 6)
    if rand == 7 then self:PlaySequenceAndMove("pounce", true)
    elseif rand == 8 then self:PlaySequenceAndMove("pounce2", true)
    else self:PlaySequenceAndMove("attack"..rand, true) end
  end

  -- Possession --

  function ENT:DoPossessionBinds(binds)
    if binds:IsDown("IN_ATTACK") then self:DoMeleeAttack() end
    if binds:IsDown("IN_JUMP") then
      local pos = self:PossessorEyeTrace(1000).HitPos
      self:Jump(pos, self.FaceForward)
    end
  end

  -- Misc --

  function ENT:OnAnimChange(old, new)
    local glide = self:LookupSequence("jump_glide")
    if glide == new then
      self:SetBodygroup(1, 1)
    elseif glide == old then
      self:SetBodygroup(1, 0)
    end
  end

  function ENT:DoLandOnGround()
    print("a")
    self:PlaySequenceAndMove("jump_stop")
  end

  function ENT:DoTakeDamage(dmg)
    if dmg:IsDamageType(DMG_PHYSGUN) then
      self:SetVelocity(dmg:GetAttacker():GetForward()*500 + Vector(0, 0, 300))
      self:PlaySequenceAndWait("flip1", function(self)
        if self:WaterLevel() >= 2 then return true end
      end)
    end
  end

  function ENT:OnComputePath(area)
    if area:IsUnderwater() then return -1 end
  end

  -- Bugbaits --

  function ENT:CustomRelationship(ent)
    if ent:IsPlayer() or ent.IsDrGNextbot then
      local weap = ent:GetActiveWeapon()
      if IsValid(weap) and weap:GetClass() == "weapon_bugbait" then
        return D_LI
      end
    end
  end

  hook.Add("PlayerSwitchWeapon", "DrG/PlayerSwitchWeaponBugbait", function(ply, old, new)
    if (IsValid(old) and old:GetClass() == "weapon_bugbait") or
    (IsValid(new) and new:GetClass() == "weapon_bugbait") then
      timer.Simple(0, function()
        for nb in DrGBase.NextbotIterator("npc_drg_antlion") do nb:UpdateRelationshipWith(ply) end
      end)
    end
  end)

  hook.Add("EntityEmitSound", "DrG/BugbaitSoundEffect", function(sound)
    if IsValid(sound.Entity) and
    sound.Entity:GetClass() == "npc_grenade_bugbait" and
    sound.OriginalSoundName == "GrenadeBugBait.Splat" then
      local bugbait = sound.Entity
      local tr = util.DrG_TraceHull({
        start = bugbait:GetPos(), endpos = bugbait:GetPos(),
        mins = Vector(-10, -10, -10),
        maxs = Vector(10, 10, 10),
        filter = bugbait
      })
      if IsValid(tr.Entity) then
        for nb in DrGBase.NextbotIterator("npc_drg_antlion") do nb:DetectEntity(tr.Entity, 30) end
      end
    end
  end)

  -- Events --

  function ENT:OnAnimEvent()
    if self:IsAttacking() then
      if self:GetCycle() > 0.3 then
        local hit = self:MeleeAttack({
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