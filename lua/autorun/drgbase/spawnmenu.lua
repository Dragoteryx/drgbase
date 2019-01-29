if SERVER then return end

local defaultIcon = "drgbase/icon16.png"
local hookName = "PopulateDrGBaseSpawnmenuHook"
hook.Add(hookName, "AddDrGBaseNextbots", function(pnlContent, tree, node)
	local list = list.Get("DrGBaseNextbot")
	local categories = {}
	for class, ent in pairs(list) do
		local category = ent.Category or "Other"
		local tab = categories[category] or {}
		tab[class] = ent
		categories[category] = tab
	end
	local nextbotsTree = tree:AddNode("Nextbots", "icon16/monkey.png")
	for categoryName, category in SortedPairs(categories) do
		local icon = "icon16/monkey.png"
		if categoryName == "DrGBase" then icon = defaultIcon end
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

--[[hook.Add(hookName, "AddDrGBaseWeapons", function(pnlContent, tree, node)
	local list = list.Get("DrGBaseWeapons")
	local categories = {}
	for class, ent in pairs(list) do
		local category = ent.Category or "Other"
		local tab = categories[category] or {}
		tab[class] = ent
		categories[category] = tab
	end
	local weaponsTree = tree:AddNode("Weapons", "icon16/gun.png")
	for categoryName, category in SortedPairs(categories) do
		local icon = "icon16/gun.png"
		if categoryName == "DrGBase" then icon = defaultIcon end
		local node = weaponsTree:AddNode(categoryName, icon)
		node.DoPopulate = function(self)
			if self.PropPanel then return end
			self.PropPanel = vgui.Create("ContentContainer", pnlContent)
			self.PropPanel:SetVisible(false)
			self.PropPanel:SetTriggerSpawnlistChange(false)
			for class, ent in SortedPairsByMemberValue(category, "Name") do
				spawnmenu.CreateContentIcon("weapon", self.PropPanel, {
					nicename	= ent.PrintName or class,
					spawnname	= class,
					material	= "entities/"..class..".png",
					admin	= ent.AdminOnly
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
end)]]

spawnmenu.AddCreationTab("DrGBase", function()
  local ctrl = vgui.Create("SpawnmenuContentPanel")
  ctrl:EnableSearch("drgbase", hookName)
  ctrl:CallPopulateHook(hookName)
  return ctrl
end, defaultIcon, 75, "Every addon made using DrGBase.")

search.AddProvider(function(str)
	str = str:PatternSafe()
	local results = {}
	for class, ent in pairs(list.Get("DrGBaseNextbot")) do
		if string.find(string.lower(ent.Name), string.lower(str)) ~= nil or
		string.find(string.lower(class), string.lower(str)) ~= nil then
			table.insert(results, {
				text = ent.Name or class,
				icon = spawnmenu.CreateContentIcon("npc", nil, {
					nicename = ent.Name or class,
					spawnname = class,
					material = "entities/"..class..".png",
					admin = ent.AdminOnly
				}),
				words = {ent}
			})
		end
		if #results >= 128 then break end
	end
	table.SortByMember(results, "text", true)
	return results
end, "drgbase")

--[[

spawnmenu.AddContentType( "npc", function( container, obj )

	if ( !obj.material ) then return end
	if ( !obj.nicename ) then return end
	if ( !obj.spawnname ) then return end

	if ( !obj.weapon ) then obj.weapon = { "" } end

	local icon = vgui.Create( "ContentIcon", container )
	icon:SetContentType( "npc" )
	icon:SetSpawnName( obj.spawnname )
	icon:SetName( obj.nicename )
	icon:SetMaterial( obj.material )
	icon:SetAdminOnly( obj.admin )
	icon:SetNPCWeapon( obj.weapon )
	icon:SetColor( Color( 244, 164, 96, 255 ) )

	icon.DoClick = function()

		local weapon = table.Random( obj.weapon )
		if ( gmod_npcweapon:GetString() != "" ) then weapon = gmod_npcweapon:GetString() end

		RunConsoleCommand( "gmod_spawnnpc", obj.spawnname, weapon )
		surface.PlaySound( "ui/buttonclickrelease.wav" )
	end

	icon.OpenMenu = function( icon )

		local menu = DermaMenu()

			local weapon = table.Random( obj.weapon )
			if ( gmod_npcweapon:GetString() != "" ) then weapon = gmod_npcweapon:GetString() end

			menu:AddOption( "Copy to Clipboard", function() SetClipboardText( obj.spawnname ) end )
			menu:AddOption( "Spawn Using Toolgun", function() RunConsoleCommand( "gmod_tool", "creator" ) RunConsoleCommand( "creator_type", "2" ) RunConsoleCommand( "creator_name", obj.spawnname ) RunConsoleCommand( "creator_arg", weapon ) end )
			menu:AddSpacer()
			menu:AddOption( "Delete", function() icon:Remove() hook.Run( "SpawnlistContentChanged", icon ) end )
		menu:Open()

	end

	if ( IsValid( container ) ) then
		container:Add( icon )
	end

	return icon

end )

]]
