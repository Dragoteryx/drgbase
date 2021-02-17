local japanese = DrGBase.GetLang("ja")
japanese:Set("drgbase.hello", "おはよう！")

-- Possession --

japanese:Set("drgbase.possession.allowed", function(nb) return nb.."になった" end)
japanese:Set("drgbase.possession.denied.notplayer", "プレヤーじゃないの？")
--[[japanese:Set("drgbase.possession.denied.dead", "Tu peux ne pas posséder de nextbot en étant mort")
japanese:Set("drgbase.possession.denied.invehicle", "Tu ne peux pas posséder de nextbot depuis un véhicule")]]