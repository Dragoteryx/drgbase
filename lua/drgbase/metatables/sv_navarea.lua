local areaMETA = FindMetaTable("CNavArea")

-- clusters

local Cluster = DrGBase.CreateClass()

local CLUSTER_ID = 1
function Cluster:new()
  local id = CLUSTER_ID
  CLUSTER_ID = CLUSTER_ID+1
  function self:GetID()
    return id
  end
end

function Cluster.prototype:IsConnected(cluster)
  if self == cluster then return true end
  if not self.connections then
    self.connections = {}
    for _, area in ipairs(navmesh.GetAllNavAreas()) do
      if area:DrG_GetCluster() ~= self then continue end
      for _, adjacent in ipairs(area:GetAdjacentAreas()) do
        local cluster = adjacent:DrG_GetCluster()
        if cluster ~= self then
          self.connections[cluster] = true
        end
      end
    end
    return self:IsConnected(cluster)
  else return self.connections[cluster] or false end
end
function Cluster.prototype:IsConnectedIndirectly(cluster)
  if self:IsConnected(cluster) then return true end
  for connected in pairs(self.connections) do
    if connected:IsConnectedIndirectly(cluster) then return true end
  end
  return false
end

local CLUSTERS = {}
function InvalidateClusters()
  print("invalidate")
  CLUSTERS = {}
end
function SetCluster(self, cluster)
  CLUSTERS[self:GetID()] = cluster
  for _, area in ipairs(self:GetAdjacentAreas()) do
    if not area:IsConnected(self) then continue end
    if not CLUSTERS[area:GetID()] then
      SetCluster(area, cluster)
    end
  end
end
function areaMETA:DrG_GetCluster()
  local id = self:GetID()
  if not CLUSTERS[id] then
    SetCluster(self, Cluster())
  end
  return CLUSTERS[id]
end

hook.Add("Think", "DrG/ShowClusters", function()
  if not DrGBase.DebugEnabled() then return end
  for _, area in ipairs(navmesh.GetAllNavAreas()) do
    local cluster = area:DrG_GetCluster()
    debugoverlay.Text(area:GetCenter() + Vector(0, 0, 5), cluster:GetID(), 0.05, true)
  end
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

local Remove = areaMETA.Remove
function areaMETA:Remove(...)
  print("remove")
  local id = self:GetID()
  MAT_TYPES[id] = nil
  InvalidateClusters()
  return Remove(self, ...)
end