DrGBase = DrGBase or {}
DrGBase.Version = "2.0"

-- Colors --

DrGBase.CLR_WHITE = Color(255, 255, 255)
DrGBase.CLR_GREEN = Color(150, 255, 40)
DrGBase.CLR_RED = Color(255, 50, 50)
DrGBase.CLR_CYAN = Color(0, 200, 200)
DrGBase.CLR_PURPLE = Color(220, 40, 115)
DrGBase.CLR_BLUE = Color(50, 100, 255)
DrGBase.CLR_ORANGE = Color(255, 150, 30)
DrGBase.CLR_DARKGRAY = Color(20, 20, 20)
DrGBase.CLR_LIGHTGRAY = Color(200, 200, 200)

local function Transparent(color)
  color = color:ToVector():ToColor()
  color.a = 0
  return color
end

DrGBase.CLR_WHITE_TR = Transparent(DrGBase.CLR_WHITE)
DrGBase.CLR_GREEN_TR = Transparent(DrGBase.CLR_GREEN)
DrGBase.CLR_RED_TR = Transparent(DrGBase.CLR_RED)
DrGBase.CLR_CYAN_TR = Transparent(DrGBase.CLR_CYAN)
DrGBase.CLR_PURPLE_TR = Transparent(DrGBase.CLR_PURPLE)
DrGBase.CLR_BLUE_TR = Transparent(DrGBase.CLR_BLUE)
DrGBase.CLR_ORANGE_TR = Transparent(DrGBase.CLR_ORANGE)
DrGBase.CLR_DARKGRAY_TR = Transparent(DrGBase.CLR_DARKGRAY)
DrGBase.CLR_LIGHTGRAY_TR = Transparent(DrGBase.CLR_LIGHTGRAY)

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
    net.Start("DrG/ChatPrint")
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

if SERVER then
  util.AddNetworkString("DrG/ChatPrint")
else
  net.Receive("DrG/ChatPrint", function()
    DrGBase.Print(net.ReadString(), {
      chat = net.ReadBool(),
      color = net.ReadColor()
    })
  end)
end

-- ConVars --

function DrGBase.ConVar(name, value, ...)
  return CreateConVar(name, value, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, ...)
end
if SERVER then
  function DrGBase.ServerConVar(name, value, ...)
    return CreateConVar(name, value, {FCVAR_ARCHIVE}, ...)
  end
else
  function DrGBase.ClientConVar(name, value, ...)
    return CreateConVar(name, value, {FCVAR_ARCHIVE}, ...)
  end
  function DrGBase.SharedClientConVar(name, value, ...)
    return CreateConVar(name, value, {FCVAR_ARCHIVE, FCVAR_USERINFO}, ...)
  end
end

local EnableDebug = DrGBase.ConVar("drgbase_debug", "0")
function DrGBase.DebugEnabled()
  return GetConVar("developer"):GetBool() and EnableDebug:GetBool()
end

-- Classes --

local CLASSES = setmetatable({}, {__mode = "k"})
local function GetClass(obj)
  return CLASSES[obj]
end

function DrGBase.CreateClass(superclass)
  local class = setmetatable({}, {})
  class.prototype = setmetatable({}, {})

  if istable(superclass) then
    getmetatable(class).__index = superclass
    class.super = superclass

    getmetatable(class.prototype).__index = superclass.prototype
    class.prototype.super = setmetatable({}, {
      __index = superclass.prototype,
      __call = function(_, ...)
        if isfunction(superclass.new) then
          superclass.new(...)
        end
      end
    })
  end

  local function lessthan(self, other)
    return self:compare(other) < 0
  end
  local function lessequal(self, other)
    return self:compare(other) <= 0
  end
  local function concat(self, other)
    return tostring(self)..other
  end

  getmetatable(class).__call = function(_, ...)
    local obj = setmetatable({}, {
      __index = class.prototype,
      __call = class.prototype.call,
      __tostring = class.prototype.tostring,
      __len = class.prototype.length,
      __unm = class.prototype.unm,
      __add = class.prototype.add,
      __sub = class.prototype.sub,
      __mul = class.prototype.mul,
      __div = class.prototype.div,
      __mod = class.prototype.mod,
      __pow = class.prototype.pow,
      __eq = class.prototype.equals,

      __lt = lessthan,
      __le = lessequal,
      __concat = concat
    })
    CLASSES[obj] = class
    if isfunction(class.new) then
      return obj, class.new(obj, ...)
    else return obj end
  end

  function class.IsInstance(obj)
    if not istable(obj) then return false end
    local meta = getmetatable(obj)
    if not meta then return false end
    return meta.__index == class.prototype or
      IsInstance(meta.__index)
  end

  function class.IsChildClass(other)
    return class.IsInstance(other.prototype)
  end

  return class
end

function DrGBase.FlagsHelper(length)
  local ALL = (2^length)-1
  local class = DrGBase.CreateClass()

  local FLAGS = setmetatable({}, {__mode = "k"})
  function class:new(flags)
    FLAGS[self] = isnumber(flags) and flags or 0
  end

  function class.prototype:GetFlags()
    return FLAGS[self]
  end
  function class.prototype:AddFlags(flags)
    FLAGS[self] = bit.bor(FLAGS[self], flags)
  end
  function class.prototype:RemoveFlags(flags)
    if not self:IsFlagSet(flags) then return end
    FLAGS[self] = self:GetFlags() - flags
  end
  function class.prototype:IsFlagSet(flags)
    return bit.band(self:GetFlags(), flags) == flags
  end

  function class.prototype:equals(other)
    return self:GetFlags() == other:GetFlags()
  end
  function class.prototype:unm()
    return GetClass(self)(ALL - self:GetFlags())
  end
  function class.prototype:add(other)
    return GetClass(self)(bit.bor(self:GetFlags(), other:GetFlags()))
  end
  function class.prototype:mul(other)
    return GetClass(self)(bit.band(self:GetFlags(), other:GetFlags()))
  end
  function class.prototype:sub(other)
    return self * (-other)
  end

  return class
end

-- Files --

local DEPTH = 0
local function IncludePrefix()
  local depth = DEPTH
  local prefix = depth > 0 and "- " or ""
  while depth > 1 do
    prefix = "  "..prefix
    depth = depth-1
  end
  return prefix
end
local function ServerClient(fileName)
  local explode = string.Explode("[/\\]", fileName, true)
  local server = true
  local client = true
  for i = 1, #explode do
    local str = explode[i]
    if str == "server" or string.StartWith(str, "sv_") then client = false end
    if str == "client" or string.StartWith(str, "cl_") then server = false end
  end
  return server, client
end

local function IncludeFile(fileName)
  DEPTH = DEPTH+1
  local res = include(fileName)
  DEPTH = DEPTH-1
  return res
end
local function IncludeFolder(folder)
  local tbl = {}
  DEPTH = DEPTH+1
  for _, fileName in ipairs(file.Find(folder.."/*.lua", "LUA")) do
    tbl[folder.."/"..fileName] = DrGBase.IncludeFile(folder.."/"..fileName)
  end
  DEPTH = DEPTH-1
  return tbl
end

function DrGBase.IncludeFile(fileName)
  local server, client = ServerClient(fileName)
  local prefix = IncludePrefix()
  if server and not client then
    if CLIENT then return end
    DrGBase.Print(prefix.."File: "..fileName.." (include)")
    return IncludeFile(fileName)
  elseif client and not server then
    if CLIENT then
      DrGBase.Print(prefix.."File: "..fileName.." (include)")
      return IncludeFile(fileName)
    else
      DrGBase.Print(prefix.."File: "..fileName.." (send to client)")
      AddCSLuaFile(fileName)
    end
  elseif server and client then
    if SERVER then
      DrGBase.Print(prefix.."File: "..fileName.. " (include & send to client)")
      AddCSLuaFile(fileName)
    else DrGBase.Print(prefix.."File: "..fileName.." (include)") end
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
  local server, client = ServerClient(folder)
  local prefix = IncludePrefix()
  if server and not client then
    if CLIENT then return {} end
    DrGBase.Print(prefix.."Folder: "..folder.." (include)")
    return IncludeFolder(folder)
  elseif client and not server then
    if CLIENT then DrGBase.Print(prefix.."Folder: "..folder.." (include)")
    else DrGBase.Print(prefix.."Folder: "..folder.." (send to client)") end
    return IncludeFolder(folder)
  elseif server and client then
    if CLIENT then DrGBase.Print(prefix.."Folder: "..folder.." (include)")
    else DrGBase.Print(prefix.."Folder: "..folder.. " (include & send to client)") end
    return IncludeFolder(folder)
  else return {} end
end

function DrGBase.RecursiveInclude(folder)
  local tbl = DrGBase.IncludeFolder(folder)
  local _, folders = file.Find(folder.."/*", "LUA")
  DEPTH = DEPTH+1
  for _, folderName in ipairs(folders) do
    table.Merge(tbl, DrGBase.RecursiveInclude(folder.."/"..folderName))
  end
  DEPTH = DEPTH-1
  return tbl
end

-- Misc --

if CLIENT then
  hook.Add("InitPostEntity", "DrG/SayHi", function()
    timer.Simple(1, function()
      DrGBase.Info(DrGBase.GetText("drgbase.hello"))
      hook.Run("DrG/Handshake")
    end)
  end)
end

-- Import --

DrGBase.IncludeFolder("drgbase/modules")
DrGBase.IncludeFolder("drgbase")
DrGBase.IncludeFolder("drgbase/metatables")
DrGBase.IncludeFolder("drgbase/autorun")
DrGBase.IncludeFolder("drgbase/autorun/server")
DrGBase.IncludeFolder("drgbase/autorun/client")