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
function DrGBase.Nextbot.IsLoaded(class)
  if type(class) ~= "string" then class = nextbot:GetClass() end
  return list.Get("DrGBaseNextbot")[class] ~= nil
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
      if ent:IsDrGBaseNextbot() then
        table.insert(nextbots, ent)
      end
    end
    return nextbots
  end

  -- draw nextbot info
  hook.Add("PostDrawOpaqueRenderables", "DrGBaseNextbotDrawDebug", function()
    if not DrGBase.Nextbot.ConVars.Debug:GetBool() then return end
    for i, ent in ipairs(DrGBase.Nextbot.GetAll()) do
      local bound1, bound2 = ent:GetCollisionBounds()
      render.DrawWireframeBox(ent:GetPos(), Angle(0, 0, 0), bound1, bound2, DrGBase.Colors.White, false)
      render.DrawLine(ent:BullseyePos(), ent:BullseyePos() + ent:GetVelocity(), DrGBase.Colors.Orange, false)
      if ent:EyesPos() ~= ent:BullseyePos() then
        render.DrawWireframeSphere(ent:BullseyePos(), 2, 4, 4, DrGBase.Colors.Orange, false)
      end
      local los = DrGBase.Colors.Red
      if ent:LineOfSight(LocalPlayer()) then los = DrGBase.Colors.Green end
      render.DrawWireframeSphere(ent:EyesPos(), 2, 4, 4, los, false)
      if LocalPlayer():Alive() then
        render.DrawLine(ent:EyesPos(), LocalPlayer():WorldSpaceCenter(), los, true)
      end
    end
  end)

end
