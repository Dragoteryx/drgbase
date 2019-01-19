DrGBase.Nextbot = DrGBase.Nextbot or {}

DrGBase.Nextbot.ConVars = DrGBase.Nextbot.ConVars or {}
DrGBase.Nextbot.ConVars.Debug = CreateConVar("drgbase_nextbots_debug", "0")
DrGBase.Nextbot.ConVars.Possession = CreateConVar("drgbase_nextbots_possession", "1")

function DrGBase.Nextbot.Debug(nextbot, text)
  if not DrGBase.Nextbot.ConVars.Debug:GetBool() then return end
  DrGBase.Print("Nextbot '"..nextbot:GetClass().."' ("..nextbot:EntIndex().."): "..text)
end

function DrGBase.Nextbot.Load(nextbot)
  if CLIENT then
    language.Add(nextbot.Class, nextbot.Name)
    killicon.Add(nextbot.Class, nextbot.Killicon.icon, nextbot.Killicon.color)
  end
  list.Set("NPC", nextbot.Class, nextbot)
  list.Set("DrGBaseNextbot", nextbot.Class, nextbot)
  DrGBase.Print("Nextbot '"..nextbot.Class.."': loaded.")
end
function DrGBase.Nextbot.GetLoaded()
  return list.Get("DrGBaseNextbot")
end
function DrGBase.Nextbot.IsLoaded(nextbot)
  if not isstring(nextbot) then nextbot = nextbot:GetClass() end
  return list.Get("DrGBaseNextbot")[nextbot] ~= nil
end

function DrGBase.Nextbot.Possessing(ply)
  if CLIENT then ply = ply or LocalPlayer() end
  return ply._DrGBasePossessing
end

if SERVER then

  DrGBase.Nextbot._Spawned = DrGBase.Nextbot._Spawned or {}
  function DrGBase.Nextbot.GetAll()
    return DrGBase.Nextbot._Spawned
  end

else

  function DrGBase.Nextbot.GetAll()
    local nextbots = {}
    for i, ent in ipairs(ents.GetAll()) do
      if not ent.IsDrGNextbot then continue end
      table.insert(nextbots, ent)
    end
    return nextbots
  end

end
