
function DrGBase.CreateProjectile(model, pos, angles, binds, class)
  local proj = ents.Create(class or "drgbase_projectile")
  if istable(model) and #model > 0 then model = model[math.random(#model)] end
  pos = pos or Vector(0, 0, 0)
  angles = angles or Angle(0, 0, 0)
  proj:SetPos(pos)
  proj:SetAngles(angles)
  if isfunction(binds.Init) then binds.Init(proj) end
  if isfunction(binds.Think) then proj.CustomThink = binds.Think end
  if isfunction(binds.Filter) then proj.CustomFilter = binds.Filter end
  if isfunction(binds.Contact) then proj.CustomContact = binds.Contact end
  if isfunction(binds.Use) then proj.CustomUse = binds.Use end
  if isfunction(binds.Damage) then proj.CustomDamage = binds.Damage end
  if isfunction(binds.Remove) then proj.CustomRemove = binds.Remove end
  proj:Spawn()
  if isstring(model) then proj:SetModel(model) end
  proj:PhysicsInit(SOLID_VPHYSICS)
  proj:SetMoveType(MOVETYPE_VPHYSICS)
  proj:SetSolid(SOLID_VPHYSICS)
  proj:SetUseType(SIMPLE_USE)
  local phys = proj:GetPhysicsObject()
  if IsValid(phys) then
    phys:Wake()
  end
  return proj
end
