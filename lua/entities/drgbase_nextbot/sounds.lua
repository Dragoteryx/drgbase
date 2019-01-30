
function ENT:EmitSlottedSound(slot, duration, soundName, soundLevel, pitchPercent, volume, channel)
  local lastSlot = self._DrGBaseSlottedSounds[slot]
  if lastSlot == nil or CurTime() > lastSlot then
    self._DrGBaseSlottedSounds[slot] = CurTime() + duration
    self:EmitSound(soundName, soundLevel, pitchPercent, volume, channel)
  end
end

if SERVER then

  -- Handlers --

  function ENT:_HandleAmbientSounds()
    if isstring(self.AmbientSounds) then self.AmbientSounds = {sound = self.AmbientSounds} end
    if #self.AmbientSounds > 0 and self._DrGBaseAmbientSound == nil then
      local ambient = self.AmbientSounds[math.random(#self.AmbientSounds)]
      self._DrGBaseAmbientSound = self:StartLoopingSound(ambient.sound)
      if ambient.duration ~= nil then
        self:Timer(ambient.duration, function()
          self:StopLoopingSound(self._DrGBaseAmbientSound)
          self._DrGBaseAmbientSound = nil
        end)
      end
    end
  end

else



end
