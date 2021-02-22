-- Getters --

function ENT:IsPossessionEnabled()
  return self:GetNW2Bool("DrG/DrGBase.PossessionEnabled", self.PossessionEnabled)
end

function ENT:GetPossessor()
  return self:GetNW2Entity("DrG/Possessor")
end
function ENT:IsPossessed()
  return IsValid(self:GetPossessor())
end

function ENT:GetPossessionZoom()
  return self:GetNW2Float("DrG/PossessionZoom", 1)
end

function ENT:GetPossessionView()
  return self:GetNW2Int("DrG/PossessionView")
end

-- View --

function ENT:PossessorEyePos()
  local view = self:OnPossessionCalcView(self:GetPossessionView())
  if isvector(view) then return view end
  local origin
  local distance
  if view.auto then
    origin = self:WorldSpaceCenter() +
      Vector(0, 0, self:Height()/3)
    distance = self:Length()*3
  else
    local pos = self:GetPos()
    local offset = view.offset or Vector(0, 0, 0)
    if view.origin then
      origin = view.origin
    elseif view.eyepos then
      origin = self:EyePos()
    else origin = self:WorldSpaceCenter() end
    origin = origin +
      self:PossessorForward()*offset.x*self:GetModelScale() +
      self:PossessorRight()*offset.y*self:GetModelScale() +
      self:PossessorUp()*offset.z*self:GetModelScale()
    origin = self:TraceLine({
      startpos = Vector(pos.x, pos.y, origin.z),
      endpos = origin
    }).HitPos
    distance = view.distance or 0
  end
  local tr = self:TraceLine({
    start = origin,
    direction = -self:PossessorEyeNormal()*
      (1/self:GetPossessionZoom())*
      (distance+10)
  })
  return tr.HitPos +
    self:PossessorEyeNormal()*10
end
function ENT:PossessorEyeAngles()
  return self:GetPossessor():EyeAngles()
end

function ENT:OnPossessionCalcView(view)
  return istable(self.PossessionViews) and self.PossessionViews[view+1] or {auto = true}
end

-- Util --

function ENT:PossessorEyeNormal()
  return self:PossessorEyeAngles():Forward()
end
function ENT:PossessorEyeTrace(data)
  if isnumber(data) then data = {distance = data} end
  if not istable(data) then data = {} end
  if not isvector(data.start) then data.start = self:PossessorEyePos() end
  if not isvector(data.direction) and not isvector(data.endpos) then
    data.direction = self:PossessorEyeNormal()*(data.distance or math.huge)
  end return self:TraceLine(data)
end
function ENT:PossessorForward()
  local normal = self:PossessorEyeNormal()
  normal.z = 0
  return normal:GetNormalized()
end
function ENT:PossessorRight()
  local forward = self:PossessorForward()
  forward:Rotate(Angle(0, -90, 0))
  return forward
end
function ENT:PossessorUp()
  return self:GetUp()
end

-- Internals --

properties.Add("drg/possess", {
  MenuLabel = "#drgbase.possession.possess",
	Order = 1101,
	MenuIcon = "drgbase/icon16.png",
	Filter = function(_self, ent, _ply)
    if not IsValid(ent) then return end
		if not ent.IsDrGNextbot then return false end
		if not DrGBase.PossessionEnabled:GetBool() then return false end
		if not ent.PossessionPrompt then return false end
		if not ent:IsPossessionEnabled() then return false end
		return true
	end,
	Action = function(self, ent)
    self:MsgStart()
    net.WriteEntity(ent)
    self:MsgEnd()
  end,
	Receive = function(_self, _len, ply)
		local ent = net.ReadEntity()
    local ok, reason = ent:CanPossess(ply)
    if ok then
      ent:SetPossessor(ply)
			net.Start("DrG/PossessionAllowed")
			net.WriteEntity(ent)
		else
			net.Start("DrG/PossessionDenied")
			net.WriteEntity(ent)
      net.WriteString(reason)
    end
		net.Send(ply)
	end
})

local PossessionBindsTableDeprecation = DrGBase.Deprecation("ENT.PossessionBinds", "ENT:Do/OnPossessionBinds(binds)")
local function PossessionBindsTable(self, thr)
  if not istable(self.PossessionBinds) then return end
  if SERVER then PossessionBindsTableDeprecation() end
  local ply = self:GetPossessor()
  for key, binds in pairs(self.PossessionBinds) do
    if isstring(key) then
      if CLIENT then
        local convar = GetConVar(key)
        if not convar then continue
        else key = convar:GetInt() end
      else
        key = ply:GetInfoNum(key, BUTTON_CODE_INVALID)
        if key == BUTTON_CODE_INVALID then continue end
      end
    end
    for _, bind in ipairs(binds) do
      if CLIENT and not bind.client then continue end
      if SERVER and ((not thr and bind.coroutine) or (thr and not bind.coroutine)) then continue end
      if isfunction(bind.onkeypressed) and ply:KeyPressed(key) then bind.onkeypressed(self, ply) end
      if ply:KeyDown(key) then
        if isfunction(bind.onkeydown) then bind.onkeydown(self, ply)
        elseif isfunction(bind.onkeyup) then bind.onkeyup(self, ply) end
      end
      if isfunction(bind.onkeydownlast) and ply:KeyDownLast(key) then bind.onkeydownlast(self, ply) end
      if isfunction(bind.onkeyreleased) and ply:KeyReleased(key) then bind.onkeyreleased(self, ply) end
      if isfunction(bind.onbuttonup) and ply:DrG_ButtonUp(key) then bind.onbuttonup(self, ply) end
      if isfunction(bind.onbuttonpressed) and ply:DrG_ButtonPressed(key) then bind.onbuttonpressed(self, ply) end
      if isfunction(bind.onbuttondown) and ply:DrG_ButtonDown(key) then bind.onbuttondown(self, ply) end
      if isfunction(bind.onbuttonreleased) and ply:DrG_ButtonReleased(key) then bind.onbuttonreleased(self, ply) end
    end
  end
end

hook.Add("StartCommand", "DrG/PossessionStartCommand", function(ply, cmd)
  if not isfunction(ply.DrG_IsPossessing) then return end
  if ply:DrG_IsPossessing() then
    local possessing = ply:DrG_GetPossessing()
    -- disable movement
		cmd:ClearMovement()
    -- zoom
    if SERVER and cmd:GetMouseWheel() ~= 0 then
      if cmd:GetMouseWheel() == 1 then possessing:PossessionZoomIn()
      else possessing:PossessionZoomOut() end
    end
    -- lock on
  end
end)

hook.Add("PlayerFootstep", "DrG/PossessionMuteFootsteps", function(ply)
	if not isfunction(ply.DrG_IsPossessing) then return end
	if ply:DrG_IsPossessing() then return true end
end)

hook.Add("EntityEmitSound", "DrG/PossessionMutePlayerSounds", function(sound)
  if IsValid(sound.Entity) and sound.Entity:IsPlayer() and
  isfunction(sound.Entity.DrG_IsPossessing) and sound.Entity:DrG_IsPossessing() then
    return false
  end
end)

hook.Add("CanDrive", "DrG/PossessionDisablePropDrive", function(_ply, ent)
  if ent.IsDrGNextbot then return false end
end)

if SERVER then
  util.AddNetworkString("DrG/PossessionAllowed")
  util.AddNetworkString("DrG/PossessionDenied")

  -- Getters/setters --

  function ENT:SetPossessionEnabled(bool)
    self:SetNW2Bool("DrG/DrGBase.PossessionEnabled", bool)
    if not bool then self:StopPossession() end
  end

  function ENT:EnablePossession()
    self:SetPossessionEnabled(true)
  end
  function ENT:DisablePossession()
    self:SetPossessionEnabled(false)
  end

  local PossessionMovementDeprecation = DrGBase.Deprecation("ENT.PossessionMovement", "ENT.PossessionMove")
  function ENT:GetPossessionMove()
    if self.PossessionMovement then
      PossessionMovementDeprecation()
      return self.PossessionMovement
    else return self.PossessionMove end
  end
  function ENT:SetPossessionMove(move)
    self.PossessionMove = move
  end

  function ENT:SetPossessor(ply)
    if IsValid(ply) and ply:IsPlayer() then
      if not self:CanPossess(ply) then return end
      ply:DrG_StopPossession()
      self:StopPossession()
      self:SetNW2Float("DrG/PossessionZoom", 1)
      self:SetNW2Entity("DrG/Possessor", ply)
      ply:SetNW2Entity("DrG/Possessing", self)
      ply.DrG_PrePossessPos = ply:GetPos()
      ply.DrG_PrePossessAngles = ply:GetAngles()
      ply.DrG_PrePossessEyeAngles = ply:EyeAngles()
      ply.DrG_PrePossessWeapon = ply:GetActiveWeapon()
      ply:SetActiveWeapon(nil)
      ply.DrG_PrePossessFlashlight = ply:FlashlightIsOn()
      ply:Flashlight(false)
      ply.DrG_PrePossessCollisionGroup = ply:GetCollisionGroup()
      ply:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
      ply.DrG_PrePossessNoTarget = ply:GetNoTarget()
      ply:SetNoTarget(true)
      ply.DrG_PrePossessNoDraw = ply:GetNoDraw()
      ply:SetNoDraw(true)
      ply:DrawShadow(false)
      ply:Spectate(OBS_MODE_CHASE)
      ply:SpectateEntity(self)
    elseif self:IsPossessed() then
      local ply = self:GetPossessor()
      self:SetNW2Float("DrG/PossessionZoom", 1)
      self:SetNW2Entity("DrG/Possessor", nil)
      ply:SetNW2Entity("DrG/Possessing", nil)
      ply:UnSpectate()
      ply:SetPos(ply.DrG_PrePossessPos)
      ply:SetAngles(ply.DrG_PrePossessAngles)
      ply:SetEyeAngles(ply.DrG_PrePossessEyeAngles)
      --ply:SetActiveWeapon(ply.DrG_PrePossessWeapon)
      ply:Flashlight(ply.DrG_PrePossessFlashlight)
      ply:SetCollisionGroup(ply.DrG_PrePossessCollisionGroup)
      ply:SetNoTarget(ply.DrG_PrePossessNoTarget)
      ply:SetNoDraw(ply.DrG_PrePossessNoDraw)
      ply:DrawShadow(true)
    end
  end
  function ENT:StopPossession()
    return self:SetPossessor(nil)
  end

  function ENT:CanPossess(ply)
    if not IsValid(ply) or not isentity(ply) or not ply:IsPlayer() then return false, "#drgbase.possession.denied.notplayer" end
    if not ply:Alive() then return false, "#drgbase.possession.denied.dead" end
    if ply:InVehicle() then return false, "#drgbase.possession.denied.invehicle" end
    return true
  end

  function ENT:SetPossessionZoom(zoom)
    self:SetNW2Float("DrG/PossessionZoom", zoom)
  end
  function ENT:PossessionZoomIn(mult)
    self:SetPossessionZoom(self:GetPossessionZoom()*1.05*(mult or 1))
  end
  function ENT:PossessionZoomOut(mult)
    self:SetPossessionZoom(self:GetPossessionZoom()*0.95*(mult or 1))
  end


  function ENT:SetPossessionView(view)
    self:SetNW2Int("DrG/PossessionView", view)
  end

  -- Movements --

  function ENT:PossessionFaceForward()
    if not self:IsPossessed() then return end
    --[[local lockedOn = self:PossessionGetLockedOn()
    if not IsValid(lockedOn) then]]
      self:FaceTowards(self:GetPos() + self:PossessorEyeNormal())
    --else self:FaceTowards(lockedOn) end
  end

  function ENT:PossessionMoveForward()
    if not self:IsPossessed() then return end
    self:Approach(self:GetPos() + self:PossessorForward())
  end
  function ENT:PossessionMoveBackward()
    if not self:IsPossessed() then return end
    self:Approach(self:GetPos() - self:PossessorForward())
  end
  function ENT:PossessionMoveLeft()
    if not self:IsPossessed() then return end
    self:Approach(self:GetPos() - self:PossessorRight())
  end
  function ENT:PossessionMoveRight()
    if not self:IsPossessed() then return end
    self:Approach(self:GetPos() + self:PossessorRight())
  end

  -- Hooks --

  local PossessionMovementDeprecation = DrGBase.Deprecation("ENT:PossessionMovement(forward, backward, right, left)", "ENT:DoPossessionMoveCustom(move)")
  function ENT:DoPossessionMove(move)
    local moving = move:IsMoving()
    local forward = move:IsMovingForward()
    local backward = move:IsMovingBackward()
    local left = move:IsMovingLeft()
    local right = move:IsMovingRight()
    if self:GetPossessionMove() == POSSESSION_MOVE_8DIR then
      if not moving then return end
      self:PossessionFaceForward()
      if forward then self:PossessionMoveForward() end
      if backward then self:PossessionMoveBackward() end
      if left then self:PossessionMoveLeft() end
      if right then self:PossessionMoveRight() end
    elseif self:GetPossessionMove() == POSSESSION_MOVE_4DIR then
      if moving then self:PossessionFaceForward() end
      local dir = self.DrG_PossLast4DIR or ""
      if forward and dir ~= "Y" then
        self:PossessionMoveForward()
        self.DrG_PossLast4DIR = "X"
      elseif backward and dir ~= "Y" then
        self:PossessionMoveBackward()
        self.DrG_PossLast4DIR = "X"
      elseif left and dir ~= "X" then
        self:PossessionMoveLeft()
        self.DrG_PossLast4DIR = "Y"
      elseif right and dir ~= "X" then
        self:PossessionMoveRight()
        self.DrG_PossLast4DIR = "Y"
      else self.DrG_PossLast4DIR = "" end
    elseif self:GetPossessionMove() == POSSESSION_MOVE_2DIR or
    self:GetPossessionMove() == POSSESSION_MOVE_1DIR then
      if not moving then return end
      local direction = self:GetPos()
      if forward then direction = direction + self:PossessorForward() end
      if backward then direction = direction - self:PossessorForward() end
      if left then direction = direction - self:PossessorRight() end
      if right then direction = direction + self:PossessorRight() end
      if self:GetPossessionMove() == POSSESSION_MOVE_2DIR then
        self:Approach(direction)
        local away = self:GetPos()*2 - direction
        if backward then self:FaceTowards(away)
        else self:FaceTowards(direction) end
      else self:MoveTowards(direction) end
    elseif self:GetPossessionMove() == POSSESSION_MOVE_CUSTOM then
      if isfunction(self.PossessionControls) then
        PossessionMovementDeprecation()
        self:PossessionControls(forward, backward, right, left)
      else self:DoPossessionMoveCustom(move) end
    end
  end
  function ENT:DoPossessionMoveCustom() end

  function ENT:DoPossessionBinds()
    PossessionBindsTable(self, true)
  end
  function ENT:OnPossessionBinds()
    PossessionBindsTable(self, false)
  end

  function ENT:OnPossessionNextView(view)
    if istable(self.PossessionViews) then return (view+1)%#self.PossessionViews end
  end

  -- Internal --

  function ENT:PossessionBehaviour()
    local ply = self:GetPossessor()
    if self:InCoroutine() then
      if ply:KeyDown(IN_USE) then
        local tr = self:PossessorEyeTrace()
        if IsValid(tr.Entity) then tr.Entity:Use(self)end
      end
      self:DoPossessionMove(ply:DrG_Move())
      self:DoPossessionBinds(ply:DrG_Binds())
    else self:OnPossessionBinds(ply:DrG_Binds()) end
  end

  hook.Add("PlayerUse", "DrG/PossessionDisableUse", function(ply)
	  if ply:DrG_IsPossessing() then return false end
	end)

  hook.Add("EntityTakeDamage", "DrG/PossessionProtectPlayer", function(ent)
		if ent:IsPlayer() and ent:DrG_IsPossessing() then return true end
	end)

  hook.Add("GetFallDamage", "DrG/PossessionPlayerFallDamage", function(ply)
		if ply:DrG_IsPossessing() then return 0 end
	end)

	hook.Add("SetupPlayerVisibility", "DrG/PossessionAddToPVS", function(ply)
		if not ply:DrG_IsPossessing() then return end
    local possessing = ply:DrG_GetPossessing()
    AddOriginToPVS(possessing:PossessorEyePos())
    --[[local lockedOn = possessing:PossessionGetLockedOn()
    if IsValid(lockedOn) then AddOriginToPVS(lockedOn:GetPos()) end]]
	end)

  hook.Add("PlayerSwitchFlashlight", "DrG/PossessionSwitchFlashlight", function(ply, enabled)
    if ply:DrG_IsPossessing() and enabled then return false end
  end)

  hook.Add("PlayerButtonDown", "DrG/PossessionPlayerButtonDown", function(ply, button)
    if not ply:DrG_IsPossessing() then return end
    local possessing = ply:DrG_GetPossessing()
    if button == KEY_V then
      local view = possessing:OnPossessionNextView(possessing:GetPossessionView())
      if isnumber(view) then possessing:SetPossessionView(view) end
    end
  end)

  hook.Add("PlayerSpawn", "DrG/SpawnWithPossessor", function(ply)
    if DrGBase.SpawnWithPossessor:GetBool() then ply:Give("drgbase_possessor") end
  end)

else

  -- Getters --

  function ENT:IsPossessedByLocalPlayer()
    return self:GetPossessor() == LocalPlayer()
  end

  -- Hooks --

  function ENT:PossessionBehaviour()
    self:OnPossessionBinds(LocalPlayer():DrG_Binds())
  end

  function ENT:OnPossessionBinds()
    PossessionBindsTable(self, false)
  end

  -- Internal --

  hook.Add("CalcView", "DrG/PossessionCalcView", function(ply, _origin, angles, fov, znear, zfar)
    if not isfunction(ply.DrG_IsPossessing) or not ply:DrG_IsPossessing() then return end
    local possessing = ply:DrG_GetPossessing()
    local view = {}
    view.origin = possessing:PossessorEyePos()
    view.angles = angles
    view.fov = fov
    view.znear = znear
    view.zfar = zfar
    view.drawviewer = false
    return view
  end)

  hook.Add("ShouldDisableLegs", "DrG/GmodLegs3Disable", function()
    local ply = LocalPlayer()
    if isfunction(ply.DrG_IsPossessing) and ply:DrG_IsPossessing() then return true end
  end)

  local HUD_HIDE = {
		["CHudWeaponSelection"] = true,
		["CHudAmmo"] = true,
		["CHudSecondaryAmmo"] = true,
		["CHudZoom"] = true
	}
	hook.Add("HUDShouldDraw", "DrGBasePossessionHideHUD", function(name)
		local ply = LocalPlayer()
		if not isfunction(ply.DrG_IsPossessing) or not ply:DrG_IsPossessing() then return end
		if HUD_HIDE[name] then return false end
		--if name == "CHudCrosshair" and not ply:DrG_GetPossessing().PossessionCrosshair then return false end
	end)

  net.Receive("DrG/PossessionAllowed", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    notification.AddLegacy(DrGBase.GetText("drgbase.possession.allowed", ent.PrintName or ent:GetClass()), NOTIFY_HINT, 4)
    surface.PlaySound("buttons/lightswitch2.wav")
  end)

  net.Receive("DrG/PossessionDenied", function()
    local ent = net.ReadEntity()
    if not IsValid(ent) then return end
    local reason = net.ReadString()
    notification.AddLegacy(reason, NOTIFY_ERROR, 4)
    surface.PlaySound("buttons/button10.wav")
  end)

end