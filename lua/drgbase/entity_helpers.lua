if not istable(ENT) then return end

function ENT:Timer(duration, callback)
  timer.Simple(duration, function()
    if IsValid(self) then callback(self) end
  end)
end
function ENT:LoopTimer(delay, callback)
  timer.DrG_Loop(delay, function()
    if not IsValid(self) then return false end
    return callback(self)
  end)
end

function ENT:ScreenShake(amplitude, frequency, duration, radius)
  return util.ScreenShake(self:GetPos(), amplitude, frequency, duration, radius)
end

if SERVER then
  AddCSLuaFile()

  function ENT:DynamicLight(color, radius, brightness)
    if color == nil then color = Color(255, 255, 255) end
    if not isnumber(radius) then radius = 1000 end
    radius = math.Clamp(radius, 0, math.huge)
    if not isnumber(brightness) then brightness = 1 end
    brightness = math.Clamp(brightness, 0, math.huge)
    local light = ents.Create("light_dynamic")
  	light:SetKeyValue("brightness", tostring(brightness))
  	light:SetKeyValue("distance", tostring(radius))
    light:Fire("Color", tostring(color.r).." "..tostring(color.g).." "..tostring(color.b))
  	light:SetLocalPos(self:GetPos())
  	light:SetParent(self)
  	light:Spawn()
  	light:Activate()
  	light:Fire("TurnOn", "", 0)
  	self:DeleteOnRemove(light)
    return light
  end

  function ENT:ParticleEffect(name, follow, attachment)
    if follow then
      local pattach = attachment and PATTACH_POINT_FOLLOW or PATTACH_ABSORIGIN_FOLLOW
      ParticleEffectAttach(name, pattach, self, attachment or 1)
    else
      local pattach = attachment and PATTACH_POINT or PATTACH_ABSORIGIN
      ParticleEffectAttach(name, pattach, self, attachment or 1)
    end
  end

end
