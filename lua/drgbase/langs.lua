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

  DrG_Langs = DrG_Langs or {}

  function DrGBase.CreateLanguage(id)
    if not isstring(id) then return end
    local lang = Language(id, DrG_Langs.en)
    DrG_Langs[id] = lang
    return lang
  end
  function DrGBase.GetLanguage(id)
    if not isstring(id) then return end
    return DrG_Langs[id]
  end
  function DrGBase.GetCurrentLanguage()
    return DrGBase.GetLanguage(GmodLanguage:GetString())
  end

  function DrGBase.GetOrCreateLanguage(id)
    return DrGBase.GetLanguage(id)
    or DrGBase.CreateLanguage(id)
  end

  function DrGBase.GetText(placeholder, ...)
    return DrGBase.GetCurrentLanguage():Get(placeholder, ...)
  end

  function DrGBase.LanguageIterator()
    return pairs(DrG_Langs)
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
    AddTranslation(DrGBase.GetCurrentLanguage())
  end

  -- (Re)load languages --

  local function LoadLanguages()
    DrG_Langs = {en = Language("en")}
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