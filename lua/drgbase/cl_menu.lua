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
  local function AddCategory(category, fn)
    spawnmenu.AddToolCategory("drgbase", category, "#"..category)
    hook.Add("PopulateToolMenu", "DrG/PopulateToolMenu["..category.."]"..category, function()
      local function AddSubCategory(class, cmd, fn)
        local id = category.."."..class
        local placeholder = "#"..id
        return spawnmenu.AddToolMenuOption("drgbase", category, id, placeholder, cmd or "", "", function(panel)
          fn(panel, function(str, ...) return DrGBase.GetText(placeholder.."."..str, ...) end)
        end)
      end
      fn(AddSubCategory)
    end)
  end

  AddCategory("drgbase.menu.main", function(AddSubCategory)
    AddSubCategory("info", nil, function(panel, GetText)
      --
    end)

    AddSubCategory("server", nil, function(panel, GetText)
      --
    end)

    AddSubCategory("client", nil, function(panel, GetText)
      panel:ControlHelp("\n"..GetText("language"))
      panel:Help(GetText("language.text"))
      local combo = vgui.Create("DComboBox")
      local langs = DrGBase.GetLanguages()
      table.sort(langs, function(lang1, lang2)
        return lang1.Name > lang2.Name
      end)
      for _, lang in ipairs(langs) do
        local name = lang.Name
        local nbMissing = table.Count(lang:MissingTranslations())
        if nbMissing > 0 then name = name.." "..GetText("language.missing_translations", nbMissing) end
        combo:AddChoice(name, lang.Id, lang:IsCurrent(), lang.Flag)
      end
      function combo:OnSelect(_, _, id)
        if GetConVar("gmod_language"):GetString() ~= id then
          RunConsoleCommand("gmod_language", id)
          RunConsoleCommand("spawnmenu_reload")
        end
      end
      panel:AddPanel(combo)
    end)
  end)

  AddCategory("drgbase.menu.nextbots", function(AddSubCategory)
    AddSubCategory("ai", nil, function(panel, GetText)
      panel:ControlHelp("\n"..GetText("behaviour"))
      panel:CheckBox(GetText("behaviour.ai_disabled"), DrGBase.AIDisabled:GetName())
      panel:CheckBox(GetText("behaviour.ignore_players"), DrGBase.IgnorePlayers:GetName())
      panel:CheckBox(GetText("behaviour.ignore_npcs"), DrGBase.IgnoreNPCs:GetName())
      panel:CheckBox(GetText("behaviour.ignore_others"), DrGBase.IgnoreOthers:GetName())
      panel:CheckBox(GetText("behaviour.roam"), DrGBase.AIRoam:GetName())
      panel:ControlHelp("\n"..GetText("detection"))
      panel:CheckBox(GetText("detection.omniscience"), DrGBase.AIOmniscient:GetName())
      panel:CheckBox(GetText("detection.blind"), DrGBase.AIBlind:GetName())
      panel:CheckBox(GetText("detection.deaf"), DrGBase.AIDeaf:GetName())
    end)

    AddSubCategory("possession", nil, function(panel, GetText)
      panel:ControlHelp("\n"..GetText("server"))
      panel:CheckBox(GetText("server.enabled"), DrGBase.PossessionEnabled:GetName())
      panel:CheckBox(GetText("server.spawn_with_possessor"), DrGBase.SpawnWithPossessor:GetName())
      panel:ControlHelp("\n"..GetText("client"))
      panel:AddControl("numpad", {
        label = GetText("client.binds.stop"),
        command = DrGBase.PossessionBindStop:GetName(),
        label2 = GetText("client.binds.views"),
        command2 = DrGBase.PossessionBindNextView:GetName()
      })
    end)

    AddSubCategory("misc", nil, function(panel, GetText)
      panel:ControlHelp("\n"..GetText("stats"))
      panel:NumSlider(GetText("stats.health"), DrGBase.HealthMultiplier:GetName(), 0.1, 10, 1)
      panel:NumSlider(GetText("stats.player_damage"), DrGBase.PlayerDamageMultiplier:GetName(), 0.1, 10, 1)
      panel:NumSlider(GetText("stats.npc_damage"), DrGBase.NPCDamageMultiplier:GetName(), 0.1, 10, 1)
      panel:NumSlider(GetText("stats.other_damage"), DrGBase.OtherDamageMultiplier:GetName(), 0.1, 10, 1)
      panel:NumSlider(GetText("stats.speed"), DrGBase.SpeedMultiplier:GetName(), 0.1, 10, 1)
      panel:ControlHelp("\n"..GetText("ragdolls"))
      panel:NumSlider(GetText("ragdolls.remove"), DrGBase.RagdollsRemove:GetName(), -1, 100,0)
      panel:NumSlider(GetText("ragdolls.fadeout"), DrGBase.RagdollsFadeOut:GetName(), 0, 10, 0)
      panel:CheckBox(GetText("ragdolls.disable_collisions"), DrGBase.RagdollsDisableCollisions:GetName())
    end)
  end)

  spawnmenu.AddToolCategory("drgbase", "tools", "#spawnmenu.tools_tab")
  hook.Run("DrG/ToolMenu", AddCategory)
end)