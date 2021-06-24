local function IsBasedOn(class, base)
  return class == base or scripted_ents.IsBasedOn(class, base)
end

local function CreateMetaTable(class)
  local meta, init = DrGBase.IncludeFile(class.."/shared.lua")
  debug.getregistry()[meta.MetaName] = meta
  hook.Add("OnEntityCreated", "DrG/SetMetatable("..class..")", function(ent)
    if not IsValid(ent) or not IsBasedOn(ent:GetClass(), class) then return end
    debug.setmetatable(ent, meta)
    if init then init(ent) end
  end)
  return meta
end

--CreateMetaTable("drgbase_nextbot")
--CreateMetaTable("drgbase_projectile")
--CreateMetaTable("drgbase_spawner")