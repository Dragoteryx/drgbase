hook.Add("DrG/SetupLanguages", "DrG/SetupFrench", function()
  local lang = DrGBase.GetLanguage("fr")
  lang.Name = "Français"

  -- Misc --

  lang:Set("drgbase.hello", "Salut !")

  -- Possession --

  lang:Set("drgbase.possession.possess", "Posséder")
  lang:Set("drgbase.possession.allowed", function(nb) return "Tu possèdes désormais "..nb end)
  lang:Set("drgbase.possession.denied.notplayer", "Tu n'es pas un joueur ?")
  lang:Set("drgbase.possession.denied.dead", "Tu peux ne pas posséder de nextbot en étant mort")
  lang:Set("drgbase.possession.denied.invehicle", "Tu ne peux pas posséder de nextbot depuis un véhicule")

  -- Spawnmenu --

  lang:Set("drgbase.spawnmenu.nextbots", "Nextbots")

  lang:Set("drgbase.spawnmenu.nextbots.ai", "Paramètres IA")
  lang:Set("drgbase.spawnmenu.nextbots.ai.behaviour", "Comportement")
  lang:Set("drgbase.spawnmenu.nextbots.ai.behaviour.roam", "Activer l'errance")
  lang:Set("drgbase.spawnmenu.nextbots.ai.detection", "Détection")
  lang:Set("drgbase.spawnmenu.nextbots.ai.detection.omniscience", "Omniscience")
  lang:Set("drgbase.spawnmenu.nextbots.ai.detection.blind", "Désactiver la vision")
  lang:Set("drgbase.spawnmenu.nextbots.ai.detection.deaf", "Désactiver l'écoute")

  lang:Set("drgbase.spawnmenu.nextbots.possession", "Possession")
  lang:Set("drgbase.spawnmenu.nextbots.possession.server", "Paramètres serveur")
  lang:Set("drgbase.spawnmenu.nextbots.possession.server.enable", "Activer la possession")
  lang:Set("drgbase.spawnmenu.nextbots.possession.server.spawn_with_possessor", "Spawn avec le possesseur")
  lang:Set("drgbase.spawnmenu.nextbots.possession.client", "Paramètres client")

  lang:Set("drgbase.spawnmenu.nextbots.misc", "Divers")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats", "Stats")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.health", "Multiplicateur de santé")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.player_damage", "Multiplicateur de dégâts aux joueurs")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.npc_damage", "Multiplicateur de dégâts aux PNJs")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.speed", "Multiplicateur de vitesse")

  -- Tools --
end)