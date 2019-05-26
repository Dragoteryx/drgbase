
DrGBase = DrGBase or {}
function DrGBase.IncludeFile(file)
  AddCSLuaFile(file)
  include(file)
end
function DrGBase.IncludeFolder(folder)

end
function DrGBase.Print(msg, _err)
  local color = DrGBase.CLR_GREEN
  if SERVER then color = DrGBase.CLR_CYAN
  elseif CLIENT then color = DrGBase.CLR_ORANGE end
  local color2 = DrGBase.CLR_WHITE
  if _err then color2 = DrGBase.CLR_RED end
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

for i, fileName in ipairs({
  "behaviours.lua",
  "colors.lua",
  "commands.lua",
  "misc.lua",
  "nextbots.lua",
  "projectiles.lua",
  "weapons.lua"
}) do
  DrGBase.IncludeFile("../drgbase/"..fileName)
end

if SERVER then

else

  hook.Add("Initialize", "DrGBaseHello", function()
    DrGBase.Print("Hi! :)")
  end)

end
