local MIXIN = {}

function MIXIN:Initialize(...)
  if self.DrG_PreInitialize then self:DrG_PreInitialize(...) end
  local res = self.DrG_Mixin.Initialize(self, ...)
  if self.DrG_PostInitialize then self:DrG_PostInitialize(...) end
  return res
end

function MIXIN:Think(...)
  if self.DrG_PreThink then self:DrG_PreThink(...) end
  local res = self.DrG_Mixin.Think(self, ...)
  if self.DrG_PostThink then self:DrG_PostThink(...) end
  return res
end

function MIXIN:Use(...)
  if self.DrG_Use then self:DrG_Use(...) end
  return self.DrG_Mixin.Use(self, ...)
end

function MIXIN:OnRemove(...)
  local res = self.DrG_Mixin.OnRemove(self, ...)
  if self.DrG_OnRemove then self:DrG_OnRemove(...) end
  return res
end

if CLIENT then
  function MIXIN:Draw(...)
    if self.DrG_PreDraw then self:DrG_PreDraw(...) end
    local res = self.DrG_Mixin.Draw(self, ...)
    if self.DrG_PostDraw then self:DrG_PostDraw(...) end
    return res
  end
end

return MIXIN