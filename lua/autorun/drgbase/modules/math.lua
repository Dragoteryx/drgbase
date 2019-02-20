
function math.DrG_ParabolicTrajectory(start, endpos, options)
  options = options or {}
  if options.recursive == nil then
    options.recursive = (options.pitch == nil and options.magnitude == nil)
  end
  local g = options.gravity or physenv.GetGravity():Length()
  local vec = Vector(endpos.x - start.x, endpos.y - start.y, 0)
  local x = options._length or vec:Length()
  local y = endpos.z - start.z
  local pitch
  local magnitude
  if options.magnitude ~= nil then
    magnitude = options.magnitude
    local v = magnitude
    local res = math.sqrt(v^4 - g*(g*x*x + 2*y*v*v))
    if res ~= res then
      if options.recursive and
      not (options.maxmagnitude ~= nil and magnitude > options.maxmagnitude) then
        options.gravity = g
        options._length = x
        options.magnitude = magnitude*1.05
        return math.DrG_ParabolicTrajectory(start, endpos, options)
      else return Vector(0, 0, 0), {magnitude = data} end
    else
      local s1 = math.atan((v*v + res)/(g*x))
      local s2 = math.atan((v*v - res)/(g*x))
      if options.highest then
        pitch = s1 < s2 and s2 or s1
      else pitch = s1 > s2 and s2 or s1 end
    end
  else
    pitch = options.pitch or 45
    if pitch > 90 then pitch = 90 end
    if pitch < 0 then pitch = 0 end
    pitch = math.rad(pitch)
    if y >= math.tan(pitch)*x then
      if options.recursive and math.deg(pitch) < 90 and
      not (options.maxpitch ~= nil and math.deg(pitch) > options.maxpitch) then
        options.gravity = g
        options._length = x
        options.pitch = math.deg(pitch)+1
        return math.DrG_ParabolicTrajectory(start, endpos, options)
      else return Vector(0, 0, 0), {pitch = math.deg(pitch)} end
    else magnitude = math.sqrt((-g*x^2)/(2*math.pow(math.cos(pitch), 2)*(y - x*math.tan(pitch)))) end
  end
  if options.maxmagnitude ~= nil and magnitude > options.maxmagnitude then magnitude = options.maxmagnitude end
  if options.maxpitch ~= nil and math.deg(pitch) > options.maxpitch then magnitude = math.rad(options.maxpitch) end
  vec.z = math.tan(pitch)*x
  return vec:GetNormalized()*magnitude, {pitch = math.deg(pitch), magnitude = magnitude}
end

function math.DrG_ManhattanDistance(pos1, pos2)
  return math.abs(math.abs(pos1.x - pos2.x) + math.abs(pos1.y - pos2.y) + math.abs(pos1.z - pos2.z))
end

function math.DrG_DegreeAngle(v1, v2, origin)
  origin = origin or Vector(0, 0, 0)
  v1:Sub(origin)
  v2:Sub(origin)
  v1:Normalize()
  v2:Normalize()
  return math.deg(math.acos(v1:Dot(v2)))
end

function math.DrG_MiddleVector(v1, v2)
  return Vector(v2.x - v1.x, v2.y - v1.y, v2.z - v1.z)
end

function math.DrG_AngleVectors(v1, v2)
  return math.DrG_MiddleVector(v1, v2):Angle()
end
