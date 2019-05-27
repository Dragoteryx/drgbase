
-- Registry --

function DrGBase.AddNextbot(ENT)
  local class = string.Replace(ENT.Folder, "entities/", "")
  if ENT.Name == nil or ENT.Category == nil then return false end
  for i, model in ipairs(ENT.Models or {}) do
    util.PrecacheModel(model)
  end
  if CLIENT then
    language.Add(class, ENT.Name)
    ENT.Killicon = ENT.Killicon or {
      icon = "HUD/killicons/default",
      color = Color(255, 80, 0, 255)
    }
    killicon.Add(class, ENT.Killicon.icon, ENT.Killicon.color)
  else resource.AddFile("materials/entities/"..class..".png") end
  local nextbot = {
    Name = ENT.Name,
    Class = class,
    Category = ENT.Category
  }
  list.Set("NPC", class, nextbot)
  list.Set("DrGBaseNextbot", class, nextbot)
  DrGBase.Print("Nextbot '"..class.."': loaded.")
  return true
end

-- Misc --

DrGBase._SpawnedNextbots = DrGBase._SpawnedNextbots or {}
function DrGBase.GetNextbots()
  return DrGBase._SpawnedNextbots
end
