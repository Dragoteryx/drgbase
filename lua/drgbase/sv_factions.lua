-- Init --

local function InitFactions(ent)
  if not IsValid(ent) then return false end
  if ent.DrG_Factions then return true end
  ent.DrG_Factions = {}
  local faction = DrGBase.GetDefaultFaction(ent:GetClass())
  if faction then DrGBase.JoinFaction(ent, faction) end
  return true
end

-- Setters --

function DrGBase.JoinFaction(ent, faction)
  if not InitFactions(ent) then return end
  if not DrGBase.IsInFaction(ent, faction) then
    ent.DrG_Factions[string.upper(faction)] = true
    if ent.IsDrGNextbot then ent:AddFactionRelationship(faction, D_LI, 1) end
    for nb in DrGBase.NextbotIterator() do
      if nb == ent then continue end
      nb:UpdateRelationshipWith(ent)
    end
    hook.Run("DrG/JoinFaction", ent, string.upper(faction))
  end
end
function DrGBase.JoinFactions(ent, factions)
  for i = 1, #factions do DrGBase.JoinFaction(ent, factions[i]) end
end

function DrGBase.LeaveFaction(ent, faction)
  if not InitFactions(ent) then return end
  if DrGBase.IsInFaction(ent, faction) then
    ent.DrG_Factions[string.upper(faction)] = nil
    if ent.IsDrGNextbot then ent:AddFactionRelationship(faction, D_NU, 1) end
    for nb in DrGBase.NextbotIterator() do
      if nb == ent then continue end
      nb:UpdateRelationshipWith(ent)
    end
    hook.Run("DrG/LeaveFaction", ent, string.upper(faction))
  end
end
function DrGBase.LeaveFactions(ent, factions)
  for i = 1, #factions do DrGBase.LeaveFaction(ent, factions[i])end
end
function DrGBase.LeaveAllFactions(ent)
  return DrGBase.LeaveFactions(ent, DrGBase.GetFactions(ent))
end

-- Getters --

function DrGBase.IsInFaction(ent, faction)
  if not InitFactions(ent) then return false end
  return ent.DrG_Factions[string.upper(faction)] or false
end

function DrGBase.GetFactions(ent)
  if not InitFactions(ent) then return {} end
  local factions = {}
  for faction in pairs(ent.DrG_Factions) do
    table.insert(factions, faction)
  end
  return factions
end

-- Default --

local DEFAULT_FACTIONS = {
  ["player"] = "FACTION_PLAYERS",
  ["npc_crow"] = "FACTION_ANIMALS",
  ["npc_monk"] = "FACTION_REBELS",
  ["npc_pigeon"] = "FACTION_ANIMALS",
  ["npc_seagull"] = "FACTION_ANIMALS",
  ["npc_combine_camera"] = "FACTION_COMBINE",
  ["npc_turret_ceiling"] = "FACTION_COMBINE",
  ["npc_cscanner"] = "FACTION_COMBINE",
  ["npc_combinedropship"] = "FACTION_COMBINE",
  ["npc_combinegunship"] = "FACTION_COMBINE",
  ["npc_combine_s"] = "FACTION_COMBINE",
  ["npc_hunter"] = "FACTION_COMBINE",
  ["npc_helicopter"] = "FACTION_COMBINE",
  ["npc_manhack"] = "FACTION_COMBINE",
  ["npc_metropolice"] = "FACTION_COMBINE",
  ["npc_rollermine"] = "FACTION_COMBINE",
  ["npc_clawscanner"] = "FACTION_COMBINE",
  ["npc_stalker"] = "FACTION_COMBINE",
  ["npc_strider"] = "FACTION_COMBINE",
  ["npc_turret_floor"] = "FACTION_COMBINE",
  ["npc_alyx"] = "FACTION_REBELS",
  ["npc_barney"] = "FACTION_REBELS",
  ["npc_citizen"] = "FACTION_REBELS",
  ["npc_dog"] = "FACTION_REBELS",
  ["npc_magnusson"] = "FACTION_REBELS",
  ["npc_kleiner"] = "FACTION_REBELS",
  ["npc_mossman"] = "FACTION_REBELS",
  ["npc_eli"] = "FACTION_REBELS",
  ["npc_fisherman"] = "FACTION_REBELS",
  ["npc_gman"] = "FACTION_GMAN",
  ["npc_odessa"] = "FACTION_REBELS",
  ["npc_vortigaunt"] = "FACTION_REBELS",
  ["npc_breen"] = "FACTION_COMBINE",
  ["npc_antlion"] = "FACTION_ANTLIONS",
  ["npc_antlion_grub"] = "FACTION_ANTLIONS",
  ["npc_antlionguard"] = "FACTION_ANTLIONS",
  ["npc_antlionguardian"] = "FACTION_ANTLIONS",
  ["npc_antlion_worker"] = "FACTION_ANTLIONS",
  ["npc_barnacle"] = "FACTION_BARNACLES",
  ["npc_headcrab_fast"] = "FACTION_ZOMBIES",
  ["npc_fastzombie"] = "FACTION_ZOMBIES",
  ["npc_fastzombie_torso"] = "FACTION_ZOMBIES",
  ["npc_headcrab"] = "FACTION_ZOMBIES",
  ["npc_headcrab_black"] = "FACTION_ZOMBIES",
  ["npc_poisonzombie"] = "FACTION_ZOMBIES",
  ["npc_zombie"] = "FACTION_ZOMBIES",
  ["npc_zombie_torso"] = "FACTION_ZOMBIES",
  ["npc_zombine"] = "FACTION_ZOMBIES",
  ["monster_alien_grunt"] = "FACTION_XEN_ARMY",
  ["monster_alien_slave"] = "FACTION_XEN_ARMY",
  ["monster_human_assassin"] = "FACTION_HECU",
  ["monster_babycrab"] = "FACTION_ZOMBIES",
  ["monster_bullchicken"] = "FACTION_XEN_WILDLIFE",
  ["monster_cockroach"] = "FACTION_ANIMALS",
  ["monster_alien_controller"] = "FACTION_XEN_ARMY",
  ["monster_gargantua"] = "FACTION_XEN_ARMY",
  ["monster_bigmomma"] = "FACTION_ZOMBIES",
  ["monster_human_grunt"] = "FACTION_HECU",
  ["monster_headcrab"] = "FACTION_ZOMBIES",
  ["monster_houndeye"] = "FACTION_XEN_WILDLIFE",
  ["monster_nihilanth"] = "FACTION_XEN_ARMY",
  ["monster_scientist"] = "FACTION_REBELS",
  ["monster_barney"] = "FACTION_REBELS",
  ["monster_snark"] = "FACTION_XEN_WILDLIFE",
  ["monster_tentacle"] = "FACTION_XEN_WILDLIFE",
  ["monster_zombie"] = "FACTION_ZOMBIES",
  ["npc_apc_dropship"] = "FACTION_COMBINE",
  ["npc_elite_overwatch_dropship"] = "FACTION_COMBINE",
  ["npc_civil_protection_tier1_dropship"] = "FACTION_COMBINE",
  ["npc_civil_protection_tier2_dropship"] = "FACTION_COMBINE",
  ["npc_shotgunner_dropship"] = "FACTION_COMBINE",
  ["npc_overwatch_squad_tier1_dropship"] = "FACTION_COMBINE",
  ["npc_overwatch_squad_tier2_dropship"] = "FACTION_COMBINE",
  ["npc_overwatch_squad_tier3_dropship"] = "FACTION_COMBINE",
  ["npc_random_combine_dropship"] = "FACTION_COMBINE",
  ["npc_strider_dropship"] = "FACTION_COMBINE"
}
function DrGBase.GetDefaultFaction(class)
  return DEFAULT_FACTIONS[class]
end