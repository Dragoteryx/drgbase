
if SERVER then

  function ENT:_HandleAmbientSounds()
    if #self.AmbientSounds > 0 and self._DrGBaseAmbientSound == nil then
      local ambient = self.AmbientSounds[math.random(#self.AmbientSounds)]
      self._DrGBaseAmbientSound = ambient.sound
      self:EmitSound(ambient.sound)
      self:Timer(ambient.duration, function()
        self._DrGBaseAmbientSound = nil
      end)
    end
  end

else



end
