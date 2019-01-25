
DEFINE_BASECLASS("drive_base")
drive.Register("drive_drgbase_nextbot", {
  Init = function() end,
	CalcView = function(self, view)
    if not self.Entity.IsDrGNextbot then return end
    view.origin, view.angles = self.Entity:PossessorView()
    return view
	end,
  SetupControls = function() end,
  StartMove = function(self)
    if not self.Entity.IsDrGNextbot then return end
    self.Player:SetObserverMode(OBS_MODE_CHASE)
  end,
	Move = function(self)
    if not self.Entity.IsDrGNextbot then return end
    if not self.Entity:CanMove(self.Player) then return end
    local origin, angles = self.Entity:PossessorView()
    if self.Entity:IsFlying() then
      self.Entity:SetAngles(Angle(angles.p, angles.y, 0))
    else self.Entity:SetAngles(Angle(0, angles.y, 0)) end
  end,
  FinishMove = function(self)
    if not self.Entity.IsDrGNextbot then return end
    if self.Player:KeyPressed(IN_USE) then self.Entity:Dispossess(true)
    elseif self.Player:KeyPressed(IN_ZOOM) then self.Entity:CyclePossessionViews() end
  end
}, "drive_base")
