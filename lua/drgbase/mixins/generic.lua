return function(ENT)

  -- Initialize --

  if isfunction(ENT.Initialize) then
    local old_Initialize = ENT.Initialize
    function ENT:Initialize(...)
      if self.DrG_PreInitialize then self:DrG_PreInitialize(...) end
      local res = old_Initialize(self, ...)
      if self.DrG_PostInitialize then self:DrG_PostInitialize(...) end
      return res
    end
  end

  -- Think --

  if isfunction(ENT.Think) then
    local old_Think = ENT.Think
    function ENT:Think(...)
      if self.DrG_PreThink then self:DrG_PreThink(...) end
      local res = old_Think(self, ...)
      if self.DrG_PostThink then self:DrG_PostThink(...) end
      return res
    end
  end

  if isfunction(ENT.Use) then
    local old_Use = ENT.Use
    function ENT:Use(...)
      if self.DrG_Use then self:DrG_Use(...) end
      return old_Use(self, ...)
    end
  end

  -- OnRemove --

  if isfunction(ENT.OnRemove) then
    local old_OnRemove = ENT.OnRemove
    function ENT:OnRemove(...)
      if self.DrG_OnRemove then self:DrG_OnRemove(...) end
      return old_OnRemove(self, ...)
    end
  end

  -- Draw --

  if CLIENT and isfunction(ENT.Draw) then
    local old_Draw = ENT.Draw
    function ENT:Draw(...)
      if self.DrG_PreDraw then self:DrG_PreDraw(...) end
      local res = old_Draw(self, ...)
      if self.DrG_PostDraw then self:DrG_PostDraw(...) end
      return res
    end
  end

end