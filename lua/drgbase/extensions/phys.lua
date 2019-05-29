
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
