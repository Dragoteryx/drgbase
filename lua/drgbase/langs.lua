if CLIENT then

  local GmodLanguage = GetConVar("gmod_language")

  -- Language class --

  local Language = DrGBase.CreateClass()

  function Language:new(id, parent)
    self.Name = id
    self.Parent = parent
    self.Data = {}
    function self:GetID()
      return tostring(id)
    end
  end

  function Language.prototype:IsCurrent()
    return self:GetID() == GmodLanguage:GetString()
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

  function Language.prototype:MissingTranslations()
    if self.Parent then
      local missing = self.Parent:MissingTranslations()
      for key in pairs(self.Parent.Data) do
        if self.Data[key] then missing[key] = nil
        else missing[key] = self.Parent end
      end
      return missing
    else return {} end
  end

  function Language.prototype:tostring()
    return "Language("..self.Name..")"
  end

  -- Functions --

  local LANGS

  function DrGBase.CreateLanguage(lang)
    if not LANGS then return false end
    if not isstring(lang) then return false end
    if not LANGS[lang] then
      LANGS[lang] = Language(lang, LANGS.en)
      return true
    else return false end
  end
  function DrGBase.GetLanguage(lang)
    if not LANGS then return end
    if not isstring(lang) then lang = GmodLanguage:GetString() end
    return LANGS[lang]
  end

  function DrGBase.GetOrCreateLanguage(lang)
    if not LANGS then return end
    if not isstring(lang) then return end
    DrGBase.CreateLanguage(lang)
    return LANGS[lang]
  end

  function DrGBase.GetText(placeholder, ...)
    if not LANGS then return end
    return DrGBase.GetLanguage():Get(placeholder, ...)
  end

  function DrGBase.LanguageIterator()
    return pairs(LANGS or {})
  end
  function DrGBase.GetLanguages()
    local langs = {}
    for _, lang in DrGBase.LanguageIterator() do
      table.insert(langs, lang)
    end
    return langs
  end

  -- Add translation --

  local function AddTranslation(lang)
    if lang.Parent then AddTranslation(lang.Parent) end
    for placeholder, translation in pairs(lang.Data) do
      if not isstring(translation) then continue end
      language.Add(placeholder, translation)
    end
  end

  local function AddCurrentTranslation()
    AddTranslation(DrGBase.GetLanguage())
  end

  -- (Re)load languages --

  local function LoadLanguages()
    LANGS = {en = Language("en")}
    hook.Run("DrG/LoadLanguages")
    AddCurrentTranslation()
  end

  hook.Add("PreGamemodeLoaded", "DrG/LoadLanguages", function()
    LoadLanguages()
  end)
  concommand.Add("drgbase_cmd_reload_languages", function()
    LoadLanguages()
  end)
  cvars.AddChangeCallback("gmod_language", function()
    AddCurrentTranslation()
  end, "DrG/LanguageChange")

  function DrGBase.ReloadLanguages()
    LoadLanguages()
  end

end

-- Import languages --

DrGBase.IncludeFolder("drgbase/cl_langs")