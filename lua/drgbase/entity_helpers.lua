if not istable(ENT) then return end

-- Print --

function ENT:PrintPoseParameters()
  for i = 0, self:GetNumPoseParameters() - 1 do
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
  for i = 0, self:GetBoneCount() - 1 do
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

function ENT:Timer(duration, callback)
  timer.Simple(duration, function()
    if IsValid(self) then callback(self) end
  end)
end
function ENT:LoopTimer(delay, callback)
  timer.DrG_Loop(delay, function()
    if not IsValid(self) then return false end
    return callback(self)
  end)
end

-- Misc --

function ENT:ScreenShake(amplitude, frequency, duration, radius)
  return util.ScreenShake(self:GetPos(), amplitude, frequency, duration, radius)
end

function ENT:AddListener(name, callback)
  if not isfunction(callback) then return false end
  self[name] = function(...)
    callback(...)
    if isfunction(self[name]) then
      self[name](...)
    end
  end
  return true
end

function ENT:GetCooldown(name)
  local delay = self:GetNW2Float("DrGBaseCooldowns-"..tostring(name), false)
  if delay ~= false then
    return math.Clamp(delay - CurTime(), 0, math.huge)
  else return 0 end
end

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
    self:SetNW2Float("DrGBaseCooldowns-"..tostring(name), CurTime() + delay)
  end

  function ENT:PushEntity(ent, force)
    if istable(ent) then
      local vecs = {}
      for i, en in ipairs(ent) do
        vec[ent:EntIndex()] = self:PushEntity(en, force)
      end
      return vecs
    elseif isentity(ent) and IsValid(ent) then
      local direction = self:GetPos():DrG_Direction(ent:GetPos())
      local forward = direction
      forward.z = 0
      forward:Normalize()
      local right = Vector()
      right:Set(forward)
      right:Rotate(Angle(0, 90, 0))
      local up = Vector(0, 0, 1)
      local vec = forward*force.x + right*force.y + up*force.z
      local phys = ent:GetPhysicsObject()
      if ent.Type == "nextbot" then
        local jumpHeight = ent.loco:GetJumpHeight()
        ent.loco:SetJumpHeight(1)
        ent.loco:Jump()
        ent.loco:SetJumpHeight(jumpHeight)
        ent:SetVelocity(ent:GetVelocity()+vec)
      elseif IsValid(phys) and not ent:IsPlayer() then
        phys:AddVelocity(vec)
      else ent:SetVelocity(ent:GetVelocity()+vec) end
      return vec
    end
  end

  -- Effects --

  function ENT:DynamicLight(color, radius, brightness)
    if color == nil then color = Color(255, 255, 255) end
    if not isnumber(radius) then radius = 1000 end
    radius = math.Clamp(radius, 0, math.huge)
    if not isnumber(brightness) then brightness = 1 end
    brightness = math.Clamp(brightness, 0, math.huge)
    local light = ents.Create("light_dynamic")
  	light:SetKeyValue("brightness", tostring(brightness))
  	light:SetKeyValue("distance", tostring(radius))
    light:Fire("Color", tostring(color.r).." "..tostring(color.g).." "..tostring(color.b))
  	light:SetLocalPos(self:GetPos())
  	light:SetParent(self)
  	light:Spawn()
  	light:Activate()
  	light:Fire("TurnOn", "", 0)
  	self:DeleteOnRemove(light)
    return light
  end

  function ENT:ParticleEffect(name, follow, attachment)
    if follow then
      local pattach = attachment and PATTACH_POINT_FOLLOW or PATTACH_ABSORIGIN_FOLLOW
      ParticleEffectAttach(name, pattach, self, attachment or 1)
    else
      local pattach = attachment and PATTACH_POINT or PATTACH_ABSORIGIN
      ParticleEffectAttach(name, pattach, self, attachment or 1)
    end
  end

end
