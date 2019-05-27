
local entMETA = FindMetaTable("Entity")

function entMETA:DrG_IsSanic()
  return self.OnReloaded ~= nil and
  self.GetNearestTarget ~= nil and
  self.AttackNearbyTargets ~= nil and
  self.IsHidingSpotFull ~= nil and
  self.GetNearestUsableHidingSpot ~= nil and
  self.ClaimHidingSpot ~= nil and
  self.AttemptJumpAtTarget ~= nil and
  self.LastPathingInfraction ~= nil and
  self.RecomputeTargetPath ~= nil and
  self.UnstickFromCeiling ~= nil
end
