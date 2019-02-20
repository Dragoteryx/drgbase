
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
    if CLIENT then return end
    if not self.Entity.IsDrGNextbot then return end
    self.Player:SetObserverMode(OBS_MODE_CHASE)
    if self.Entity:PossessionBlockYaw() then return end
    if not self.Entity:CanMove(self.Player) then return end
    local origin, angles = self.Entity:PossessorView()
    local selfangles = self.Entity:GetAngles()
    selfangles.y = angles.y
    self.Entity:SetAngles(selfangles)
  end,
	Move = function(self)
    if CLIENT then return end
    if not self.Entity.IsDrGNextbot then return end
    -- done inside the coroutine because nextbot
  end,
  FinishMove = function(self)
    if CLIENT then return end
    if not self.Entity.IsDrGNextbot then return end
    if self.Player:KeyPressed(IN_USE) then self.Entity:Dispossess(true)
    elseif self.Player:KeyPressed(IN_ZOOM) then self.Entity:CyclePossessionViews() end
  end
}, "drive_base")
