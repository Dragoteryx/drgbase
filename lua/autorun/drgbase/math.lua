DrGBase.Math = DrGBase.Math or {}

function DrGBase.Math.ManhattanDistance(pos1, pos2)
  return math.abs(math.abs(pos1.x - pos2.x) + math.abs(pos1.y - pos2.y) + math.abs(pos1.z - pos2.z))
end

function DrGBase.Math.ParabolicTrajectory(start, endpos, duration)
  local g = physenv.GetGravity():Length()

end
