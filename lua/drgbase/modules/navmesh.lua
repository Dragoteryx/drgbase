if CLIENT then return end

local navareaMETA = FindMetaTable("CNavArea")

function navareaMETA:DrG_GetNodesWithin()
  return nodegraph.DrG_GetNodesWithinNavArea(self)
end

function navareaMETA:DrG_HiddenFromPlayers()
  for i, ply in ipairs(player.GetAll()) do
    if self:IsVisible(ply:EyePos()) then return false end
  end
  return true
end
