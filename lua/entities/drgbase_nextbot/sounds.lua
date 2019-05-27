
-- Helpers --

function ENT:EmitFootstep(soundLevel, pitchPercent, volume, channel)
  local tr = util.TraceLine({
    start = self:GetPos(),
    endpos = self:GetPos() - self:GetUp()*999,
    filter = self
  })
  local sounds = self.Footsteps[tr.MatType] or self.DefaultFootsteps[tr.MatType]
  if not istable(sounds) or #sounds == 0 then sounds = self.Footsteps[MAT_DEFAULT] end
  if not istable(sounds) or #sounds == 0 then return false end
  self:EmitSound(sounds[math.random(#sounds)], soundLevel, pitchPercent, volume, channel or CHAN_BODY)
  return true
end

function ENT:LoopSound(sound)
  table.insert(self._DrGBaseLoopingSounds, self:StartLoopingSound(sound))
end

function ENT:EmitSlotSound(slot, duration, soundName, soundLevel, pitchPercent, volume, channel)
  local lastSlot = self._DrGBaseSlotSounds[slot]
  if lastSlot == nil or CurTime() > lastSlot then
    self._DrGBaseSlotSounds[slot] = CurTime() + duration
    self:EmitSound(soundName, soundLevel, pitchPercent, volume, channel)
  end
end

-- Music --

local current = nil
function ENT:PlayMusic(music, fade, callback)
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
    self._DrGBaseWantToPlayMusic = nil
    self._DrGBaseWantToPlayMusicFade = nil
    self._DrGBaseWantToPlayMusicCallback = nil
    self._DrGBaseWantToPlayMusicCheck = nil
    self:CallOnRemove("DrGBaseMusic", function()
      if not IsValid(current.ent) then return end
      if current.ent:EntIndex() ~= self:EntIndex() then return end
      self:StopMusic()
    end)
    if isfunction(callback) then callback(sound, true) end
    return true
  elseif current.ent:EntIndex() ~= self:EntIndex() then
    if not istable(music) then music = {music} end
    self._DrGBaseWantToPlayMusic = music
    self._DrGBaseWantToPlayMusicFade = fade
    self._DrGBaseWantToPlayMusicCallback = callback
    self._DrGBaseWantToPlayMusicCheck = {}
    for i, mus in ipairs(music) do
      self._DrGBaseWantToPlayMusicCheck[mus] = true
    end
    return false
  else
    if (istable(music) and not table.HasValue(music, current.music)) or
    (isstring(music) and music ~= current.music) then
      self:StopMusic()
      return false
    else
      if isfunction(callback) then callback(sound, false) end
      return true
    end
  end
end
function ENT:StopMusic()
  self._DrGBaseWantToPlayMusic = nil
  self._DrGBaseWantToPlayMusicFade = nil
  self._DrGBaseWantToPlayMusicCallback = nil
  self._DrGBaseWantToPlayMusicCheck = nil
  if current == nil or current.stopping then return end
  if current.ent:EntIndex() ~= self:EntIndex() then return end
  for i, ent in ipairs(DrGBase.GetNextbots()) do
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
  for i, ent in ipairs(DrGBase.GetNextbots()) do
    if ent:EntIndex() == self:EntIndex() then continue end
    if ent._DrGBaseWantToPlayMusic ~= nil then
      ent:PlayMusic(ent._DrGBaseWantToPlayMusic, self._DrGBaseWantToPlayMusicFade, self._DrGBaseWantToPlayMusicCallback)
      return
    end
  end
end
hook.Add("Think", "DrGBasePlayMusic", function()
  if current ~= nil and not current.stopping and not current.sound:IsPlaying() then
    current.sound:Play()
  end
end)
