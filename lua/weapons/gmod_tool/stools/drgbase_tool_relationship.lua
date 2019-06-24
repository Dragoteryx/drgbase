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

function TOOL:Deploy()
	if CLIENT then return end
  self.Selected = self.Selected or {}
end
function TOOL:LeftClick(tr)
  if not IsValid(tr.Entity) then return false end
  if not tr.Entity.IsDrGNextbot then return false end
	if CLIENT then return true end
  if table.HasValue(self.Selected, tr.Entity) then
    table.RemoveByValue(self.Selected, tr.Entity)
  else table.insert(self.Selected, tr.Entity) end
	net.Start("DrGBaseToolRelationshipSelect")
  net.WriteEntity(tr.Entity)
  net.WriteBool(table.HasValue(self.Selected, tr.Entity))
  net.Send(self:GetOwner())
  return true
end
function TOOL:RightClick(tr)
  if not IsValid(tr.Entity) and not tr.Entity:IsWorld() then return false end
	if CLIENT then return true end
	if tr.Entity:IsWorld() then tr.Entity = self:GetOwner() end
	local disp = self:GetClientNumber("disposition")
	for i, nextbot in ipairs(self.Selected) do
    if not IsValid(nextbot) then continue end
    nextbot:_SetRelationship(tr.Entity, disp)
		if tr.Entity.IsDrGNextbot and tobool(self:GetClientNumber("bothways")) then
			tr.Entity:_SetRelationship(nextbot, disp)
		end
  end
  return true
end
function TOOL:Reload(tr)
	if CLIENT then return true end
  self.Selected = {}
	net.Start("DrGBaseToolRelationshipClear")
  net.Send(self:GetOwner())
  return true
end

if SERVER then
  util.AddNetworkString("DrGBaseToolRelationshipSelect")
  util.AddNetworkString("DrGBaseToolRelationshipClear")
else
	language.Add("tool.drgbase_tool_relationship.name", "AI Relationship")
	language.Add("tool.drgbase_tool_relationship.desc", "Change relationship of a nextbot towards an entity.")
	language.Add("tool.drgbase_tool_relationship.0", "Left click to select/deselect a nextbot, right click to set the relationship towards an entity (aim at the ground to set the relationship towards yourself) and reload to clear the list of selected nextbots.")

  local selected = {}
  net.Receive("DrGBaseToolRelationshipSelect", function()
    local ent = net.ReadEntity()
    if net.ReadBool() then table.insert(selected, ent)
    else table.RemoveByValue(selected, ent) end
  end)
  net.Receive("DrGBaseToolRelationshipClear", function()
    selected = {}
  end)
  hook.Add("PreDrawHalos", "DrGBaseToolRelationshipHalos", function()
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" then return end
    local tool = LocalPlayer():GetTool()
    if tool == nil or tool.Mode ~= "drgbase_tool_relationship" then return end
		local disp = GetConVar("drgbase_tool_relationship_disposition"):GetInt()
		if disp == D_LI then halo.Add(selected, DrGBase.CLR_GREEN)
		elseif disp == D_HT then halo.Add(selected, DrGBase.CLR_RED)
		elseif disp == D_FR then halo.Add(selected, DrGBase.CLR_PURPLE)
		else halo.Add(selected, DrGBase.CLR_CYAN) end
  end)
end
