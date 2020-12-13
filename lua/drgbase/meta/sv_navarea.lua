local areaMETA = FindMetaTable("CNavArea")

-- clusters

local CLUSTERS = {}
local CLUSTER_ID = 0
local function PropagateCluster(self)
  for _, area in ipairs(self:GetAdjacentAreas()) do
    if not area:IsConnected(self) then continue end
    if not CLUSTERS[area:GetID()] then
      CLUSTERS[area:GetID()] = CLUSTERS[self:GetID()]
      PropagateCluster(area)
    end
  end
end
function areaMETA:DrG_GetCluster()
  local id = self:GetID()
  if not CLUSTERS[id] then
    CLUSTERS[id] = CLUSTER_ID
    CLUSTER_ID = CLUSTER_ID+1
    PropagateCluster(self)
  end
  return CLUSTERS[id]
end

hook.Add("Think", "DrG/ShowClusters", function()
  --[[if not DrGBase.DebugEnabled() then return end
  for _, area in ipairs(navmesh.GetAllNavAreas()) do
    debugoverlay.Text(area:GetCenter() + Vector(0, 0, 5), area:DrG_GetCluster(), 0.01, true)
  end]]
end)

-- misc

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