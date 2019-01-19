
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
    local angles = self.Entity:GetAngles()
    angles.y = self.Player:EyeAngles().y
    if self.Entity:IsFlying() then
      angles.p = self.Player:EyeAngles().p
    end
    self.Entity:SetAngles(angles)
  end,
  FinishMove = function(self)
    if not self.Entity.IsDrGNextbot then return end
    if self.Player:KeyPressed(IN_USE) then self.Entity:Dispossess(true) end
  end
}, "drive_base")
