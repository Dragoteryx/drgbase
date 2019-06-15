
-- Registry --

function DrGBase.AddNextbot(ENT)
  local class = string.Replace(ENT.Folder, "entities/", "")
  if ENT.PrintName == nil or ENT.Category == nil then return false end
  for i, model in ipairs(ENT.Models or {}) do
    if not isstring(model) then continue end
    util.PrecacheModel(model)
  end
  for i, sounds in ipairs({
    ENT.OnSpawnSounds,
    ENT.OnIdleSounds,
    ENT.OnAttackSounds,
    ENT.OnHitSounds,
    ENT.OnMissSounds,
    ENT.OnDamageSounds,
    ENT.OnDeathSounds
  }) do
    if not istable(sounds) then continue end
    for h, soundName in ipairs(sounds) do
      if not isstring(soundName) then continue end
      util.PrecacheSound(soundName)
    end
  end
  if CLIENT then
    language.Add(class, ENT.PrintName)
    ENT.Killicon = ENT.Killicon or {
      icon = "HUD/killicons/default",
      color = Color(255, 80, 0, 255)
    }
    killicon.Add(class, ENT.Killicon.icon, ENT.Killicon.color)
  else resource.AddFile("materials/entities/"..class..".png") end
  local nextbot = {
    Name = ENT.PrintName,
    Class = class,
    Category = ENT.Category
  }
  if ENT.Spawnable ~= false then
    list.Set("NPC", class, nextbot)
    list.Set("DrGBaseNextbots", class, nextbot)
  end
  DrGBase.Print("Nextbot '"..class.."': loaded.")
  return true
end

hook.Add("PopulateDrGBaseSpawnmenu", "AddDrGBaseNextbots", function(pnlContent, tree, node)
	local list = list.Get("DrGBaseNextbots")
	local categories = {}
	for class, ent in pairs(list) do
		local category = ent.Category or "Other"
		local tab = categories[category] or {}
		tab[class] = ent
		categories[category] = tab
	end
	local nextbotsTree = tree:AddNode("Nextbots", "icon16/monkey.png")
	for categoryName, category in SortedPairs(categories) do
		local icon = DrGBase.GetIcon(categoryName) or "icon16/monkey.png"
		if categoryName == "DrGBase" then icon = DrGBase.Icon end
		local node = nextbotsTree:AddNode(categoryName, icon)
		node.DoPopulate = function(self)
			if self.PropPanel then return end
			self.PropPanel = vgui.Create("ContentContainer", pnlContent)
			self.PropPanel:SetVisible(false)
			self.PropPanel:SetTriggerSpawnlistChange(false)
			for class, ent in SortedPairsByMemberValue(category, "Name") do
				spawnmenu.CreateContentIcon("npc", self.PropPanel, {
					nicename	= ent.Name or class,
					spawnname	= class,
					material = "entities/"..class..".png",
					admin	= ent.AdminOnly or false
				})
			end
		end
		node.DoClick = function(self)
			self:DoPopulate()
			pnlContent:SwitchPanel(self.PropPanel)
		end
	end
	local firstNode = tree:Root():GetChildNode(0)
	if IsValid(firstNode) then
		firstNode:InternalDoClick()
	end
end)

-- Misc --

DrGBase._SpawnedNextbots = DrGBase._SpawnedNextbots or {}
function DrGBase.GetNextbots()
  return DrGBase._SpawnedNextbots
end
