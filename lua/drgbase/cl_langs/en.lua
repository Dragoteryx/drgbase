local english = DrGBase.GetLang("en")
english:Set("drgbase.hello", "Hi!")

-- Possession --

english:Set("drgbase.possession.allowed", function(nb) return "You are now possessing "..nb end)
english:Set("drgbase.possession.denied.notplayer", "Are you not a player?")
english:Set("drgbase.possession.denied.dead", "You can't possess nextbots if you are dead")
english:Set("drgbase.possession.denied.invehicle", "You can't possess nextbots while in a vehicle")