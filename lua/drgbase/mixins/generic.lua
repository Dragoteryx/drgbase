return function(ENT)

  if isfunction(ENT.Initialize) then
    local Initialize = ENT.Initialize
    function ENT:Initialize(...)
      if self.DrG_PreInitialize then self:DrG_PreInitialize(...) end
      local res = Initialize(self, ...)
      if self.DrG_PostInitialize then self:DrG_PostInitialize(...) end
      return res
    end
  end

  if isfunction(ENT.Think) then
    local Think = ENT.Think
    function ENT:Think(...)
      if self.DrG_PreThink then self:DrG_PreThink(...) end
      local res = Think(self, ...)
      if self.DrG_PostThink then self:DrG_PostThink(...) end
      return res
    end
  end

  if isfunction(ENT.Use) then
    local Use = ENT.Use
    function ENT:Use(...)
      if self.DrG_Use then self:DrG_Use(...) end
      return Use(self, ...)
    end
  end

  if isfunction(ENT.OnRemove) then
    local OnRemove = ENT.OnRemove
    function ENT:OnRemove(...)
      local res = OnRemove(self, ...)
      if self.DrG_OnRemove then self:DrG_OnRemove(...) end
      return res
    end
  end

  if CLIENT and isfunction(ENT.Draw) then
    local Draw = ENT.Draw
    function ENT:Draw(...)
      if self.DrG_PreDraw then self:DrG_PreDraw(...) end
      local res = Draw(self, ...)
      if self.DrG_PostDraw then self:DrG_PostDraw(...) end
      return res
    end
  end

end