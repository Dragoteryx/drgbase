
local commands = {}
function concommand.DrG_Add(prefix, name, callback, autoComplete, helpText, flags)
  if string.find(name, " ") ~= nil then return false end
  concommand.Add(name, callback, autoComplete, helpText, flags)
  commands[name] = {
    prefix = prefix,
    callback = callback
  }
  return true
end
function concommand.DrG_Remove(name)
  if not concommand.DrG_Exists(name) then return false end
  concommand.Remove(name)
  commands[name] = nil
  return true
end
function concommand.DrG_Exists(name)
  return commands[name] ~= nil
end

local function CheckChatCommands(ply, str)
  for name, command in pairs(commands) do
    if string.Split(str, " ")[1] ~= command.prefix..name then continue end
    local argstr = string.Trim(string.Replace(str, command.prefix..name, ""))
    local args = string.Split(argstr, " ")
    if args[1] == "" then table.remove(args, 1) end
    command.callback(ply, name, args, argstr, true)
    return ""
  end
end

if SERVER then
  hook.Add("PlayerSay", "DrGBaseCommandsPlayerSay", function(ply, str)
    return CheckChatCommands(ply, str)
  end)
else
  hook.Add("OnPlayerChat", "DrGBaseCommandsOnPlayerChat", function(ply, str)
    if ply:EntIndex() ~= LocalPlayer():EntIndex() then return end
    return CheckChatCommands(ply, str) == ""
  end)
end
