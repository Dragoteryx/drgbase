
local targettablesDelay = 0
local targettables = {}
local exceptions = {
  ["replicator_melon"] = true,
  ["replicator_queen"] = true,
  ["replicator_queen_hive"] = true,
  ["replicator_worker"] = true
}
hook.Add("Think", "DrGBaseRefreshTargettableEntitiesList", function()
  if CurTime() < targettablesDelay then return end
  targettablesDelay = CurTime() + 1
  local newTargettables = {}
  for i, ent in ipairs(ents.GetAll()) do
    if not IsValid(ent) then continue end
    if ent:GetClass() == "npc_bullseye" then continue end
    if ent:IsPlayer() or ent:IsNPC() or ent.Type == "nextbot" or
    ent:IsFlagSet(FL_OBJECT) or string.StartWith(ent:GetClass(), "npc_") or
    exceptions[ent:GetClass()] then
      table.insert(newTargettables, ent)
    end
  end
  table.CopyFromTo(newTargettables, targettables)
end)

function ENT:GetTargettableEntities()
  return targettables
end

if SERVER then

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

  function ENT:GetRelationship(ent)
    if not IsValid(ent) then return D_ER end
    if self:EntIndex() == ent:EntIndex() then return D_ER end
    if ent:IsPlayer() and (not ent:Alive() or GetConVar("ai_ignoreplayers"):GetBool() or IsValid(ent:DrG_Possessing())) then return D_NU end
    if ent.IsDrGNextbot and ent:IsDead() then return D_NU end
    if ent:Health() <= 0 then return D_NU end
    local individual = self:GetEntityRelationship(ent)
    if individual then return individual end
    local relationships = {}
    local class = self:GetClassRelationship(ent:GetClass())
    if class then table.insert(relationships, class) end
    local model = self:GetModelRelationship(ent:GetModel())
    if model then table.insert(relationships, model) end
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
      local res = callback(ent, self)
      if res then table.insert(relationships, res) end
    end
    if #relationships == 1 then
      return relationships[1]
    elseif #relationships > 1 then
      table.sort(relationships, function(rel1, rel2)
        return relPrios[rel1] > relPrios[rel2]
      end)
      return relationships[1]
    else return self:GetDefaultRelationship() end
  end

  function ENT:GetDefaultRelationship()
    return self._DrGBaseDefaultRelationship
  end
  function ENT:SetDefaultRelationship(relationship)
    self._DrGBaseDefaultRelationship = relationship
    self:NPCRelationship()
  end

  function ENT:GetEntityRelationship(ent)
    if not IsValid(ent) then return D_ER end
    return self._DrGBaseEntityRelationships[ent:GetCreationID()]
  end
  function ENT:SetEntityRelationship(ent, relationship)
    self._DrGBaseEntityRelationships[ent:GetCreationID()] = relationship
    if ent:IsNPC() then self:NPCRelationship(ent) end
  end

  function ENT:GetClassRelationship(class)
    if class == nil then return D_ER end
    return self._DrGBaseClassRelationships[string.lower(class)]
  end
  function ENT:SetClassRelationship(class, relationship)
    self._DrGBaseClassRelationships[string.lower(class)] = relationship
    self:NPCRelationship()
  end

  function ENT:GetModelRelationship(model)
    if model == nil then return D_ER end
    return self._DrGBaseModelRelationships[string.lower(model)]
  end
  function ENT:SetModelRelationship(model, relationship)
    self._DrGBaseModelRelationships[string.lower(model)] = relationship
    self:NPCRelationship()
  end

  function ENT:GetFactionRelationship(faction)
    if faction == nil then return D_ER end
    return self._DrGBaseFactionRelationships[string.upper(faction)]
  end
  function ENT:SetFactionRelationship(faction, relationship)
    self._DrGBaseFactionRelationships[string.upper(faction)] = relationship
    self:NPCRelationship()
  end

  function ENT:RemoveCustomRelationshipCheck(name)
    self._DrGBaseCustomRelationships[name] = nil
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
      for i, ent in ipairs(self:GetTargettableEntities()) do
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
    if not ent:IsNPC() then return end
    timer.Simple(0, function()
      for i, nextbot in ipairs(DrGBase.Nextbot.GetAll()) do
        nextbot:NPCRelationship(ent)
      end
    end)
  end)

  -- Aliases --

  function ENT:Disposition(ent)
    return self:GetRelationship(ent)
  end

  function ENT:AddEntityRelationship(ent, relationship)
    self:SetEntityRelationship(ent, relationship)
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
    self:SetClassRelationship(class, relationship)
  end

  -- Callbacks

  DrGBase.Net.DefineCallback("DrGBaseNextbotEntityRelationship", function(data)
    local nextbot = Entity(data.nextbot)
    local ent = Entity(data.ent)
    if not IsValid(nextbot) then return D_ER end
    return nextbot:GetRelationship(ent)
  end)

else

  function ENT:GetRelationship(ent, callback)
    DrGBase.Net.UseCallback("DrGBaseNextbotEntityRelationship", {
      nextbot = self:EntIndex(), ent = ent:EntIndex()
    }, function(res)
      if not IsValid(self) then return end
      if not IsValid(ent) then callback(D_ER)
      else callback(res) end
    end)
  end

end
