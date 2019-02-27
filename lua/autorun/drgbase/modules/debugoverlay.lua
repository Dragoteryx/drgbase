
function debugoverlay.DrG_BallisticTrajectory(start, velocity, lifetime, color, ignoreZ, options)
  local info = math.DrG_BallisticTrajectoryInfoVectors(start, velocity)
  options = options or {}
  options.from = options.from or 0
  options.to = options.to or 10
  options.increments = options.increments or 0.01
  local t = options.from
  while t < options.to do
    debugoverlay.Line(info.Predict(t), info.Predict(t+options.increments), lifetime, color, ignoreZ)
    t = t+options.increments
  end
  local highestPoint = info.Predict(info.highest)
  local tr = util.TraceLine({
    start = highestPoint,
    endpos = highestPoint + Vector(0, 0, -999999999),
    collisiongroup = COLLISION_GROUP_IN_VEHICLE
  })
  debugoverlay.Line(highestPoint, tr.HitPos, lifetime, color, ignoreZ)
end
