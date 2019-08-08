if not istable(ENT) then return end

-- Print --

function ENT:PrintPoseParameters()
  for i = 0, (self:GetNumPoseParameters()-1) do
  	local min, max = self:GetPoseParameterRange(i)
  	print(self:GetPoseParameterName(i).." "..min.." / "..max)
  end
end
function ENT:PrintAnimations()
  for i, seq in pairs(self:GetSequenceList()) do
    local act = self:GetSequenceActivity(i)
    if act ~= -1 then
      print(i.." - "..seq.." / "..self:GetSequenceActivityName(i).." - "..act)
    else
      print(i.." - "..seq.." /")
    end
  end
end
function ENT:PrintBones()
  for i = 0, (self:GetBoneCount()-1) do
    local bonename = self:GetBoneName(i)
    if bonename == nil then continue end
    print(i.." => "..bonename)
  end
end
function ENT:PrintAttachments()
  for i, attach in ipairs(self:GetAttachments()) do
    print(attach.id.." => "..attach.name)
  end
end
function ENT:PrintBodygroups()
  for i, group in ipairs(self:GetBodyGroups()) do
    print(group.id.." => "..group.name.." ("..group.num.." subgroups)")
  end
end

-- Timers --

function ENT:Timer(duration, callback, ...)
  timer.DrG_Simple(duration, function(...)
    if IsValid(self) then callback(self, ...) end
  end, ...)
end
function ENT:LoopTimer(delay, callback, ...)
  timer.DrG_Loop(delay, function(...)
    if not IsValid(self) then return false end
    return callback(self, ...)
  end, ...)
end

-- Traces --

function ENT:TraceLine(vec, data)
  local trdata = {}
  data = data or {}
  local center = self:OBBCenter()
  trdata.start = data.start or self:GetPos() + center
  trdata.endpos = data.endpos or trdata.start + vec
  trdata.collisiongroup = data.collisiongroup or self:GetCollisionGroup()
  if self.IsDrGNextbot then
    trdata.mask = data.mask or self:GetSolidMask()
    trdata.filter = data.filter or {self, self:GetWeapon(), self:GetPossessor()}
  else trdata.filter = data.filter or self end
  return util.DrG_TraceLine(trdata)
end
function ENT:TraceHull(vec, data)
  local bound1, bound2 = self:GetCollisionBounds()
  if bound1.z < bound2.z then
    local temp = bound1
    bound1 = bound2
    bound2 = temp
  end
  local trdata = {}
  data = data or {}
  if self.IsDrGNextbot and data.step then
    bound2.z = self.loco:GetStepHeight()
  end
  trdata.start = data.start or self:GetPos()
  trdata.endpos = data.endpos or trdata.start + vec
  trdata.collisiongroup = data.collisiongroup or self:GetCollisionGroup()
  if self.IsDrGNextbot then
    trdata.mask = data.mask or self:GetSolidMask()
    trdata.filter = data.filter or {self, self:GetWeapon(), self:GetPossessor()}
  else trdata.filter = data.filter or self end
  trdata.maxs = data.maxs or bound1
  trdata.mins = data.mins or bound2
  return util.DrG_TraceHull(trdata)
end
function ENT:TraceLineRadial(distance, precision, data)
  local traces = {}
  for i = 1, precision do
    local normal = self:GetForward()*distance
    normal:Rotate(Angle(0, i*(360/precision), 0))
    table.insert(traces, self:TraceLine(normal, data))
  end
  table.sort(traces, function(tr1, tr2)
    return self:GetRangeSquaredTo(tr1.HitPos) < self:GetRangeSquaredTo(tr2.HitPos)
  end)
  return traces
end
function ENT:TraceHullRadial(distance, precision, data)
  local traces = {}
  for i = 1, precision do
    local normal = self:GetForward()*distance
    normal:Rotate(Angle(0, i*(360/precision), 0))
    table.insert(traces, self:TraceHull(normal, data))
  end
  table.sort(traces, function(tr1, tr2)
    return self:GetRangeSquaredTo(tr1.HitPos) < self:GetRangeSquaredTo(tr2.HitPos)
  end)
  return traces
end

-- Misc --

function ENT:ScreenShake(amplitude, frequency, duration, radius)
  return util.ScreenShake(self:GetPos(), amplitude, frequency, duration, radius)
end

function ENT:GetCooldown(name)
  local delay = self:GetNW2Float("DrGBaseCooldowns/"..tostring(name), false)
  if delay ~= false then
    return math.Clamp(delay - CurTime(), 0, math.huge)
  else return 0 end
end

-- Net --

function ENT:NetMessage(name, ...)
  return net.DrG_Send("DrGBaseEntMessage", name, self, ...)
end
function ENT:_HandleNetMessage() end
function ENT:OnNetMessage() end

if SERVER then
  AddCSLuaFile()

  -- Misc --

  function ENT:GetNoTarget()
    return self:IsFlagSet(FL_NOTARGET)
  end
  function ENT:SetNoTarget(bool)
    if bool then self:AddFlags(FL_NOTARGET)
    else self:RemoveFlags(FL_NOTARGET) end
  end

  function ENT:SetCooldown(name, delay)
    self:SetNW2Float("DrGBaseCooldowns/"..tostring(name), CurTime() + delay)
  end

  function ENT:PushEntity(ent, force)
    if istable(ent) then
      local vecs = {}
      for i, en in ipairs(ent) do
        if not IsValid(en) then continue end
        vecs[en:EntIndex()] = self:PushEntity(en, force)
      end
      return vecs
    elseif isentity(ent) and IsValid(ent) then
      local direction = self:GetPos():DrG_Direction(ent:GetPos())
      local forward = direction
      forward.z = 0
      forward:Normalize()
      local right = Vector()
      right:Set(forward)
      right:Rotate(Angle(0, -90, 0))
      local up = Vector(0, 0, 1)
      local vec = forward*force.x + right*force.y + up*force.z
      local phys = ent:GetPhysicsObject()
      if ent.IsDrGNextbot then
        ent:LeaveGround()
        ent:SetVelocity(ent:GetVelocity()+vec)
      elseif ent.Type == "nextbot" then
        local jumpHeight = ent.loco:GetJumpHeight()
        ent.loco:SetJumpHeight(1)
        ent.loco:Jump()
        ent.loco:SetJumpHeight(jumpHeight)
        ent.loco:SetVelocity(ent.loco:GetVelocity()+vec)
      elseif IsValid(phys) and not ent:IsPlayer() then
        phys:AddVelocity(vec)
      else ent:SetVelocity(ent:GetVelocity()+vec) end
      return vec
    end
  end

  -- Net --

  net.DrG_Receive("DrGBaseEntMessage", function(ply, name, self, ...)
    if not IsValid(self) then return end
    if not self.IsDrGEntity then return end
    if not self:_HandleNetMessage(name, ply, ...) then
      self:OnNetMessage(name, ply, ...)
    end
  end)

  function ENT:NetCallback(name, callback, ply, ...)
    if not isfunction(callback) then return end
    if not ply:IsPlayer() then return end
    return ply:DrG_NetCallback(name, function(...)
      if IsValid(self) then callback(...) end
    end, self, ...)
  end

  -- Effects --

  function ENT:ParticleEffect(effect, ...)
    local root = {parent = self}
    local args, n = table.DrG_Pack(...)
    local attachment = false
    if n > 0 then
      local data = root
      for i = 1, n do
        local arg = args[i]
        if i == 1 and isstring(arg) then
          root.attachment = arg
          attachment = true
        elseif isentity(arg) and IsValid(arg) then
          data.cpoints = {{parent = arg}}
          if isstring(args[i+1]) then
            data.cpoints[1].attachment = args[i+1]
          end
          data = data.cpoints[1]
        elseif isvector(arg) then
          data.cpoints = {{pos = arg}}
          data = data.cpoints[1]
        else continue end
      end
      if data ~= root then
        data.active = false
      end
    end
    return DrGBase.ParticleEffect(effect, root)
  end

  function ENT:DynamicLight(color, radius, brightness, style, attachment)
    if color == nil then color = Color(255, 255, 255) end
    if not isnumber(radius) then radius = 1000 end
    radius = math.Clamp(radius, 0, math.huge)
    if not isnumber(brightness) then brightness = 1 end
    brightness = math.Clamp(brightness, 0, math.huge)
    local light = ents.Create("light_dynamic")
  	light:SetKeyValue("brightness", tostring(brightness))
  	light:SetKeyValue("distance", tostring(radius))
    if isstring(style) then
      light:SetKeyValue("style", tostring(style))
    end
    light:Fire("Color", tostring(color.r).." "..tostring(color.g).." "..tostring(color.b))
  	light:SetLocalPos(self:GetPos())
  	light:SetParent(self)
    if isstring(attachment) then
      light:Fire("setparentattachment", attachment)
    end
  	light:Spawn()
  	light:Activate()
  	light:Fire("TurnOn", "", 0)
  	self:DeleteOnRemove(light)
    return light
  end

else

  -- Net --

  local function ReceiveMessage(name, self, ...)
    if not IsValid(self) then return end
    if isfunction(self._HandleNetMessage) and isfunction(self.OnNetMessage) then
      if not self:_HandleNetMessage(name, ...) then self:OnNetMessage(name, ...) end
    else timer.DrG_Simple(engine.TickInterval(), ReceiveMessage, name, self, ...) end
  end
  net.DrG_Receive("DrGBaseEntMessage", ReceiveMessage)
  function ENT:NetCallback(name, callback, ...)
    if not isfunction(callback) then return end
    return net.DrG_UseCallback(name, function(...)
      if IsValid(self) then callback(...) end
    end, self, ...)
  end

  -- Effects --

  function ENT:DynamicLight(color, radius, brightness, style, attachment)
    if color == nil then color = Color(255, 255, 255) end
    if not isnumber(radius) then radius = 1000 end
    radius = math.Clamp(radius, 0, math.huge)
    if not isnumber(brightness) then brightness = 1 end
    brightness = math.Clamp(brightness, 0, math.huge)
    local light = DynamicLight(self:EntIndex())
    light.r = color.r
    light.g = color.g
    light.b = color.b
    light.size = radius
    light.brightness = brightness
    light.style = style
    light.dieTime = CurTime() + 1
    light.decay = 100000
    if attachment then
      if isstring(attachment) then
        attachment = self:LookupAttachment(attachment)
      end
      if isnumber(attachment) and attachment > 0 then
        light.pos = self:GetAttachment(attachment).Pos
      else light.pos = self:GetPos() end
    else light.pos = self:GetPos() end
    return light
  end

end
