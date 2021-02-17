-- Icons --

local ICON = "drgbase/icon16.png"

function DrGBase.GetIcon(name)
  if name == "DrGBase" then return ICON end
  return list.Get("DrG/Icons", name)
end
function DrGBase.SetIcon(name, icon)
  list.Set("DrG/Icons", name, tostring(icon))
end

-- Creation Tab --

spawnmenu.AddCreationTab("DrGBase", function()
  local panel = vgui.Create("SpawnmenuContentPanel")
  panel:EnableSearch("drgbase", "DrG/PopulateSpawnmenu")
  panel:CallPopulateHook("DrG/PopulateSpawnmenu")
  return panel
end, ICON, 75, "Every addon made using DrGBase.")

search.AddProvider(function(str)
	return {}
end, "drgbase")

-- Tool Tab --

hook.Add("AddToolMenuTabs", "DrG/ToolMenu", function()
  spawnmenu.AddToolTab("drgbase", "DrGBase", ICON)
end)