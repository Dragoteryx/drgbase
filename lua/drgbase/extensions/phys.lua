
local physMETA = FindMetaTable("PhysObj")

local DebugTrajectory = CreateConVar("drgbase_debug_trajectories", "0")

function physMETA:DrG_Trajectory(pos, options)
  options = options or {}
  local vec, info = self:GetPos():DrG_CalcTrajectory(pos, options)
  if not vec:IsZero() then
    if not options.drag then self:EnableDrag(false)
    else self:EnableDrag(true) end
    if DebugTrajectory:GetFloat() > 0 then
      debugoverlay.DrG_Trajectory(self:GetPos(), vec, DebugTrajectory:GetFloat(), function(t)
        if t < 0 then return DrGBase.CLR_GREEN
        elseif t > info.duration then return DrGBase.CLR_RED
        else return DrGBase.CLR_WHITE end
      end, false, {
        from = math.min(-info.duration, info.highest),
        to = math.max(info.duration*2, info.highest)
      })
    end
    self:SetVelocity(vec)
  end
  return vec, info
end
