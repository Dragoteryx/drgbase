if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.Name = "DrGBase Test Nextbot"
ENT.Class = "npc_drg_nextbot_test"
ENT.Category = "DrGBase"
ENT.Models = {
  "models/player/police.mdl",
  "models/player/police_fem.mdl"
}
ENT.EnableBodyMoveXY = true

-- Relationships --
ENT.Factions = {"DrGBase"}

-- Possession --
ENT.PossessionEnabled = true
ENT.Possession = {
  distance = 100,
  offset = Vector(0, 30, 20),
  binds = {
    {
      bind = IN_ATTACK,
      onkeypressed = function(self)
        DrGBase.Utils.Explosion(self:PossessorTrace().HitPos, {
          damage = self:Health(),
          owner = self
        })
      end,
      coroutine = false
    },
    {
      bind = IN_ATTACK2,
      onkeydown = function(self)
        self:Kill(self:GetPossessor())
      end,
      coroutine = false
    },
    {
      bind = IN_JUMP,
      onkeydown = function(self)
        self:QuickJump(100)
      end,
      coroutine = false
    }
  }
}

if SERVER then

  -- Misc --
  function ENT:CustomInitialize()
    self:SetDefaultRelationship(D_HT)
    self:SetPlayersRelationship(D_LI)
    self:SetFactionRelationship(DRGBASE_FACTION_SANIC, D_FR)
  end
  function ENT:Use(ply)
    if self:IsEnemy(ply) then self:SetEntityRelationship(ply, D_LI)
    else self:SetEntityRelationship(ply, D_HT) end
  end

  -- AI --
  function ENT:OnPursueEnemy(enemy)
    return true
  end
  function ENT:EnemyInRange(enemy) end
  function ENT:FetchDestination()
    return self:RandomPos(1500)
  end
  function ENT:ReachedDestination(pos)
    self:PlaySequenceAndWait("taunt_dance_base")
  end

  -- Movement --
  function ENT:GroundSpeed(state)
    if state == DRGBASE_STATE_AI_FIGHT or
    state == DRGBASE_STATE_AI_AVOID then return 200
    else return 100 end
  end

  -- Possession --
  function ENT:PossessionGroundSpeed(sprint)
    if sprint then return 200
    else return 100 end
  end

  -- Animations --
  function ENT:SyncAnimation(speed, onground, flying, up, down)
    if not onground then return "jump_knife"
    elseif speed == 0 then return "idle_all_01"
    elseif speed < 120 then return "walk_all"
    else return "run_all_charging" end
  end

  -- Hooks --
  function ENT:OnSpawn()
    self:PlaySequenceAndWait("zombie_slump_rise_01")
  end
  function ENT:OnTakeDamage(dmg, lethal)
    if lethal then return end
    local sounds = {
      "npc/metropolice/pain1.wav",
      "npc/metropolice/pain2.wav",
      "npc/metropolice/pain3.wav",
      "npc/metropolice/pain4.wav"
    }
    self:EmitSound(sounds[math.random(#sounds)])
  end
  function ENT:AfterTakeDamage(dmg, delay)
    if delay > 0.05 then return end
    --self:PlaySequenceAndWait("reload_dual_original")
  end
  function ENT:OnDeath(dmg)
    local sounds = {
      "npc/metropolice/die1.wav",
      "npc/metropolice/die2.wav",
      "npc/metropolice/die3.wav",
      "npc/metropolice/die4.wav"
    }
    self:EmitSound(sounds[math.random(#sounds)])
    return dmg:GetDamageForce():Length() < 10000
  end
  function ENT:DoOnDeath(dmg, delay)
    local deaths = {
      "death_01", "death_02", "death_03", "death_04"
    }
    self:PlaySequenceAndWait(deaths[math.random(#deaths)])
  end

  function ENT:OnDoorContact(door)
    return "open", 0, 2
  end

end

-- DO NOT TOUCH --
if SERVER then
  AddCSLuaFile("shared.lua")
end
DrGBase.Nextbot.Load({
  Name = ENT.Name,
  Class = ENT.Class,
  Category = ENT.Category,
  Killicon = ENT.Killicon
})
