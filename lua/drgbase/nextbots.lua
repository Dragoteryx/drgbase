-- Misc --

DrG_Nextbots = DrG_Nextbots or {}
function DrGBase.NextbotIterator(class)
  local i = 1
  return function()
    for j = i, #DrG_Nextbots do
      local ent = DrG_Nextbots[j]
      if not IsValid(ent) then continue end
      if class and class ~= ent:GetClass() then continue end
      i = j+1
      return ent
    end
  end
end
function DrGBase.GetNextbots(class)
  local nextbots = {}
  for nextbot in DrGBase.NextbotIterator(class) do
    table.insert(nextbots, nextbot)
  end
  return nextbots
end

-- Registry --

function DrGBase.AddNextbot(ENT)
  local class = string.Replace(ENT.Folder, "entities/", "")
  if ENT.PrintName == nil or ENT.Category == nil then return false end

  -- precache models
  if istable(ENT.Models) then
    for _, model in ipairs(ENT.Models) do
      if not isstring(model) then continue end
      util.PrecacheModel(model)
    end
  end

  -- precache sounds
  for _, sounds in ipairs({
    ENT.OnSpawnSounds,
    ENT.OnIdleSounds,
    ENT.OnDamageSounds,
    ENT.OnDeathSounds
  }) do
    if not istable(sounds) then continue end
    for _, soundName in ipairs(sounds) do
      if not isstring(soundName) then continue end
      util.PrecacheSound(soundName)
    end
  end

  -- resources
  if SERVER then
    resource.AddFile("materials/entities/"..class..".png")
  end

  -- language & killicon
  if CLIENT then
    language.Add(class, ENT.PrintName)
    ENT.Killicon = ENT.Killicon or {
      icon = "HUD/killicons/default",
      color = Color(255, 80, 0, 255)
    }
    killicon.Add(class, ENT.Killicon.icon, ENT.Killicon.color)
  end

  -- register nextbot
  local NPC = {Name = ENT.PrintName, Class = class, Category = ENT.Category}
  if ENT.Spawnable ~= false then
    list.Set("NPC", class, NPC)
    list.Set("DrG/Nextbots", class, NPC)
  end

  DrGBase.Print("Nextbot '"..class.."' loaded")
  return true
end

-- Spawnmenu --

if CLIENT then

  spawnmenu.AddContentType("drg/nextbot", function(panel, data)

  end)

  hook.Add("DrG/PopulateSpawnmenu", "AddDrGBaseNextbots", function(panel, tree)
    local categories = {}
    for class, nextbot in pairs(list.Get("DrG/Nextbots")) do
      local category = nextbot.Category or "Other"
      categories[category] = categories[category] or {}
      categories[category][class] = nextbot
    end
    local nextbots = tree:AddNode("Nextbots", "icon16/monkey.png")
    for name, category in pairs(categories) do
      local icon = DrGBase.GetIcon(name) or "icon16/monkey.png"

    end
  end)

end
