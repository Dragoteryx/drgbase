local nbMETA = FindMetaTable("NextBot")

local NB = {}

local function __index(self, key)
  local val = NB[key]
  if val ~= nil then return val end
  return nbMETA.__index(self, key)
end

hook.Add("OnEntityCreated", "DrG/NextbotMetaTable", function(ent)
  if not scripted_ents.IsBasedOn(ent:GetClass(), "drgbase_nextbot") then return end
  local metatable = table.Merge({}, debug.getmetatable(ent))
  metatable.__index = __index
  debug.setmetatable(ent, metatable)
end)