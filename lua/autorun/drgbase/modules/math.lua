
function math.DrG_ManhattanDistance(pos1, pos2)
  return math.abs(math.abs(pos1.x - pos2.x) + math.abs(pos1.y - pos2.y) + math.abs(pos1.z - pos2.z))
end

function math.DrG_ParabolicTrajectory(start, endpos, maxforce)
  local g = physenv.GetGravity():Length()

end

function math.DrG_VectorsAngle(v1, v2, origin)
  origin = origin or Vector(0, 0, 0)
  v1:Sub(origin)
  v2:Sub(origin)
  v1:Normalize()
  v2:Normalize()
  return math.deg(math.acos(v1:Dot(v2)))
end
