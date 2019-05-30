
--[[local str = "extensions/"
DrGBase.IncludeFiles({
  str.."entity.lua",
  str.."npc.lua",
  str.."phys.lua",
  str.."player.lua",
  str.."vector.lua"
})]]

-- ENTITY --

local entMETA = FindMetaTable("Entity")

-- Misc --

function entMETA:DrG_IsSanic()
  return self.OnReloaded ~= nil and
  self.GetNearestTarget ~= nil and
  self.AttackNearbyTargets ~= nil and
  self.IsHidingSpotFull ~= nil and
  self.GetNearestUsableHidingSpot ~= nil and
  self.ClaimHidingSpot ~= nil and
  self.AttemptJumpAtTarget ~= nil and
  self.LastPathingInfraction ~= nil and
  self.RecomputeTargetPath ~= nil and
  self.UnstickFromCeiling ~= nil
end

-- Doors --

local DOORS = {
  ["prop_door_rotating"] = true,
  ["func_door"] = true,
  ["func_door_rotating"] = true,
  ["prop_dynamic"] = true
}
function entMETA:DrG_IsDoor()
  return DOORS[self:GetClass()] or false
end

local Door = {}
Door.__index = Door
function Door:New(nextbot, ent)
  local door = {}
  door._nextbot = nextbot
  door._door = ent
  setmetatable(door, self)
  return door
end
function Door:IsValid()
  return IsValid(self._nextbot) and IsValid(self._door)
end
function Door:Open(away)
  if not self:IsValid() then return end
  if self:IsDouble() then
    local double = self:GetDouble()
    if away then
      self._door:Fire("openawayfrom", self._nextbot:GetName())
      double:Fire("openawayfrom", self._nextbot:GetName())
    else
      self._door:Fire("open")
      double:Fire("open")
    end
  else
    if away then
      self._door:Fire("openawayfrom", self._nextbot:GetName())
    else self._door:Fire("open") end
  end
end
function Door:Close()
  if not self:IsValid() then return end
  self._door:Fire("close")
  if self:IsDouble() then
    self:GetDouble():Fire("close")
  end
end
function Door:GetDouble()
  if not self:IsValid() then return end
  local keyvalues = self._door:GetKeyValues()
  if isstring(keyvalues.slavename) then
    return ents.FindByName(keyvalues.slavename)[1]
  end
end
function Door:IsDouble()
  return IsValid(self:GetDouble())
end
function Door:SetSpeed(speed)
  if not self:IsValid() then return end
  door:Fire("setspeed", speed)
  if self:IsDouble() then
    self:GetDouble():Fire("setspeed", speed)
  end
end
function Door:GetNextbot()
  return self._nextbot
end
function Door:GetDoor()
  return self._door
end

function entMETA:DrG_DoorOpener(ent)
  if not ent.IsDrGNextbot then return end
  return Door:New(ent, self)
end

-- PHYSOBJECT --

local physMETA = FindMetaTable("PhysObj")

function physMETA:DrG_Trajectory(pos, options)
  options = options or {}
  local vec, info = self:GetPos():DrG_CalcTrajectory(pos, options)
  if not vec:IsZero() then
    if not options.drag then self:EnableDrag(false)
    else self:EnableDrag(true) end
    if options.draw then
      debugoverlay.DrG_Trajectory(self:GetPos(), vec, 5, nil, false, {
        from = -info.duration, to = info.duration*2, colors = function(t)
          if t < 0 then return DrGBase.Colors.Green
          elseif t > info.duration then return DrGBase.Colors.Red
          else return DrGBase.Colors.White end
        end
      })
    end
    self:SetVelocity(vec)
  end
  return vec, info
end

-- PLAYER --

local plyMETA = FindMetaTable("Player")

function plyMETA:DrG_IsPossessing()
  return IsValid(self:DrG_Possessing())
end
function plyMETA:DrG_Possessing()
  return self:GetNW2Entity("DrGBasePossessing")
end

function plyMETA:DrG_SteamAvatar(callback, onerror)
  http.Fetch("https://steamcommunity.com/profiles/"..self:SteamID64().."?xml=1", function(body)
    -- fetch the avatar from the xml file
    callback(avatar)
  end, function(err)
    if isfunction(onerror) then onerror(err) end
  end)
end

-- Factions --

function plyMETA:DrG_JoinFaction(faction)
  self:DrG_InitFactions()
  if self:DrG_IsInFaction(faction) then return end
  self._DrGBaseFactions[string.upper(faction)] = true
  for i, nextbot in ipairs(DrGBase.GetNextbots()) do
    nextbot:UpdateRelationshipWith(self)
  end
end
function plyMETA:DrG_LeaveFaction(faction)
  self:DrG_InitFactions()
  if not self:DrG_IsInFaction(faction) then return end
  self._DrGBaseFactions[string.upper(faction)] = false
  for i, nextbot in ipairs(DrGBase.GetNextbots()) do
    nextbot:UpdateRelationshipWith(self)
  end
end
function plyMETA:DrG_IsInFaction(faction)
  self:DrG_InitFactions()
  return self._DrGBaseFactions[string.upper(faction)] or false
end
function plyMETA:DrG_GetFactions()
  self:DrG_InitFactions()
  local factions = {}
  for faction, joined in pairs(self._DrGBaseFactions) do
    if joined then table.insert(factions, faction) end
  end
  return factions
end
function plyMETA:DrG_InitFactions()
  self._DrGBaseFactions = self._DrGBaseFactions or {}
end
function plyMETA:DrG_JoinFactions(factions)
  for i, faction in ipairs(factions) do
    self:DrG_JoinFaction(faction)
  end
end
function plyMETA:DrG_LeaveFactions(factions)
  for i, faction in ipairs(factions) do
    self:DrG_LeaveFaction(faction)
  end
end
function plyMETA:DrG_LeaveAllFactions()
  self:DrG_LeaveFactions(self:DrG_GetFactions())
end

-- VECTOR --

local vecMETA = FindMetaTable("Vector")

-- Ballistic stuff --

function vecMETA:DrG_CalcTrajectory(endpos, options)
  options = options or {}
  if options.recursive == nil then
    options.recursive = (options.pitch == nil and options.magnitude == nil)
  end
  local g = isnumber(options.gravity) and options.gravity or physenv.GetGravity():Length()
  local vec = Vector(endpos.x - self.x, endpos.y - self.y, 0)
  local x = options._length or vec:Length()
  local y = endpos.z - self.z
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
        return self:DrG_CalcTrajectory(endpos, options)
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
        return self:DrG_CalcTrajectory(endpos, options)
      else return Vector(0, 0, 0), {magnitude = magnitude} end
    else
      local s1 = math.atan((v*v + res)/(g*x))
      local s2 = math.atan((v*v - res)/(g*x))
      if options.highest then
        pitch = s1 < s2 and s2 or s1
      else pitch = s1 > s2 and s2 or s1 end
    end
  elseif not pitchnumber and not magnitudenumber then
    local normal = (endpos - self):GetNormalized()
    local forward = Vector(normal.x, normal.y, 0):GetNormalized()
    options.gravity = g
    options._length = x
    options.pitch = (90 - math.DrG_DegreeAngle(forward, normal))/2
    return self:DrG_CalcTrajectory(endpos, options)
  else
    pitch = options.pitch
    magnitude = options.magnitude
  end
  if options.maxmagnitude ~= nil and magnitude > options.maxmagnitude then magnitude = options.maxmagnitude end
  if options.maxpitch ~= nil and math.deg(pitch) > options.maxpitch then pitch = math.rad(options.maxpitch) end
  vec.z = math.tan(pitch)*x
  local velocity = vec:GetNormalized()*magnitude
  local info = self:DrG_TrajectoryInfo2({
    direction = velocity, magnitude = magnitude,
    pitch = math.deg(pitch), gravity = g
  })
  local calc = magnitude*math.sin(pitch)
  info.duration = (calc+math.sqrt(calc^2-2*g*y))/g
  return velocity, info
end

function vecMETA:DrG_TrajectoryInfo2(options)
  options = options or {}
  options.direction = options.direction or Vector(0, 0, 0)
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
    return (self + pos), velocity
  end
  return {
    pitch = options.pitch,
    magnitude = options.magnitude,
    highest = highest,
    height = Predict(highest).z - self.z,
    Predict = Predict
  }
end

function vecMETA:DrG_TrajectoryInfo(direction)
  local data = direction:DrG_Data()
  return self:DrG_TrajectoryInfo2({
    direction = data.direction,
    magnitude = data.magnitude, pitch = data.pitch
  })
end

function vecMETA:DrG_Data()
  local forward = Vector(self.x, self.y, 0)
  local pitch = math.atan(self.z/forward:Length())
  return {
    normal = self:GetNormalized(),
    direction = forward:GetNormalized(),
    magnitude = self:Length(),
    pitch = math.deg(pitch)
  }
end

-- Misc --

function vecMETA:DrG_ManhattanDistance(pos)
  return math.abs(math.abs(self.x - pos.x) + math.abs(self.y - pos.y) + math.abs(self.z - pos.z))
end

function vecMETA:DrG_Direction(pos)
  return pos - self
end

function vecMETA:DrG_Degrees(vec2, origin)
  local vec1 = self
  origin = origin or Vector(0, 0, 0)
  vec1 = vec1 - origin
  vec2 = vec2 - origin
  return math.deg(math.acos(vec1:GetNormalized():Dot(vec2:GetNormalized())))
end
