
function debugoverlay.DrG_Trajectory(start, velocity, lifetime, color, ignoreZ, options)
  local info = start:DrG_TrajectoryInfo(velocity)
  options = options or {}
  options.from = options.from or 0
  options.to = options.to or 10
  options.increments = options.increments or 0.01
  if options.colors == nil then options.colors = function() end end
  if options.height == nil then options.height = true end
  local t = options.from
  while t < options.to do
    debugoverlay.Line(info.Predict(t), info.Predict(t + options.increments), lifetime, options.colors(t) or color, ignoreZ)
    t = t + options.increments
  end
  if options.height then
    local highestPoint = info.Predict(info.highest)
    local tr = util.TraceLine({
      start = highestPoint,
      endpos = highestPoint + Vector(0, 0, -999999999),
      collisiongroup = COLLISION_GROUP_IN_VEHICLE
    })
    debugoverlay.Line(highestPoint, tr.HitPos, lifetime, options.colors(info.highest) or color, ignoreZ)
  end
end
