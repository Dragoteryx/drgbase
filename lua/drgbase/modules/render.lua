if SERVER then return end

function render.DrG_Trajectory(start, velocity, color, writeZ, options)
  local info = start:DrG_TrajectoryInfo(velocity)
  options = options or {}
  options.from = options.from or 0
  options.to = options.to or 10
  options.increments = options.increments or 0.01
  if options.colors == nil then options.colors = function() end end
  local t = options.from
  while t < options.to do
    render.DrawLine(info.Predict(t), info.Predict(t+options.increments), options.colors(t) or color, writeZ)
    t = t+options.increments
  end
  if options.height then
    local highestPoint = info.Predict(info.highest)
    local tr = util.TraceLine({
      start = highestPoint,
      endpos = highestPoint + Vector(0, 0, -999999999),
      collisiongroup = COLLISION_GROUP_IN_VEHICLE
    })
    render.DrawLine(highestPoint, tr.HitPos, color, writeZ)
  end
end
