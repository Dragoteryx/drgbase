-- Functions --

local MIXINS = {}
function DrGBase.ApplyMixin(class, mixin)
  MIXINS[class] = MIXINS[class] or {}
  table.insert(MIXINS[class], mixin)
end

-- SENTs --

local function ApplySENTMixins(ENT, class)
  for mixinClass, mixins in pairs(MIXINS) do
    if class ~= mixinClass and
    not scripted_ents.IsBasedOn(class, mixinClass) then continue end
    ENT.DrG_Mixin = ENT.DrG_Mixin or {}
    for _, mixin in ipairs(mixins) do
      for key, value in pairs(mixin) do
        if ENT[key] == nil then continue end
        ENT.DrG_Mixin[key] = ENT[key]
        ENT[key] = value
      end
    end
  end
end

hook.Add("PreRegisterSENT", "DrG/ApplySENTMixins", function(ENT, class)
  if not DrG_scripted_ents_OnLoaded_Ok then return end
  ApplySENTMixins(ENT, class)
end)

DrG_scripted_ents_OnLoaded = DrG_scripted_ents_OnLoaded or scripted_ents.OnLoaded
function scripted_ents.OnLoaded()
  DrG_scripted_ents_OnLoaded()
  if not DrG_scripted_ents_OnLoaded_Ok then
    for class, tbl in pairs(scripted_ents.GetList()) do ApplySENTMixins(tbl.t, class) end
    DrG_scripted_ents_OnLoaded_Ok = true
  end
end

-- SWEPS --



-- Built-in --

local GenericMixin = DrGBase.IncludeFile("mixins/generic.lua")
local NextbotMixin = DrGBase.IncludeFile("mixins/nextbot.lua")
local ProjectileMixin = DrGBase.IncludeFile("mixins/projectile.lua")
local SpawnerMixin = DrGBase.IncludeFile("mixins/spawner.lua")
local WeaponMixin = DrGBase.IncludeFile("mixins/weapon.lua")

DrGBase.ApplyMixin("drgbase_nextbot", GenericMixin)
DrGBase.ApplyMixin("drgbase_nextbot", NextbotMixin)

DrGBase.ApplyMixin("drgbase_projectile", GenericMixin)
DrGBase.ApplyMixin("drgbase_projectile", ProjectileMixin)

DrGBase.ApplyMixin("drgbase_spawner", GenericMixin)
DrGBase.ApplyMixin("drgbase_spawner", SpawnerMixin)