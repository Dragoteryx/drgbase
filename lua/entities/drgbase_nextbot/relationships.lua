
local MaxRadius = CreateConVar("drgbase_max_radius", "5000")

-- Handlers --

function ENT:_InitRelationships()
  if CLIENT then return end
  self._DrGBaseRelationships = {}
  self._DrGBaseIsConsidered = {}
  self._DrGBaseConsideredEntities = {}
  self._DrGBaseEntityCaches = {
    [D_LI] = {}, [D_HT] = {}, [D_FR] = {}
  }
  self._DrGBaseIgnoredEntities = {}
  self._DrGBaseDefaultRelationship = D_NU
  self._DrGBaseEntityRelationships = {}
  self._DrGBaseClassRelationships = {}
  self._DrGBaseModelRelationships = {}
  self._DrGBaseFactionRelationships = {}
  self._DrGBaseFrightening = tobool(self.Frightening)
  self:UpdateRelationships()
  self._DrGBaseFactions = {}
  for i, faction in ipairs(self.Factions) do
    self:JoinFaction(faction)
  end
end

if SERVER then

  local DEFAULT_PRIORITY = 1
  local DISP_PRIORITIES = {
    [D_LI] = 4,
    [D_HT] = 3,
    [D_FR] = 2,
    [D_NU] = 1,
    [D_ER] = 0
  }
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

  local function IsValidDisposition(disp)
    return isnumber(disp) and table.HasValue({D_LI, D_HT, D_FR, D_NU}, disp)
  end

  -- Getters/setters --

  function ENT:IsIgnored(ent)
    return self._DrGBaseIgnoredEntities[ent:GetCreationID()] or false
  end
  function ENT:SetIgnored(ent, bool)
    self._DrGBaseIgnoredEntities[ent:GetCreationID()] = tobool(bool)
  end

  function ENT:IsFrightening()
    return self._DrGBaseFrightening or false
  end
  function ENT:SetFrightening(bool)
    self._DrGBaseFrightening = tobool(bool)
    self:UpdateRelationships()
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
  function ENT:IsNeutral(ent)
    return self:GetRelationship(ent) == D_NU
  end

  function ENT:IsConsidered(ent)
    return self._DrGBaseIsConsidered[ent:GetCreationID()] or false
  end
  function ENT:ConsideredEntities(original)
    if not original then
      local entities = {}
      for i, ent in ipairs(self._DrGBaseConsideredEntities) do
        if IsValid(ent) then table.insert(entities, ent) end
      end
      return entities
    else return self._DrGBaseConsideredEntities end
  end

  -- Get/set relationship
  function ENT:GetRelationship(ent, absolute)
    if not IsValid(ent) then return D_ER end
    if self == ent then return D_ER end
    if not absolute then
      if not self:IsConsidered(ent) then return D_NU end
      if self:IsIgnored(ent) then return D_NU end
      if ent:IsFlagSet(FL_NOTARGET) then return D_NU end
      if ent:IsPlayer() and (not ent:Alive() or GetConVar("ai_ignoreplayers"):GetBool()) then return D_NU end
      if (ent:IsPlayer() or ent:IsNPC() or ent.Type == "nextbot") and ent:Health() <= 0 then return D_NU end
      if ent.IsDrGNextbot and (ent:IsDown() or ent:IsDead()) then return D_NU end
    end
    return self._DrGBaseRelationships[ent:GetCreationID()] or D_NU
  end
  function ENT:_SetRelationship(ent, disp)
    if not IsValid(ent) or ent == self then return end
    local disps = {D_LI, D_HT, D_FR}
    if disp == D_NU and not self:_ConsiderEntity(ent) then disp = nil end
    if IsValidDisposition(disp) then
      local old = self:GetRelationship(ent, true)
      if old == disp then return end
      self._DrGBaseRelationships[ent:GetCreationID()] = disp
      if not self:IsConsidered(ent) then
        self._DrGBaseIsConsidered[ent:GetCreationID()] = true
        table.insert(self._DrGBaseConsideredEntities, ent)
      end
      for i, disp2 in ipairs(disps) do
        if disp ~= disp2 then
          table.RemoveByValue(self._DrGBaseEntityCaches[disp2], ent)
        else table.insert(self._DrGBaseEntityCaches[disp2], ent) end
      end
      if ent:IsNPC() then self:_UpdateNPCRelationship(ent, disp) end
      if old ~= disp then self:OnRelationshipChange(ent, old or D_NU, disp) end
    elseif disp == nil or disp == D_ER then
      if not self:IsConsidered(ent) then return end
      local old = self:GetRelationship(ent, true)
      self._DrGBaseRelationships[ent:GetCreationID()] = nil
      self._DrGBaseIsConsidered[ent:GetCreationID()] = false
      table.RemoveByValue(self._DrGBaseConsideredEntities, ent)
      for i, disp2 in ipairs(disps) do
        table.RemoveByValue(self._DrGBaseEntityCaches[disp2], ent)
      end
      if ent:IsNPC() then self:_UpdateNPCRelationship(ent, D_NU) end
      if old ~= D_NU then self:OnRelationshipChange(ent, old, D_NU) end
    end
    self:UpdateBehaviourTree()
  end

  -- Default
  function ENT:GetDefaultRelationship()
    return self._DrGBaseDefaultRelationship, DEFAULT_PRIORITY
  end
  function ENT:SetDefaultRelationship(disp)
    if not IsValidDisposition(disp) then return end
    self._DrGBaseDefaultRelationship = disp
    self:UpdateRelationships()
  end

  -- Entity
  function ENT:GetEntityRelationship(ent)
    if not IsValid(ent) then return D_ER, DEFAULT_PRIORITY end
    local rel = self._DrGBaseEntityRelationships[ent:GetCreationID()]
    if rel == nil then return D_NU, DEFAULT_PRIORITY end
    return rel.disp, rel.prio
  end
  function ENT:SetEntityRelationship(ent, disp, prio)
    if not IsValid(ent) then return end
    if not IsValidDisposition(disp) then return end
    self._DrGBaseEntityRelationships[ent:GetCreationID()] = {
      disp = disp, prio = prio or DEFAULT_PRIORITY
    }
    self:UpdateRelationshipWith(ent)
  end
  function ENT:AddEntityRelationship(ent, disp, prio)
    if not IsValid(ent) then return end
    local gdisp, gprio = self:GetEntityRelationship(ent)
    if not isnumber(prio) or prio >= gprio then
      self:SetEntityRelationship(ent, disp, prio)
    end
  end

  -- Class
  function ENT:GetClassRelationship(class)
    if not isstring(class) then return D_ER, DEFAULT_PRIORITY end
    local rel = self._DrGBaseClassRelationships[string.lower(class)]
    if rel == nil then return D_NU, DEFAULT_PRIORITY end
    return rel.disp, rel.prio
  end
  function ENT:SetClassRelationship(class, disp, prio)
    if not isstring(class) then return end
    if not IsValidDisposition(disp) then return end
    self._DrGBaseClassRelationships[string.lower(class)] = {
      disp = disp, prio = prio or DEFAULT_PRIORITY
    }
    self:UpdateRelationships()
  end
  function ENT:AddClassRelationship(class, disp, prio)
    if not isstring(class) then return end
    local gdisp, gprio = self:GetClassRelationship(class)
    if not isnumber(prio) or prio >= gprio then
      self:SetClassRelationship(class, disp, prio)
    end
  end

  -- Players
  function ENT:GetPlayersRelationship()
    return self:GetClassRelationship("player")
  end
  function ENT:SetPlayersRelationship(disp, prio)
    return self:SetClassRelationship("player", disp, prio)
  end
  function ENT:AddPlayersRelationship(disp, prio)
    return self:AddClassRelationship("player", disp, prio)
  end

  -- Same class
  function ENT:GetSelfClassRelationship()
    return self:GetClassRelationship(self:GetClass())
  end
  function ENT:SetSelfClassRelationship(disp, prio)
    return self:SetClassRelationship(self:GetClass(), disp, prio)
  end
  function ENT:AddSelfClassRelationship(disp, prio)
    return self:AddClassRelationship(self:GetClass(), disp, prio)
  end

  -- Model
  function ENT:GetModelRelationship(model)
    if not isstring(model) then return D_ER, DEFAULT_PRIORITY end
    local rel = self._DrGBaseModelRelationships[string.lower(model)]
    if rel == nil then return D_NU, DEFAULT_PRIORITY end
    return rel.disp, rel.prio
  end
  function ENT:SetModelRelationship(model, disp, prio)
    if not isstring(model) then return end
    if not IsValidDisposition(disp) then return end
    self._DrGBaseModelRelationships[string.lower(model)] = {
      disp = disp, prio = prio or DEFAULT_PRIORITY
    }
    self:UpdateRelationships()
  end
  function ENT:AddModelRelationship(model, disp, prio)
    if not isstring(model) then return end
    local gdisp, gprio = self:GetModelRelationship(model)
    if not isnumber(prio) or prio >= gprio then
      self:SetModelRelationship(model, disp, prio)
    end
  end

  -- Same model
  function ENT:GetSelfModelRelationship()
    return self:GetModelRelationship(self:GetModel())
  end
  function ENT:SetSelfModelRelationship(disp, prio)
    return self:SetModelRelationship(self:GetModel(), disp, prio)
  end
  function ENT:AddSelfModelRelationship(disp, prio)
    return self:AddModelRelationship(self:GetModel(), disp, prio)
  end

  -- Factions
  function ENT:GetFactionRelationship(faction)
    if not isstring(faction) then return D_ER, DEFAULT_PRIORITY end
    local rel = self._DrGBaseFactionRelationships[string.upper(faction)]
    if rel == nil then return D_NU, DEFAULT_PRIORITY end
    return rel.disp, rel.prio
  end
  function ENT:SetFactionRelationship(faction, disp, prio)
    if not isstring(faction) then return end
    if not IsValidDisposition(disp) then return end
    self._DrGBaseFactionRelationships[string.upper(faction)] = {
      disp = disp, prio = prio or DEFAULT_PRIORITY
    }
    self:UpdateRelationships()
  end
  function ENT:AddFactionRelationship(faction, disp, prio)
    if not isstring(faction) then return end
    local gdisp, gprio = self:GetFactionRelationship(faction)
    if not isnumber(prio) or prio >= gprio then
      self:SetFactionRelationship(faction, disp, prio)
    end
  end

  -- Functions --

  -- Update relationships
  local function HighestRelationship(relationships)
    table.sort(relationships, function(rel1, rel2)
      if rel1.disp == nil then return false end
      if rel2.disp == nil then return true end
      if rel1.prio > rel2.prio then return true
      elseif DISP_PRIORITIES[rel1.disp] > DISP_PRIORITIES[rel2.disp] then
        return true
      else return false end
    end)
    return relationships[1]
  end

  function ENT:UpdateRelationships()
    for i, ent in ipairs(ents.GetAll()) do
      if ent == self then continue end
      self:UpdateRelationshipWith(ent)
    end
  end
  function ENT:UpdateRelationshipWith(ent)
    if not IsValid(ent) or ent == self then return end
    if self:_ConsiderEntity(ent) then
      local default, defprio = self:GetDefaultRelationship()
      local entdisp, entprio = self:GetEntityRelationship(ent)
      local classdisp, classprio = self:GetClassRelationship(ent:GetClass())
      local modeldisp, modelprio = self:GetModelRelationship(ent:GetModel())
      local customdisp, customprio = self:CustomRelationship(ent)
      local relationships = {
        {disp = default, prio = defprio}, {disp = entdisp, prio = entprio},
        {disp = classdisp, prio = classprio}, {disp = modeldisp, prio = modelprio},
        {disp = customdisp or D_NU, prio = customprio or DEFAULT_PRIORITY}
      }
      relationships = {HighestRelationship(relationships)}
      for faction, relationship in pairs(self._DrGBaseFactionRelationships) do
        if relationship.disp == D_ER or relationship.prio < relationships[1].prio then continue end
        if ent:IsPlayer() then
          if ent:DrG_IsInFaction(faction) then
            table.insert(relationships, relationship)
          end
        elseif ent.IsDrGNextbot then
          if ent:IsInFaction(faction) then
            table.insert(relationships, relationship)
          end
        elseif ent:DrG_IsSanic() then
          if faction == FACTION_SANIC then
            table.insert(relationships, relationship)
            break
          end
        elseif ent.IsVJBaseSNPC then
          for i, class in ipairs(ent.VJ_NPC_Class) do
            if string.upper(class) ~= faction then continue end
            table.insert(relationships, relationship)
            break
          end
        elseif ent.CPTBase_NPC or ent.IV04NextBot then
          if string.upper(ent.Faction) == faction then
            table.insert(relationships, relationship)
            break
          end
        else
          local def = DEFAULT_FACTIONS[ent:GetClass()]
          if def == faction then
            table.insert(relationships, relationship)
            break
          end
        end
      end
      local relationship = HighestRelationship(relationships)
      self:_SetRelationship(ent, relationship.disp)
    else self:_SetRelationship(ent, nil) end
  end

  -- Factions
  function ENT:JoinFaction(faction)
    if self:IsInFaction(faction) then return end
    self._DrGBaseFactions[string.upper(faction)] = true
    self:SetFactionRelationship(faction, D_LI)
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      if nextbot == self then continue end
      nextbot:UpdateRelationshipWith(self)
    end
  end
  function ENT:LeaveFaction(faction)
    if not self:IsInFaction(faction) then return end
    self._DrGBaseFactions[string.upper(faction)] = nil
    local disp, prio = self:GetFactionRelationship(faction)
    if disp == D_LI and prio == DEFAULT_PRIORITY then
      self:SetFactionRelationship(faction, D_NU)
    end
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      if nextbot == self then continue end
      nextbot:UpdateRelationshipWith(self)
    end
  end
  function ENT:IsInFaction(faction)
    return self._DrGBaseFactions[string.upper(faction)] or false
  end
  function ENT:GetFactions()
    local factions = {}
    for faction, joined in pairs(self._DrGBaseFactions) do
      if joined then table.insert(factions, faction) end
    end
    return factions
  end
  function ENT:JoinFactions(factions)
    for i, faction in ipairs(factions) do
      self:JoinFaction(faction)
    end
  end
  function ENT:LeaveFactions(factions)
    for i, faction in ipairs(factions) do
      self:LeaveFaction(faction)
    end
  end
  function ENT:LeaveAllFactions()
    self:LeaveFactions(self:GetFactions())
  end

  -- Get entities
  function ENT:GetEntities(disp, spotted)
    if not IsValidDisposition(disp) then return {} end
    local maxradius = MaxRadius:GetFloat()^2
    local entities = {}
    local cache = disp == D_NU and self._DrGBaseConsideredEntities or self._DrGBaseEntityCaches[disp]
    for i, ent in ipairs(cache) do
      if not IsValid(ent) then continue end
      if self:GetRangeSquaredTo(ent) > maxradius then continue end
      if spotted and not self:HasSpottedEntity(ent) then continue end
      if self:GetRelationship(ent) == disp then
        table.insert(entities, ent)
      end
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
  function ENT:GetNeutrals(spotted)
    return self:GetEntities(D_NU, spotted)
  end

  -- Get closest entity
  function ENT:GetClosestEntity(disp, spotted)
    local entities = self:GetEntities(disp, spotted)
    table.sort(entities, function(ent1, ent2)
      return self:GetRangeSquaredTo(ent1) < self:GetRangeSquaredTo(ent2)
    end)
    return entities[1]
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
  function ENT:GetClosestNeutral(spotted)
    return self:GetClosestEntity(D_NU, spotted)
  end

  -- Number of entities left
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
  function ENT:NeutralsLeft(spotted)
    return self:EntitiesLeft(D_NU, spotted)
  end

  -- Hooks --

  function ENT:ShouldConsiderEntity() end
  function ENT:CustomRelationship() end
  function ENT:OnRelationshipChange() end

  -- Handlers --

  local CONSIDER_BLACKLIST = {
    ["npc_bullseye"] = true,
    ["npc_grenade_frag"] = true,
    ["npc_tripmine"] = true,
    ["npc_satchel"] = true
  }
  local CONSIDER_WHITELIST = {
    ["replicator_melon"] = true,
    ["replicator_worker"] = true,
    ["replicator_queen"] = true,
    ["replicator_queen_hive"] = true
  }
  function ENT:_ConsiderEntity(ent)
    if not IsValid(ent) then return false end
    local res = self:ShouldConsiderEntity(ent)
    if res == false then return false
    elseif res == true then return true end
    if CONSIDER_BLACKLIST[ent:GetClass()] then return false end
    if CONSIDER_WHITELIST[ent:GetClass()] then return true end
    if ent.DrGBaseShouldConsider then return true end
    if ent:IsPlayer() then return true end
    if ent:IsNPC() then return true end
    if ent.Type == "nextbot" then return true end
    if string.StartWith(ent:GetClass(), "npc_") then return true end
    if res then return true end
    return false
  end

  function ENT:_UpdateNPCRelationship(ent, relationship)
    if not IsValid(ent) or not ent:IsNPC() then return end
    if relationship == D_FR then relationship = D_HT
    elseif relationship == D_HT and self:IsFrightening() then
      relationship = D_FR
    end
    ent:AddEntityRelationship(self, relationship, 1)
    if ent.IsVJBaseSNPC then
      if (relationship == D_HT or relationship == D_FR) then
        if not table.HasValue(ent.VJ_AddCertainEntityAsEnemy, self) then
          table.insert(ent.VJ_AddCertainEntityAsEnemy, self)
        end
      else table.RemoveByValue(ent.VJ_AddCertainEntityAsEnemy, self) end
      if relationship == D_LI then
        if not table.HasValue(ent.VJ_AddCertainEntityAsFriendly, self) then
          table.insert(ent.VJ_AddCertainEntityAsFriendly, self)
        end
      else table.RemoveByValue(ent.VJ_AddCertainEntityAsFriendly, self) end
      self:_NotifyVJ(ent)
    end
  end

  function ENT:_NotifyVJ(ent)
    if ent:Health() > 1 then
      local bleeds = ent.Bleeds
      ent.Bleeds = false
      local health = ent:Health()
      local dmg = DamageInfo()
      dmg:SetDamage(1)
      dmg:SetAttacker(self)
      dmg:SetInflictor(self)
      dmg:SetDamageType(DMG_DIRECT)
      ent:TakeDamageInfo(dmg)
      ent:SetHealth(health)
      ent.Bleeds = bleeds
    end
  end

  hook.Add("OnEntityCreated", "DrGBaseNextbotRelationshipsInit", function(ent)
    timer.Simple(0, function()
      if not IsValid(ent) then return end
      for i, nextbot in ipairs(DrGBase.GetNextbots()) do
        nextbot:UpdateRelationshipWith(ent)
      end
    end)
  end)

  hook.Add("EntityRemoved", "DrGBaseNextbotRelationshipsRemove", function(ent)
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      nextbot:_SetRelationship(ent, nil)
    end
  end)

  -- Aliases --

  function ENT:Disposition(ent)
    return self:GetRelationship(ent)
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
