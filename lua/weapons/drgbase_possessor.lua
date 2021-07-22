AddCSLuaFile()

SWEP.PrintName = "Possessor"
SWEP.Category = "DrGBase"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Primary.Ammo = ""
SWEP.Secondary.Ammo = ""
SWEP.WorldModel = ""
SWEP.ViewModel = "models/weapons/v_bugbait.mdl"
SWEP.DrawAmmo = false
SWEP.AutoSwitchTo = false
SWEP.Slot = 5

local function CanPossess(ent)
  return ent.IsDrGNextbot
  and ent.PossessionPrompt
  and ent:IsPossessionEnabled()
end

if SERVER then

  function SWEP:Initialize()
    self:SetHoldType("magic")
  end

  function SWEP:PrimaryAttack()
    if CLIENT then return end
    local owner = self:GetOwner()
    if not IsValid(owner) then return end
    if not owner:IsPlayer() then return end
    local ent = owner:GetEyeTraceNoCursor().Entity
    if IsValid(ent) and CanPossess(ent) then
      local ok, reason = ent:CanPossess(owner)
      if ok then
        ent:SetPossessor(owner)
        net.Start("DrG/PossessionAllowed")
        net.WriteEntity(ent)
      else
        net.Start("DrG/PossessionDenied")
        net.WriteEntity(ent)
        net.WriteString(reason)
      end
      net.Send(owner)
    end
  end

  function SWEP:SecondaryAttack() end
  function SWEP:Reload() end

else

  hook.Add("PreDrawHalos", "DrG/PossessorSWEP", function()
    local ply = LocalPlayer()
    local weapon = ply:GetActiveWeapon()
    if IsValid(weapon) and weapon:GetClass() == "drgbase_possessor" then
      local ent = ply:GetEyeTraceNoCursor().Entity
      if not IsValid(ent) then return end
      if CanPossess(ent) and not ent:IsPossessed() then
        halo.Add({ent}, DrGBase.CLR_GREEN)
      else halo.Add({ent}, DrGBase.CLR_RED) end
    end
  end)

end