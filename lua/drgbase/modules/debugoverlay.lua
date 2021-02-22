-- Trajectories --

function debugoverlay.DrG_Trajectory(start, velocity, lifetime, color, ignoreZ, options)
  local info = start:DrG_TrajectoryInfo(velocity, options.ballistic)
  options = options or {}
  options.from = options.from or 0
  options.to = options.to or 10
  options.increments = options.increments or 0.01
  if options.colors == nil then options.colors = function() end end
  if options.height == nil then options.height = true end
  local t = options.from
  while t < options.to do
    if isfunction(color) then
      debugoverlay.Line(info.Predict(t), info.Predict(t+options.increments), lifetime, color(t), ignoreZ)
    else debugoverlay.Line(info.Predict(t), info.Predict(t+options.increments), lifetime, color, ignoreZ) end
    t = t+options.increments
  end
  if info.ballistic and options.height then
    local highestPoint = info.Predict(info.highest)
    local tr = util.TraceLine({
      start = highestPoint,
      endpos = highestPoint + Vector(0, 0, -999999999),
      collisiongroup = COLLISION_GROUP_IN_VEHICLE
    })
    if isfunction(color) then
      debugoverlay.Line(highestPoint, tr.HitPos, lifetime, color(info.highest), ignoreZ)
    else debugoverlay.Line(highestPoint, tr.HitPos, lifetime, color, ignoreZ) end
  end
end

local DebugTrajectories = DrGBase.ConVar("drgbase_debug_trajectories", "0")
function DrG_DebugTrajectory(pos, dir, info)
  if DebugTrajectories:GetFloat() <= 0 then return end
  debugoverlay.DrG_Trajectory(pos, dir, DebugTrajectories:GetFloat(), function(t)
    if t < 0 then return DrGBase.CLR_GREEN
    elseif t > info.duration then return DrGBase.CLR_RED
    else return DrGBase.CLR_WHITE end
  end, false, info.ballistic and (info.duration == -1 and {
    from = math.min(0, info.highest), to = math.max(0, info.highest),
    ballistic = true
  } or {
    from = math.min(-info.duration, info.highest),
    to = math.max(info.duration*2, info.highest),
    ballistic = true
  }) or {
    from = -info.duration, to = info.duration*2,
    ballistic = false
  })
end