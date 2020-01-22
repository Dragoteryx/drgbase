
DrGBase = DrGBase or {}
DrGBase.Icon = "drgbase/icon16.png"

-- Print --

function DrGBase.Print(msg, options)
  options = options or {}
  if not options.chat then
    local color = DrGBase.CLR_GREEN
    if options.color then color = options.color
    elseif SERVER then color = DrGBase.CLR_CYAN
    elseif CLIENT then color = DrGBase.CLR_ORANGE end
    local color2 = DrGBase.CLR_WHITE
    if options._error then color2 = DrGBase.CLR_RED end
    MsgC(color, "[DrGBase] ", color2, msg, "\n")
  elseif SERVER then
    net.Start("DrGBaseChatPrint")
    net.WriteString(msg)
    net.WriteBool(tobool(options._error))
    local hasColor = options.color ~= nil
    net.WriteBool(hasColor)
    if hasColor then net.WriteColor(options.color) end
    if IsValid(options.player) then net.Send(options.player)
    else net.Broadcast() end
  else
    local color = DrGBase.CLR_GREEN
    if options.color then color = options.color
    elseif options._server then color = DrGBase.CLR_CYAN
    elseif CLIENT then color = DrGBase.CLR_ORANGE end
    local color2 = DrGBase.CLR_WHITE
    if options._error then color2 = DrGBase.CLR_RED end
    chat.AddText(color, "[DrGBase] ", color2, msg)
  end
end
function DrGBase.Error(msg, options)
  options = options or {}
  options._error = true
  return DrGBase.Print(msg, options)
end
if CLIENT then
  net.Receive("DrGBaseChatPrint", function()
    local msg = net.ReadString()
    local error = net.ReadBool()
    local options = {_server = true, _error = error, chat = true}
    if net.ReadBool() then options.color = net.ReadColor() end
    DrGBase.Print(msg, options)
  end)
end

-- Manage files --

function DrGBase.IncludeFile(fileName, serverOnly)
  DrGBase.Print("Include file '"..fileName.."'.")
  if not serverOnly then
    AddCSLuaFile(fileName)
    return include(fileName)
  elseif SERVER then
    return include(fileName)
  end
end
function DrGBase.IncludeFiles(files, serverOnly)
  local tbl = {}
  for i, fileName in ipairs(files) do
    local res = DrGBase.IncludeFile(fileName, serverOnly)
    if res then table.insert(tbl, res) end
  end
  return tbl
end
function DrGBase.IncludeFolder(folder, serverOnly)
  DrGBase.Print("Include folder '"..folder.."'.")
  local tbl = {}
  for i, fileName in ipairs(file.Find(folder.."/*.lua", "LUA")) do
    local res = DrGBase.IncludeFile(folder.."/"..fileName, serverOnly)
    if res then table.insert(tbl, res) end
  end
  return tbl
end
function DrGBase.RecursiveInclude(folder, serverOnly)
  local tbl = DrGBase.IncludeFolder(folder)
  local files, folders = file.Find(folder.."/*", "LUA")
  for i, folderName in ipairs(folders) do
    table.Merge(tbl, DrGBase.RecursiveInclude(folder.."/"..folderName, serverOnly))
  end
  return tbl
end

-- Autorun --

DrGBase.IncludeFolder("drgbase")
DrGBase.IncludeFolder("drgbase/meta")
DrGBase.IncludeFolder("drgbase/modules")

if SERVER then
  util.AddNetworkString("DrGBaseChatPrint")
else

  hook.Add("Initialize", "DrGBaseHello", function()
    DrGBase.Print("Hi! :)", {color = DrGBase.CLR_GREEN})
  end)

end
