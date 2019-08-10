TOOL.Category = "DrGBase"
TOOL.Name = "#tool.drgbase_tool_relationship.name"
TOOL.ClientConVar = {
	["disposition"] = 1,
	["bothways"] = 0
}
TOOL.BuildCPanel = function(panel)
	panel:Help("#tool.drgbase_tool_relationship.desc")
	panel:Help("#tool.drgbase_tool_relationship.0")
	panel:ControlHelp("\nOptions\n")
	local combo = panel:ComboBox("Relationship", "drgbase_tool_relationship_disposition")
	combo:AddChoice("Like", 3)
	combo:AddChoice("Hate", 1)
	combo:AddChoice("Fear", 2)
	combo:AddChoice("Ignore", 4)
	panel:CheckBox("Both ways", "drgbase_tool_relationship_bothways")
	panel:Help("If both ways, it will set the same relationship on the other entity.")
end

function TOOL:LeftClick(tr)
  if not IsValid(tr.Entity) then return false end
  if not tr.Entity.IsDrGNextbot and
	not tr.Entity:IsNPC() then return false end
	if CLIENT then return true end
  self:GetOwner():DrG_CleverEntitySelect(tr.Entity)
  return true
end
function TOOL:RightClick(tr)
  if not IsValid(tr.Entity) and not tr.Entity:IsWorld() then return false end
	if CLIENT then return true end
	if tr.Entity:IsWorld() then tr.Entity = self:GetOwner() end
	local disp = self:GetClientNumber("disposition")
	if self:GetOwner():KeyDown(IN_SPEED) then
		for ent in self:GetOwner():DrG_SelectedEntities() do
			for ent2 in self:GetOwner():DrG_SelectedEntities() do
		    if ent == ent2 then continue end
				if ent.IsDrGNextbot then
					ent:_SetRelationship(ent2, disp)
				elseif ent:IsNPC() then
					ent:DrG_SetRelationship(ent2, disp)
				end
		  end
	  end
	else
		for ent in self:GetOwner():DrG_SelectedEntities() do
			if ent.IsDrGNextbot then
				ent:_SetRelationship(tr.Entity, disp)
			elseif ent:IsNPC() then
				ent:DrG_SetRelationship(tr.Entity, disp)
			end
	  end
	end
  return true
end
function TOOL:Reload(tr)
	if CLIENT then return true end
  self:GetOwner():DrG_ClearSelectedEntities()
  return true
end

if CLIENT then
	language.Add("tool.drgbase_tool_relationship.name", "AI Relationship")
	language.Add("tool.drgbase_tool_relationship.desc", "Change relationship of a nextbot towards an entity.")
	language.Add("tool.drgbase_tool_relationship.0", "Left click to select/deselect a nextbot/NPC (hold shift to select multiple entities), right click to set the relationship towards an entity (aim at the ground to set the relationship towards yourself) and reload to clear the list of selected entities.")

  hook.Add("PreDrawHalos", "DrGBaseToolRelationshipHalos", function()
		local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" then return end
    local tool = ply:GetTool()
    if tool == nil or tool.Mode ~= "drgbase_tool_relationship" then return end
		local disp = GetConVar("drgbase_tool_relationship_disposition"):GetInt()
		local selected = ply:DrG_GetSelectedEntities()
		if disp == D_LI then halo.Add(selected, DrGBase.CLR_GREEN)
		elseif disp == D_HT then halo.Add(selected, DrGBase.CLR_RED)
		elseif disp == D_FR then halo.Add(selected, DrGBase.CLR_PURPLE)
		else halo.Add(selected, DrGBase.CLR_CYAN) end
  end)
end
