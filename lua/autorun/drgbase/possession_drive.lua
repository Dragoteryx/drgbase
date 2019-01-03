
DEFINE_BASECLASS("drive_base")
drive.Register("drive_drgbase_nextbot", {
  Init = function() end,
	CalcView = function(self, view)
    local angle = self.Player:GetAngles() + self.Entity:GetForward():Angle()
    angle.y = angle.y + 180
    angle.p = -angle.p
    angle.r = 0
    local origin = self.Entity:BullseyePos() +
    self.Entity:GetForward()*self.Entity.Possession.offset.x +
    self.Entity:GetRight()*self.Entity.Possession.offset.y +
    self.Entity:GetUp()*self.Entity.Possession.offset.z
    local endpos = origin + angle:Forward()*self.Entity.Possession.distance
    local tr = util.TraceLine({
      start = origin,
      endpos = endpos,
      collisiongroup = COLLISION_GROUP_IN_VEHICLE
    })
    if origin:DistToSqr(tr.HitPos) < math.pow(self.Entity.Possession.distance+1, 2) then
      view.origin = tr.HitPos + tr.Normal*-10
    else view.origin = endpos end
    view.angles = util.TraceLine({
      start = view.origin,
      endpos = origin,
      collisiongroup = COLLISION_GROUP_IN_VEHICLE
    }).Normal:Angle()
    return view
	end,
  SetupControls = function() end,
  StartMove = function(self)
    if not self.Entity:IsDrGBaseNextbot() then return end
    self.Player:SetObserverMode(OBS_MODE_CHASE)
    if self.Player:KeyPressed(IN_USE) then self.Entity:Dispossess(true) end
  end,
	Move = function(self) end,
  FinishMove = function(self) end
}, "drive_base")
