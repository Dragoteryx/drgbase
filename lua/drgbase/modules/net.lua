-- Util --

function net.DrG_WriteMessage(...)
  local args, n = table.DrG_Pack(...)
  net.WriteUInt(n, 8)
  for i = 1, n do
    net.WriteType(args[i])
  end
end
function net.DrG_ReadMessage()
  local n = net.ReadUInt(8)
  local args = {}
  for i = 1, n do
    args[i] = net.ReadType()
  end
  return args, n
end

-- Messages --

function net.DrG_Receive(name, fn)
  return net.Receive(name, function(_len, ply)
    local args, n = net.DrG_ReadMessage()
    if SERVER then fn(ply, table.DrG_Unpack(args, n))
    else fn(table.DrG_Unpack(args, n)) end
  end)
end
function net.DrG_DelayedReceive(name, fn)
  return net.DrG_Receive(name, function(...)
    timer.DrG_Simple(engine.TickInterval(), fn, ...)
  end)
end

if SERVER then
  local plyMETA = FindMetaTable("Player")
  function plyMETA:DrG_Send(name, ...)
    net.Start(name)
    net.DrG_WriteMessage(...)
    return net.Send(self)
  end
  function net.DrG_BroadCast(name, ...)
    net.Start(name)
    net.DrG_WriteMessage(...)
    return net.Broadcast()
  end
else
  function net.DrG_SendToServer(name, ...)
    net.Start(name)
    net.DrG_WriteMessage(...)
    return net.SendToServer()
  end
end

-- Callbacks --

DrG_NetCallbacks = DrG_NetCallbacks or {}
function net.DrG_DefineCallback(name, fn)
  DrG_NetCallbacks[name] = fn
end
function net.DrG_RemoveCallback(name)
  DrG_NetCallbacks[name] = nil
end

DrG_NetCallbackID = DrG_NetCallbackID or 0
DrG_NetCallbacksPending = DrG_NetCallbacksPending or {}
local function UseCallback(name, fn, ...)
  net.Start("DrG/NetCallbackReq")
  local id = DrG_NetCallbackID
  DrG_NetCallbackID = DrG_NetCallbackID+1
  net.WriteInt(id, 32)
  net.WriteString(name)
  net.DrG_WriteMessage(...)
  DrG_NetCallbacksPending[id] = fn
end

net.Receive("DrG/NetCallbackReq", function(_len, ply)
  local id = net.ReadInt(32)
  local name = net.ReadString()
  local args, n = net.DrG_ReadMessage()
  local fn = DrG_NetCallbacks[name]
  if not isfunction(fn) then return end
  net.Start("DrG/NetCallbackRes")
  net.WriteInt(id, 32)
  net.DrG_WriteMessage(fn(table.DrG_Unpack(args, n)))
  if SERVER then net.Send(ply)
  else net.SendToServer() end
end)
net.Receive("DrG/NetCallbackRes", function()
  local id = net.ReadInt(32)
  local args, n = net.DrG_ReadMessage()
  local fn = DrG_NetCallbacksPending[id]
  if not isfunction(fn) then return end
  DrG_NetCallbacksPending[id] = nil
  fn(table.DrG_Unpack(args, n))
end)

if SERVER then
  util.AddNetworkString("DrG/NetCallbackReq")
  util.AddNetworkString("DrG/NetCallbackRes")

  local plyMETA = FindMetaTable("Player")
  function plyMETA:DrG_RunCallback(name, fn, ...)
    UseCallback(name, fn, ...)
    net.Send(self)
  end
else
  function net.DrG_RunCallback(name, fn, ...)
    UseCallback(name, fn, ...)
    net.SendToServer()
  end
end