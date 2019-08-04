
local physMETA = FindMetaTable("PhysObj")

local DebugTrajectory = CreateConVar("drgbase_debug_trajectories", "0")

function physMETA:DrG_Trajectory(pos, options)
  options = options or {}
  local vec, info = self:GetPos():DrG_CalcTrajectory(pos, options)
  if not vec:IsZero() then
    if not options.drag then self:EnableDrag(false)
    else self:EnableDrag(true) end
    if DebugTrajectory:GetFloat() > 0 then
      debugoverlay.DrG_Trajectory(self:GetPos(), vec, DebugTrajectory:GetFloat(), nil, false, {
        from = -info.duration, to = info.duration*2, colors = function(t)
          if t < 0 then return DrGBase.CLR_GREEN
          elseif t > info.duration then return DrGBase.CLR_RED
          else return DrGBase.CLR_WHITE end
        end
      })
    end
    self:SetVelocity(vec)
  end
  return vec, info
end
