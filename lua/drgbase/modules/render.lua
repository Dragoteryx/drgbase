if SERVER then return end

-- Sprites --

local MATERIALS = {}
function render.DrG_DrawSprite(sprite, pos, size, options)
  options = options or {}
  size = isnumber(size) and math.Clamp(size, 0, math.huge) or 100
  local half = size/2
  local normal = pos:DrG_Direction(isvector(options.origin) and options.origin or EyePos())
  normal.z = 0
  if not MATERIALS[sprite] then
    local material = Material(sprite)
    MATERIALS[sprite] = material
    render.SetMaterial(material)
  else render.SetMaterial(MATERIALS[sprite]) end
  if MATERIALS[sprite]:IsError() then return end
  local color = options.color or Color(255, 255, 255)
  if options.lighting then
    local light = (render.GetLightColor(pos)*255):ToColor()
    local p = ((light.r + light.g + light.b)/3)/255
    color = Color(color.r*p, color.g*p, color.b*p, color.a)
  end
  render.DrawQuadEasy(pos, normal, size, size, color, (options.rotation or 0) + 180)
end

-- Misc --

function render.DrG_DrawTrajectory(start, velocity, color, writeZ, options)
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
