local DEFAULT_DISP = D_NU
local DEFAULT_PRIO = 1

if SERVER then

  local function SetRelationship(self, ent, disp, priority)
    --
  end

  -- Defined relationships --

  local function DefinedRelationships(self, name)
    self._DrGBaseDefinedRelationships = self._DrGBaseDefinedRelationships or {}
    self._DrGBaseDefinedRelationships[name] = self._DrGBaseDefinedRelationships[name] or {}
    return self._DrGBaseDefinedRelationships[name]
  end
  local function GetDefinedRelationship(self, name, id)
    local rel = DefinedRelationships(self, name)[id]
    if rel then return rel.disp, rel.prio
    else return DEFAULT_DISP, DEFAULT_PRIO end
  end
  local function SetDefinedRelationship(self, name, id, disp, prio)
    prio = isnumber(prio) and prio or DEFAULT_PRIO
    DefinedRelationships(self, name)[id] = {
      disp = disp, prio = prio
    }
  end
  local function AddDefinedRelationship(self, name, id, disp, prio)
    prio = isnumber(prio) and prio or DEFAULT_PRIO
    local curr = DefinedRelationships(self, name)[id]
    if curr.prio > prio then return end
    SetDefinedRelationship(self, name, id, disp, prio)
  end

  function ENT:GetEntityRelationship(ent)
    return GetDefinedRelationship(self, "entity", ent)
  end
  function ENT:SetEntityRelationship(ent, disp, prio)
    return SetDefinedRelationship(self, "entity", ent, disp, prio)
  end
  function ENT:AddEntityRelationship(ent, disp, prio)
    return AddDefinedRelationship(self, "entity", ent, disp, prio)
  end

end