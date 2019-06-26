
-- Handlers --

local DEFAULT_DISP = D_NU
local DEFAULT_PRIO = 1
local DEFAULT_REL = {disp = DEFAULT_DISP, prio = DEFAULT_PRIO}
function ENT:_InitRelationships()
  if CLIENT then return end
  self._DrGBaseRelationships = table.DrG_Default({}, DEFAULT_REL)
  self._DrGBaseRelPriorities = table.DrG_Default({}, DEFAULT_PRIO)
  self._DrGBaseRelationshipCaches = {[D_LI] = {}, [D_HT] = {}, [D_FR] = {}}
  self._DrGBaseIgnoredEntities = {}
  self._DrGBaseDefaultRelationship = DEFAULT_DISP
  self._DrGBaseRelationshipDefiners = {
    ["entity"] = table.DrG_Default({}, DEFAULT_REL),
    ["class"] = table.DrG_Default({}, DEFAULT_REL),
    ["model"] = table.DrG_Default({}, DEFAULT_REL),
    ["faction"] = table.DrG_Default({}, DEFAULT_REL)
  }
  self._DrGBaseFrightening = tobool(self.Frightening)
  self._DrGBaseFactions = {}
  self:UpdateRelationships()
  self:JoinFactions(self.Factions)
end

if SERVER then

  local DISP_PRIORITIES = {
    [D_LI] = 4,
    [D_HT] = 3,
    [D_FR] = 2,
    [D_NU] = 1,
    [D_ER] = 0
  }
  local function HighestRelationship(relationships)
    table.sort(relationships, function(rel1, rel2)
      if rel1.prio > rel2.prio then return true
      elseif DISP_PRIORITIES[rel1.disp] > DISP_PRIORITIES[rel2.disp] then
        return true
      else return false end
    end)
    return relationships[1]
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

  -- Getters/setters --

  function ENT:GetRelationship(ent, absolute)
    if not IsValid(ent) then return D_ER, -1 end
    if self == ent then return D_ER, -1 end
    local disp = self._DrGBaseRelationships[ent]
    local prio = self._DrGBaseRelPriorities[ent]
    if not absolute then
      if self:IsIgnored(ent) then return D_NU, prio end
      if ent:IsFlagSet(FL_NOTARGET) then return D_NU, prio end
      if (ent:IsPlayer() or ent:IsNPC() or ent.Type == "nextbot") and ent:Health() <= 0 then return D_NU, prio end
      if ent.IsDrGNextbot and (ent:IsDown() or ent:IsDead()) then return D_NU, prio end
    end
    return disp, prio
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
  function ENT:_SetRelationship(ent, disp, prio)
    if not IsValid(ent) then return end
    self._DrGBaseRelPriorities[ent] = prio or DEFAULT_PRIO
    local curr = self:GetRelationship(ent)
    if curr == disp then return end
    if table.HasValue({D_LI, D_HT, D_FR}, curr) then
      table.RemoveByValue(self._DrGBaseRelationshipCaches[curr], ent)
    end
    for i, cdisp in ipairs({D_LI, D_HT, D_FR}) do
      if disp ~= cdisp then continue end
      self._DrGBaseRelationships[ent] = disp
      table.insert(self._DrGBaseRelationshipCaches[cdisp], ent)
      if ent:IsNPC() then self:_UpdateNPCRelationship(ent, disp) end
      return
    end
    if curr ~= DEFAULT_DISP then
      self._DrGBaseRelationships[ent] = DEFAULT_DISP
      if ent:IsNPC() then self:_UpdateNPCRelationship(ent, DEFAULT_DISP) end
    end
  end

  function ENT:IsIgnored(ent)
    if ent:IsPlayer() and not ent:Alive() then return true end
    if ent:IsPlayer() and GetConVar("ai_ignoreplayers"):GetBool() then return true end
    return self._DrGBaseIgnoredEntities[ent] or false
  end
  function ENT:SetIgnored(ent, bool)
    self._DrGBaseIgnoredEntities[ent] = tobool(bool)
  end

  function ENT:IsFrightening()
    return self._DrGBaseFrightening or false
  end
  function ENT:SetFrightening(bool)
    self._DrGBaseFrightening = tobool(bool)
    self:UpdateRelationships()
  end

  -- Functions --

  function ENT:GetDefaultRelationship()
    return self._DrGBaseDefaultRelationship, DEFAULT_PRIO
  end
  function ENT:SetDefaultRelationship(disp)
    self._DrGBaseDefaultRelationship = disp
    self:UpdateRelationships()
  end

  function ENT:_GetRelationshipDefiner(name, id)
    local rel = self._DrGBaseRelationshipDefiners[name][id]
    return rel.disp, rel.prio
  end
  function ENT:_SetRelationshipDefiner(name, id, disp, prio)
    self._DrGBaseRelationshipDefiners[name][id] = {
      disp = disp, prio = prio or DEFAULT_PRIO
    }
  end
  function ENT:_AddRelationshipDefiner(name, id, disp, prio)
    prio = prio or DEFAULT_PRIO
    local curr = self._DrGBaseRelationshipDefiners[name][id]
    if curr.prio > prio then return end
    self:_SetRelationshipDefiner(name, id, disp, prio)
  end

  -- Entity
  function ENT:GetEntityRelationship(ent)
    if not IsValid(ent) then return D_ER, -1 end
    return self:_GetRelationshipDefiner("entity", ent)
  end
  function ENT:SetEntityRelationship(ent, disp, prio)
    if not IsValid(ent) then return end
    local res = self:_SetRelationshipDefiner("entity", ent, disp, prio)
    self:UpdateRelationshipWith(ent)
    return res
  end
  function ENT:AddEntityRelationship(ent, disp, prio)
    if not IsValid(ent) then return end
    local res = self:_AddRelationshipDefiner("entity", ent, disp, prio)
    self:UpdateRelationshipWith(ent)
    return res
  end

  -- Class
  function ENT:GetClassRelationship(class)
    if not isstring(class) then return D_ER, -1 end
    class = string.lower(class)
    return self:_GetRelationshipDefiner("class", class)
  end
  function ENT:SetClassRelationship(class, disp, prio)
    if not isstring(class) then return end
    class = string.lower(class)
    local res = self:_SetRelationshipDefiner("class", class, disp, prio)
    self:UpdateRelationships()
    return res
  end
  function ENT:AddClassRelationship(class, disp, prio)
    if not isstring(class) then return end
    class = string.lower(class)
    local res = self:_AddRelationshipDefiner("class", class, disp, prio)
    self:UpdateRelationships()
    return res
  end

  function ENT:GetSelfClassRelationship()
    return self:GetClassRelationship(self:GetClass())
  end
  function ENT:SetSelfClassRelationship(disp, prio)
    return self:SetClassRelationship(self:GetClass(), disp, prio)
  end
  function ENT:AddSelfClassRelationship(disp, prio)
    return self:AddClassRelationship(self:GetClass(), disp, prio)
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

  -- Models
  function ENT:GetModelRelationship(model)
    if not isstring(model) then return D_ER, -1 end
    model = string.lower(model)
    return self:_GetRelationshipDefiner("model", model)
  end
  function ENT:SetModelRelationship(model, disp, prio)
    if not isstring(model) then return end
    model = string.lower(model)
    local res = self:_SetRelationshipDefiner("model", model, disp, prio)
    self:UpdateRelationships()
    return res
  end
  function ENT:AddModelRelationship(model, disp, prio)
    if not isstring(model) then return end
    model = string.lower(model)
    local res = self:_AddRelationshipDefiner("model", model, disp, prio)
    self:UpdateRelationships()
    return res
  end

  function ENT:GetSelfModelRelationship()
    return self:GetModelRelationship(self:GetModel())
  end
  function ENT:SetSelfModelRelationship(disp, prio)
    return self:GetModelRelationship(self:GetModel(), disp, prio)
  end
  function ENT:AddSelfModelRelationship(disp, prio)
    return self:AddModelRelationship(self:GetModel(), disp, prio)
  end

  -- Factions
  function ENT:GetFactionRelationship(faction)
    if not isstring(faction) then return D_ER, -1 end
    faction = string.upper(faction)
    return self:_GetRelationshipDefiner("faction", faction)
  end
  function ENT:SetFactionRelationship(faction, disp, prio)
    if not isstring(faction) then return end
    faction = string.upper(faction)
    local res = self:_SetRelationshipDefiner("faction", faction, disp, prio)
    self:UpdateRelationships()
    return res
  end
  function ENT:AddFactionRelationship(faction, disp, prio)
    if not isstring(faction) then return end
    faction = string.upper(faction)
    local res = self:_AddRelationshipDefiner("faction", faction, disp, prio)
    self:UpdateRelationships()
    return res
  end

  function ENT:JoinFaction(faction)
    if self:IsInFaction(faction) then return end
    self._DrGBaseFactions[string.upper(faction)] = true
    self:AddFactionRelationship(faction, D_LI)
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      if nextbot == self then continue end
      nextbot:UpdateRelationshipWith(self)
    end
  end
  function ENT:JoinFactions(factions)
    for i, faction in ipairs(factions) do self:JoinFaction(faction) end
  end

  function ENT:LeaveFaction(faction)
    if not self:IsInFaction(faction) then return end
    self._DrGBaseFactions[string.upper(faction)] = nil
    local disp, prio = self:GetFactionRelationship(faction)
    if disp == D_LI and prio == DEFAULT_PRIO then
      self:SetFactionRelationship(faction, D_NU)
    end
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      if nextbot == self then continue end
      nextbot:UpdateRelationshipWith(self)
    end
  end
  function ENT:LeaveFactions(factions)
    for i, faction in ipairs(factions) do self:LeaveFaction(faction) end
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

  -- Update
  function ENT:UpdateRelationships()
    for i, ent in ipairs(ents.GetAll()) do
      self:UpdateRelationshipWith(ent)
    end
  end
  function ENT:UpdateRelationshipWith(ent)
    if not IsValid(ent) then return end
    if ent == self then return end
    local default, defprio
    if not DrGBase.IsTarget(ent) then
      default = DEFAULT_DISP
      defprio = DEFAULT_PRIO
    else default, defprio = self:GetDefaultRelationship() end
    local entdisp, entprio = self:GetEntityRelationship(ent)
    local classdisp, classprio = self:GetClassRelationship(ent:GetClass())
    local modeldisp, modelprio = self:GetModelRelationship(ent:GetModel())
    local customdisp, customprio = self:CustomRelationship(ent)
    local relationships = {
      {disp = default, prio = defprio}, {disp = entdisp, prio = entprio},
      {disp = classdisp, prio = classprio}, {disp = modeldisp, prio = modelprio},
      {disp = customdisp or DEFAULT_DISP, prio = customprio or DEFAULT_PRIO}
    }
    relationships = {HighestRelationship(relationships)}
    for faction, relationship in pairs(self._DrGBaseRelationshipDefiners["faction"]) do
      if istable(faction) then continue end
      if relationship.disp == D_ER or relationship.prio < relationships[1].prio then continue end
      if ent:IsPlayer() then
        if ent:DrG_IsInFaction(faction) then table.insert(relationships, relationship) end
      elseif ent.IsDrGNextbot then
        if ent:IsInFaction(faction) then table.insert(relationships, relationship) end
      elseif ent:DrG_IsSanic() then
        if faction == FACTION_SANIC then table.insert(relationships, relationship) end
      elseif ent.IsVJBaseSNPC then
        for i, class in ipairs(ent.VJ_NPC_Class) do
          if string.upper(class) ~= faction then continue end
          table.insert(relationships, relationship)
          break
        end
      elseif ent.CPTBase_NPC or ent.IV04NextBot then
        if string.upper(ent.Faction) == faction then table.insert(relationships, relationship) end
      else
        local def = DEFAULT_FACTIONS[ent:GetClass()]
        if def == faction then table.insert(relationships, relationship) end
      end
    end
    local relationship = HighestRelationship(relationships)
    self:_SetRelationship(ent, relationship.disp, relationship.prio)
  end

  -- Iterators
  function ENT:EntityIterator(disp, spotted)
    local i = 1
    local cache = disp == D_NU and ents.GetAll() or self._DrGBaseRelationshipCaches[disp]
    return function()
      for h = i, #cache do
        local ent = cache[h]
        i = i+1
        if disp ~= self:GetRelationship(ent) then continue end
        if spotted and not self:HasSpotted(ent) then continue end
        return ent
      end
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
  function ENT:NeutralIterator(spotted)
    return self:EntityIterator(D_NU, spotted)
  end

  -- Get entities
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

  function ENT:CustomRelationship() end

  -- Handlers --

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
    elseif ent.CPTBase_NPC then
      ent:SetRelationship(self, relationship)
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
        if ent == nextbot then continue end
        nextbot:UpdateRelationshipWith(ent)
      end
    end)
  end)
  hook.Add("EntityRemoved", "DrGBaseNextbotRelationshipsRemove", function(ent)
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      if ent == nextbot then continue end
      nextbot:_SetRelationship(ent, D_NU)
    end
  end)

  -- Aliases --

  function ENT:Disposition(ent)
    local disp, prio = self:GetRelationship(ent)
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

else

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

end
