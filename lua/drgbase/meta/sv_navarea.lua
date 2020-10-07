local areaMETA = FindMetaTable("CNavArea")

local MAT_TYPES = {}
function areaMETA:DrG_GetMaterialType()
  local id = self:GetID()
  if not MAT_TYPES[id] then
    MAT_TYPES[id] = util.DrG_TraceLine({
      start = self:GetCenter() + Vector(0, 0, 5),
      endpos = self:GetCenter() + Vector(0, 0, -100)
    }).MatType
  end
  return MAT_TYPES[id]
end

local old_Remove = areaMETA.Remove
function areaMETA:Remove(...)
  MAT_TYPES[self:GetID()] = nil
  return old_Remove(self, ...)
end