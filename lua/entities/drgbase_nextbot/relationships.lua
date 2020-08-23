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

  -- Setters --

  ENT._DrGBaseRelationships = {}
  ENT._DrGBaseRelationshipCaches = {[D_LI] = {}, [D_HT] = {}, [D_FR] = {}}
  ENT._DrGBaseRelationshipCachesDetected = {[D_LI] = {}, [D_HT] = {}, [D_FR] = {}}

  local function SetRelationship(self, ent, disp, prio)
    if not IsValid(ent) then return end
    if not IsValidDisp(disp) then return end
    if IsCachedDisp(disp) then
      self._DrGBaseRelationshipCaches[D_LI][ent] = nil
      self._DrGBaseRelationshipCaches[D_HT][ent] = nil
      self._DrGBaseRelationshipCaches[D_FR][ent] = nil
      self._DrGBaseRelationshipCaches[disp][ent] = true
      if self._DrGBaseDetected[ent] then
        self._DrGBaseRelationshipCachesDetected[D_LI][ent] = nil
        self._DrGBaseRelationshipCachesDetected[D_HT][ent] = nil
        self._DrGBaseRelationshipCachesDetected[D_FR][ent] = nil
        self._DrGBaseRelationshipCachesDetected[disp][ent] = true
      end
      ent:CallOnRemove("DrGBaseRemoveFromDrGNextbot"..self:GetCreationID().."RelationshipCache", function()
        if not IsValid(self) then return end
        self._DrGBaseRelationshipCaches[disp][ent] = nil
        self._DrGBaseRelationshipCachesDetected[disp][ent] = nil
      end)
    else
      self._DrGBaseRelationshipCaches[D_LI][ent] = nil
      self._DrGBaseRelationshipCaches[D_HT][ent] = nil
      self._DrGBaseRelationshipCaches[D_FR][ent] = nil
      self._DrGBaseRelationshipCachesDetected[D_LI][ent] = nil
      self._DrGBaseRelationshipCachesDetected[D_HT][ent] = nil
      self._DrGBaseRelationshipCachesDetected[D_FR][ent] = nil
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
    local entities = ents.GetAll()
    for i = 1, #entities do
      if not entities[i]:IsNPC() then continue end
      self:UpdateRelationshipWith(entities[i])
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
    local nextbots = DrGBase.GetNextbots()
    for i = 1, #nextbots do
      local nextbot = nextbots[i]
      if nextbot == self then continue end
      nextbot:UpdateRelationshipWith(self)
    end
  end
  function ENT:JoinFactions(factions)
    for i = 1, #factions do self:JoinFaction(factions[i]) end
  end

  function ENT:LeaveFaction(faction)
    if not self:IsInFaction(faction) then return end
    self._DrGBaseFactions[string.upper(faction)] = nil
    local disp, prio = self:GetFactionRelationship(faction)
    if disp == D_LI and prio == 1 then self:ResetFactionRelationship(faction) end
    local nextbots = DrGBase.GetNextbots()
    for i = 1, #nextbots do
      local nextbot = nextbots[i]
      if nextbot == self then continue end
      nextbot:UpdateRelationshipWith(self)
    end
  end
  function ENT:LeaveFactions(factions)
    for i = 1, #factions do self:LeaveFaction(factions[i]) end
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
      if not IsValid(ent) then return end
      local nextbots = DrGBase.GetNextbots()
      for i = 1, #nextbots do
        nextbots[i]:UpdateRelationshipWith(ent)
      end
    end)
  end)

  function ENT:UpdateRelationships()
    if not self._DrGBaseRelationshipSystemReady then return end
    local entities = ents.GetAll()
    for i = 1, #entities do
      self:UpdateRelationshipWith(entities[i])
    end
  end
  function ENT:UpdateRelationshipWith(ent)
    if not self._DrGBaseRelationshipSystemReady then return D_ER, 1 end
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
    for faction, rel in pairs(DefinedRelationshipTable(self, "Faction")) do
      if rel.disp == D_ER or rel.prio < relationships[1].prio then continue end
      local def = DEFAULT_FACTIONS[ent:GetClass()]
      if def == faction then
        table.insert(relationships, rel)
      elseif ent:IsPlayer() then
        if ent:DrG_IsInFaction(faction) then table.insert(relationships, rel) end
      elseif ent.IsDrGNextbot then
        if ent:IsInFaction(faction) then table.insert(relationships, rel) end
      elseif ent:DrG_IsSanic() then
        if faction == FACTION_SANIC then table.insert(relationships, rel) end
      elseif ent.IsVJBaseSNPC then
        for i = 1, #ent.VJ_NPC_Class do
          if string.upper(ent.VJ_NPC_Class[i]) == faction then
            table.insert(relationships, rel)
            break
          end
        end
      elseif ent.CPTBase_NPC or ent.IV04NextBot then
        if string.upper(ent.Faction) == faction then table.insert(relationships, rel) end
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
  local function EntityIterator(self, disp, detected)
    local cor
    if disp == "hostile" then
      cor = coroutine.create(function()
        for ent in self:EnemyIterator(detected) do coroutine.yield(ent) end
        for ent in self:AfraidOfIterator(detected) do coroutine.yield(ent) end
      end)
    elseif IsCachedDisp(disp) then
      if detected then
        if not self:IsOmniscient() then
          cor = coroutine.create(function()
            for ent in pairs(self._DrGBaseRelationshipCachesDetected[disp]) do
              if not IsValid(ent) then continue end
              if self:IsIgnored(ent) then continue end
              coroutine.yield(ent)
            end
          end)
        else return EntityIterator(self, disp) end
      else
        cor = coroutine.create(function()
          for ent in pairs(self._DrGBaseRelationshipCaches[disp]) do
            if not IsValid(ent) then continue end
            if isbool(detected) and self:HasDetected(ent) ~= detected then continue end
            if self:IsIgnored(ent) then continue end
            coroutine.yield(ent)
          end
        end)
      end
    else
      cor = coroutine.create(function()
        local entities = ents.GetAll()
        for i = 1, #entities do
          local ent = entities[i]
          if not IsValid(ent) then continue end
          if isbool(detected) and self:HasDetected(ent) ~= detected then continue end
          if self:GetRelationship(ent) ~= disp then continue end
          coroutine.yield(ent)
        end
      end)
    end
    return function()
      local _, res = coroutine.resume(cor)
      return res
    end
  end
  function ENT:AllyIterator(detected)
    return EntityIterator(self, D_LI, detected)
  end
  function ENT:EnemyIterator(detected)
    return EntityIterator(self, D_HT, detected)
  end
  function ENT:AfraidOfIterator(detected)
    return EntityIterator(self, D_FR, detected)
  end
  function ENT:HostileIterator(detected)
    return EntityIterator(self, "hostile", detected)
  end
  function ENT:NeutralIterator(detected)
    return EntityIterator(self, D_NU, detected)
  end

  -- get entities
  local function GetEntities(self, disp, detected)
    local entities = {}
    for ent in EntityIterator(self, disp, detected) do
      table.insert(entities, ent)
    end
    return entities
  end
  function ENT:GetAllies(detected)
    return GetEntities(self, D_LI, detected)
  end
  function ENT:GetEnemies(detected)
    return GetEntities(self, D_HT, detected)
  end
  function ENT:GetAfraidOf(detected)
    return GetEntities(self, D_FR, detected)
  end
  function ENT:GetHostiles(detected)
    return GetEntities(self, "hostile", detected)
  end
  function ENT:GetNeutrals(detected)
    return GetEntities(self, D_NU, detected)
  end

  -- get closest entity
  local function GetClosestEntity(self, disp, detected)
    local closest = NULL
    for ent in EntityIterator(self, disp, detected) do
      if not IsValid(closest) or
      self:GetRangeSquaredTo(ent) < self:GetRangeSquaredTo(closest) then
        closest = ent
      end
    end
    return closest
  end
  function ENT:GetClosestAlly(detected)
    return GetClosestEntity(self, D_LI, detected)
  end
  function ENT:GetClosestEnemy(detected)
    return GetClosestEntity(self, D_HT, detected)
  end
  function ENT:GetClosestAfraidOf(detected)
    return GetClosestEntity(self, D_FR, detected)
  end
  function ENT:GetClosestHostile(detected)
    return GetClosestEntity(self, "hostile", detected)
  end
  function ENT:GetClosestNeutral(detected)
    return GetClosestEntity(self, D_NU, detected)
  end

  -- number of entities left
  local function GetNumberOfEntities(self, disp, detected)
    return #GetEntities(self, disp, detected)
  end
  function ENT:GetNumberOfAllies(detected)
    return GetNumberOfEntities(self, D_LI, detected)
  end
  function ENT:GetNumberOfEnemies(detected)
    return GetNumberOfEntities(self, D_HT, detected)
  end
  function ENT:GetNumberOfAfraidOf(detected)
    return GetNumberOfEntities(self, D_FR, detected)
  end
  function ENT:GetNumberOfHostiles(detected)
    return GetNumberOfEntities(self, "hostile", detected)
  end
  function ENT:GetNumberOfNeutralsLeft(detected)
    return GetNumberOfEntities(self, D_NU, detected)
  end

  -- Hooks --

  function ENT:CustomRelationship() end
  function ENT:ShouldIgnore() end
  function ENT:OnRelationshipChange() end

  -- NPC Aliases --

  function ENT:Disposition(ent)
    local disp = self:GetRelationship(ent)
    return disp
  end
  function ENT:AddRelationship(str)
    local split = string.Explode("[%s]+", str, true)
    if #split ~= 3 then return end
    local class = split[1]
    local relationship = split[2]
    if relationship == "D_ER" then relationship = D_ER
    elseif relationship == "D_HT" then relationship = D_HT
    elseif relationship == "D_FR" then relationship = D_FR
    elseif relationship == "D_LI" then relationship = D_LI
    elseif relationship == "D_NU" then relationship = D_NU
    else return end
    local val = tonumber(split[3])
    if val ~= val then return end
    self:AddClassRelationship(class, relationship, val)
  end

end