
local entMETA = FindMetaTable("Entity")
local plyMETA = FindMetaTable("Player")
local npcMETA = FindMetaTable("NPC")

function entMETA:IsDrGBaseNextbot()
  return self._DrGBaseNextbot == true
end

function entMETA:Timer_DrG(duration, callback)
  timer.Simple(duration, function()
    if not IsValid(self) then return end
    callback()
  end)
end

function entMETA:EmitSound_DrG(soundname, options, callback)
  DrGBase.Utils.EmitSound(soundname, self, options, callback)
end

function entMETA:SetVar_DrG(name, value)
  return DrGBase.Net.SetVar(name, value, self)
end

function entMETA:GetVar_DrG(name)
  return DrGBase.Net.GetVar(name, self)
end

if SERVER then
  util.AddNetworkString("DrGBaseMetaScreenShake")

  function entMETA:Explode_DrG(options)
    options = options or {}
    if options.remove == nil then options.remove = true end
    options.owner = self
    local pos = self:GetPos()
    if options.remove then self:Remove() end
    DrGBase.Utils.Explosion(pos, options)
  end

  function plyMETA:ScreenShake_DrG(amplitude, frequency, duration)
    if amplitude == nil or frequency == nil or duration == nil then return end
    net.Start("DrGBaseMetaScreenShake")
    net.WriteFloat(amplitude)
    net.WriteFloat(frequency)
    net.WriteFloat(duration)
    net.Send(self)
  end

else

  function plyMETA:ScreenShake_DrG(amplitude, frequency, duration)
    if self:EntIndex() ~= LocalPlayer():EntIndex() then return end
    if amplitude == nil or frequency == nil or duration == nil then return end
    util.ScreenShake(self:GetPos(), amplitude, frequency, duration, 999999)
  end

  net.Receive("DrGBaseMetaScreenShake", function()
    local amplitude = net.ReadFloat()
    local frequency = net.ReadFloat()
    local duration = net.ReadFloat()
    LocalPlayer():ScreenShake_DrG(amplitude, frequency, duration)
  end)

end
