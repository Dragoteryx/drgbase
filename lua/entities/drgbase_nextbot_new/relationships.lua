-- Convars --

local RelationshipWithPlayers = CreateConVar("drgbase_relationships_players", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
local RelationshipWithNPCs = CreateConVar("drgbase_relationships_npcs", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
local RelationshipWithOther = CreateConVar("drgbase_relationships_other", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

local TargetRepMelons = CreateConVar("drgbase_target_repmelons", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
local TargetGrubs = CreateConVar("drgbase_target_antlion_grubs", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

-- Getters --

function ENT:Team()
  return self:GetNW2Int("DrGBaseTeam", 0)
end

if SERVER then

  -- Internal --

  local CACHED_DISPS = {
    [D_LI] = true,
    [D_HT] = true,
    [D_FR] = true
  }
  local function IsCachedDisp(disp)
    return CACHED_DISPS[disp] or false
  end
  local function IsValidDisp(disp)
    return IsCachedDisp(disp) or disp == D_NU
  end

  local DISP_PRIORITIES = {
    [D_LI] = 4,
    [D_FR] = 3,
    [D_HT] = 2,
    [D_NU] = 1,
    [D_ER] = 0
  }
  local function HighestRelationship(relationships)
    local relationship = table.DrG_Fetch(relationships, function(rel1, rel2)
      if rel1.prio > rel2.prio then
        return true
      elseif rel1.prio == rel2.prio then
        if DISP_PRIORITIES[rel1.disp] > DISP_PRIORITIES[rel2.disp] then
          return true
        else return false end
      else return false end
    end)
    return relationship
  end

  local function CheckDisp(disp)
    return IsValidDisp(disp) and disp or D_ER
  end
  local function CheckPrio(prio)
    if not isnumber(prio) or prio ~= prio then return 1
    else return math.Clamp(prio, 1, math.huge) end
  end
  local function CheckDispPrio(disp, prio)
    return CheckDisp(disp), CheckPrio(prio)
  end

  local DEFAULT_FACTIONS = {
    ["npc_crow"] = FACTION_ANIMALS,
    ["npc_monk"] = FACTION_REBELS,
    ["npc_pigeon"] = FACTION_ANIMALS,
    ["npc_seagull"] = FACTION_ANIMALS,
    ["npc_combine_camera"] = FACTION_COMBINE,
    ["npc_turret_ceiling"] = FACTION_COMBINE,
    ["npc_cscanner"] = FACTION_COMBINE,
    ["npc_combinedropship"] = FACTION_COMBINE,
    ["npc_combinegunship"] = FACTION_COMBINE,
    ["npc_combine_s"] = FACTION_COMBINE,
    ["npc_hunter"] = FACTION_COMBINE,
    ["npc_helicopter"] = FACTION_COMBINE,
    ["npc_manhack"] = FACTION_COMBINE,
    ["npc_metropolice"] = FACTION_COMBINE,
    ["npc_rollermine"] = FACTION_COMBINE,
    ["npc_clawscanner"] = FACTION_COMBINE,
    ["npc_stalker"] = FACTION_COMBINE,
    ["npc_strider"] = FACTION_COMBINE,
    ["npc_turret_floor"] = FACTION_COMBINE,
    ["npc_alyx"] = FACTION_REBELS,
    ["npc_barney"] = FACTION_REBELS,
    ["npc_citizen"] = FACTION_REBELS,
    ["npc_dog"] = FACTION_REBELS,
    ["npc_magnusson"] = FACTION_REBELS,
    ["npc_kleiner"] = FACTION_REBELS,
    ["npc_mossman"] = FACTION_REBELS,
    ["npc_eli"] = FACTION_REBELS,
    ["npc_fisherman"] = FACTION_REBELS,
    ["npc_gman"] = FACTION_GMAN,
    ["npc_odessa"] = FACTION_REBELS,
    ["npc_vortigaunt"] = FACTION_REBELS,
    ["npc_breen"] = FACTION_COMBINE,
    ["npc_antlion"] = FACTION_ANTLIONS,
    ["npc_antlion_grub"] = FACTION_ANTLIONS,
    ["npc_antlionguard"] = FACTION_ANTLIONS,
    ["npc_antlionguardian"] = FACTION_ANTLIONS,
    ["npc_antlion_worker"] = FACTION_ANTLIONS,
    ["npc_barnacle"] = FACTION_BARNACLES,
    ["npc_headcrab_fast"] = FACTION_ZOMBIES,
    ["npc_fastzombie"] = FACTION_ZOMBIES,
    ["npc_fastzombie_torso"] = FACTION_ZOMBIES,
    ["npc_headcrab"] = FACTION_ZOMBIES,
    ["npc_headcrab_black"] = FACTION_ZOMBIES,
    ["npc_poisonzombie"] = FACTION_ZOMBIES,
    ["npc_zombie"] = FACTION_ZOMBIES,
    ["npc_zombie_torso"] = FACTION_ZOMBIES,
    ["npc_zombine"] = FACTION_ZOMBIES,
    ["monster_alien_grunt"] = FACTION_XEN_ARMY,
    ["monster_alien_slave"] = FACTION_XEN_ARMY,
    ["monster_human_assassin"] = FACTION_HECU,
    ["monster_babycrab"] = FACTION_ZOMBIES,
    ["monster_bullchicken"] = FACTION_XEN_WILDLIFE,
    ["monster_cockroach"] = FACTION_ANIMALS,
    ["monster_alien_controller"] = FACTION_XEN_ARMY,
    ["monster_gargantua"] = FACTION_XEN_ARMY,
    ["monster_bigmomma"] = FACTION_ZOMBIES,
    ["monster_human_grunt"] = FACTION_HECU,
    ["monster_headcrab"] = FACTION_ZOMBIES,
    ["monster_houndeye"] = FACTION_XEN_WILDLIFE,
    ["monster_nihilanth"] = FACTION_XEN_ARMY,
    ["monster_scientist"] = FACTION_REBELS,
    ["monster_barney"] = FACTION_REBELS,
    ["monster_snark"] = FACTION_XEN_WILDLIFE,
    ["monster_tentacle"] = FACTION_XEN_WILDLIFE,
    ["monster_zombie"] = FACTION_ZOMBIES,
    ["npc_apc_dropship"] = FACTION_COMBINE,
    ["npc_elite_overwatch_dropship"] = FACTION_COMBINE,
    ["npc_civil_protection_tier1_dropship"] = FACTION_COMBINE,
    ["npc_civil_protection_tier2_dropship"] = FACTION_COMBINE,
    ["npc_shotgunner_dropship"] = FACTION_COMBINE,
    ["npc_overwatch_squad_tier1_dropship"] = FACTION_COMBINE,
    ["npc_overwatch_squad_tier2_dropship"] = FACTION_COMBINE,
    ["npc_overwatch_squad_tier3_dropship"] = FACTION_COMBINE,
    ["npc_random_combine_dropship"] = FACTION_COMBINE,
    ["npc_strider_dropship"] = FACTION_COMBINE
  }

  -- Targetting --

  local TARGET_EXCEPTIONS = {
    ["npc_bullseye"] = false,
    ["npc_grenade_frag"] = false,
    ["npc_tripmine"] = false,
    ["npc_satchel"] = false,

    ["replicator_melon"] = TargetRepMelons,
    ["npc_antlion_grub"] = TargetGrubs,
    ["replicator_worker"] = true,
    ["replicator_queen"] = true,
    ["replicator_queen_hive"] = true
  }
  local function IsTarget(ent)
    if not IsValid(ent) then return false end
    local class = ent:GetClass()
    if TARGET_EXCEPTIONS[class] then
      local exception = TARGET_BLACKLIST[class]
      if isbool(exception) then return expection
      else return exception:GetBool() end
    else
      if ent.DrGBase_Target then return true end
      if ent:IsNextBot() then return true end
      if ent:IsPlayer() then return true end
      if ent:IsNPC() then return true end
      return false
    end
  end

  -- Optimisation for servers --

  DrGBase._TARGETTING_NPCS = DrGBase._TARGETTING_NPCS or {}
  DrGBase._TARGETTING_OTHER = DrGBase._TARGETTING_OTHER or {}
  hook.Add("OnEntityCreated", "DrGBase_RelationshipSystemOptimisation", function(ent)
    timer.Simple(0, function()
      if not IsValid(ent) then return end
      if IsTarget(ent) then
        if ent:IsPlayer() then return end
        DrGBase._TARGETTING_NPCS[ent] = true
        ent:CallOnRemove("DrGBase_RelationshipSystemOptimisation", function()
          DrGBase._TARGETTING_NPCS[ent] = nil
        end)
      else
        DrGBase._TARGETTING_OTHER[ent] = true
        ent:CallOnRemove("DrGBase_RelationshipSystemOptimisation", function()
          DrGBase._TARGETTING_OTHER[ent] = nil
        end)
      end
    end)
  end)

  local function EntitiesList()
    local cor = coroutine.create(function()
      if RelationshipWithPlayers:GetBool() then
        for _, ply in ipairs(player.GetAll()) do coroutine.yield(ply) end
      end
      if RelationshipWithNPCs:GetBool() then
        for ent in pairs(DrGBase._TARGETTING_NPCS) do
          if IsValid(ent) then coroutine.yield(ent) end
        end
      end
      if RelationshipWithOther:GetBool() then
        for ent in pairs(DrGBase._TARGETTING_OTHER) do
          if IsValid(ent) then coroutine.yield(ent) end
        end
      end
    end)
    return function()
      local _, res = coroutine.resume(cor)
      return res
    end
  end

  local function IsInEntitiesList(ent)
    if not IsValid(ent) then return false end
    if IsTarget(ent) then
      if ent:IsPlayer() then return RelationshipWithPlayers:GetBool()
      else return RelationshipWithNPCs:GetBool() end
    else return RelationshipWithOther:GetBool() end
  end

  -- Setters --

  ENT._DrGBaseRelationships = {}
  ENT._DrGBaseRelationshipCaches = {[D_LI] = {}, [D_HT] = {}, [D_FR] = {}}
  ENT._DrGBaseRelationshipCachesSpotted = {[D_LI] = {}, [D_HT] = {}, [D_FR] = {}}

  local function SetRelationship(self, ent, disp, prio)
    if not IsValid(ent) then return end
    if not IsValidDisp(disp) then return end
    if IsCachedDisp(disp) then
      self._DrGBaseRelationshipCaches[D_LI][ent] = nil
      self._DrGBaseRelationshipCaches[D_HT][ent] = nil
      self._DrGBaseRelationshipCaches[D_FR][ent] = nil
      self._DrGBaseRelationshipCaches[disp][ent] = true
      self._DrGBaseRelationshipCachesSpotted[D_LI][ent] = nil
      self._DrGBaseRelationshipCachesSpotted[D_HT][ent] = nil
      self._DrGBaseRelationshipCachesSpotted[D_FR][ent] = nil
      if self._DrGBaseSpotted[ent] then self._DrGBaseRelationshipCachesSpotted[disp][ent] = true end
      ent:CallOnRemove("DrGBaseRemoveFromDrGNextbot"..self:GetCreationID().."RelationshipCache", function()
        if IsValid(self) then
          self._DrGBaseRelationshipCaches[disp][ent] = nil
          self._DrGBaseRelationshipCachesSpotted[disp][ent] = nil
        end
      end)
    end
    self._DrGBaseRelationships[ent] = {disp = disp, prio = prio}
    if self:GetEnemy() == ent and not self:IsHostile(ent) then
      self:UpdateEnemy()
    end
    --[[if ent:IsPlayer() then
      net.Start("DrGBaseNextbotPlayerRelationship")
      net.WriteEntity(self)
      net.WriteInt(disp, 4)
      net.WriteInt(prio)
      net.Send(ent)
    end]]
  end

  ENT._DrGBaseDefinedRelationships = {}

  local function DefinedRelationshipTable(self, name)
    self._DrGBaseDefinedRelationships[name] = self._DrGBaseDefinedRelationships[name] or {}
    return self._DrGBaseDefinedRelationships[name]
  end
  local function GetDefinedRelationship(self, type, value)
    local rel = DefinedRelationshipTable(self, type)[value]
    if rel then return rel.disp, rel.prio
    else return D_NU, 1 end
  end
  local function SetDefinedRelationship(self, type, value, disp, prio)
    if disp == D_NU and prio == 1 then DefinedRelationshipTable(self, type)[value] = nil else
      DefinedRelationshipTable(self, type)[value] = {disp = CheckDisp(disp), prio = CheckPrio(prio)}
    end
    if type == "Entity" then self:UpdateRelationshipWith(value)
    else self:UpdateRelationships() end
  end
  local function AddDefinedRelationship(self, type, value, disp, prio)
    prio = CheckPrio(prio)
    local _, cprio = GetDefinedRelationship(self, type, value)
    if cprio > prio then return false end
    SetDefinedRelationship(self, type, value, disp, prio)
    return true
  end
  local function ResetDefinedRelationship(self, type, value)
    return SetDefinedRelationship(self, type, value, D_NU, 1)
  end

  function ENT:GetDefaultRelationship()
    return CheckDisp(self.DefaultRelationship), 1
  end
  function ENT:SetDefaultRelationship(disp)
    self.DefaultRelationship = disp
    self:UpdateRelationships()
  end

  function ENT:GetEntityRelationship(ent)
    return GetDefinedRelationship(self, "Entity", ent)
  end
  function ENT:SetEntityRelationship(ent, disp, prio)
    return SetDefinedRelationship(self, "Entity", ent, disp, prio)
  end
  function ENT:AddEntityRelationship(ent, disp, prio)
    return AddDefinedRelationship(self, "Entity", ent, disp, prio)
  end
  function ENT:ResetEntityRelationship(ent)
    return ResetDefinedRelationship(self, "Entity", ent)
  end

  function ENT:GetClassRelationship(class)
    return GetDefinedRelationship(self, "Class", string.lower(class))
  end
  function ENT:SetClassRelationship(class, disp, prio)
    return SetDefinedRelationship(self, "Class", string.lower(class), disp, prio)
  end
  function ENT:AddClassRelationship(class, disp, prio)
    return AddDefinedRelationship(self, "Class", string.lower(class), disp, prio)
  end
  function ENT:ResetClassRelationship(class)
    return ResetDefinedRelationship(self, "Class", string.lower(class))
  end

  function ENT:GetOwnClassRelationship()
    return self:GetClassRelationship(self:GetClass())
  end
  function ENT:SetOwnClassRelationship(disp, prio)
    return self:SetClassRelationship(self:GetClass(), disp, prio)
  end
  function ENT:AddOwnClassRelationship(disp, prio)
    return self:AddClassRelationship(self:GetClass(), disp, prio)
  end
  function ENT:ResetOwnClassRelationship()
    return self:ResetClassRelationship(self:GetClass())
  end

  function ENT:GetPlayersRelationship()
    return self:GetClassRelationship("player")
  end
  function ENT:SetPlayersRelationship(disp, prio)
    return self:SetClassRelationship("player", disp, prio)
  end
  function ENT:AddPlayersRelationship(disp, prio)
    return self:AddClassRelationship("player", disp, prio)
  end
  function ENT:ResetPlayersRelationship()
    return self:ResetClassRelationship("player")
  end

  function ENT:GetModelRelationship(model)
    if not isstring(model) then return D_ER, 1 end
    return GetDefinedRelationship(self, "Model", string.lower(model))
  end
  function ENT:SetModelRelationship(model, disp, prio)
    if not isstring(model) then return end
    return SetDefinedRelationship(self, "Model", string.lower(model), disp, prio)
  end
  function ENT:AddModelRelationship(model, disp, prio)
    if not isstring(model) then return end
    return AddDefinedRelationship(self, "Model", string.lower(model), disp, prio)
  end
  function ENT:ResetModelRelationship(model)
    if not isstring(model) then return end
    return ResetDefinedRelationship(self, "Model", string.lower(model))
  end

  function ENT:GetOwnModelRelationship()
    return self:GetModelRelationship(self:GetModel())
  end
  function ENT:SetOwnModelRelationship(disp, prio)
    return self:SetModelRelationship(self:GetModel(), disp, prio)
  end
  function ENT:AddOwnModelRelationship(disp, prio)
    return self:AddModelRelationship(self:GetModel(), disp, prio)
  end
  function ENT:ResetOwnModelRelationship()
    return self:ResetModelRelationship(self:GetModel())
  end

  function ENT:GetFactionRelationship(faction)
    return GetDefinedRelationship(self, "Faction", string.upper(faction))
  end
  function ENT:SetFactionRelationship(faction, disp, prio)
    return SetDefinedRelationship(self, "Faction", string.upper(faction), disp, prio)
  end
  function ENT:AddFactionRelationship(faction, disp, prio)
    return AddDefinedRelationship(self, "Faction", string.upper(faction), disp, prio)
  end
  function ENT:ResetFactionRelationship(faction)
    return ResetDefinedRelationship(self, "Faction", string.upper(faction))
  end

  function ENT:IsFrightening()
    return tobool(self.Frightening)
  end
  function ENT:SetFrightening(frightening)
    local old = self:IsFrightening()
    self.Frightening = tobool(frightening)
    if old == self.Frightening then return end
    for ent in EntitiesList() do
      if not ent:IsNPC() then continue end
      self:UpdateRelationshipWith(ent)
    end
  end

  ENT._DrGBaseIgnoredEntities = {}

  local NPC_STATES_IGNORED = {
    [NPC_STATE_PLAYDEAD] = true,
    [NPC_STATE_DEAD] = true
  }
  function ENT:IsIgnored(ent)
    if ent:IsPlayer() and not ent:Alive() then return true end
    if ent:IsPlayer() and GetConVar("ai_ignoreplayers"):GetBool() then return true end
    if ent:IsFlagSet(FL_NOTARGET) then return true end
    if ent.IsVJBaseSNPC and ent.VJ_NoTarget then return true end
    if ent.CPTBase_NPC and ent.UseNotarget then return true end
    if ent:IsNPC() and NPC_STATES_IGNORED[ent:GetNPCState()] then return true end
    if (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) and ent:Health() <= 0 then return true end
    if ent.IsDrGNextbot and (ent:IsDown() or ent:IsDead()) then return true end
    if self:ShouldIgnore(ent) then return true end
    return self._DrGBaseIgnoredEntities[ent] or false
  end
  function ENT:SetIgnored(ent, ignored)
    self._DrGBaseIgnoredEntities[ent] = tobool(ignored)
  end

  -- Factions & Teams --

  function ENT:SetTeam(team)
    local current = self:Team()
    self:SetNW2Int("DrGBaseTeam", tonumber(team))
    if tonumber(team) ~= current then self:UpdateRelationships() end
  end

  ENT._DrGBaseFactions = {}

  function ENT:JoinFaction(faction)
    if self:IsInFaction(faction) then return end
    self._DrGBaseFactions[string.upper(faction)] = true
    self:AddFactionRelationship(faction, D_LI, 1)
    for _, nextbot in ipairs(DrGBase.GetNextbots()) do
      if nextbot == self then continue end
      nextbot:UpdateRelationshipWith(self)
    end
  end
  function ENT:JoinFactions(factions)
    for _, faction in ipairs(factions) do self:JoinFaction(faction) end
  end

  function ENT:LeaveFaction(faction)
    if not self:IsInFaction(faction) then return end
    self._DrGBaseFactions[string.upper(faction)] = nil
    local disp, prio = self:GetFactionRelationship(faction)
    if disp == D_LI and prio == 1 then self:ResetFactionRelationship(faction) end
    for _, nextbot in ipairs(DrGBase.GetNextbots()) do
      if nextbot == self then continue end
      nextbot:UpdateRelationshipWith(self)
    end
  end
  function ENT:LeaveFactions(factions)
    for _, faction in ipairs(factions) do self:LeaveFaction(faction) end
  end
  function ENT:LeaveAllFactions()
    return self:LeaveFactions(self:GetFactions())
  end

  function ENT:IsInFaction(faction)
    return self._DrGBaseFactions[string.upper(faction)] or false
  end
  function ENT:GetFactions()
    local factions = {}
    for faction, joined in pairs(self._DrGBaseFactions) do
      if not joined then return end
      table.insert(factions, faction)
    end
    return factions
  end

  -- Update --

  hook.Add("OnEntityCreated", "DrGBase_UpdateRelationshipWithNew", function(ent)
    timer.Simple(0, function()
      if not IsValid(ent) or not IsInEntitiesList(ent) then return end
      for _, nextbot in ipairs(DrGBase.GetNextbots()) do
        nextbot:UpdateRelationshipWith(ent)
      end
    end)
  end)

  function ENT:UpdateRelationships()
    for ent in EntitiesList() do
      self:UpdateRelationshipWith(ent)
    end
  end
  function ENT:UpdateRelationshipWith(ent)
    if not IsValid(ent) or ent == self then return D_ER, 1 end
    local default_disp
    if IsTarget(ent) then
      default_disp = self:GetDefaultRelationship()
    else default_disp = D_NU end
    local ent_disp, ent_prio = self:GetEntityRelationship(ent)
    local class_disp, class_prio = self:GetClassRelationship(ent:GetClass())
    local model_disp, model_prio = self:GetModelRelationship(ent:GetModel())
    local custom_disp, custom_prio = CheckDispPrio(self:CustomRelationship(ent))
    local relationships = {HighestRelationship({
      {disp = default_disp, prio = 1}, {disp = ent_disp, prio = ent_prio},
      {disp = class_disp, prio = class_prio}, {disp = model_disp, prio = model_prio},
      {disp = custom_disp, prio = custom_prio}
    })}
    for faction, relationship in pairs(DefinedRelationshipTable(self, "Faction")) do
      if relationship.disp == D_ER or relationship.prio < relationships[1].prio then continue end
      local def = DEFAULT_FACTIONS[ent:GetClass()]
      if def == faction then table.insert(relationships, relationship) end
      if ent:IsPlayer() then
        if ent:DrG_IsInFaction(faction) then table.insert(relationships, relationship) end
      elseif ent.IsDrGNextbot then
        if ent:IsInFaction(faction) then table.insert(relationships, relationship) end
      elseif ent:DrG_IsSanic() then
        if faction == FACTION_SANIC then table.insert(relationships, relationship) end
      elseif ent.IsVJBaseSNPC then
        for _, class in ipairs(ent.VJ_NPC_Class) do
          if string.upper(class) == faction then
            table.insert(relationships, relationship)
            break
          end
        end
      elseif ent.CPTBase_NPC or ent.IV04NextBot then
        if string.upper(ent.Faction) == faction then table.insert(relationships, relationship) end
      end
    end
    local highest = HighestRelationship(relationships)
    SetRelationship(self, ent, highest.disp, highest.prio)
    return highest.disp, highest.prio
  end

  -- Getters --

  function ENT:GetRelationship(ent, absolute)
    local rel = self._DrGBaseRelationships[ent]
    if rel then
      if not absolute and self:IsIgnored(ent) then return D_NU, rel.prio
      else return rel.disp, rel.prio end
    else return D_NU, 1 end
  end
  function ENT:IsAlly(ent)
    return self:GetRelationship(ent) == D_LI
  end
  function ENT:IsEnemy(ent)
    return self:GetRelationship(ent) == D_HT
  end
  function ENT:IsAfraidOf(ent)
    return self:GetRelationship(ent) == D_FR
  end
  function ENT:IsHostile(ent)
    local disp = self:GetRelationship(ent)
    return disp == D_HT or disp == D_FR
  end
  function ENT:IsNeutral(ent)
    return self:GetRelationship(ent) == D_NU
  end

  -- iterators
  function ENT:EntityIterator(disp, spotted)
    local cor
    if istable(disp) then
      cor = coroutine.create(function()
        for _, dis in ipairs(disp) do
          local iterator = self:EntityIterator(dis, spotted)
          local ent = iterator()
          while ent do
            coroutine.yield(ent)
            ent = iterator()
          end
        end
      end)
    elseif IsCachedDisp(disp) then
      if self:IsOmniscient() then
        cor = coroutine.create(function()
          if spotted == false then return end
          for ent in pairs(self._DrGBaseRelationshipCaches[disp]) do
            if not IsValid(ent) then continue end
            if self:IsIgnored(ent) then continue end
            coroutine.yield(ent)
          end
        end)
      elseif spotted then
        cor = coroutine.create(function()
          for ent in pairs(self._DrGBaseRelationshipCachesSpotted[disp]) do
            if not IsValid(ent) then continue end
            if self:IsIgnored(ent) then continue end
            coroutine.yield(ent)
          end
        end)
      else
        cor = coroutine.create(function()
          for ent in pairs(self._DrGBaseRelationshipCaches[disp]) do
            if not IsValid(ent) then continue end
            if isbool(spotted) and self:HasSpotted(ent) then continue end
            if self:IsIgnored(ent) then continue end
            coroutine.yield(ent)
          end
        end)
      end
    elseif disp == D_NU or disp == D_ER then
      cor = coroutine.create(function()
        for ent in EntitiesList() do
          if not IsValid(ent) then continue end
          if self:GetRelationship(ent) ~= disp then continue end
          if isbool(spotted) and self:HasSpotted(ent) ~= tobool(spotted) then continue end
          coroutine.yield(ent)
        end
      end)
    else return function() end end
    return function()
      local _, res = coroutine.resume(cor)
      return res
    end
  end
  function ENT:AllyIterator(spotted)
    return self:EntityIterator(D_LI, spotted)
  end
  function ENT:EnemyIterator(spotted)
    return self:EntityIterator(D_HT, spotted)
  end
  function ENT:AfraidOfIterator(spotted)
    return self:EntityIterator(D_FR, spotted)
  end
  function ENT:HostileIterator(spotted)
    return self:EntityIterator({D_HT, D_FR}, spotted)
  end
  function ENT:NeutralIterator(spotted)
    return self:EntityIterator(D_NU, spotted)
  end

  -- get entities
  function ENT:GetEntities(disp, spotted)
    local entities = {}
    for ent in self:EntityIterator(disp, spotted) do
      table.insert(entities, ent)
    end
    return entities
  end
  function ENT:GetAllies(spotted)
    return self:GetEntities(D_LI, spotted)
  end
  function ENT:GetEnemies(spotted)
    return self:GetEntities(D_HT, spotted)
  end
  function ENT:GetAfraidOf(spotted)
    return self:GetEntities(D_FR, spotted)
  end
  function ENT:GetHostiles(spotted)
    return self:GetEntities({D_HT, D_FR}, spotted)
  end
  function ENT:GetNeutrals(spotted)
    return self:GetEntities(D_NU, spotted)
  end

  -- number of entities left
  function ENT:EntitiesLeft(disp, spotted)
    return #self:GetEntities(disp, spotted)
  end
  function ENT:AlliesLeft(spotted)
    return self:EntitiesLeft(D_LI, spotted)
  end
  function ENT:EnemiesLeft(spotted)
    return self:EntitiesLeft(D_HT, spotted)
  end
  function ENT:AfraidOfLeft(spotted)
    return self:Entitiesleft(D_FR, spotted)
  end
  function ENT:HostilesLeft(spotted)
    return self:Entitiesleft({D_HT, D_FR}, spotted)
  end
  function ENT:NeutralsLeft(spotted)
    return self:EntitiesLeft(D_NU, spotted)
  end

  -- get closest entity
  function ENT:GetClosestEntity(disp, spotted)
    local closest = NULL
    for ent in self:EntityIterator(disp, spotted) do
      if not IsValid(closest) or
      self:GetRangeSquaredTo(ent) < self:GetRangeSquaredTo(closest) then
        closest = ent
      end
    end
    return closest
  end
  function ENT:GetClosestAlly(spotted)
    return self:GetClosestEntity(D_LI, spotted)
  end
  function ENT:GetClosestEnemy(spotted)
    return self:GetClosestEntity(D_HT, spotted)
  end
  function ENT:GetClosestAfraidOf(spotted)
    return self:GetClosestEntity(D_FR, spotted)
  end
  function ENT:GetClosestHostile(spotted)
    return self:GetClosestEntity({D_HT, D_FR}, spotted)
  end
  function ENT:GetClosestNeutral(spotted)
    return self:GetClosestEntity(D_NU, spotted)
  end

  -- Hooks --

  function ENT:CustomRelationship() end
  function ENT:ShouldIgnore() end
  function ENT:OnRelationshipChange() end

end