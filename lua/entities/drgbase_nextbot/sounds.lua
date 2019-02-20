
function ENT:EmitSlottedSound(slot, duration, soundName, soundLevel, pitchPercent, volume, channel)
  local lastSlot = self._DrGBaseSlottedSounds[slot]
  if lastSlot == nil or CurTime() > lastSlot then
    self._DrGBaseSlottedSounds[slot] = CurTime() + duration
    self:EmitSound(soundName, soundLevel, pitchPercent, volume, channel)
  end
end

function ENT:EmitFootstep(soundLevel, pitchPercent, volume, channel)
  local matType = util.TraceLine({
    start = self:GetPos(), endpos = self:GetPos() + self:GetUp()*-999, filter = self
  }).MatType
  local sounds = self.Footsteps[matType]
  if sounds == nil or #sounds == 0 then
    matType = MAT_DEFAULT
    sounds = self.Footsteps[matType]
  end
  if sounds == nil or #sounds == 0 then return false end
  self:EmitSound(sounds[math.random(#sounds)], soundLevel, pitchPercent, volume, channel)
  return true
end

if SERVER then

  -- Handlers --

  function ENT:_HandleAmbientSounds()
    if isstring(self.AmbientSounds) then self.AmbientSounds = {sound = self.AmbientSounds} end
    if #self.AmbientSounds > 0 and self._DrGBaseAmbientSound == nil then
      local ambient = self.AmbientSounds[math.random(#self.AmbientSounds)]
      if ambient.loop then
        print("a")
        self._DrGBaseAmbientSound = self:StartLoopingSound(ambient.sound)
      else
        self._DrGBaseAmbientSound = ambient.sound
        self:EmitSound(ambient.sound)
      end
      if ambient.duration ~= nil then
        self:Timer(ambient.duration, function()
          if ambient.looping then
            self:StopLoopingSound(self._DrGBaseAmbientSound)
          end
          self._DrGBaseAmbientSound = nil
        end)
      end
    end
  end

end
