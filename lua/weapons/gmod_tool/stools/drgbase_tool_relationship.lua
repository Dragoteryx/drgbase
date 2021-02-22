TOOL.Tab = "drgbase"
TOOL.Category = "tools"
TOOL.Name = "#tool.drgbase_tool_relationship.name"

function TOOL:LeftClick(tr) end
function TOOL:RightClick(tr) end
function TOOL:Reload() end

if SERVER then
  util.AddNetworkString("DrGBaseRelationshipTool")
else
  language.Add("tool.drgbase_tool_relationship.name", "Relationship Tool")
	language.Add("tool.drgbase_tool_relationship.desc", "Edit a nextbot's relationships.")
	language.Add("tool.drgbase_tool_relationship.0", "Left click to select a nextbot, right click to use quick select.")
end
