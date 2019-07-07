
local PossessionEnabled = CreateConVar("drgbase_possession_enable", "1", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

properties.Add("drgbasepossess", {
	MenuLabel = "Possess",
	Order = 1000,
	MenuIcon = "drgbase/icon16.png",
	Filter = function(self, ent, ply)
		if not ent.IsDrGNextbot then return false end
		if not PossessionEnabled:GetBool() then return false end
		if not ent.PossessionPrompt then return false end
		if not ent:IsPossessionEnabled() then return false end
		return true
	end,
	Action = function(self, ent)
    self:MsgStart()
    net.WriteEntity(ent)
    self:MsgEnd()
  end,
	Receive = function(self, len, ply)
		local ent = net.ReadEntity()
    local possess = ent:Possess(ply)
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

hook.Add("StartCommand", "DrGBasePossessionStartCommand", function(ply, cmd)
	if not isfunction(ply.DrG_IsPossessing) then return end
	if ply:DrG_IsPossessing() then
		cmd:ClearMovement()
		if ply:HasWeapon("drgbase_possession") then
			cmd:SelectWeapon(ply:GetWeapon("drgbase_possession"))
		elseif SERVER then
			ply:Give("drgbase_possession")
		end
	elseif SERVER then
		ply:StripWeapon("drgbase_possession")
	end
end)

hook.Add("PlayerFootstep", "DrGBasePossessionMuteFootsteps", function(ply)
	if not isfunction(ply.DrG_IsPossessing) then return end
	if ply:DrG_IsPossessing() then return true end
end)

if SERVER then
	util.AddNetworkString("DrGBaseNextbotCanPossess")
	util.AddNetworkString("DrGBaseNextbotCantPossess")

	hook.Add("PlayerUse", "DrGBaseNextbotPossessionDisableUse", function(ply, ent)
	  if ply:DrG_IsPossessing() then return false end
	end)

	hook.Add("EntityTakeDamage", "DrGBaseNextbotProtectPossessingPlayer", function(ent, dmg)
		if ent:IsPlayer() and ent:DrG_IsPossessing() then return true end
	end)

	local function PlayerDeath(ply)
		if ply:DrG_IsPossessing() then ply:DrG_Possessing():Dispossess() end
	end
	hook.Add("PlayerDeath", "DrGBasePossessionPlayerDeath", PlayerDeath)
	hook.Add("PlayerSilentDeath", "DrGBasePossessionPlayerSilentDeath", PlayerDeath)

	hook.Add("PlayerButtonDown", "DrGBasePossessionButtons", function(ply, button)
		if not ply:DrG_IsPossessing() then return end
		local possessing = ply:DrG_Possessing()
		if SERVER then
			if button == ply:GetInfoNum("drgbase_possession_view", KEY_V) then
				possessing:CycleViewPresets()
			elseif button == ply:GetInfoNum("drgbase_possession_exit", KEY_E) then
				possessing:Dispossess()
			end
		end
	end)

	hook.Add("PlayerSwitchFlashlight", "DrGBasePossessionDisableFlashlight", function(ply, state)
		--if ply:DrG_IsPossessing() and state then return false end
	end)

	hook.Add("GetFallDamage", "DrGBasePossessionPlayerFallDamage", function(ply)
		if ply:DrG_IsPossessing() then return 0 end
	end)

else

	CreateClientConVar("drgbase_possession_exit", tostring(KEY_E), true, true)
	CreateClientConVar("drgbase_possession_view", tostring(KEY_V), true, true)
	CreateClientConVar("drgbase_possession_climb", tostring(KEY_C), true, true)

	net.Receive("DrGBaseNextbotCanPossess", function()
		local ent = net.ReadEntity()
		if not IsValid(ent) then return end
		notification.AddLegacy("You are now possessing "..ent.PrintName..".", NOTIFY_HINT, 4)
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
		elseif enum == "in vehicle" then reason = "you are in a vehicle."
		end
		notification.AddLegacy("You can't possess "..ent.PrintName..": "..reason, NOTIFY_ERROR, 4)
		surface.PlaySound("buttons/button10.wav")
	end)

	local HUD_HIDE = {
		["CHudWeaponSelection"] = true,
		["CHudAmmo"] = true,
		["CHudSecondaryAmmo"] = true,
		["CHudZoom"] = true
	}
	hook.Add("HUDShouldDraw", "DrGBasePossessionHideHUD", function(name)
		local ply = LocalPlayer()
		if not isfunction(ply.DrG_IsPossessing) then return end
		if not ply:DrG_IsPossessing() then return end
		if HUD_HIDE[name] then return false end
		if name == "CHudCrosshair" and not ply:DrG_Possessing().PossessionCrosshair then return false end
	end)

	hook.Add("CalcView", "DrGBasePossessionCalcView", function(ply, origin, angles, fov, znear, zfar)
		if not isfunction(ply.DrG_IsPossessing) then return end
		if not ply:DrG_IsPossessing() then return end
		local possessing = ply:DrG_Possessing()
		local view = {}
		view.origin, view.angles = possessing:PossessorView()
		view.fov, view.znear, view.zfar = fov, znear, zfar
		view.drawviewer = true
		return view
	end)

	hook.Add("ContextMenuOpen", "DrGBasePossessionDisableCMenu", function()
		local ply = LocalPlayer()
		if not isfunction(ply.DrG_IsPossessing) then return end
		if ply:DrG_IsPossessing() then return false end
	end)

	function DrGBase.DrawPossessionHUD(ent)
		local ply = LocalPlayer()
		-- I should put the rest of the HUD code here but
		-- I don't have any inspiration for how the HUD should look
		-- so right now there is no code here
		-- I'll take care of it one day
	end

end
