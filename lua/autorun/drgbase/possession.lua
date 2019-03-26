
local PossessionEnabled = CreateConVar("drgbase_enable_possession", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

properties.Add("drgbasepossess", {
	MenuLabel = "Possess",
	Order = 1000,
	MenuIcon = "drgbase/icon16.png",
	Filter = function(self, ent, ply)
    return ent.IsDrGNextbot and
		ent.PossessionEnabled and
		ent.PossessionPrompt and
		PossessionEnabled:GetBool()
	end,
	Action = function(self, ent)
    self:MsgStart()
    net.WriteEntity(ent)
    self:MsgEnd()
  end,
	Receive = function(self, len, ply)
		local ent = net.ReadEntity()
    local possess = ent:Possess(ply, true)
    if possess == "ok" then
			net.Start("DrGBaseNextbotCanPossess")
			net.WriteEntity(ent)
		else
			net.Start("DrGBaseNextbotCantPossess")
			net.WriteEntity(ent)
      net.WriteString(possess)
    end
		net.Send(ply)
	end
})

if SERVER then
	util.AddNetworkString("DrGBaseNextbotCanPossess")
	util.AddNetworkString("DrGBaseNextbotCantPossess")

	hook.Add("PlayerUse", "DrGBaseNextbotPossessionDisableUse", function(ply, ent)
	  if ply:DrG_IsPossessing() then return false end
	end)

	hook.Add("EntityTakeDamage", "DrGBaseNextbotProtectPossessingPlayer", function(ent, dmg)
		if ent:IsPlayer() and ent:DrG_IsPossessing() then return true end
	end)

else

	net.Receive("DrGBaseNextbotCanPossess", function()
		local ent = net.ReadEntity()
		if not IsValid(ent) then return end
		notification.AddLegacy("You are now possessing this nextbot ("..ent.Name..").", NOTIFY_HINT, 4)
		surface.PlaySound("buttons/lightswitch2.wav")
	end)

	net.Receive("DrGBaseNextbotCantPossess", function()
		local ent = net.ReadEntity()
		if not IsValid(ent) then return end
		local enum = net.ReadString()
		local reason = enum
		if enum == "not allowed" then reason = "you are not allowed to possess this nextbot."
		elseif enum == "already possessed" then reason = "another player is already possessing this nextbot."
		elseif enum == "error" then reason = "unknown error."
		elseif enum == "not alive" then reason = "you are dead."
		elseif enum == "already possessing" then reason = "you are already possessing a nextbot."
		elseif enum == "disabled" then reason = "possession is not available for this nextbot."
		elseif enum == "no views" then reason = "no defined camera views."
		end
		notification.AddLegacy("You can't possess this nextbot ("..ent.Name.."): "..reason, NOTIFY_ERROR, 4)
		surface.PlaySound("buttons/button10.wav")
	end)

end

DrGBase.IncludeFile("possession_drive.lua")
