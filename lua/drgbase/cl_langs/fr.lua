local french = DrGBase.GetLang("fr")
french.Name = "Français"

-- Misc --

french:Set("drgbase.hello", "Salut !")

-- Possession --

french:Set("drgbase.possession.allowed", function(nb) return "Tu possèdes désormais "..nb end)
french:Set("drgbase.possession.denied.notplayer", "Tu n'es pas un joueur ?")
french:Set("drgbase.possession.denied.dead", "Tu peux ne pas posséder de nextbot en étant mort")
french:Set("drgbase.possession.denied.invehicle", "Tu ne peux pas posséder de nextbot depuis un véhicule")