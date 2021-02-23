TOOL.Tab = "drgbase"
TOOL.Category = "tools"
TOOL.Name = "#tool.drgbase_tool_disableai.name"
TOOL.BuildCPanel = function(panel)
	panel:Help("#tool.drgbase_tool_disableai.desc")
	panel:Help("#tool.drgbase_tool_disableai.0")
end

function TOOL:LeftClick(tr)
  if not IsValid(tr.Entity) then return false end
  if not tr.Entity.IsDrGNextbot then return false end
  if SERVER then tr.Entity:SetAIDisabled(not tr.Entity:IsAIDisabled()) end
  return true
end

if CLIENT then
  language.Add("tool.drgbase_tool_disableai.name", "Disable AI")
	language.Add("tool.drgbase_tool_disableai.desc", "Disable/enable AI for a nextbot.")
	language.Add("tool.drgbase_tool_disableai.0", "Left click to toggle AI. (Green => Enabled / Red => Disabled)")

  hook.Add("PreDrawHalos", "DrGBaseToolDisableAIHalos", function()
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" then return end
    local tool = LocalPlayer():GetTool()
    if tool == nil or tool.Mode ~= "drgbase_tool_disableai" then return end
    local enabled = {}
    local disabled = {}
    for i, nextbot in ipairs(DrGBase.GetNextbots()) do
      if not IsValid(nextbot) then continue end
      if nextbot:IsAIDisabled() then table.insert(disabled, nextbot)
      else table.insert(enabled, nextbot) end
    end
    halo.Add(enabled, DrGBase.CLR_GREEN)
    halo.Add(disabled, DrGBase.CLR_RED)
  end)
end
