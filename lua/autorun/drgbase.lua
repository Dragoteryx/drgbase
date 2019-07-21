
DrGBase = DrGBase or {}
DrGBase.Icon = "drgbase/icon16.png"

-- Print --

function DrGBase.Print(msg, error)
  local color = DrGBase.CLR_GREEN
  if SERVER then color = DrGBase.CLR_CYAN
  elseif CLIENT then color = DrGBase.CLR_ORANGE end
  local color2 = DrGBase.CLR_WHITE
  if error then color2 = DrGBase.CLR_RED end
  MsgC(color, "[DrGBase] ", color2, msg, "\n")
end
function DrGBase.Error(msg)
  return DrGBase.Print(msg, true)
end

function DrGBase.ChatPrint(msg, ply, error)
  if SERVER and IsValid(ply) then
    ply:SendLua('DrGBase.ChatPrint("'..msg..'", NULL, '..tostring(error)..')')
  else
    local color = DrGBase.CLR_GREEN
    if SERVER or ply == NULL then color = DrGBase.CLR_CYAN
    elseif CLIENT then color = DrGBase.CLR_ORANGE end
    local color2 = DrGBase.CLR_WHITE
    if error then color2 = DrGBase.CLR_RED end
    chat.AddText(color, "[DrGBase] ", color2, msg)
  end
end
function DrGBase.ChatError(msg, ply)
  return DrGBase.ChatPrint(msg, ply, true)
end

-- Manage files --

function DrGBase.IncludeFile(fileName, serverOnly)
  DrGBase.Print("Include file '"..fileName.."'.")
  if not serverOnly then AddCSLuaFile(fileName) end
  include(fileName)
end
function DrGBase.IncludeFiles(files, serverOnly)
  for i, fileName in ipairs(files) do
    DrGBase.IncludeFile(fileName, serverOnly)
  end
end
function DrGBase.IncludeFolder(folder, serverOnly)
  DrGBase.Print("Include folder '"..folder.."'.")
  for i, fileName in ipairs(file.Find(folder.."/*.lua", "LUA")) do
    DrGBase.IncludeFile(folder.."/"..fileName, serverOnly)
  end
end
function DrGBase.RecursiveInclude(folder, serverOnly)
  DrGBase.IncludeFolder(folder)
  local files, folders = file.Find(folder.."/*", "LUA")
  for i, folderName in ipairs(folders) do
    DrGBase.RecursiveInclude(folder.."/"..folderName, serverOnly)
  end
end

-- Autorun --

DrGBase.IncludeFolder("drgbase")
DrGBase.IncludeFolder("drgbase/extensions")
DrGBase.IncludeFolder("drgbase/modules")

if SERVER then

else

  hook.Add("Initialize", "DrGBaseHello", function()
    DrGBase.Print("Hi! :)")
  end)

end
