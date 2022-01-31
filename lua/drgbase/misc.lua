local RANGE_MELEE = {
  ["melee"] = true,
  ["melee2"] = true,
  ["fist"] = true,
  ["knife"] = true
}
function DrGBase.IsMeleeWeapon(weapon)
  local holdType = weapon:GetHoldType()
  if RANGE_MELEE[holdType] or RANGE_MELEE[weapon.HoldType] then return true end
  return weapon.DrGBase_Melee or string.find(holdType, "melee") ~= nil
end

if SERVER then

  function DrGBase.CreateProjectile(model, binds)
    local proj = ents.Create("proj_drg_default")
    if not IsValid(proj) then return NULL end
    if istable(model) and #model > 0 then model = model[math.random(#model)] end
    if isstring(model) then proj:SetModel(model) end
    binds = binds or {}
    if isfunction(binds.Init) then proj.CustomInitialize = binds.Init end
    if isfunction(binds.Think) then proj.CustomThink = binds.Think end
    if isfunction(binds.Contact) then proj.OnContact = binds.Contact end
    if isfunction(binds.Use) then proj.Use = binds.Use end
    if isfunction(binds.DealtDamage) then proj.OnDealtDamage = binds.DealtDamage end
    if isfunction(binds.TakeDamage) then proj.OnTakeDamage = binds.TakeDamage end
    if isfunction(binds.Remove) then proj.OnRemove = binds.Remove end
    proj:Spawn()
    return proj
  end

end