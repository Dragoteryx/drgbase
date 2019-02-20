
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

local current = nil
function ENT:PlayMusic(music, fade)
  if current == nil or current.stopping then
    if istable(music) then music = music[math.random(#music)] end
    local filter
    if SERVER then
      filter = RecipientFilter()
      filter:AddAllPlayers()
    end
    if current ~= nil and current.sound:IsPlaying() then current.sound:Stop() end
    local sound = CreateSound(game.GetWorld(), music, filter)
    sound:SetSoundLevel(0)
    current = {
      ent = self,
      music = music,
      sound = sound,
      fade = fade
    }
    sound:Play()
    self:CallOnRemove("DrGBaseMusic", function()
      if not IsValid(current.ent) then return end
      if current.ent:EntIndex() ~= self:EntIndex() then return end
      self:StopMusic()
    end)
    return true, sound
  else
    if not istable(music) then music = {music} end
    self._DrGBaseWantToPlayMusic = music
    self._DrGBaseWantToPlayMusicCheck = {}
    for i, mus in ipairs(music) do
      self._DrGBaseWantToPlayMusicCheck[mus] = true
    end
    return false, current.sound
  end
end
function ENT:StopMusic()
  if current == nil or current.stopping then return end
  if current.ent:EntIndex() ~= self:EntIndex() then return end
  for i, ent in ipairs(DrGBase.Nextbots.GetAll()) do
    if ent:EntIndex() == self:EntIndex() then continue end
    if ent._DrGBaseWantToPlayMusic == nil then continue end
    if not ent._DrGBaseWantToPlayMusicCheck[current.music] then continue end
    current.ent = ent
    ent:CallOnRemove("DrGBaseMusic", function()
      if not IsValid(current.ent) then return end
      if current.ent:EntIndex() ~= ent:EntIndex() then return end
      ent:StopMusic()
    end)
    return
  end
  current.sound:FadeOut(current.fade or 0)
  current.stopping = true
  for i, ent in ipairs(DrGBase.Nextbots.GetAll()) do
    if ent:EntIndex() == self:EntIndex() then continue end
    if ent._DrGBaseWantToPlayMusic ~= nil then
      ent:PlayMusic(ent._DrGBaseWantToPlayMusic)
      return
    end
  end
end

if SERVER then

  -- Handlers --

  function ENT:_HandleAmbientSounds()
    if isstring(self.AmbientSounds) then self.AmbientSounds = {sound = self.AmbientSounds} end
    if #self.AmbientSounds > 0 and self._DrGBaseAmbientSound == nil then
      local ambient = self.AmbientSounds[math.random(#self.AmbientSounds)]
      self._DrGBaseAmbientSound = ambient.sound
      self:EmitSound(ambient.sound)
      if ambient.duration ~= nil then
        self:Timer(ambient.duration, function()
          self._DrGBaseAmbientSound = nil
        end)
      end
    end
  end

end
