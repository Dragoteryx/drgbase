local ent_meta = FindMetaTable("Entity")
local nb_meta = FindMetaTable("NextBot")

local meta = {}
meta.__newindex = nb_meta.__newindex
meta.__tostring = nb_meta.__tostring
meta.MetaBaseClass = nb_meta
meta.MetaName = "DrG/NextBot"
meta.MetaID = 9

function meta:__index(key)
  local val = meta[key]
  if val ~= nil then return val end
  local val = nb_meta[key]
  if val ~= nil then return val end
  local val = ent_meta.__index(self, key)
  if val ~= nil then return val end
  return nil
end

function meta:ThisIsATest() end

return meta