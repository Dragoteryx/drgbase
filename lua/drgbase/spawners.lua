-- Misc --

if SERVER then

  function DrGBase.CreateSpawner(pos, tospawn, radius, quantity, class)
    local spawner = ents.Create(class or "spwn_drg_default")
    if not IsValid(spawner) then return NULL end
    if isvector(pos) then spawner:SetPos(pos) end
    spawner:Spawn()
    spawner:SetRadius(radius)
    spawner:SetQuantity(quantity)
    if istable(tospawn) then
      for class, nb in pairs(tospawn) do
        spawner:AddToSpawn(class, nb)
      end
    else spawner:AddToSpawn(tospawn) end
    return spawner
  end

end

-- Registry --

function DrGBase.AddSpawner(ENT)
  local class = string.Replace(ENT.Folder, "entities/", "")
  if ENT.PrintName == nil or ENT.Category == nil then return false end
  if SERVER then resource.AddFile("materials/entities/"..class..".png")
  else language.Add(class, ENT.PrintName) end
  local spawner = {
    Name = ENT.PrintName,
    Class = class,
    Category = ENT.Category
  }
  if ENT.Spawnable ~= false then
    list.Set("NPC", class, spawner)
    list.Set("DrG/Spawners", class, spawner)
  end
  DrGBase.Print("Spawner '"..class.."' loaded")
  return true
end

-- Spawnmenu --

hook.Add("DrG/PopulateSpawnmenu", "AddSpawners", function(panel, tree)
	local spawners = list.Get("DrG/Spawners")
	
end)