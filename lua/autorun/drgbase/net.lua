
DrGBase.Net = DrGBase.Net or {}
DrGBase.Net._Callbacks = DrGBase.Net._Callbacks or {}
function DrGBase.Net.DefineCallback(name, callback)
  DrGBase.Net._Callbacks[name] = callback
end
local reqID = 0
function DrGBase.Net.UseCallback(name, data, callback, ply)
  if SERVER and (not IsValid(ply) or not ply:IsPlayer()) then return end
  local currID = reqID
  net.Receive("DrGBaseNetCallbackResponse", function(len)
    local tab = util.JSONToTable(util.Decompress(net.ReadData(len/8)))
    if tab.reqID ~= currID then return end
    callback(tab.res)
  end)
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
  if DrGBase.Net._Callbacks[tab.name] == nil then return end
  local res = DrGBase.Net._Callbacks[tab.name](tab.data)
  local compressed = util.Compress(util.TableToJSON({
    reqID = tab.reqID,
    res = res
  }))
  net.Start("DrGBaseNetCallbackResponse")
  net.WriteData(compressed, #compressed)
  if SERVER then net.Send(ply)
  else net.SendToServer() end
end)

DrGBase.Net._Vars = DrGBase.Net._Vars or {}
function DrGBase.Net.SetVar(name, value, ent)
  if CLIENT then return false end
  if ent == nil then ent = Entity(0) end
  if not IsValid(ent) and ent:EntIndex() ~= 0 then return end
  local valid = true
  local typ = type(value)
  net.Start("DrGBaseNetVar")
  net.WriteString(name)
  net.WriteEntity(ent)
  if typ == "Angle" then
    net.WriteFloat(DRGBASE_VARS_ANGLE)
    net.WriteAngle(value)
  elseif typ == "boolean" then
    net.WriteFloat(DRGBASE_VARS_BOOL)
    net.WriteBool(value)
  elseif typ == "Entity" then
    net.WriteFloat(DRGBASE_VARSentITY)
    net.WriteEntity(value)
  elseif typ == "number" then
    net.WriteFloat(DRGBASE_VARS_NUMBER)
    net.WriteFloat(value)
  elseif typ == "string" then
    net.WriteFloat(DRGBASE_VARS_STRING)
    net.WriteString(value)
  elseif typ == "Vector" then
    net.WriteFloat(DRGBASE_VARS_VECTOR)
    net.WriteVector(value)
  else valid = false
    net.WriteFloat(DRGBASE_VARS_INVALID)
  end
  net.Broadcast()
  ent._DrGBaseVars = ent._DrGBaseVars or {}
  ent._DrGBaseVars[name] = value
  return valid
end

function DrGBase.Net.GetVar(name, ent)
  if ent == nil then ent = Entity(0) end
  if IsValid(ent) or ent:EntIndex() == 0 then
    --PrintTable(ent._DrGBaseVars)
    ent._DrGBaseVars = ent._DrGBaseVars or {}
    return ent._DrGBaseVars[name]
  end
end

if SERVER then
  util.AddNetworkString("DrGBaseNetCallbackRequest")
  util.AddNetworkString("DrGBaseNetCallbackResponse")
  util.AddNetworkString("DrGBaseNetVar")

else

  net.Receive("DrGBaseNetVar", function()
    local name = net.ReadString()
    local ent = net.ReadEntity()
    local typ = net.ReadFloat()
    if typ == DRGBASE_VARS_INVALID then return end
    local value = nil
    if typ == DRGBASE_VARS_ANGLE then
      value = net.ReadAngle()
    elseif typ == DRGBASE_VARS_BOOL then
      value = net.ReadBool()
    elseif typ == DRGBASE_VARSentITY then
      value = net.ReadEntity()
    elseif typ == DRGBASE_VARS_NUMBER then
      value = net.ReadFloat()
    elseif typ == DRGBASE_VARS_STRING then
      value = net.ReadString()
    elseif typ == DRGBASE_VARS_VECTOR then
      value = net.ReadVector()
    end
    ent._DrGBaseVars = ent._DrGBaseVars or {}
    ent._DrGBaseVars[name] = value
  end)

end
