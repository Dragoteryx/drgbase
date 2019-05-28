TOOL.Category = "DrGBase"
TOOL.Name = "#tool.drgbase_tool_mover.name"
TOOL.BuildCPanel = function(panel)
	panel:Help("#tool.drgbase_tool_mover.desc")
	panel:Help("#tool.drgbase_tool_mover.0")
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
  net.Start("DrGBaseToolMoverSelect")
  net.WriteEntity(tr.Entity)
  net.WriteBool(table.HasValue(self.Selected, tr.Entity))
  net.Send(self:GetOwner())
  return true
end
function TOOL:RightClick(tr)
  if IsValid(tr.Entity) then return false end
  if CLIENT then return true end
  for i, nextbot in ipairs(self.Selected) do
    if not IsValid(nextbot) then continue end
		if nextbot:IsDead() then continue end
		nextbot._DrGBaseMoverTool = true
    nextbot:CallInCoroutine(function()
			nextbot._DrGBaseMoverTool = false
      nextbot:MoveToPos(tr.HitPos, {}, function()
        if nextbot:IsDead() then return "dead" end
				if nextbot._DrGBaseMoverTool then return "tool" end
      end)
    end)
  end
  return true
end
function TOOL:Reload(tr)
  if CLIENT then return true end
  self.Selected = {}
  net.Start("DrGBaseToolMoverClear")
  net.Send(self:GetOwner())
  return true
end

if SERVER then
  util.AddNetworkString("DrGBaseToolMoverSelect")
  util.AddNetworkString("DrGBaseToolMoverClear")
else
  language.Add("tool.drgbase_tool_mover.name", "AI Mover")
	language.Add("tool.drgbase_tool_mover.desc", "Force nextbots to move to a different position.")
	language.Add("tool.drgbase_tool_mover.0", "Left click to select/deselect a nextbot, right click to set the position to go to and reload to clear the list of selected nextbots.")

  local selected = {}
  net.Receive("DrGBaseToolMoverSelect", function()
    local ent = net.ReadEntity()
    if net.ReadBool() then table.insert(selected, ent)
    else table.RemoveByValue(selected, ent) end
  end)
  net.Receive("DrGBaseToolMoverClear", function()
    selected = {}
  end)
  hook.Add("PreDrawHalos", "DrGBaseToolMoverHalos", function()
    local wep = LocalPlayer():GetActiveWeapon()
    if not IsValid(wep) or wep:GetClass() ~= "gmod_tool" then return end
    local tool = LocalPlayer():GetTool()
    if tool == nil or tool.Mode ~= "drgbase_tool_mover" then return end
    halo.Add(selected, DrGBase.CLR_CYAN)
  end)
end
