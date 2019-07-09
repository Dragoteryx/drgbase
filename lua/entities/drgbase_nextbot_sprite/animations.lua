
-- Disable 3D stuff --

function ENT:SequenceEvent() end
function ENT:DirectPoseParametersAt() end

-- Getters/setters --

function ENT:GetSpriteAnim()

end

-- Functions --

function ENT:SpriteAnimEvent(anim, frames, callback)
  if istable(anim) then
    for i, ani in ipairs(anim) do
      self:SequenceEvent(ani, frames, callback)
    end
  else
    self._DrGBaseSpriteAnimEvents[anim] = self._DrGBaseSpriteAnimEvents[anim] or {}
    local event = self._DrGBaseSpriteAnimEvents[anim]
    if isnumber(frames) then frames = {frames} end
    for i, frame in ipairs(frames) do
      event[frame] = event[frame] or {}
      table.insert(event[frame], callback)
    end
  end
end

-- Hooks --

function ENT:OnSpriteAnimEvent() end

-- Handlers --

function ENT:_InitAnimations()
  self._DrGBaseSpriteAnims = {}
  self._DrGBaseSpriteAnimEvents = {}
end

function ENT:_HandleAnimations()
  local anim = self:GetSpriteAnim()
  local event = self._DrGBaseSpriteAnimEvents[anim]
  if event then
    
  end
end

if SERVER then

  -- Disable 3D stuff --

  function ENT:IsPlayingSequence() return false end
  function ENT:IsPlayingActivity() return false end

  function ENT:PlaySequenceAndWait() return 0 end
  function ENT:PlayActivityAndWait() return 0 end

  function ENT:PlaySequenceAndMove() return 0 end
  function ENT:PlayActivityAndMove() return 0 end

  function ENT:PlaySequenceAndMoveAbsolute() return 0 end
  function ENT:PlayActivityAndMoveAbsolute() return 0 end

  function ENT:PlaySequence() return 0 end
  function ENT:PlayActivity() return 0 end

  function ENT:PlayClimbSequence() return 0 end
  function ENT:PlayClimbActivity() return 0 end
  function ENT:PlayClimbAnimation() return 0 end

  -- Getters/setters --

  function ENT:IsPlayingSpriteAnim()
    return self._DrGBasePlayingSpriteAnim or false
  end
  function ENT:IsPlayingAnimation()
    return self:IsPlayingSpriteAnim()
  end

  function ENT:DefineSpriteAnim(name, tbl)

  end
  function ENT:SetSpriteAnim(anim)

  end
  function ENT:ResetSpriteAnim(anim)

  end

  -- Functions --

  function ENT:PlaySpriteAnimAndWait(anim, rate, callback)

  end
  function ENT:PlayAnimationAndWait(anim, rate, callback)
    return self:PlaySpriteAnimAndWait(anim, rate, callback)
  end
  function ENT:PlayAnimationAndMove(anim, rate, callback)
    return self:PlaySpriteAnimAndWait(anim, rate, callback)
  end
  function ENT:PlayAnimationAndMoveAbsolute(anim, rate, callback)
    local pos = self:GetPos()
    return self:PlaySpriteAnimAndWait(anim, rate, function(self, frame)
      self:SetPos(pos)
    end)
  end

  function ENT:PlaySpriteAnim(anim, rate, callback)

  end
  function ENT:PlayAnimation(anim, rate, callback)
    return self:PlaySpriteAnim(anim, rate, callback)
  end

  -- Update --

  function ENT:UpdateAnimation()
    if self:IsPlayingSpriteAnim() then return end
    local anim, rate = self:OnUpdateAnimation()
    if anim == self:GetSpriteAnim() then return end
    self:SetSpriteAnim(anim)
    self:SetPlaybackRate(rate or 1)
  end

  -- Hooks --

  function ENT:BodyUpdate() end

  -- Handlers --

else

  -- Disable 3D stuff --

  -- Getters/setters --

  -- Functions --

  -- Hooks --

  -- Handlers --

end
