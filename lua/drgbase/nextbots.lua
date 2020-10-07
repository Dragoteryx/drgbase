-- Misc --

DrG_Nextbots = DrG_Nextbots or {}
function DrGBase.NextbotIterator()
  local thr = coroutine.create(function()
    for i = 1, #DrG_Nextbots do
      local nextbot = DrG_Nextbots[i]
      if IsValid(nextbot) then coroutine.yield(nextbot) end
    end
  end)
  return function()
    local _, nextbot = coroutine.resume(thr)
    return nextbot
  end
end
function DrGBase.GetNextbots()
  local nextbots = {}
  for nextbot in DrGBase.NextbotIterator() do
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
  nextbots:InternalDoClick()
end)

-- Footsteps --

DrGBase.DefaultFootsteps = {
  [MAT_ANTLION] = {
    "physics/flesh/flesh_impact_hard1.wav",
    "physics/flesh/flesh_impact_hard2.wav",
    "physics/flesh/flesh_impact_hard3.wav",
    "physics/flesh/flesh_impact_hard4.wav",
    "physics/flesh/flesh_impact_hard5.wav",
    "physics/flesh/flesh_impact_hard6.wav"
  },
  [MAT_BLOODYFLESH] = {
    "physics/flesh/flesh_squishy_impact_hard1.wav",
    "physics/flesh/flesh_squishy_impact_hard2.wav",
    "physics/flesh/flesh_squishy_impact_hard3.wav",
    "physics/flesh/flesh_squishy_impact_hard4.wav"
  },
  [MAT_CONCRETE] = {
    "player/footsteps/concrete1.wav",
    "player/footsteps/concrete2.wav",
    "player/footsteps/concrete3.wav",
    "player/footsteps/concrete4.wav"
  },
  [MAT_DIRT] = {
    "player/footsteps/dirt1.wav",
    "player/footsteps/dirt2.wav",
    "player/footsteps/dirt3.wav",
    "player/footsteps/dirt4.wav"
  },
  [MAT_EGGSHELL] = {
    "physics/flesh/flesh_impact_hard1.wav",
    "physics/flesh/flesh_impact_hard2.wav",
    "physics/flesh/flesh_impact_hard3.wav",
    "physics/flesh/flesh_impact_hard4.wav",
    "physics/flesh/flesh_impact_hard5.wav",
    "physics/flesh/flesh_impact_hard6.wav"
  },
  [MAT_FLESH] = {
    "physics/flesh/flesh_impact_hard1.wav",
    "physics/flesh/flesh_impact_hard2.wav",
    "physics/flesh/flesh_impact_hard3.wav",
    "physics/flesh/flesh_impact_hard4.wav",
    "physics/flesh/flesh_impact_hard5.wav",
    "physics/flesh/flesh_impact_hard6.wav"
  },
  [MAT_GRATE] = {
    "player/footsteps/chainlink1.wav",
    "player/footsteps/chainlink2.wav",
    "player/footsteps/chainlink3.wav",
    "player/footsteps/chainlink4.wav"
  },
  [MAT_ALIENFLESH] = {
    "physics/flesh/flesh_impact_hard1.wav",
    "physics/flesh/flesh_impact_hard2.wav",
    "physics/flesh/flesh_impact_hard3.wav",
    "physics/flesh/flesh_impact_hard4.wav",
    "physics/flesh/flesh_impact_hard5.wav",
    "physics/flesh/flesh_impact_hard6.wav"
  },
  [MAT_SNOW] = {
    "player/footsteps/grass1.wav",
    "player/footsteps/grass2.wav",
    "player/footsteps/grass3.wav",
    "player/footsteps/grass4.wav"
  },
  [MAT_PLASTIC] = {
    "physics/plastic/plastic_box_impact_soft1.wav",
    "physics/plastic/plastic_box_impact_soft2.wav",
    "physics/plastic/plastic_box_impact_soft3.wav",
    "physics/plastic/plastic_box_impact_soft4.wav"
  },
  [MAT_METAL] = {
    "player/footsteps/metal1.wav",
    "player/footsteps/metal2.wav",
    "player/footsteps/metal3.wav",
    "player/footsteps/metal4.wav"
  },
  [MAT_SAND] = {
    "player/footsteps/sand1.wav",
    "player/footsteps/sand2.wav",
    "player/footsteps/sand3.wav",
    "player/footsteps/sand4.wav"
  },
  [MAT_FOLIAGE] = {
    "player/footsteps/grass1.wav",
    "player/footsteps/grass2.wav",
    "player/footsteps/grass3.wav",
    "player/footsteps/grass4.wav"
  },
  [MAT_COMPUTER] = {
    "player/footsteps/metal1.wav",
    "player/footsteps/metal2.wav",
    "player/footsteps/metal3.wav",
    "player/footsteps/metal4.wav"
  },
  [MAT_SLOSH] = {
    "player/footsteps/slosh1.wav",
    "player/footsteps/slosh2.wav",
    "player/footsteps/slosh3.wav",
    "player/footsteps/slosh4.wav"
  },
  [MAT_TILE] = {
    "player/footsteps/tile1.wav",
    "player/footsteps/tile2.wav",
    "player/footsteps/tile3.wav",
    "player/footsteps/tile4.wav"
  },
  [MAT_GRASS] = {
    "player/footsteps/grass1.wav",
    "player/footsteps/grass2.wav",
    "player/footsteps/grass3.wav",
    "player/footsteps/grass4.wav"
  },
  [MAT_VENT] = {
    "player/footsteps/duct1.wav",
    "player/footsteps/duct2.wav",
    "player/footsteps/duct3.wav",
    "player/footsteps/duct4.wav"
  },
  [MAT_WOOD] = {
    "player/footsteps/wood1.wav",
    "player/footsteps/wood2.wav",
    "player/footsteps/wood3.wav",
    "player/footsteps/wood4.wav"
  },
  [MAT_DEFAULT] = {
    "player/footsteps/concrete1.wav",
    "player/footsteps/concrete2.wav",
    "player/footsteps/concrete3.wav",
    "player/footsteps/concrete4.wav"
  },
  [MAT_GLASS] = {
    "physics/glass/glass_sheet_step1.wav",
    "physics/glass/glass_sheet_step2.wav",
    "physics/glass/glass_sheet_step3.wav",
    "physics/glass/glass_sheet_step4.wav"
  },
  [MAT_WARPSHIELD] = {
    "physics/glass/glass_sheet_step1.wav",
    "physics/glass/glass_sheet_step2.wav",
    "physics/glass/glass_sheet_step3.wav",
    "physics/glass/glass_sheet_step4.wav"
  }
}
