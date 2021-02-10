-- ConVars --

function DrGBase.ConVar(name, value, ...)
  return CreateConVar(name, value, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, ...)
end
function DrGBase.ClientConVar(name, value, ...)
  return CreateClientConVar(name, value, true, false, ...)
end
function DrGBase.SharedClientConVar(name, value, ...)
  return CreateClientConVar(name, value, true, true, ...)
end

DrGBase.EnableDebug = DrGBase.ConVar("drgbase_debug", "0")
function DrGBase.DebugEnabled()
  return GetConVar("developer"):GetBool() and DrGBase.EnableDebug:GetBool()
end

-- Misc --

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

function DrGBase.Deprecation(old, new)
  local warned = false
  return function()
    if not warned and GetConVar("developer"):GetBool() then
      ErrorNoHalt("[DrGBase] Deprecation warning: '", old, "' is deprecated, you should use '", new, "' instead", "\n")
      warned = true
    end
  end
end
function DrGBase.Deprecated(old, new, fn)
  local deprecation = DrGBase.Deprecation(old, new)
  return function(...)
    deprecation()
    return fn(...)
  end
end

if SERVER then

  -- Misc --

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

else

  -- Misc --

  local MATERIALS = {}
  function DrGBase.Material(name, ...)
    if not MATERIALS[name] then
      local material = Material(name, ...)
      MATERIALS[name] = material
      return material
    else return MATERIALS[name] end
  end

end