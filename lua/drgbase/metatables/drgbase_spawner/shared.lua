local ent_meta = FindMetaTable("Entity")

local meta = {}
meta.__newindex = ent_meta.__newindex
meta.__tostring = ent_meta.__tostring
meta.MetaBaseClass = ent_meta
meta.MetaName = "DrG/Spawner"
meta.MetaID = 9

function meta:__index(key)
  local val = meta[key]
  if val ~= nil then return val end
  return ent_meta[key]
end

return meta