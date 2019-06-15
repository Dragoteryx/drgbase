if SERVER then return end

function DrGBase.GetIcon(name)
  return list.Get("DrGBaseIcons")[name]
end
function DrGBase.SetIcon(name, icon)
  list.Set("DrGBaseIcons", name, icon)
end
DrGBase.SetIcon("DrGBase", DrGBase.Icon)

spawnmenu.AddCreationTab("DrGBase", function()
  local ctrl = vgui.Create("SpawnmenuContentPanel")
  ctrl:EnableSearch("drgbase", "PopulateDrGBaseSpawnmenu")
  ctrl:CallPopulateHook("PopulateDrGBaseSpawnmenu")
  return ctrl
end, DrGBase.Icon, 75, "Every addon made using DrGBase.")

search.AddProvider(function(str)
	str = str:PatternSafe()
	local results = {}
	for class, ent in pairs(list.Get("DrGBaseNextbots")) do
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
	for class, ent in pairs(list.Get("DrGBaseSpawners")) do
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
