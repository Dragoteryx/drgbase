DrGBase = DrGBase or {}
function DrGBase.IncludeFile(file)
  AddCSLuaFile(file)
  include(file)
end
function DrGBase.Print(msg, _err)
  local color = DrGBase.Colors.Green
  if SERVER then color = DrGBase.Colors.Cyan
  elseif CLIENT then color = DrGBase.Colors.Orange end
  local color2 = DrGBase.Colors.White
  if _err then color2 = DrGBase.Colors.Red end
  MsgC(color, "[DrGBase] ", color2, msg, "\n")
end
function DrGBase.Error(msg)
  DrGBase.Print(msg, true)
end

DrGBase.IncludeFile("drgbase/colors.lua")
DrGBase.IncludeFile("drgbase/enums.lua")
DrGBase.IncludeFile("drgbase/meta.lua")
DrGBase.IncludeFile("drgbase/modules.Lua")
DrGBase.IncludeFile("drgbase/nextbots.lua")
DrGBase.IncludeFile("drgbase/possession_drive.lua")
DrGBase.IncludeFile("drgbase/possession.lua")
DrGBase.IncludeFile("drgbase/resources.lua")
DrGBase.IncludeFile("drgbase/spawnmenu.lua")
DrGBase.IncludeFile("drgbase/weapons.lua")

if SERVER then

else

  hook.Add("Initialize", "DrGBaseHello", function()
    DrGBase.Print("Hi! :)")
  end)

end
