hook.Add("DrG/LoadLanguages", "DrG/EnglishLanguage", function()
  local lang = DrGBase.GetOrCreateLanguage("en")
  lang.Flag = "flags16/gb.png"
  lang.Name = "English"

  -- Misc --

  lang:Set("drgbase.hello", "Hi!")

  -- Possession --

  lang:Set("drgbase.possession.possess", "Possess")
  lang:Set("drgbase.possession.allowed", function(name) return "You are now possessing "..name end)
  lang:Set("drgbase.possession.denied.notplayer", "Are you not a player?")
  lang:Set("drgbase.possession.denied.dead", "You can't possess nextbots if you are dead")
  lang:Set("drgbase.possession.denied.invehicle", "You can't possess nextbots from a vehicle")

  -- Spawnmenu --

  lang:Set("drgbase.spawnmenu.main", "Main Menu")

  lang:Set("drgbase.spawnmenu.main.info", "Information")

  lang:Set("drgbase.spawnmenu.main.server", "Server Settings")

  lang:Set("drgbase.spawnmenu.main.client", "Client Settings")
  lang:Set("drgbase.spawnmenu.main.client.language", "Language")
  lang:Set("drgbase.spawnmenu.main.client.language.text", "Set the current language, this will automatically reload the spawnmenu.")
  lang:Set("drgbase.spawnmenu.main.client.language.missing_translations", function(nb) return "(missing translations: "..nb..")" end)

  lang:Set("drgbase.spawnmenu.nextbots", "Nextbots")

  lang:Set("drgbase.spawnmenu.nextbots.ai", "AI Settings")
  lang:Set("drgbase.spawnmenu.nextbots.ai.behaviour", "Behaviour")
  lang:Set("drgbase.spawnmenu.nextbots.ai.behaviour.ai_disabled", "AI disabled")
  lang:Set("drgbase.spawnmenu.nextbots.ai.behaviour.ignore_players", "Ignore players")
  lang:Set("drgbase.spawnmenu.nextbots.ai.behaviour.ignore_npcs", "Ignore NPCs")
  lang:Set("drgbase.spawnmenu.nextbots.ai.behaviour.ignore_others", "Ignore other entities")
  lang:Set("drgbase.spawnmenu.nextbots.ai.behaviour.roam", "Enable roaming")
  lang:Set("drgbase.spawnmenu.nextbots.ai.detection", "Detection")
  lang:Set("drgbase.spawnmenu.nextbots.ai.detection.omniscience", "Omniscience")
  lang:Set("drgbase.spawnmenu.nextbots.ai.detection.blind", "Disable sight")
  lang:Set("drgbase.spawnmenu.nextbots.ai.detection.deaf", "Disable hearing")

  lang:Set("drgbase.spawnmenu.nextbots.possession", "Possession")
  lang:Set("drgbase.spawnmenu.nextbots.possession.server", "Server Settings")
  lang:Set("drgbase.spawnmenu.nextbots.possession.server.enabled", "Enable possession")
  lang:Set("drgbase.spawnmenu.nextbots.possession.server.spawn_with_possessor", "Spawn with possessor")
  lang:Set("drgbase.spawnmenu.nextbots.possession.client", "Client Settings")
  lang:Set("drgbase.spawnmenu.nextbots.possession.client.binds.views", "Next camera")

  lang:Set("drgbase.spawnmenu.nextbots.misc", "Misc")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats", "Stats")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.health", "Health multiplier")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.player_damage", "Player damage multiplier")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.npc_damage", "NPC damage multiplier")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.other_damage", "Other entities damage multiplier")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.speed", "Speed multiplier")
  lang:Set("drgbase.spawnmenu.nextbots.misc.ragdolls", "Ragdolls")
  lang:Set("drgbase.spawnmenu.nextbots.misc.ragdolls.remove", "Remove ragdolls")
  lang:Set("drgbase.spawnmenu.nextbots.misc.ragdolls.fadeout", "Fade out duration")
  lang:Set("drgbase.spawnmenu.nextbots.misc.ragdolls.disable_collisions", "Disable collisions")

  -- Tools --

  lang:Set("tool.drgbase_tool_damage.name", "Inflict Damage")
  lang:Set("tool.drgbase_tool_damage.desc", "Inflict damage to an entity.")
	lang:Set("tool.drgbase_tool_damage.0", "Left click to inflict damage.")
  lang:Set("tool.drgbase_tool_damage.damage", "Damage")
  lang:Set("tool.drgbase_tool_damage.type", "Type")
  lang:Set("tool.drgbase_tool_damage.enabled", "Enabled")
  lang:Set("tool.drgbase_tool_damage.yes", "Yes")
  lang:Set("tool.drgbase_tool_damage.no", "No")
  lang:Set("tool.drgbase_tool_damage.dmg_crush", "Crush")
  lang:Set("tool.drgbase_tool_damage.dmg_slash", "Slash")
  lang:Set("tool.drgbase_tool_damage.dmg_blast", "Blast")
  lang:Set("tool.drgbase_tool_damage.dmg_burn", "Burn")
  lang:Set("tool.drgbase_tool_damage.dmg_slowburn", "Slow burn")
  lang:Set("tool.drgbase_tool_damage.dmg_shock", "Shock")
  lang:Set("tool.drgbase_tool_damage.dmg_plasma", "Plasma")
  lang:Set("tool.drgbase_tool_damage.dmg_dissolve", "Dissolve")
  lang:Set("tool.drgbase_tool_damage.dmg_sonic", "Sonic")
  lang:Set("tool.drgbase_tool_damage.dmg_poison", "Poison")
  lang:Set("tool.drgbase_tool_damage.dmg_acid", "Acid")
  lang:Set("tool.drgbase_tool_damage.dmg_radiation", "Radiation")
  lang:Set("tool.drgbase_tool_damage.dmg_neurotoxin", "Neurotoxin")

  lang:Set("tool.drgbase_tool_disable_ai.name", "Disable AI")
	lang:Set("tool.drgbase_tool_disable_ai.desc", "Disable/enable AI of a nextbot.")
	lang:Set("tool.drgbase_tool_disable_ai.0", "Left click to toggle AI. (Green => Enabled / Red => Disabled)")

end)