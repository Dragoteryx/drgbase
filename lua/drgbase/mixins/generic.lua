return function(ENT)

  -- Initialize --

  if isfunction(ENT.Initialize) then
    local old_Initialize = ENT.Initialize
    function ENT:Initialize(...)
      if self._DrGBasePreInitialize then self:_DrGBasePreInitialize(...) end
      local res = old_Initialize(self, ...)
      if self._DrGBasePostInitialize then self:_DrGBasePostInitialize(...) end
      return res
    end
  end

  -- Think --

  if isfunction(ENT.Think) then
    local old_Think = ENT.Think
    function ENT:Think(...)
      if self._DrGBasePreThink then self:_DrGBasePreThink(...) end
      local res = old_Think(self, ...)
      if self._DrGBasePostThink then self:_DrGBasePostThink(...) end
      return res
    end
  end

  -- OnRemove --

  if isfunction(ENT.OnRemove) then
    local old_OnRemove = ENT.OnRemove
    function ENT:OnRemove(...)
      local res = old_OnRemove(self, ...)
      if self._DrGBaseOnRemove then self:_DrGBaseOnRemove(...) end
      return res
    end
  end

  -- Draw --

  if CLIENT and isfunction(ENT.Draw) then
    local old_Draw = ENT.Draw
    function ENT:Draw(...)
      if self._DrGBasePreDraw then self:_DrGBasePreDraw(...) end
      local res = old_Draw(self, ...)
      if self._DrGBasePostDraw then self:_DrGBasePostDraw(...) end
      return res
    end
  end

end