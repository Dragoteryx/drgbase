
-- Ballistic related --

function math.DrG_BallisticTrajectory(start, endpos, options)
  options = options or {}
  if options.recursive == nil then
    options.recursive = (options.pitch == nil and options.magnitude == nil)
  end
  local g = isnumber(options.gravity) and options.gravity or physenv.GetGravity():Length()
  local vec = Vector(endpos.x - start.x, endpos.y - start.y, 0)
  local x = options._length or vec:Length()
  local y = endpos.z - start.z
  local pitch
  local magnitude
  local pitchnumber = isnumber(options.pitch)
  local magnitudenumber = isnumber(options.magnitude)
  if pitchnumber and not magnitudenumber then
    pitch = options.pitch
    if pitch > 90 then pitch = 90 end
    if pitch < -90 then pitch = 90 end
    pitch = math.rad(pitch)
    if y >= math.tan(pitch)*x then
      if options.recursive and math.deg(pitch) < 90 then
        options.gravity = g
        options._length = x
        options.pitch = math.deg(pitch)+1
        return math.DrG_BallisticTrajectory(start, endpos, options)
      else return Vector(0, 0, 0), {pitch = math.deg(pitch)} end
    else magnitude = math.sqrt((-g*x^2)/(2*math.pow(math.cos(pitch), 2)*(y - x*math.tan(pitch)))) end
  elseif magnitudenumber and not pitchnumber then
    magnitude = math.abs(options.magnitude)
    local v = magnitude
    local res = math.sqrt(v^4 - g*(g*x*x + 2*y*v*v))
    if res ~= res then
      if options.recursive then
        options.gravity = g
        options._length = x
        options.magnitude = magnitude*1.05
        return math.DrG_BallisticTrajectory(start, endpos, options)
      else return Vector(0, 0, 0), {magnitude = magnitude} end
    else
      local s1 = math.atan((v*v + res)/(g*x))
      local s2 = math.atan((v*v - res)/(g*x))
      if options.highest then
        pitch = s1 < s2 and s2 or s1
      else pitch = s1 > s2 and s2 or s1 end
    end
  elseif not pitchnumber and not magnitudenumber then
    local normal = (endpos - start):GetNormalized()
    local forward = Vector(normal.x, normal.y, 0):GetNormalized()
    local subangle = math.DrG_DegreeAngle(forward, normal)
    options.gravity = g
    options._length = x
    options.pitch = (90-subangle)/2
    options.magnitude = nil
    return math.DrG_BallisticTrajectory(start, endpos, options)
  else
    pitch = options.pitch
    magnitude = options.magnitude
  end
  if options.maxmagnitude ~= nil and magnitude > options.maxmagnitude then magnitude = options.maxmagnitude end
  if options.maxpitch ~= nil and math.deg(pitch) > options.maxpitch then pitch = math.rad(options.maxpitch) end
  vec.z = math.tan(pitch)*x
  local velocity = vec:GetNormalized()*magnitude
  local info = math.DrG_BallisticTrajectoryInfo({
    start = start, direction = velocity, magnitude = magnitude,
    pitch = math.deg(pitch), gravity = g
  })
  local calc = magnitude*math.sin(pitch)
  info.duration = (calc+math.sqrt(calc^2-2*g*y))/g
  return velocity, info
end

function math.DrG_BallisticTrajectoryInfo(options)
  options = options or {}
  options.start = options.start or Vector(0, 0, 0)
  options.direction = options.direction or Vector(1, 0, 0)
  options.magnitude = options.magnitude or 1
  options.pitch = options.pitch or 45
  options.gravity = options.gravity or physenv.GetGravity():Length()
  local pitch = math.rad(options.pitch)
  local calc = options.magnitude*math.sin(pitch)
  local highest = calc/options.gravity
  local function Predict(t)
    local forward = Vector(options.direction.x, options.direction.y, 0):GetNormalized()
    local pos = forward*options.magnitude*t*math.cos(pitch)
    pos.z = options.magnitude*t*math.sin(pitch)-(options.gravity*t*t)/2
    local velocity = forward*options.magnitude*math.cos(pitch)
    velocity.z = options.magnitude*math.sin(pitch)-options.gravity*t
    return (options.start + pos), velocity
  end
  return {
    pitch = options.pitch,
    magnitude = options.magnitude,
    highest = highest,
    height = Predict(highest).z - options.start.z,
    Predict = Predict
  }
end

function math.DrG_BallisticTrajectoryInfoVectors(start, velocity)
  local data = math.DrG_VectorData(velocity)
  return math.DrG_BallisticTrajectoryInfo({
    start = start, direction = data.direction,
    magnitude = data.magnitude, pitch = data.pitch
  })
end

function math.DrG_VectorData(vec)
  local forward = Vector(vec.x, vec.y, 0)
  local pitch = math.atan(vec.z/forward:Length())
  return {
    normal = vec:GetNormalized(),
    direction = forward:GetNormalized(),
    magnitude = vec:Length(),
    pitch = math.deg(pitch)
  }
end

-- Misc --

function math.DrG_ManhattanDistance(pos1, pos2)
  return math.abs(math.abs(pos1.x - pos2.x) + math.abs(pos1.y - pos2.y) + math.abs(pos1.z - pos2.z))
end

function math.DrG_DegreeAngle(v1, v2, origin)
  origin = origin or Vector(0, 0, 0)
  v1 = v1 - origin
  v2 = v2 - origin
  return math.deg(math.acos(v1:GetNormalized():Dot(v2:GetNormalized())))
end
