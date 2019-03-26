if CLIENT then return end

-- Getters/setters --

function ENT:GetPath()
  self._DrGBasePath = self._DrGBasePath or Path("Follow")
  return self._DrGBasePath
end

-- Functions --

function ENT:InvalidatePath()
  local path = self:GetPath()
  if not IsValid(path) then return end
  path:Invalidate()
end

function ENT:DrawPath()
  local path = self:GetPath()
  if not IsValid(path) then return end
  path:Draw()
end

-- Meta --

local pathMETA = FindMetaTable("PathFollower")

local old_Compute = pathMETA.Compute
function pathMETA:Compute(nextbot, pos, generator)
  if nextbot.IsDrGNextbot then
    return old_Compute(self, nextbot, pos, generator)
  else return old_Compute(self, nextbot, pos, generator) end
end
