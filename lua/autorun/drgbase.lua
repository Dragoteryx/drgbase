
DrGBase = DrGBase or {}
function DrGBase.IncludeFile(fileName)
  AddCSLuaFile(fileName)
  include(fileName)
end
function DrGBase.IncludeFiles(files)
  for i, fileName in ipairs(files) do
    DrGBase.IncludeFile(fileName)
  end
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

local str = "../drgbase/"
DrGBase.IncludeFiles({
  str.."behaviours.lua",
  str.."colors.lua",
  str.."commands.lua",
  str.."enumerations.lua",
  str.."extensions.lua",
  str.."misc.lua",
  str.."modules.lua",
  str.."nextbots.lua",
  str.."possession.lua",
  str.."projectiles.lua",
  str.."resources.lua",
  str.."spawnmenu.lua",
  str.."weapons.lua"
})

if SERVER then

else

  hook.Add("Initialize", "DrGBaseHello", function()
    DrGBase.Print("Hi! :)")
  end)

end
