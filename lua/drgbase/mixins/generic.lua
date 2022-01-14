local MIXIN = {}

function MIXIN:Initialize(init, ...)
  if self.DrG_PreInitialize then self:DrG_PreInitialize(...) end
  local res = init(self, ...)
  if self.DrG_PostInitialize then self:DrG_PostInitialize(...) end
  return res
end

function MIXIN:Think(think, ...)
  if self.DrG_PreThink then self:DrG_PreThink(...) end
  local res = think(self, ...)
  if self.DrG_PostThink then self:DrG_PostThink(...) end
  return res
end

function MIXIN:Use(use, ...)
  if self.DrG_Use then self:DrG_Use(...) end
  return use(self, ...)
end

function MIXIN:OnRemove(onRemove, ...)
  local res = onRemove(self, ...)
  if self.DrG_OnRemove then self:DrG_OnRemove(...) end
  return res
end

if CLIENT then
  function MIXIN:Draw(draw, ...)
    if self.DrG_PreDraw then self:DrG_PreDraw(...) end
    local res = draw(self, ...)
    if self.DrG_PostDraw then self:DrG_PostDraw(...) end
    return res
  end
end

return MIXIN