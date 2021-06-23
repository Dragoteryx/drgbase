-- Getters --

function ENT:Team()
  return self:GetNW2Int("DrG/Team", 0)
end

if SERVER then
  util.AddNetworkString("DrG/RelationshipChange")

  -- Internal --

  local D_HS = 5

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
    else return math.Clamp(prio, 0.01, math.huge) end
  end
  local function CheckDispPrio(disp, prio)
    return CheckDisp(disp), CheckPrio(prio)
  end

  -- Targetting --

  local TARGET_EXCEPTIONS = {
    ["npc_bullseye"] = false,
    ["npc_grenade_frag"] = false,
    ["npc_tripmine"] = false,
    ["npc_satchel"] = false,

    ["replicator_melon"] = DrGBase.TargetRepMelons,
    ["neo_replicator_melon"] = DrGBase.TargetRepMelons,
    ["npc_antlion_grub"] = DrGBase.TargetInsects,
    ["monster_cockroach"] = DrGBase.TargetInsects,
    ["replicator_worker"] = true,
    ["replicator_queen"] = true,
    ["replicator_queen_hive"] = true
  }
  function DrG_IsTarget(ent)
    if not IsValid(ent) then return false end
    local class = ent:GetClass()
    if TARGET_EXCEPTIONS[class] ~= nil then
      local exception = TARGET_EXCEPTIONS[class]
      if isbool(exception) then return expection
      else return exception:GetBool() end
    else
      if ent.DrG_Target then return true end
      if ent:IsNextBot() then return true end
      if ent:IsPlayer() then return true end
      if ent:IsNPC() then return true end
      return false
    end
  end

  -- Setters --

  ENT.DrG_Relationships = {}
  ENT.DrG_RelationshipCache = {[D_LI] = {}, [D_HT] = {}, [D_FR] = {}}
  ENT.DrG_RelationshipCacheDetected = {[D_LI] = {}, [D_HT] = {}, [D_FR] = {}}
  ENT.DrG_DefinedRelationships = {}
  ENT.DrG_IgnoredEntities = {}

  local function SetRelationship(self, ent, disp, prio)
    if not IsValid(ent) then return end
    if not IsValidDisp(disp) then return end
    local old = self:GetRelationship(ent)
    if old ~= disp then
      if IsCachedDisp(disp) then
        self:ListenTo(ent, disp ~= D_LI)
        self.DrG_RelationshipCache[D_LI][ent] = nil
        self.DrG_RelationshipCache[D_HT][ent] = nil
        self.DrG_RelationshipCache[D_FR][ent] = nil
        self.DrG_RelationshipCache[disp][ent] = true
        if self.DrG_DetectState[ent] then
          self.DrG_RelationshipCacheDetected[D_LI][ent] = nil
          self.DrG_RelationshipCacheDetected[D_HT][ent] = nil
          self.DrG_RelationshipCacheDetected[D_FR][ent] = nil
          self.DrG_RelationshipCacheDetected[disp][ent] = true
        end
      else
        self:ListenTo(ent, false)
        self.DrG_RelationshipCache[D_LI][ent] = nil
        self.DrG_RelationshipCache[D_HT][ent] = nil
        self.DrG_RelationshipCache[D_FR][ent] = nil
        self.DrG_RelationshipCacheDetected[D_LI][ent] = nil
        self.DrG_RelationshipCacheDetected[D_HT][ent] = nil
        self.DrG_RelationshipCacheDetected[D_FR][ent] = nil
      end
    end
    self.DrG_Relationships[ent] = {disp = disp, prio = prio}
    if old ~= disp then
      self:OnRelationshipChange(ent, old, disp)
      self:ReactInCoroutine(self.DoRelationshipChange, ent, old, disp)
      if ent:IsPlayer() then ent:DrG_Send("DrG/RelationshipChange", self, old, disp)
      elseif ent:IsNPC() then
        if self:IsAlly(ent) then ent:DrG_SetRelationship(self, D_LI)
        elseif self:IsAfraidOf(ent) then ent:DrG_SetRelationship(self, D_HT)
        elseif self:IsHostile(ent) then
          if self:IsFrightening() then ent:DrG_SetRelationship(self, D_FR)
          else ent:DrG_SetRelationship(self, D_HT) end
        end
      end
    end
    if self:GetEnemy() == ent and not self:IsHostile(ent) then
      self:UpdateEnemy()
    end
  end

  local function DefinedRelationshipTable(self, name)
    self.DrG_DefinedRelationships[name] = self.DrG_DefinedRelationships[name] or {}
    return self.DrG_DefinedRelationships[name]
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

  function ENT:GetSelfClassRelationship()
    return self:GetClassRelationship(self:GetClass())
  end
  function ENT:SetSelfClassRelationship(disp, prio)
    return self:SetClassRelationship(self:GetClass(), disp, prio)
  end
  function ENT:AddSelfClassRelationship(disp, prio)
    return self:AddClassRelationship(self:GetClass(), disp, prio)
  end
  function ENT:ResetSelfClassRelationship()
    return self:ResetClassRelationship(self:GetClass())
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

  function ENT:GetSelfModelRelationship()
    return self:GetModelRelationship(self:GetModel())
  end
  function ENT:SetSelfModelRelationship(disp, prio)
    return self:SetModelRelationship(self:GetModel(), disp, prio)
  end
  function ENT:AddSelfModelRelationship(disp, prio)
    return self:AddModelRelationship(self:GetModel(), disp, prio)
  end
  function ENT:ResetSelfModelRelationship()
    return self:ResetModelRelationship(self:GetModel())
  end

  function ENT:GetFactionRelationship(faction)
    if not isstring(faction) then return D_ER, 1 end
    return GetDefinedRelationship(self, "Faction", string.upper(faction))
  end
  function ENT:SetFactionRelationship(faction, disp, prio)
    if not isstring(faction) then return end
    return SetDefinedRelationship(self, "Faction", string.upper(faction), disp, prio)
  end
  function ENT:AddFactionRelationship(faction, disp, prio)
    if not isstring(faction) then return end
    return AddDefinedRelationship(self, "Faction", string.upper(faction), disp, prio)
  end
  function ENT:ResetFactionRelationship(faction)
    if not isstring(faction) then return end
    return ResetDefinedRelationship(self, "Faction", string.upper(faction))
  end

  function ENT:GetPlayersRelationship()
    return self:GetFactionRelationship("FACTION_PLAYERS")
  end
  function ENT:SetPlayersRelationship(disp, prio)
    return self:SetFactionRelationship("FACTION_PLAYERS", disp, prio)
  end
  function ENT:AddPlayersRelationship(disp, prio)
    return self:AddFactionRelationship("FACTION_PLAYERS", disp, prio)
  end
  function ENT:ResetPlayersRelationship()
    return self:ResetFactionRelationship("FACTION_PLAYERS")
  end

  -- Factions & Teams --

  function ENT:SetTeam(team)
    local current = self:Team()
    self:SetNW2Int("DrG/Team", tonumber(team))
    if tonumber(team) ~= current then self:UpdateRelationships() end
  end

  function ENT:JoinFaction(faction)
    return self:DrG_JoinFaction(faction)
  end
  function ENT:JoinFactions(factions)
    return self:DrG_JoinFactions(factions)
  end

  function ENT:LeaveFaction(faction)
    return self:DrG_LeaveFaction(faction)
  end
  function ENT:LeaveFactions(factions)
    return self:DrG_LeaveFactions(factions)
  end
  function ENT:LeaveAllFactions()
    return self:DrG_LeaveAllFactions()
  end

  function ENT:IsInFaction(faction)
    return self:DrG_IsInFaction(faction)
  end
  function ENT:GetFactions()
    return self:DrG_GetFactions()
  end

  -- Ignore & Frightening --

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

  local NPC_STATES_IGNORED = {
    [NPC_STATE_PLAYDEAD] = true,
    [NPC_STATE_DEAD] = true
  }
  function ENT:IsIgnored(ent)
    if ent:IsPlayer() and not ent:Alive() then return true end
    if ent:IsPlayer() and ent:DrG_IsPossessing() then return true end
    if ent:IsPlayer() and GetConVar("ai_ignoreplayers"):GetBool() then return true end
    if ent:IsPlayer() and DrGBase.IgnorePlayers:GetBool() then return true
    elseif DrG_IsTarget(ent) then
      if DrGBase.IgnoreNPCs:GetBool() then return true end
    elseif DrGBase.IgnoreOthers:GetBool() then return true end
    if ent:IsFlagSet(FL_NOTARGET) then return true end
    if ent.IsVJBaseSNPC and ent.VJ_NoTarget then return true end -- why the f❤ck
    if ent.CPTBase_NPC and ent.UseNotarget then return true end -- don't you use
    if ent.IV04NextBot and ent.IsNTarget then return true end -- the built-in no target
    if ent:IsNPC() and NPC_STATES_IGNORED[ent:GetNPCState()] then return true end
    if (ent:IsPlayer() or ent:IsNPC() or ent:IsNextBot()) and ent:Health() <= 0 then return true end
    if ent.IsDrGNextbot and (ent:IsDown() or ent:IsDead()) then return true end
    if self:ShouldIgnore(ent) then return true end
    return self.DrG_IgnoredEntities[ent] or false
  end
  function ENT:SetIgnored(ent, ignored)
    self.DrG_IgnoredEntities[ent] = tobool(ignored)
  end

  function ENT:GetNoTarget()
    return self:IsFlagSet(FL_NOTARGET)
  end
  function ENT:SetNoTarget(noTarget)
    if noTarget then self:AddFlags(FL_NOTARGET)
    else self:RemoveFlags(FL_NOTARGET) end
  end

  -- Update --

  hook.Add("OnEntityCreated", "DrG/UpdateRelationshipWithNew", function(ent)
    timer.Simple(0, function()
      if not IsValid(ent) then return end
      for nb in DrGBase.NextbotIterator() do
        nb:UpdateRelationshipWith(ent)
      end
    end)
  end)

  function ENT:InitRelationships()
    if self.DrG_RelationshipsReady then return end
    self.DrG_RelationshipsReady = true
    self:UpdateRelationships()
  end
  function ENT:UpdateRelationships()
    if not self.DrG_RelationshipsReady then return end
    local entities = ents.GetAll()
    for i = 1, #entities do
      self:UpdateRelationshipWith(entities[i])
    end
  end
  function ENT:UpdateRelationshipWith(ent)
    if not self.DrG_RelationshipsReady then return D_ER, 1 end
    if not IsValid(ent) or ent == self then return D_ER, 1 end
    local default_disp = DrG_IsTarget(ent) and self:GetDefaultRelationship() or D_NU
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
      if ent:DrG_IsInFaction(faction) then
        table.insert(relationships, rel)
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
    if ent == self then return D_ER, 1 end
    local rel = self.DrG_Relationships[ent]
    if rel and (absolute or not self:IsIgnored(ent)) then
      return rel.disp, rel.prio
    else return D_NU, 1 end
  end
  function ENT:IsAlly(ent, absolute)
    return self:GetRelationship(ent, absolute) == D_LI
  end
  function ENT:IsEnemy(ent, absolute)
    return self:GetRelationship(ent, absolute) == D_HT
  end
  function ENT:IsAfraidOf(ent, absolute)
    return self:GetRelationship(ent, absolute) == D_FR
  end
  function ENT:IsHostile(ent, absolute)
    local disp = self:GetRelationship(ent, absolute)
    return disp == D_HT or disp == D_FR
  end
  function ENT:IsNeutral(ent, absolute)
    return self:GetRelationship(ent, absolute) == D_NU
  end

  -- iterators
  local function EntityIterator(self, disp, detected)
    if disp == D_HS then
      return util.DrG_MergeIterators({
        self:EnemyIterator(detected),
        self:AfraidOfIterator(detected)
      })
    elseif IsCachedDisp(disp) then
      if detected then
        local cache = self:IsOmniscient() and
          self.DrG_RelationshipCache[disp] or
          self.DrG_RelationshipCacheDetected[disp]
        return function(_, ent)
          while true do
            ent = next(cache, ent)
            if not ent then return end
            if not IsValid(ent) then continue end
            if self:GetRelationship(ent) ~= disp then continue end
            return ent
          end
        end
      else
        return function(_, ent)
          while true do
            ent = next(self.DrG_RelationshipCache[disp], ent)
            if not ent then return end
            if not IsValid(ent) then continue end
            if isbool(detected) and self:HasDetected(ent) ~= detected then continue end
            if self:GetRelationship(ent) ~= disp then continue end
            return ent
          end
        end
      end
    else
      local i = 1
      local entities = ents.GetAll()
      return function()
        for j = i, #entities do
          local ent = entities[j]
          if not IsValid(ent) then continue end
          if isbool(detected) and self:HasDetected(ent) ~= detected then continue end
          if self:GetRelationship(ent) ~= disp then continue end
          i = j+1
          return ent
        end
      end
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
    return EntityIterator(self, D_HS, detected)
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
    return GetEntities(self, D_HS, detected)
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
    return GetClosestEntity(self, D_HS, detected)
  end
  function ENT:GetClosestNeutral(detected)
    return GetClosestEntity(self, D_NU, detected)
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

else

  -- Hooks --

  function ENT:OnRelationshipChange(_old, _new) end

  -- Getters --

  net.DrG_DelayedReceive("DrG/RelationshipChange", function(nb, old, new)
    if not IsValid(nb) then return end
    nb.DrG_LocalPlayerDisp = new
    nb:OnRelationshipChange(LocalPlayer(), old, new)
  end)
  function ENT:GetRelationship(ent)
    if ent ~= LocalPlayer() then return D_ER, 1 end
    return self.DrG_LocalPlayerDisp or D_NU, 1
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
  function ENT:IsHostile(ent)
    return self:IsEnemy(ent) or self:IsHostile(ent)
  end

end