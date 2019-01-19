
DrGBase.Net = DrGBase.Net or {}

local callbacks = {}
function DrGBase.Net.DefineCallback(name, callback)
  callbacks[name] = callback
end
local reqID = 0
function DrGBase.Net.UseCallback(name, data, callback, ply)
  if SERVER and (not IsValid(ply) or not ply:IsPlayer()) then return end
  local currID = reqID
  reqID = reqID+1
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

local vars = {}
function DrGBase.Net.GetVar(name, ent)
  if not IsValid(ent) then return end
  if vars[ent:EntIndex()] == nil then vars[ent:EntIndex()] = {} end
  return vars[ent:EntIndex()][name]
end

hook.Add("EntityRemove", "DrGBaseNetVarsRemove", function(ent)
  vars[ent:EntIndex()] = {}
end)

if SERVER then
  util.AddNetworkString("DrGBaseNetCallbackRequest")
  util.AddNetworkString("DrGBaseNetCallbackResponse")
  util.AddNetworkString("DrGBaseNetVar")

  function DrGBase.Net.SetVar(name, value, ent)
    if not IsValid(ent) then return end
    local valid = true
    net.Start("DrGBaseNetVar")
    if istable(value) then
      net.WriteInt(DRGBASE_VARS_TABLE, 32)
      local compressed = util.Compress(util.TableToJSON({
        name = name, ent = ent:EntIndex(), value = value
      }))
      net.WriteData(compressed, #compressed)
    else
      if isangle(value) then
        net.WriteInt(DRGBASE_VARS_ANGLE, 32)
        net.WriteAngle(value)
      elseif isbool(value) then
        net.WriteInt(DRGBASE_VARS_BOOL, 32)
        net.WriteBool(value)
      elseif isentity(value) then
        net.WriteInt(DRGBASE_VARS_ENTITY, 32)
        net.WriteEntity(value)
      elseif isnumber(value) then
        net.WriteInt(DRGBASE_VARS_NUMBER, 32)
        net.WriteFloat(value)
      elseif isstring(value) then
        net.WriteInt(DRGBASE_VARS_STRING, 32)
        net.WriteString(value)
      elseif isvector(value) then
        net.WriteInt(DRGBASE_VARS_VECTOR, 32)
        net.WriteVector(value)
      else
        valid = false
        net.WriteFloat(DRGBASE_VARS_INVALID)
      end
      net.WriteString(name)
      net.WriteEntity(ent)
    end
    net.Broadcast()
    if vars[ent:EntIndex()] == nil then vars[ent:EntIndex()] = {} end
    vars[ent:EntIndex()][name] = value
    return valid
  end

else

  net.Receive("DrGBaseNetVar", function(len)
    local typ = net.ReadInt(32)
    local name
    local ent
    local value
    if typ == DRGBASE_VARS_TABLE then
      local data = util.JSONToTable(util.Decompress(net.ReadData(len/8)))
      name = data.name
      ent = Entity(data.ent)
      value = data.value
    else
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
      elseif typ == DRGBASE_VARS_INVALID then
        value = nil
      end
      name = net.ReadString()
      ent = net.ReadEntity()
    end
    if not IsValid(ent) then return end
    if vars[ent:EntIndex()] == nil then vars[ent:EntIndex()] = {} end
    vars[ent:EntIndex()][name] = value
  end)

end
