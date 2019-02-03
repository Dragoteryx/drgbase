DrGBase.Nextbots = DrGBase.Nextbots or {}

function DrGBase.Nextbots.Load(nextbot)
  if nextbot.Name == nil or nextbot.Class == nil or nextbot.Category == nil then
    DrGBase.Error("Couldn't load nextbot: name, class or category nil.")
  else
    nextbot.Killicon = nextbot.Killicon or {
      icon = "HUD/killicons/default",
      color = Color(255, 80, 0, 255)
    }
    if CLIENT then
      language.Add(nextbot.Class, nextbot.Name)
      killicon.Add(nextbot.Class, nextbot.Killicon.icon, nextbot.Killicon.color)
    else resource.AddFile("materials/entities/"..nextbot.Class..".png") end
    list.Set("NPC", nextbot.Class, nextbot)
    list.Set("DrGBaseNextbot", nextbot.Class, nextbot)
    DrGBase.Print("Nextbot '"..nextbot.Class.."': loaded.")
  end
end
function DrGBase.Nextbots.GetLoaded()
  return list.Get("DrGBaseNextbot")
end
function DrGBase.Nextbots.IsLoaded(nextbot)
  if not isstring(nextbot) then nextbot = nextbot:GetClass() end
  return list.Get("DrGBaseNextbot")[nextbot] ~= nil
end

function DrGBase.Nextbots.Possessing(ply)
  if CLIENT then ply = ply or LocalPlayer() end
  return ply._DrGBasePossessing
end

if SERVER then

  DrGBase.Nextbots._Spawned = DrGBase.Nextbots._Spawned or {}
  function DrGBase.Nextbots.GetAll()
    return DrGBase.Nextbots._Spawned
  end

else

  function DrGBase.Nextbots.GetAll()
    local nextbots = {}
    for i, ent in ipairs(ents.GetAll()) do
      if not ent.IsDrGNextbot then continue end
      table.insert(nextbots, ent)
    end
    return nextbots
  end

end
