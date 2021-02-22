
local vecMETA = FindMetaTable("Vector")

local function VecData(vec)
  local forward = Vector(vec.x, vec.y, 0)
  local pitch = math.atan(vec.z/forward:Length())
  return {
    normal = vec:GetNormalized(),
    forward = forward:GetNormalized(),
    length = vec:Length(),
    pitch = math.deg(pitch)
  }
end

-- Ballistic stuff --

function vecMETA:DrG_TrajectoryInfo(direction, ballistic, options)
  if not istable(options) then optons = {} end
  local data = VecData(self)
  if ballistic then
    local gravity = options.gravity or physenv.GetGravity():Length()
    local magnitude = data.length
    local pitch = math.rad(data.pitch)
    local forward = data.forward
    local calc = magnitude*math.sin(pitch)
    local highest = calc/gravity
    local function Predict(t)
      local pos = forward*magnitude*t*math.cos(pitch)
      pos.z = magnitude*t*math.sin(pitch)-(gravity*t*t)/2
      local velocity = forward*magnitude*math.cos(pitch)
      velocity.z = magnitude*math.sin(pitch)-gravity*t
      return self + pos, velocity
    end
    return {
      normal = data.normal,
      forward = data.forward,
      magnitude = data.length,
      pitch = data.pitch,
      highest = highest,
      height = Predict(highest).z - self.z,
      ballistic = true,
      Predict = Predict
    }
  else
    return {
      normal = data.normal,
      forward = data.forward,
      magnitude = data.length,
      pitch = data.pitch,
      ballistic = false,
      Predict = function(t)
        return self+direction*t, direction
      end
    }
  end
end

function vecMETA:DrG_CalcLineTrajectory(target, options)
  if isnumber(options) then return self:DrG_CalcLineTrajectory(target, {speed = options}) end
  if istable(options) and isnumber(options.speed) and options.speed > 0 then
    if isentity(target) and IsValid(target) then
      local aimAt = options.center == false and target:GetPos() or target:WorldSpaceCenter()
      local velocity = target:IsNPC() and target:GetGroundSpeedVelocity() or target:GetVelocity()
      local dist = self:Distance(aimAt)
      return self:DrG_CalcLineTrajectory(aimAt+velocity*(dist/speed), speed)
    elseif isvector(target) then
      local dir = self:DrG_Dir(target):GetNormalized()*speed
      local info = self:DrG_TrajectoryInfo(dir, false)
      info.duration = self:Distance(target)/speed
      return dir, info
    end
  end
  local dir = Vector(0, 0, 0)
  return dir, self:DrG_TrajectoryInfo(dir, false)
end

function vecMETA:DrG_CalcBallisticTrajectory(target, options, recursive)
  if istable(options) and isentity(target) and IsValid(target) then
    local aimAt = options.center == false and target:GetPos() or target:WorldSpaceCenter()
    local velocity = target:IsNPC() and target:GetGroundSpeedVelocity() or target:GetVelocity()
    local _, info = self:DrG_CalcBallisticTrajectory(aimAt, table.Copy(options), true)
    return self:DrG_CalcBallisticTrajectory(aimAt+velocity*info.duration, options, recursive)
  elseif istable(options) and isvector(target) then
    local dir = Vector(target.x - self.x, target.y - self.y, 0)
    local g = options.gravity or physenv.GetGravity():Length()
    local x = dir:Length()
    local y = target.z - self.z
    local pitch = nil
    local magnitude = nil
    if isnumber(options.pitch) and not isnumber(options.magnitude) then
      pitch = math.rad(math.Clamp(options.pitch, -90, 90))
      local n = math.tan(pitch)*x
      if y >= n then
        if recursive then
          options.pitch = math.deg(pitch)+1
          return self:DrG_CalcBallisticTrajectory(target, options, true)
        else
          dir.z = n
          local velocity = dir:GetNormalized()
          local info = self:DrG_TrajectoryInfo(velocity)
          info.duration = -1
          return velocity, info
        end
      else magnitude = math.sqrt((-g*x*x)/(2*(math.cos(pitch)^2)*(y-x*math.tan(pitch)))) end
    elseif isnumber(options.magnitude) and not isnumber(options.pitch) then
      magnitude = math.abs(options.magnitude)
      local v = magnitude
      local n = math.sqrt(v^4-g*(g*x*x+2*y*v*v))
      if n ~= n then
        if recursive then
          options.magnitude = v*1.05
          return self:DrG_CalcBallisticTrajectory(target, options, true)
        else
          local velocity = self:DrG_Dir(target):GetNormalized()*v
          local info = self:DrG_TrajectoryInfo(velocity)
          info.duration = -1
          return velocity, info
        end
      else
        local s1 = math.atan((v*v+n)/(g*x))
        local s2 = math.atan((v*v-n)/(g*x))
        if options.highest then
          pitch = s1 < s2 and s2 or s1
        else pitch = s1 > s2 and s2 or s1 end
      end
    elseif not isnumber(options.pitch) and not isnumber(options.magnitude) then
      options.pitch = 45
      return self:DrG_CalcBallisticTrajectory(target, options)
    else
      pitch = math.rad(options.pitch)
      magnitude = options.magnitude
    end
    dir.z = math.tan(pitch)*x
    local velocity = dir:GetNormalized()*magnitude
    local info = self:DrG_TrajectoryInfo(velocity, true, {gravity = g})
    local calc = math.sqrt(((velocity.z^2)/(g^2))-((2*y)/g))
    local duration1 = (velocity.z/g)+calc
    local duration2 = (velocity.z/g)-calc
    local dist1 = info.Predict(duration1):DistToSqr(target)
    local dist2 = info.Predict(duration2):DistToSqr(target)
    if dist1 < dist2 then info.duration = duration1
    else info.duration = duration2 end
    return velocity, info
  else
    local dir = Vector(0, 0, 0)
    local g = options.gravity or physenv.GetGravity():Length()
    return dir, self:DrG_TrajectoryInfo(dir, true, {gravity = g})
  end
end

-- Misc --

function vecMETA:DrG_ManhattanDistance(pos)
  return math.abs(self.x - pos.x) + math.abs(self.y - pos.y) + math.abs(self.z - pos.z)
end

function vecMETA:DrG_Direction(pos)
  return pos - self
end
function vecMETA:DrG_Dir(pos)
  return self:DrG_Direction(pos)
end

function vecMETA:DrG_Degrees(vec1, vec2)
  return math.deg(math.acos(math.Round((vec1-self):GetNormalized():Dot((vec2-self):GetNormalized()), 2)))
end

function vecMETA:DrG_Round(round)
  return Vector(
    math.Round(self.x, round),
    math.Round(self.y, round),
    math.Round(self.z, round)
  )
end
function vecMETA:DrG_ToString(round)
  local rounded = self:DrG_Round(round)
  return tostring(util.NiceFloat(rounded.x)).." / "..tostring(util.NiceFloat(rounded.y)).." / "..tostring(util.NiceFloat(rounded.z))
end

function vecMETA:DrG_Copy()
  local copy = Vector()
  copy:Set(self)
  return copy
end

function vecMETA:DrG_Join(other, ratio)
  return self*(1-ratio)+other*ratio
end

function vecMETA:DrG_Away(pos)
  return self*2 - pos
end
