
local COMMANDS = {}
function DrGBase.AddCommand(name, callback, autoComplete, helpText, flags)
  if DrGBase.CommandExists(name) then DrGBase.RemoveCommand(name) end
  concommand.Add(name, callback, autoComplete, helpText, flags)
  COMMANDS[name] = callback
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

local function CheckChatCommands(ply, str, prefix)
  for name, command in pairs(COMMANDS) do
    if not string.StartWith(str, prefix..name) then continue end
    local argstr = string.Trim(string.Replace(str, prefix..name, ""))
    local args = string.Split(argstr, " ")
    if args[1] == "" then table.remove(args, 1) end
    command(ply, name, args, argstr, true)
    return ""
  end
end

if SERVER then

  hook.Add("PlayerSay", "DrGBaseCommandsPlayerSay", function(ply, str)
    return CheckChatCommands(ply, str, ply:GetInfo("drgbase_command_prefix"))
  end)

else

  local CommandPrefix = CreateClientConVar("drgbase_command_prefix", "!", true, true)

  hook.Add("OnPlayerChat", "DrGBaseCommandsOnPlayerChat", function(ply, str)
    if ply:EntIndex() ~= LocalPlayer():EntIndex() then return end
    return CheckChatCommands(ply, str, CommandPrefix:GetString()) == ""
  end)

end
