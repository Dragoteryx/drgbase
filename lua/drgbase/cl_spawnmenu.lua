-- Icons --

local ICON = "drgbase/icon16.png"

DrG_Icons = DrG_Icons or {}
function DrGBase.GetIcon(name)
  if name == "DrGBase" then return ICON
  else return DrG_Icons[name] end
end
function DrGBase.SetIcon(name, icon)
  DrG_Icons[name] = tostring(icon)
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