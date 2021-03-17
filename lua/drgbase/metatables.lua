-- Functions --

local function IsBasedOn(class, base)
  return class == base or scripted_ents.IsBasedOn(class, base)
end

local function CreateMetaTable(class)
  local meta = DrGBase.IncludeFile("drgbase/metatables/"..class.."/shared.lua")
  debug.getregistry()[meta.MetaName] = meta
  hook.Add("OnEntityCreated", "DrG/SetMetatable("..class..")", function(ent)
    if not IsBasedOn(ent:GetClass(), class) then return end
    debug.setmetatable(ent, meta)
  end)
  return meta
end

-- Create metatables --

local nextbot = CreateMetaTable("drgbase_nextbot")