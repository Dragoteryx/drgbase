hook.Add("DrG/SetupLanguages", "DrG/SetupEnglish", function()
  local lang = DrGBase.GetLanguage("en")
  lang.Name = "English"

  -- Misc --

  lang:Set("drgbase.hello", "Hi!")

  -- Possession --

  lang:Set("drgbase.possession.possess", "Possess")
  lang:Set("drgbase.possession.allowed", function(nb) return "You are now possessing "..nb end)
  lang:Set("drgbase.possession.denied.notplayer", "Are you not a player?")
  lang:Set("drgbase.possession.denied.dead", "You can't possess nextbots if you are dead")
  lang:Set("drgbase.possession.denied.invehicle", "You can't possess nextbots while in a vehicle")

  -- Spawnmenu --

  lang:Set("drgbase.spawnmenu.nextbots", "Nextbots")

  lang:Set("drgbase.spawnmenu.nextbots.ai", "AI Settings")
  lang:Set("drgbase.spawnmenu.nextbots.ai.behaviour", "Behaviour")
  lang:Set("drgbase.spawnmenu.nextbots.ai.behaviour.roam", "Enable roaming")
  lang:Set("drgbase.spawnmenu.nextbots.ai.detection", "Detection")
  lang:Set("drgbase.spawnmenu.nextbots.ai.detection.omniscience", "Omniscience")
  lang:Set("drgbase.spawnmenu.nextbots.ai.detection.blind", "Disable sight")
  lang:Set("drgbase.spawnmenu.nextbots.ai.detection.deaf", "Disable hearing")

  lang:Set("drgbase.spawnmenu.nextbots.possession", "Possession")
  lang:Set("drgbase.spawnmenu.nextbots.possession.server", "Server Settings")
  lang:Set("drgbase.spawnmenu.nextbots.possession.server.enable", "Enable possession")
  lang:Set("drgbase.spawnmenu.nextbots.possession.server.spawn_with_possessor", "Spawn with possessor")
  lang:Set("drgbase.spawnmenu.nextbots.possession.client", "Client Settings")

  lang:Set("drgbase.spawnmenu.nextbots.misc", "Misc")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats", "Stats")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.health", "Health multiplier")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.player_damage", "Player damage multiplier")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.npc_damage", "NPC damage multiplier")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.speed", "Speed multiplier")


  -- Tools --


end)