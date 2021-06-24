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

return META