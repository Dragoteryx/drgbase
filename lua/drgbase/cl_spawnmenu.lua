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
  str = str:PatternSafe()
  local results = {}

	return results
end, "drgbase")

-- Tool Tab --

hook.Add("AddToolMenuTabs", "DrG/AddToolMenuTab", function()
  spawnmenu.AddToolTab("drgbase", "DrGBase", ICON)
end)

hook.Add("AddToolMenuCategories", "DrG/AddToolMenuCategories", function()
  local function AddCategory(category)
    return spawnmenu.AddToolCategory("drgbase", category, "#drgbase.spawnmenu."..category)
  end

  AddCategory("nextbots")

  spawnmenu.AddToolCategory("drgbase", "tools", "#spawnmenu.tools_tab")
end)

hook.Add("PopulateToolMenu", "DrG/PopulateToolMenu", function()
  local function AddToolMenuOption(category, class, fn)
    local placeholder = "#drgbase.spawnmenu."..category.."."..class
    return spawnmenu.AddToolMenuOption("drgbase", category, class, placeholder, "", "", function(panel)
      fn(panel, function(str)
        local placeholder2 = placeholder.."."..str
        return DrGBase.GetText(placeholder2) or placeholder2
      end)
    end)
  end

  -- Nextbot settings --

  AddToolMenuOption("nextbots", "ai", function(panel, Text)
    panel:ControlHelp("\n"..Text("behaviour"))
    panel:CheckBox(Text("behaviour.roam"), DrGBase.EnableRoam:GetName())
    panel:ControlHelp("\n"..Text("detection"))
    panel:CheckBox(Text("detection.omniscience"), DrGBase.AllOmniscient:GetName())
    panel:CheckBox(Text("detection.blind"), DrGBase.AIBlind:GetName())
    panel:CheckBox(Text("detection.deaf"), DrGBase.AIDeaf:GetName())
  end)

  AddToolMenuOption("nextbots", "possession", function(panel, Text)
    panel:ControlHelp("\n"..Text("server"))
    panel:CheckBox(Text("server.enable"), DrGBase.PossessionEnabled:GetName())
    panel:CheckBox(Text("server.spawn_with_possessor"), DrGBase.SpawnWithPossessor:GetName())
    panel:ControlHelp("\n"..Text("client"))
  end)

  AddToolMenuOption("nextbots", "misc", function(panel, Text)
    panel:ControlHelp("\n"..Text("stats"))
    panel:NumSlider(Text("stats.health"), DrGBase.MultHealth:GetName(), 0.1, 10, 1)
    /*panel:NumSlider(Text("stats.player_damage"), "drgbase_multiplier_damage_players", 0.1, 10, 1)
    panel:NumSlider(Text("stats.npc_damage"), "drgbase_multiplier_damage_npc", 0.1, 10, 1)*/
    panel:NumSlider(Text("stats.speed"), DrGBase.MultSpeed:GetName(), 0.1, 10, 1)
  end)
end)