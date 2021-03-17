hook.Add("DrG/LoadLanguages", "DrG/FrenchLanguage", function()
  local lang = DrGBase.GetOrCreateLanguage("fr")
  lang.Flag = "flags16/fr.png"
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

  lang:Set("drgbase.spawnmenu.main", "Menu principal")

  lang:Set("drgbase.spawnmenu.main.info", "Informations")

  lang:Set("drgbase.spawnmenu.main.server", "Paramètres serveur")

  lang:Set("drgbase.spawnmenu.main.client", "Paramètres client")
  lang:Set("drgbase.spawnmenu.main.client.language", "Langue")
  lang:Set("drgbase.spawnmenu.main.client.language.text", "Définir la langue utilisée, cela recharge automatiquement le spawnmenu.")
  lang:Set("drgbase.spawnmenu.main.client.language.missing_translations", function(nb) return "(traductions manquantes: "..nb..")" end)

  lang:Set("drgbase.spawnmenu.nextbots", "Nextbots")

  lang:Set("drgbase.spawnmenu.nextbots.ai", "Paramètres IA")
  lang:Set("drgbase.spawnmenu.nextbots.ai.behaviour", "Comportement")
  lang:Set("drgbase.spawnmenu.nextbots.ai.behaviour.ai_disabled", "Désactiver l'IA")
  lang:Set("drgbase.spawnmenu.nextbots.ai.behaviour.ignore_players", "Ignorer les joueurs")
  lang:Set("drgbase.spawnmenu.nextbots.ai.behaviour.ignore_npcs", "Ignorer les PNJs")
  lang:Set("drgbase.spawnmenu.nextbots.ai.behaviour.ignore_others", "Ignorer les autres entités")
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
  lang:Set("drgbase.spawnmenu.nextbots.possession.client.player_stats", "Remplacer les stats du joueur")
  lang:Set("drgbase.spawnmenu.nextbots.possession.client.player_stats.text",
    "Force les HUDs à afficher les stats du nextbot plutôt que celles du joueur pendant la possession. N'a aucun effet sur le HUD vanilla.")

  lang:Set("drgbase.spawnmenu.nextbots.misc", "Divers")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats", "Stats")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.health", "Multiplicateur de santé")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.player_damage", "Multiplicateur de dégâts aux joueurs")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.npc_damage", "Multiplicateur de dégâts aux PNJs")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.other_damage", "Multiplicateur de dégâts aux autres entités")
  lang:Set("drgbase.spawnmenu.nextbots.misc.stats.speed", "Multiplicateur de vitesse")
  lang:Set("drgbase.spawnmenu.nextbots.misc.ragdolls", "Corps")
  lang:Set("drgbase.spawnmenu.nextbots.misc.ragdolls.remove", "Retirer les corps")
  lang:Set("drgbase.spawnmenu.nextbots.misc.ragdolls.fadeout", "Durée de la disparition")
  lang:Set("drgbase.spawnmenu.nextbots.misc.ragdolls.disable_collisions", "Désactiver les collisions")

  -- Tools --

end)