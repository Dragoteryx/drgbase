
if SERVER then

  function DrGBase.CreateProjectile(model, binds, class)
    local proj = ents.Create(class or "proj_drg_default")
    if not IsValid(proj) then return NULL end
    if istable(model) and #model > 0 then model = model[math.random(#model)] end
    if isstring(model) then proj:SetModel(model) end
    if isfunction(binds.Init) then proj.CustomInitialize = binds.Init end
    if isfunction(binds.Think) then proj.CustomThink = binds.Think end
    if isfunction(binds.Filter) then proj.OnFilter = binds.Filter end
    if isfunction(binds.Contact) then proj.OnContact = binds.Contact end
    if isfunction(binds.Use) then proj.Use = binds.Use end
    if isfunction(binds.Damage) then proj.OnTakeDamage = binds.Damage end
    if isfunction(binds.Remove) then proj.OnRemove = binds.Remove end
    proj:Spawn()
    return proj
  end

  local TARGET_BLACKLIST = {
    ["npc_bullseye"] = true,
    ["npc_grenade_frag"] = true,
    ["npc_tripmine"] = true,
    ["npc_satchel"] = true
  }
  local TARGET_WHITELIST = {
    ["replicator_melon"] = true,
    ["replicator_worker"] = true,
    ["replicator_queen"] = true,
    ["replicator_queen_hive"] = true
  }
  function DrGBase.IsTarget(ent)
    if not IsValid(ent) then return false end
    if TARGET_BLACKLIST[ent:GetClass()] then return false end
    if TARGET_WHITELIST[ent:GetClass()] then return true end
    if ent.DrGBase_Target then return true end
    if ent:IsPlayer() then return true end
    if ent:IsNPC() then return true end
    if ent.Type == "nextbot" then return true end
    if string.StartWith(ent:GetClass(), "npc_") then return true end
    return false
  end

end
