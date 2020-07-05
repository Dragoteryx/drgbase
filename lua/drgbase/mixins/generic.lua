return function(ENT)

  -- Initialize --

  if isfunction(ENT.Initialize) then
    local old_Initialize = ENT.Initialize
    function ENT:Initialize(...)
      if self._DrGBaseInitialize then
        self:_DrGBaseInitialize(...)
      end
      return old_Initialize(self, ...)
    end
  end

  -- Think --

  if isfunction(ENT.Think) then
    local old_Think = ENT.Think
    function ENT:Think(...)
      if self._DrGBaseThink then
        self:_DrGBaseThink(...)
      end
      return old_Think(self, ...)
    end
  end

  -- OnRemove --

  if isfunction(ENT.OnRemove) then
    local old_OnRemove = ENT.OnRemove
    function ENT:OnRemove(...)
      local res = old_OnRemove(self, ...)
      if self._DrGBaseOnRemove then
        self:_DrGBaseOnRemove(...)
      end
      return res
    end
  end

  -- Draw --

  if CLIENT and isfunction(ENT.Draw) then
    local old_Draw = ENT.Draw
    function ENT:Draw(...)
      local res = old_Draw(self, ...)
      if self._DrGBaseDraw then
        self:_DrGBaseDraw(...)
      end
      return res
    end
  end

end