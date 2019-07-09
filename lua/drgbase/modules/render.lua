if SERVER then return end

-- Sprites --

local MATERIALS = {}
function render.DrG_DrawSprite(sprite, pos, size, color)
  size = isnumber(size) and math.Clamp(size, 0, math.huge) or 100
  local half = size/2
  local dir = EyePos():DrG_Direction(pos + Vector(0, 0, half))
  cam.Start3D2D(pos + Vector(0, 0, half), dir:Angle() + Angle(90, 0, 0), 1)
  surface.SetDrawColor(color or Color(255, 255, 255))
  --[[if not MATERIALS[sprite] then
    local material = Material(sprite)
    MATERIALS[sprite] = material
    surface.SetMaterial(material)
  else surface.SetMaterial(MATERIALS[sprite]) end]]
  surface.DrawPoly({
    {x = -half, y = -half, u = 0, v = 0},
    {x = half, y = -half, u = 1, v = 0},
    {x = half, y = half, u = 1, v = 1},
    {x = -half, y = half, u = 0, v = 1},
  })
  cam.End3D2D()
end

-- Misc --

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
