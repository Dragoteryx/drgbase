
local DrGPossessionEnabled = CreateConVar("drgbase_possession", "1")

properties.Add("drgbasepossess", {
	MenuLabel = "Possess",
	Order = 999,
	MenuIcon = "drgbase/icon16.png",
	Filter = function(self, ent, ply)
    return ent.IsDrGNextbot and
		DrGPossessionEnabled:GetBool()
	end,
	Action = function(self, ent)
    self:MsgStart()
    net.WriteEntity(ent)
    self:MsgEnd()
  end,
	Receive = function(self, len, ply)
		local ent = net.ReadEntity()
    local possess = ent:Possess(ply, true)
    if possess == DRGBASE_POSSESS_OK then
			net.Start("DrGBaseNextbotCanPossess")
			net.WriteEntity(ent)
		else
			net.Start("DrGBaseNextbotCantPossess")
			net.WriteEntity(ent)
      net.WriteInt(possess, 32)
    end
		net.Send(ply)
	end
})

net.Receive("DrGBaseNextbotCanPossess", function()
	local ent = net.ReadEntity()
	if not IsValid(ent) then return end
	notification.AddLegacy("You are now possessing this nextbot ("..ent.Name..").", NOTIFY_HINT, 4)
	surface.PlaySound("buttons/lightswitch2.wav")
end)

net.Receive("DrGBaseNextbotCantPossess", function()
	local ent = net.ReadEntity()
	if not IsValid(ent) then return end
	local enum = net.ReadInt(32)
	local reason = enum
	if enum == DRGBASE_POSSESS_NOT_ALLOWED then reason = "you are not allowed to possess this nextbot."
	elseif enum == DRGBASE_POSSESS_NOT_EMPTY then reason = "another player is already possessing this nextbot."
	elseif enum == DRGBASE_POSSESS_ERROR then reason = "unknown error."
	elseif enum == DRGBASE_POSSESS_NOT_ALIVE then reason = "you are dead."
	elseif enum == DRGBASE_POSSESS_ALREADY then reason = "you are already possessing a nextbot."
	elseif enum == DRGBASE_POSSESS_DISABLED then reason = "possession is not available for this nextbot."
	elseif enum == DRGBASE_POSSESS_NOVIEWS then reason = "no defined camera views."
	end
	notification.AddLegacy("You can't possess this nextbot ("..ent.Name.."): "..reason, NOTIFY_ERROR, 4)
	surface.PlaySound("buttons/button10.wav")
end)

if SERVER then

	hook.Add("PlayerUse", "DrGBaseNextbotPossessionDisableUse", function(ply, ent)
	  if IsValid(ply:DrG_Possessing()) then return false end
	end)

	hook.Add("EntityTakeDamage", "DrGBaseNextbotProtectPossessingPlayer", function(ent, dmg)
		if ent:IsPlayer() and IsValid(ent:DrG_Possessing()) then return true end
	end)

end

DrGBase.IncludeFile("possession_drive.lua")
