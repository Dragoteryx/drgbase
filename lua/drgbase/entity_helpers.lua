if not istable(ENT) then return end

-- Print --

function ENT:PrintPoseParameters()
  for i = 0, (self:GetNumPoseParameters()-1) do
    local min, max = self:GetPoseParameterRange(i)
    print(self:GetPoseParameterName(i).." "..min.." / "..max)
  end
end
function ENT:PrintAnimations()
  for _, seq in pairs(self:GetSequenceList()) do
    local act = self:GetSequenceActivity(i)
    if act ~= -1 then
      print(i.." => "..seq.." / "..act.." => "..self:GetSequenceActivityName(i))
    else
      print(i.." => "..seq.." / -1")
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
  for _, attach in ipairs(self:GetAttachments()) do
    print(attach.id.." => "..attach.name)
  end
end
function ENT:PrintBodygroups()
  for _, group in ipairs(self:GetBodyGroups()) do
    print(group.id.." => "..group.name.." ("..group.num.." subgroups)")
  end
end

-- Timers --

function ENT:Timer(...)
  return self:DrG_Timer(...)
end
function ENT:LoopTimer(...)
  return self:DrG_LoopTimer(...)
end

-- Traces --

function ENT:TraceLine(...)
  return self:DrG_TraceLine(...)
end
function ENT:TraceHull(...)
  return self:DrG_TraceHull(...)
end
function ENT:TraceLineRadial(...)
  return self:DrG_TraceLineRadial(...)
end
function ENT:TraceHullRadial(...)
  return self:DrG_TraceHullRadial(...)
end

-- Misc --

function ENT:ScreenShake(...)
  return util.ScreenShake(self:GetPos(), ...)
end

function ENT:GetCooldown(name)
  local delay = self:GetNW2Float("DrG/Cooldowns/"..tostring(name), false)
  if delay ~= false then return math.Clamp(delay - CurTime(), 0, math.huge)
  else return 0 end
end

--[[function ENT:GetScale()
  return self:GetModelScale()
end
function ENT:SetScale(scale)
  return self:SetModelScale(scale)
end
function ENT:Scale(scale)
  return self:SetModelScale(self:GetModelScale()*scale)
end]]

if SERVER then

  -- Misc --

  function ENT:RandomPos(min, max)
    return self:DrG_RandomPos(min, max)
  end

  function ENT:SetCooldown(name, delay)
    self:SetNW2Float("DrG/Cooldowns/"..tostring(name), CurTime() + delay)
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

  function ENT:SafeSetPos(pos)
    return self:DrG_SafeSetPos(pos)
  end

  -- Effects --

  function ENT:ParticleEffect(effect, ...)
    return self:DrG_ParticleEffect(effect, ...)
  end
  function ENT:DynamicLight(color, radius, brightness, style, attachment)
    return self:DrG_DynamicLight(color, radius, brightness, style, attachment)
  end

else

  -- Effects --

  function ENT:DynamicLight(color, radius, brightness, style, attachment)
    return self:DrG_DynamicLight(color, radius, brightness, style, attachment)
  end

end