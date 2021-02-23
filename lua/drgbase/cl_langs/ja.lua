hook.Add("DrG/LoadLanguages", "DrG/JapaneseLanguage", function()
  local lang = DrGBase.GetOrCreateLanguage("ja")
  lang.Flag = "flags16/jp.png"
  lang.Name = "日本語"

  -- Misc --

  lang:Set("drgbase.hello", "おはよう！")

  -- Possession --

  lang:Set("drgbase.possession.possess", "操る")
  lang:Set("drgbase.possession.allowed", function(nb) return nb.."を操ています" end)
  --[[lang:Set("drgbase.possession.denied.notplayer", "Tu n'es pas un joueur ?")
  lang:Set("drgbase.possession.denied.dead", "Tu peux ne pas posséder de nextbot en étant mort")
  lang:Set("drgbase.possession.denied.invehicle", "Tu ne peux pas posséder de nextbot depuis un véhicule")]]
end)