
local COMMANDS = {}
function DrGBase.AddCommand(prefix, name, callback, autoComplete, helpText, flags)
  if string.find(name, " ") ~= nil then return false end
  concommand.Add(name, callback, autoComplete, helpText, flags)
  COMMANDS[name] = {
    prefix = prefix,
    callback = callback
  }
  return true
end
function DrGBase.RemoveCommand(name)
  if not DrGBase.CommandExists(name) then return false end
  concommand.Remove(name)
  COMMANDS[name] = nil
  return true
end
function DrGBase.CommandExists(name)
  return COMMANDS[name] ~= nil
end

local function CheckChatCommands(ply, str)
  for name, command in pairs(COMMANDS) do
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
