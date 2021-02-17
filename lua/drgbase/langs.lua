if CLIENT then

  -- Lang class --

  local Lang = DrGBase.CreateClass()

  function Lang:new(name, parent)
    self.Name = tostring(name)
    self.Parent = parent
    self.Data = {}
  end

  function Lang.prototype:Set(id, translated)
    self.Data[id] = translated
    return self
  end
  function Lang.prototype:Get(id, ...)
    local translated = self.Data[id]
    if translated then
      if isfunction(translated) then translated = translated(...) end
      if isstring(translated) then return translated end
    elseif self.Parent then
      return self.Parent:Get(id, ...)
    end
  end

  function Lang.prototype:tostring()
    return "Lang("..self.Name..")"
  end

  -- Functions --

  local LANGS = {en = Lang("en")}

  function DrGBase.GetLang(lang)
    if not isstring(lang) then lang = GetConVar("gmod_language"):GetString() end
    if not LANGS[lang] then LANGS[lang] = Lang(lang, LANGS.en) end
    return LANGS[lang]
  end

  function DrGBase.GetText(id, ...)
    return DrGBase.GetLang():Get(id, ...)
  end

end

-- Import buiilt-in languages --

DrGBase.IncludeFolder("drgbase/cl_langs")