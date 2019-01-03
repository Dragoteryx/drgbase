
DrGBase.Commands = DrGBase.Commands or {}
DrGBase.Commands._List = DrGBase.Commands._List or {}

function DrGBase.Commands.Add(prefix, name, callback, autoComplete, helpText, flags)
  if string.find(name, " ") ~= nil then return false end
  concommand.Add(name, callback, autoComplete, helpText, flags)
  DrGBase.Commands._List[name] = {
    prefix = prefix,
    callback = callback
  }
  return true
end

function DrGBase.Commands.Remove(name)
  if not DrGBase.Commands.Exists(name) then return false end
  concommand.Remove(name)
  DrGBase.Commands._List[name] = nil
  return true
end

function DrGBase.Commands.Exists(name)
  return DrGBase.Commands._List[name] ~= nil
end

local function CheckChatCommands(ply, str)
  for name, command in pairs(DrGBase.Commands._List) do
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
