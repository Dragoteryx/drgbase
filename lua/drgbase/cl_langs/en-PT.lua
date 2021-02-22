hook.Add("DrG/SetupLanguages", "DrG/SetupPirateEnglish", function()
  local lang = DrGBase.GetLanguage("en-PT")
  lang.Name = "Pirate English"

  -- Misc --

  lang:Set("drgbase.hello", "Ahoy!")

  -- Possession --

  lang:Set("drgbase.possession.possess", "Possess")
  lang:Set("drgbase.possession.allowed", function(nb) return "Ye be now possessin' "..nb end)
  lang:Set("drgbase.possession.denied.notplayer", "Are ye nah a player?")
  lang:Set("drgbase.possession.denied.dead", "Ye can nah possess nextbots if ye be dead")
  lang:Set("drgbase.possession.denied.invehicle", "Ye can nah possess nextbots while in a ship")
end)