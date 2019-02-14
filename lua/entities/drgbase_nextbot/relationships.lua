
if SERVER then

  -- Targettables --

  local ignore = {
    ["npc_bullseye"] = true,
    ["weapon_striderbuster"] = true,
    ["npc_grenade_frag"] = true
  }
  local exceptions = {
    ["replicator_melon"] = true,
    ["replicator_queen"] = true,
    ["replicator_queen_hive"] = true,
    ["replicator_worker"] = true
  }
  function ENT:GetTargets()
    return self._DrGBaseTargets
  end
  function ENT:RefreshTargets()
    self._DrGBaseTargets = {}
    self._DrGBaseTargetsList = {}
    for i, ent in ipairs(ents.GetAll()) do
      if self:TargetCheck(ent) then self:_AddTarget(ent) end
    end
    self:NPCRelationship()
    return self:GetTargets()
  end
  function ENT:IsTarget(ent)
    return self._DrGBaseTargetsList[ent:GetCreationID()] or false
  end
  function ENT:_AddTarget(ent)
    table.insert(self._DrGBaseTargets, ent)
    self._DrGBaseTargetsList[ent:GetCreationID()] = true
  end
  function ENT:TargetCheck(ent)
    if not IsValid(ent) then return false end
    if ent:EntIndex() == self:EntIndex() then return false end
    if not ignore[ent:GetClass()] and (
      ent:IsPlayer() or
      ent:IsNPC() or
      ent.Type == "nextbot" or
      ent:IsFlagSet(FL_OBJECT) or
      string.StartWith(ent:GetClass(), "npc_") or
      exceptions[ent:GetClass()]
    ) then return true end
    for name, callback in pairs(self._DrGBaseCustomTargetChecks) do
      if callback(ent) then return true end
    end
  end
  function ENT:DefineCustomTargetCheck(name, callback)
    self._DrGBaseCustomTargetChecks[name] = callback
    self:RefreshTargets()
  end
  function ENT:RemoveCustomTargetCheck(name)
    self._DrGBaseCustomTargetChecks[name] = nil
    self:RefreshTargets()
  end

  -- Relationships --

  local defaultFactions = {
    ["npc_crow"] = DRGBASE_FACTION_ANIMALS,
    ["npc_monk"] = DRGBASE_FACTION_REBELS,
    ["npc_pigeon"] = DRGBASE_FACTION_ANIMALS,
    ["npc_seagull"] = DRGBASE_FACTION_ANIMALS,
    ["npc_combine_camera"] = DRGBASE_FACTION_COMBINE,
    ["npc_turret_ceiling"] = DRGBASE_FACTION_COMBINE,
    ["npc_cscanner"] = DRGBASE_FACTION_COMBINE,
    ["npc_combinedropship"] = DRGBASE_FACTION_COMBINE,
    ["npc_combinegunship"] = DRGBASE_FACTION_COMBINE,
    ["npc_combine_s"] = DRGBASE_FACTION_COMBINE,
    ["npc_hunter"] = DRGBASE_FACTION_COMBINE,
    ["npc_helicopter"] = DRGBASE_FACTION_COMBINE,
    ["npc_manhack"] = DRGBASE_FACTION_COMBINE,
    ["npc_metropolice"] = DRGBASE_FACTION_COMBINE,
    ["npc_rollermine"] = DRGBASE_FACTION_COMBINE,
    ["npc_clawscanner"] = DRGBASE_FACTION_COMBINE,
    ["npc_stalker"] = DRGBASE_FACTION_COMBINE,
    ["npc_strider"] = DRGBASE_FACTION_COMBINE,
    ["npc_turret_floor"] = DRGBASE_FACTION_COMBINE,
    ["npc_alyx"] = DRGBASE_FACTION_REBELS,
    ["npc_barney"] = DRGBASE_FACTION_REBELS,
    ["npc_citizen"] = DRGBASE_FACTION_REBELS,
    ["npc_dog"] = DRGBASE_FACTION_REBELS,
    ["npc_magnusson"] = DRGBASE_FACTION_REBELS,
    ["npc_kleiner"] = DRGBASE_FACTION_REBELS,
    ["npc_mossman"] = DRGBASE_FACTION_REBELS,
    ["npc_eli"] = DRGBASE_FACTION_REBELS,
    ["npc_fisherman"] = DRGBASE_FACTION_REBELS,
    ["npc_gman"] = DRGBASE_FACTION_GMAN,
    ["npc_odessa"] = DRGBASE_FACTION_REBELS,
    ["npc_vortigaunt"] = DRGBASE_FACTION_REBELS,
    ["npc_breen"] = DRGBASE_FACTION_COMBINE,
    ["npc_antlion"] = DRGBASE_FACTION_ANTLIONS,
    ["npc_antlion_grub"] = DRGBASE_FACTION_ANTLIONS,
    ["npc_antlionguard"] = DRGBASE_FACTION_ANTLIONS,
    ["npc_antlionguardian"] = DRGBASE_FACTION_ANTLIONS,
    ["npc_antlion_worker"] = DRGBASE_FACTION_ANTLIONS,
    ["npc_barnacle"] = DRGBASE_FACTION_BARNACLES,
    ["npc_headcrab_fast"] = DRGBASE_FACTION_ZOMBIES,
    ["npc_fastzombie"] = DRGBASE_FACTION_ZOMBIES,
    ["npc_fastzombie_torso"] = DRGBASE_FACTION_ZOMBIES,
    ["npc_headcrab"] = DRGBASE_FACTION_ZOMBIES,
    ["npc_headcrab_black"] = DRGBASE_FACTION_ZOMBIES,
    ["npc_poisonzombie"] = DRGBASE_FACTION_ZOMBIES,
    ["npc_zombie"] = DRGBASE_FACTION_ZOMBIES,
    ["npc_zombie_torso"] = DRGBASE_FACTION_ZOMBIES,
    ["npc_zombine"] = DRGBASE_FACTION_ZOMBIES,
    ["monster_alien_grunt"] = DRGBASE_FACTION_XEN_ARMY,
    ["monster_alien_slave"] = DRGBASE_FACTION_XEN_ARMY,
    ["monster_human_assassin"] = DRGBASE_FACTION_HECU,
    ["monster_babycrab"] = DRGBASE_FACTION_ZOMBIES,
    ["monster_bullchicken"] = DRGBASE_FACTION_XEN_WILDLIFE,
    ["monster_cockroach"] = DRGBASE_FACTION_ANIMALS,
    ["monster_alien_controller"] = DRGBASE_FACTION_XEN_ARMY,
    ["monster_gargantua"] = DRGBASE_FACTION_XEN_ARMY,
    ["monster_bigmomma"] = DRGBASE_FACTION_ZOMBIES,
    ["monster_human_grunt"] = DRGBASE_FACTION_HECU,
    ["monster_headcrab"] = DRGBASE_FACTION_ZOMBIES,
    ["monster_houndeye"] = DRGBASE_FACTION_XEN_WILDLIFE,
    ["monster_nihilanth"] = DRGBASE_FACTION_XEN_ARMY,
    ["monster_scientist"] = DRGBASE_FACTION_REBELS,
    ["monster_barney"] = DRGBASE_FACTION_REBELS,
    ["monster_snark"] = DRGBASE_FACTION_XEN_WILDLIFE,
    ["monster_tentacle"] = DRGBASE_FACTION_XEN_WILDLIFE,
    ["monster_zombie"] = DRGBASE_FACTION_ZOMBIES,
    ["npc_apc_dropship"] = DRGBASE_FACTION_COMBINE,
    ["npc_elite_overwatch_dropship"] = DRGBASE_FACTION_COMBINE,
    ["npc_civil_protection_tier1_dropship"] = DRGBASE_FACTION_COMBINE,
    ["npc_civil_protection_tier2_dropship"] = DRGBASE_FACTION_COMBINE,
    ["npc_shotgunner_dropship"] = DRGBASE_FACTION_COMBINE,
    ["npc_overwatch_squad_tier1_dropship"] = DRGBASE_FACTION_COMBINE,
    ["npc_overwatch_squad_tier2_dropship"] = DRGBASE_FACTION_COMBINE,
    ["npc_overwatch_squad_tier3_dropship"] = DRGBASE_FACTION_COMBINE,
    ["npc_random_combine_dropship"] = DRGBASE_FACTION_COMBINE,
    ["npc_strider_dropship"] = DRGBASE_FACTION_COMBINE
  }

  local relPrios = {
    [D_LI] = 4,
    [D_HT] = 3,
    [D_FR] = 2,
    [D_NU] = 1,
    [D_ER] = 0
  }

  local defaultVal = 1

  function ENT:GetRelationship(ent)
    if not IsValid(ent) then return D_ER end
    if self:EntIndex() == ent:EntIndex() then return D_ER end
    if ent:IsPlayer() and (not ent:Alive() or GetConVar("ai_ignoreplayers"):GetBool() or IsValid(ent:DrG_Possessing())) then return D_NU end
    if ent.IsDrGNextbot and ent:IsDead() then return D_NU end
    if ent:Health() <= 0 then return D_NU end
    local highest = {disposition = self:GetDefaultRelationship(), val = defaultVal}
    local relationships = {}
    local individual, indval = self:GetEntityRelationship(ent)
    local class, classval = self:GetClassRelationship(ent:GetClass())
    local model, modelval = self:GetModelRelationship(ent:GetModel())
    table.insert(relationships, {
      disposition = individual, val = indval
    })
    table.insert(relationships, {
      disposition = class, val = classval
    })
    table.insert(relationships, {
      disposition = model, val = modelval
    })
    for faction, relationship in pairs(self._DrGBaseFactionRelationships) do
      if relationship == nil then continue end
      if ent:IsPlayer() then
        if ent:DrG_IsInFaction(faction) then
          table.insert(relationships, relationship)
        end
      elseif ent.IsDrGNextbot then
        if ent:IsInFaction(faction) then
          table.insert(relationships, relationship)
        end
      elseif ent:DrG_IsSanic() then
        if faction == DRGBASE_FACTION_SANIC then
          table.insert(relationships, relationship)
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
        end
      elseif ent:IsNPC() then
        local def = defaultFactions[ent:GetClass()]
        if def == faction then
          table.insert(relationships, relationship)
        end
      end
    end
    for name, callback in pairs(self._DrGBaseCustomRelationships) do
      local disp, val = callback(ent, self)
      if disp then
        table.insert(relationships, {
          disposition = disp, val = math.Round(val) or defaultVal
        })
      end
    end
    for i, relationship in ipairs(relationships) do
      if relationship.val > highest.val then highest = relationship
      elseif relationship.val == highest.val and
      relPrios[relationship.disposition] > relPrios[highest.disposition] then highest = relationship end
    end
    return highest.disposition, highest.val
  end

  -- Default
  function ENT:GetDefaultRelationship()
    return self._DrGBaseDefaultRelationship, defaultVal
  end
  function ENT:SetDefaultRelationship(relationship)
    self._DrGBaseDefaultRelationship = relationship
    self:NPCRelationship()
  end

  -- Individual
  function ENT:GetEntityRelationship(ent)
    if not IsValid(ent) then return D_ER, defaultVal end
    local rel = self._DrGBaseEntityRelationships[ent:GetCreationID()]
    if rel == nil then return D_ER, defaultVal end
    return rel.disposition, math.Round(rel.val)
  end
  function ENT:SetEntityRelationship(ent, relationship, val)
    self._DrGBaseEntityRelationships[ent:GetCreationID()] = {
      disposition = relationship, val = val or defaultVal
    }
    if ent:IsNPC() then self:NPCRelationship(ent) end
  end
  function ENT:AddEntityRelationship(ent, relationship, val)
    local disp, curr = self:GetEntityRelationship(ent)
    val = val or curr + 1
    if curr >= val then return end
    self:SetEntityRelationship(ent, relationship, val)
  end

  -- Class
  function ENT:GetClassRelationship(class)
    if class == nil then return D_ER, defaultVal end
    local rel = self._DrGBaseClassRelationships[string.lower(class)]
    if rel == nil then return D_ER, defaultVal end
    return rel.disposition, math.Round(rel.val)
  end
  function ENT:SetClassRelationship(class, relationship, val)
    self._DrGBaseClassRelationships[string.lower(class)] = {
      disposition = relationship, val = val or defaultVal
    }
    self:NPCRelationship()
  end
  function ENT:AddClassRelationship(class, relationship, val)
    local disp, curr = self:GetClassRelationship(class)
    val = val or curr + 1
    if curr >= val then return end
    self:SetClassRelationship(class, relationship, val)
  end

  -- Model
  function ENT:GetModelRelationship(model)
    if model == nil then return D_ER, defaultVal end
    local rel = self._DrGBaseModelRelationships[string.lower(model)]
    if rel == nil then return D_ER, defaultVal end
    return rel.disposition, math.Round(rel.val)
  end
  function ENT:SetModelRelationship(model, relationship, val)
    self._DrGBaseModelRelationships[string.lower(model)] = {
      disposition = relationship, val = val or defaultVal
    }
    self:NPCRelationship()
  end
  function ENT:AddModelRelationship(model, relationship, val)
    local disp, curr = self:GetModelRelationship(model)
    val = val or curr + 1
    if curr >= val then return end
    self:SetModelRelationship(model, relationship, val)
  end

  -- Factions
  function ENT:GetFactionRelationship(faction)
    if faction == nil then return D_ER, defaultVal end
    local rel = self._DrGBaseFactionRelationships[string.upper(faction)]
    if rel == nil then return D_ER, defaultVal end
    return rel.disposition, math.Round(rel.val)
  end
  function ENT:SetFactionRelationship(faction, relationship, val)
    self._DrGBaseFactionRelationships[string.upper(faction)] = {
      disposition = relationship, val = val or defaultVal
    }
    self:NPCRelationship()
  end
  function ENT:AddFactionRelationship(faction, relationship, val)
    local disp, curr = self:GetFactionRelationship(faction)
    val = val or curr + 1
    if curr >= val then return end
    self:SetFactionRelationship(faction, relationship, val)
  end

  function ENT:RemoveCustomRelationshipCheck(name)
    self._DrGBaseCustomRelationships[name] = nil
    self:NPCRelationship()
  end
  function ENT:DefineCustomRelationshipCheck(name, callback)
    self._DrGBaseCustomRelationships[name] = callback
    self:NPCRelationship()
  end

  function ENT:GetPlayersRelationship()
    self:GetClassRelationship("player")
  end
  function ENT:SetPlayersRelationship(relationship)
    self:SetClassRelationship("player", relationship)
  end

  function ENT:ResetRelationships()
    self._DrGBaseEntityRelationships = {}
    self._DrGBaseClassRelationships = {}
    self._DrGBaseModelRelationships = {}
    self._DrGBaseFactionRelationships = {}
    self._DrGBaseCustomRelationships = {}
    self._DrGBaseFactions = {}
    for i, faction in ipairs(self.Factions) do
      self._DrGBaseFactions[string.upper(faction)] = true
    end
    if self.AlliedWithSelfFactions then
      for i, faction in ipairs(self:GetFactions()) do
        self:SetFactionRelationship(faction, D_LI)
      end
    end
    self:NPCRelationship()
  end

  -- Factions --

  function ENT:JoinFaction(faction)
    self._DrGBaseFactions[string.upper(faction)] = true
  end
  function ENT:LeaveFaction(faction)
    self._DrGBaseFactions[string.upper(faction)] = false
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

  -- NPC Relationships --

  function ENT:NPCRelationship(ent, relationship)
    if ent == nil or isnumber(ent) then
      relationship = ent
      for i, ent in ipairs(self:GetTargets()) do
        self:NPCRelationship(ent, relationship)
      end
    elseif not IsValid(ent) then return
    elseif ent:IsNPC() then
      relationship = relationship or self:GetRelationship(ent)
      if relationship == D_FR then relationship = D_HT
      elseif relationship == D_HT and self.Frightening then
        relationship = D_FR
      end
      self:_Debug("refresh relationship with NPC '"..ent:GetClass().."' ("..ent:EntIndex()..") => "..relationship..".")
      ent:AddEntityRelationship(self, relationship, 100)
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
      end
    end
  end

  hook.Add("OnEntityCreated", "DrGBaseNextbotNPCRelationships", function(ent)
    timer.Simple(0, function()
      for i, nextbot in ipairs(DrGBase.Nextbots.GetAll()) do
        if nextbot:TargetCheck(ent) then nextbot:_AddTarget(ent) end
        if ent:IsNPC() then nextbot:NPCRelationship(ent) end
      end
    end)
  end)

  -- Helpers --

  function ENT:FindEntities(range, relationship, spotted)
    range = range or self.Radius
    if range < 0 then return {} end
    if range > self.Radius then range = self.Radius end
    local entities = {}
    for i, ent in ipairs(self:GetTargets()) do
      if not IsValid(ent) then continue end
      if self:EntIndex() == ent:EntIndex() then continue end
      if spotted and not self:HasSpottedEntity(ent) then continue end
      if self:GetRangeSquaredTo(ent) > range^2 then continue end
      if relationship and self:GetRelationship(ent) ~= relationship then continue end
      table.insert(entities, ent)
    end
    return entities
  end

  function ENT:GetAllies(spotted)
    return self:FindEntities(self.Radius, D_LI, spotted)
  end
  function ENT:GetEnemies(spotted)
    return self:FindEntities(self.Radius, D_HT, spotted)
  end
  function ENT:GetScaredOf(spotted)
    return self:FindEntities(self.Radius, D_FR, spotted)
  end
  function ENT:GetNeutrals(spotted)
    return self:FindEntities(self.Radius, D_NU, spotted)
  end

  function ENT:FindClosestEntity(range, relationship, spotted)
    local entities = self:FindEntities(range, relationship, spotted)
    table.sort(entities, function(ent1, ent2)
      return self:GetRangeSquaredTo(ent1) < self:GetRangeSquaredTo(ent2)
    end)
    if #entities > 0 then return entities[1]
    else return nil end
  end

  function ENT:FindClosestAlly(range, spotted)
    return self:FindClosestEntity(range, D_LI, spotted)
  end
  function ENT:FindClosestEnemy(range, spotted)
    return self:FindClosestEntity(range, D_HT, spotted)
  end
  function ENT:FindClosestScaredOf(range, spotted)
    return self:FindClosestEntity(range, D_FR, spotted)
  end

  function ENT:IsAlly(ent)
    return self:GetRelationship(ent) == D_LI
  end
  function ENT:IsEnemy(ent)
    return self:GetRelationship(ent) == D_HT
  end
  function ENT:IsScaredOf(ent)
    return self:GetRelationship(ent) == D_FR
  end
  function ENT:IsNeutral(ent)
    return self:GetRelationship(ent) == D_NU
  end

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
    local val = math.Round(tonumber(split[3]))
    local disp, curr = self:GetClassRelationship(class)
    if curr >= val then return end
    self:AddClassRelationship(class, relationship, val)
  end

  -- Callbacks

  net.DrG_DefineCallback("DrGBaseNextbotEntityRelationship", function(data)
    local nextbot = Entity(data.nextbot)
    local ent = Entity(data.ent)
    if not IsValid(nextbot) then return D_ER end
    return nextbot:GetRelationship(ent)
  end)

else

  function ENT:GetRelationship(ent, callback)
    if IsValid(ent) then
      net.DrG_UseCallback("DrGBaseNextbotEntityRelationship", {
        nextbot = self:EntIndex(), ent = ent:EntIndex()
      }, function(res)
        if not IsValid(self) then return end
        if not IsValid(ent) then callback(D_ER)
        else callback(res) end
      end)
    else callback(D_ER) end
  end

end
