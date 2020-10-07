DrGBase = DrGBase or {}

-- Print --

function DrGBase.Print(msg, options)
  if not istable(options) then options = {} end
  if SERVER and (options.chat or options.player) then
    local ply = options.player
    if ply and (
      not IsEntity(ply) or
      not IsValid(ply) or
      not ply:IsPlayer()
    ) then return false end
    net.Start("DrGBaseChatPrint")
    net.WriteString(msg)
    net.WriteBool(tobool(options.chat))
    net.WriteColor(options.color or DrGBase.CLR_CYAN)
    if ply then net.Send(ply)
    else net.Broadcast() end
    return true
  else
    local color = options.color
    if not color then
      if SERVER then color = DrGBase.CLR_CYAN
      elseif CLIENT then color = DrGBase.CLR_ORANGE
      else color = DrGBase.CLR_GREEN end
    end
    if options.chat then
      chat.AddText(color, "[DrGBase] ", DrGBase.CLR_WHITE, msg)
    else MsgC(color, "[DrGBase] ", DrGBase.CLR_WHITE, msg, "\n") end
    return true
  end
end
function DrGBase.Info(msg, options)
  if not istable(options) then options = {} end
  options.color = DrGBase.CLR_GREEN
  return DrGBase.Print(msg, options)
end
function DrGBase.Error(msg, options)
  if not istable(options) then options = {} end
  options.color = DrGBase.CLR_RED
  return DrGBase.Print(msg, options)
end
if CLIENT then
  net.Receive("DrGBaseChatPrint", function()
    DrGBase.Print(net.ReadString(), {
      chat = net.ReadBool(), color = net.ReadColor()
    })
  end)
else util.AddNetworkString("DrGBaseChatPrint") end

-- Manage files --

local function IncludeFile(fileName)
  DrGBase.Print("Include file '"..fileName.."'")
  return include(fileName)
end
function DrGBase.IncludeFile(fileName)
  local explode = string.Explode("[/\\]", fileName, true)
  local last = explode[#explode]
  if string.StartWith(last, "sv_") or
  table.HasValue(explode, "server") then
    if SERVER then return IncludeFile(fileName) end
  elseif string.StartWith(last, "cl_") or
  table.HasValue(explode, "client") then
    AddCSLuaFile(fileName)
    if CLIENT then return IncludeFile(fileName) end
  else
    AddCSLuaFile(fileName)
    return IncludeFile(fileName)
  end
end
function DrGBase.IncludeFiles(fileNames)
  local tbl = {}
  for _, fileName in ipairs(fileNames) do
    tbl[fileName] = DrGBase.IncludeFile(fileName)
  end
  return tbl
end
function DrGBase.IncludeFolder(folder)
  DrGBase.Print("Include folder '"..folder.."'")
  local tbl = {}
  for _, fileName in ipairs(file.Find(folder.."/*.lua", "LUA")) do
    tbl[folder.."/"..fileName] = DrGBase.IncludeFile(folder.."/"..fileName)
  end
  return tbl
end
function DrGBase.RecursiveInclude(folder)
  local tbl = DrGBase.IncludeFolder(folder)
  local _, folders = file.Find(folder.."/*", "LUA")
  for _, folderName in ipairs(folders) do
    table.Merge(tbl, DrGBase.RecursiveInclude(folder.."/"..folderName))
  end
  return tbl
end

-- Misc --

if CLIENT then
  hook.Add("Initialize", "DrGBaseHello", function()
    DrGBase.Info("Hi! :)")
  end)
end

-- Autorun --

DrGBase.IncludeFolder("drgbase")
DrGBase.IncludeFolder("drgbase/meta")
DrGBase.IncludeFolder("drgbase/modules")
DrGBase.RecursiveInclude("drgbase/autorun")