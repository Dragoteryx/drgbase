DrGBase.Pathfinding = DrGBase.Pathfinding or {}

DrGBase.Pathfinding.Path = {}
DrGBase.Pathfinding.Path.__index = DrGBase.Pathfinding.Path
function DrGBase.Pathfinding.Path:new(pathfollower)
  local path = {
    segments = {}
  }
  for i, segment in ipairs(pathfollower:GetAllSegments()) do
    table.insert(path.segments, segment.pos)
  end
  setmetatable(path, DrGBase.Pathfinding.Path)
  return path
end
function DrGBase.Pathfinding.Path:Compute() end
function DrGBase.Pathfinding.Path:Join(other) end
setmetatable(DrGBase.Pathfinding.Path, {__call = DrGBase.Pathfinding.Path.new})
