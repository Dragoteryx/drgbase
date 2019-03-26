DrGBase.Nextbots = DrGBase.Nextbots or {}

function DrGBase.Nextbots.Load(nextbot)
  if nextbot.Name == nil or nextbot.Class == nil or nextbot.Category == nil then
    DrGBase.Error("Couldn't load nextbot: name, class or category nil.")
  else
    if nextbot.Models ~= nil then
      for i, model in ipairs(nextbot.Models) do
        util.PrecacheModel(model)
      end
    end
    if CLIENT then
      language.Add(nextbot.Class, nextbot.Name)
      nextbot.Killicon = nextbot.Killicon or {
        icon = "HUD/killicons/default",
        color = Color(255, 80, 0, 255)
      }
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

DrGBase.Nextbots._Spawned = DrGBase.Nextbots._Spawned or {}
function DrGBase.Nextbots.GetAll()
  return DrGBase.Nextbots._Spawned
end

local DebugCommands = CreateConVar("drgbase_debug_commands", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

if SERVER then



else

  -- Commands --

  concommand.DrG_Add("!", "drgbase_count_nextbots", function()
    if not GetConVar("developer"):GetBool() or not DebugCommands:GetBool() then return end
    local nextbots = {}
    for i, ent in ipairs(DrGBase.Nextbots.GetAll()) do
      local class = ent:GetClass()
      if nextbots[class] == nil then nextbots[class] = 1
      else nextbots[class] = nextbots[class] + 1 end
    end
    local str = "Nextbots count:"
    for class, count in pairs(nextbots) do
      str = str.."\n"..class..": "..count
    end
    DrGBase.Print(str)
  end)

end
