DrGBase.AddTool(function(TOOL, GetText)
  function TOOL.BuildCPanel(panel)
    panel:Help(GetText("desc"))
    panel:Help(GetText("0"))
  end

  function TOOL:LeftClick(tr)
    if not IsValid(tr.Entity) then return false end
    if not tr.Entity.IsDrGNextbot then return false end
    if SERVER then tr.Entity:SetAIDisabled(not tr.Entity:IsAIDisabled()) end
    return true
  end
end)

if CLIENT then
  hook.Add("PreDrawHalos", "DrG/ToolDisableAIHalos", function()
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" then return end
    local tool = LocalPlayer():GetTool()
    if tool == nil or tool.Mode ~= "drgbase_tool_disable_ai" then return end
    local enabled = {}
    local disabled = {}
    for nextbot in DrGBase.NextbotIterator() do
      table.insert(nextbot:IsAIDisabled() and disabled or enabled, nextbot)
    end
    halo.Add(enabled, DrGBase.CLR_GREEN)
    halo.Add(disabled, DrGBase.CLR_RED)
  end)
end