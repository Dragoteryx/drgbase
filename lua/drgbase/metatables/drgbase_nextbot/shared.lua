local nbMETA = FindMetaTable("NextBot")

local META = {}
META.__newindex = nbMETA.__newindex
META.__tostring = nbMETA.__tostring
META.MetaBaseClass = nbMETA
META.MetaName = "DrG/NextBot"
META.MetaID = 9

function META:__index(key)
  local val = META[key]
  if val ~= nil then return val end
  return nbMETA[key]
end

debug.getregistry()[META.MetaName] = META
DrGBase.IncludeFile("ai.lua")
DrGBase.IncludeFile("animations.lua")
DrGBase.IncludeFile("bgm.lua")
DrGBase.IncludeFile("deprecated.lua")
DrGBase.IncludeFile("detection.lua")
DrGBase.IncludeFile("enemy.lua")
--DrGBase.IncludeFile("drgbase/metatables/drgbase_nextbot/hooks.lua")
DrGBase.IncludeFile("misc.lua")
DrGBase.IncludeFile("movements.lua")
DrGBase.IncludeFile("possession.lua")
DrGBase.IncludeFile("relationships.lua")
DrGBase.IncludeFile("status.lua")
DrGBase.IncludeFile("sv_locomotion.lua")
DrGBase.IncludeFile("sv_path.lua")
DrGBase.IncludeFile("weapons.lua")

function META:OnReloaded()

end

return META, function(self)
  print("hello!")

end