if SERVER then


else

  concommand.Add("drgbase_cmd_reset_binds", function()

  end)

  concommand.Add("drgbase_cmd_print_missing_translations", function(_, _, args)
    local lang = DrGBase.GetLanguage(args[1])
    if lang then
      local missing = lang:MissingTranslations()
      local nbMissing = table.Count(missing)
      if nbMissing > 0 then
        local langs = {}
        for key, lang in pairs(missing) do
          if not langs[lang] then langs[lang] = {} end
          table.insert(langs[lang], key)
        end
        for _, missings in pairs(langs) do
          table.sort(missings)
        end
        local str = "The language '"..lang.Name.."' is missing the following translations:"
        for lang, missings in pairs(langs) do
          str = str.."\n  From '"..lang.Name.."' ("..#missings.."): "
          for _, missing in ipairs(missings) do
            str = str.."\n  - "..missing
          end
        end
        DrGBase.Info(str)
      else DrGBase.Info("The language '"..lang.Name.."' isn't missing any translations.") end
    else
      local str = "The language '"..args[1].."' doesn't exist."
      str = str.."\n  List of available languages:"
      for id, lang in DrGBase.LanguageIterator() do
        str = str.."\n  - "..id.." ("..lang.Name..")"
      end
      DrGBase.Error(str)
    end
  end)

  concommand.Add("drbase_command_reload_languages_and_spawnmenu", function()
    RunConsoleCommand("drgbase_cmd_reload_languages")
    RunConsoleCommand("spawnmenu_reload")
  end)

end