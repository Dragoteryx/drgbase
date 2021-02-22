if CLIENT then

  local GmodLanguage = GetConVar("gmod_language")

  -- Lang class --

  local Language = DrGBase.CreateClass()

  function Language:new(id, parent)
    self.Name = tostring(id)
    self.Parent = parent
    self.Data = {}
    function self:GetID()
      return tostring(id)
    end
    function self:IsCurrent()
      return self:GetID() == GmodLanguage:GetString()
    end
  end

  function Language.prototype:Set(placeholder, translation)
    self.Data[placeholder:TrimLeft("#")] = translation
    return self
  end
  function Language.prototype:Get(placeholder, ...)
    local translation = self.Data[placeholder:TrimLeft("#")]
    if translation then
      if isfunction(translation) then translation = translation(...) end
      return tostring(translation)
    elseif self.Parent then
      return self.Parent:Get(placeholder, ...)
    end
  end

  function Language.prototype:UpdateLanguage()
    if self:IsCurrent() then DrGBase.UpdateLanguage() end
  end

  function Language.prototype:tostring()
    return "Language("..self.Name..")"
  end

  -- Functions --

  local LANGS = {en = Language("en")}

  function DrGBase.GetLanguage(lang)
    if not isstring(lang) then lang = GmodLanguage:GetString() end
    if not LANGS[lang] then LANGS[lang] = Language(lang, LANGS.en) end
    return LANGS[lang]
  end

  function DrGBase.GetText(placeholder, ...)
    return DrGBase.GetLanguage():Get(placeholder, ...)
  end

  -- Update lang --

  local function UpdateLanguage(lang)
    if lang.Parent then UpdateLanguage(lang.Parent) end
    for placeholder, translation in pairs(lang.Data) do
      if not isstring(translation) then continue end
      language.Add(placeholder, translation)
    end
  end

  function DrGBase.UpdateLanguage()
    UpdateLanguage(DrGBase.GetLanguage())
  end

  cvars.AddChangeCallback("gmod_language", DrGBase.UpdateLanguage, "DrG/LanguageChange")

end

-- Import languages --

DrGBase.IncludeFolder("drgbase/cl_langs")
if CLIENT then
  hook.Run("DrG/SetupLanguages")
  DrGBase.UpdateLanguage()
end