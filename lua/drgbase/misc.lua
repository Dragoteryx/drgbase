
if SERVER then

  function DrGBase.CreateProjectile(model, binds, class)
    local proj = ents.Create(class or "proj_drg_default")
    if not IsValid(proj) then return NULL end
    if istable(model) and #model > 0 then model = model[math.random(#model)] end
    proj.CustomInitialize = function(proj)
      if isstring(model) then proj:SetModel(model) end
      if isfunction(binds.Init) then binds.Init(proj) end
    end
    if isfunction(binds.Think) then proj.CustomThink = binds.Think end
    if isfunction(binds.Filter) then proj.OnFilter = binds.Filter end
    if isfunction(binds.Contact) then proj.OnContact = binds.Contact end
    if isfunction(binds.Use) then proj.Use = binds.Use end
    if isfunction(binds.Damage) then proj.OnTakeDamage = binds.Damage end
    if isfunction(binds.Remove) then proj.OnRemove = binds.Remove end
    proj:Spawn()
    return proj
  end

end
