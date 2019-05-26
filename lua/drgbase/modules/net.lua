
local reqID = 0
local callbacks = {}
local waiting = {}
function net.DrG_DefineCallback(name, callback)
  callbacks[name] = callback
end
function net.DrG_UseCallback(name, data, callback, ply)
  if not isstring(name) then return end
  if SERVER and (not IsValid(ply) or not ply:IsPlayer()) then return end
  waiting[reqID] = callback
  net.Start("DrGBaseNetCallbackRequest")
  local compressed = util.Compress(util.TableToJSON({
    reqID = reqID,
    name = name,
    data = data
  }))
  net.WriteData(compressed, #compressed)
  if SERVER then net.Send(ply)
  else net.SendToServer() end
  reqID = reqID+1
end
net.Receive("DrGBaseNetCallbackRequest", function(len, ply)
  local tab = util.JSONToTable(util.Decompress(net.ReadData(len/8)))
  if callbacks[tab.name] == nil then return end
  local res = callbacks[tab.name](tab.data)
  local compressed = util.Compress(util.TableToJSON({
    reqID = tab.reqID,
    res = res
  }))
  net.Start("DrGBaseNetCallbackResponse")
  net.WriteData(compressed, #compressed)
  if SERVER then net.Send(ply)
  else net.SendToServer() end
end)
net.Receive("DrGBaseNetCallbackResponse", function(len)
  local tab = util.JSONToTable(util.Decompress(net.ReadData(len/8)))
  if isfunction(waiting[tab.reqID]) then
    waiting[tab.reqID](tab.res)
    waiting[tab.reqID] = nil
  end
end)

if SERVER then
  util.AddNetworkString("DrGBaseNetCallbackRequest")
  util.AddNetworkString("DrGBaseNetCallbackResponse")
end
