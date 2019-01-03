
hook.Add("EntityTakeDamage", "DrGBaseNextbotProtectPossessingPlayer", function(ent, dmg)
	if ent:IsPlayer() and IsValid(DrGBase.Nextbot.Possessing(ent)) then return false end
end)

properties.Add("drgbasepossess", {
	MenuLabel = "Possess",
	Order = 999,
	MenuIcon = "drgbase/icon16.png",
	Filter = function(self, ent, ply)
    return ent:IsDrGBaseNextbot() and
		ent.PossessionEnabled and
		DrGBase.Nextbot.ConVars.Possession:GetBool()
	end,
	Action = function(self, ent)
    self:MsgStart()
    net.WriteEntity(ent)
    self:MsgEnd()
  end,
	Receive = function(self, len, ply)
		local ent = net.ReadEntity()
    local possess = ent:Possess(ply, true)
    if possess == DRGBASE_NEXTBOT_POSSESS_OK then
			net.Start("DrGBaseNextbotCanPossess")
			net.WriteEntity(ent)
      net.Send(ply)
		else
			net.Start("DrGBaseNextbotCantPossess")
			net.WriteEntity(ent)
      net.WriteFloat(possess)
      net.Send(ply)
    end
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
	local enum = net.ReadFloat()
	local reason = enum
	if enum == DRGBASE_NEXTBOT_POSSESS_NOT_ALLOWED then reason = "you are not allowed."
	elseif enum == DRGBASE_NEXTBOT_POSSESS_NOT_EMPTY then reason = "another player is already possessing it."
	elseif enum == DRGBASE_NEXTBOT_POSSESS_HOOK_DISABLED then reason = "entity driving is disabled."
	elseif enum == DRGBASE_NEXTBOT_POSSESS_NOT_ALIVE then reason = "you are dead."
	end
	notification.AddLegacy("You can't possess this nextbot ("..ent.Name.."): "..reason, NOTIFY_ERROR, 4)
	surface.PlaySound("buttons/button10.wav")
end)

hook.Add("PlayerUse", "DrGBasePossessionDisableUse", function(ply, ent)
  if IsValid(DrGBase.Nextbot.Possessing(ply)) then return false end
end)

include("possession_drive.lua")
