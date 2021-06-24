DrGBase.AddTool(function(TOOL, GetText, GetToolConVar)
	TOOL.ClientConVar = {
		["value"] = 0,
		["type"] = DMG_GENERIC
	}

	function TOOL.BuildCPanel(panel)
		local type = GetToolConVar("type")
		panel:Help(GetText("desc"))
		panel:NumSlider(GetText("damage"), "drgbase_tool_damage_value", 0, 500, 0)
		local dlist = DrGBase.DListView({GetText("type"), GetText("enabled")})
		function AddDamageType(name, value)
			dlist:AddLine(GetText(name), GetText(bit.band(type:GetInt(), value) ~= 0 and "true" or "false"), value)
		end
		AddDamageType("dmg_crush", DMG_CRUSH)
		AddDamageType("dmg_slash", DMG_SLASH)
		AddDamageType("dmg_blast", DMG_BLAST)
		AddDamageType("dmg_burn", DMG_BURN)
		AddDamageType("dmg_slowburn", DMG_SLOWBURN)
		AddDamageType("dmg_shock", DMG_SHOCK)
		AddDamageType("dmg_plasma", DMG_PLASMA)
		AddDamageType("dmg_dissolve", DMG_DISSOLVE)
		AddDamageType("dmg_sonic", DMG_SONIC)
		AddDamageType("dmg_poison", DMG_POISON)
		AddDamageType("dmg_acid", DMG_ACID)
		AddDamageType("dmg_radiation", DMG_RADIATION)
		AddDamageType("dmg_neurotoxin", DMG_NERVEGAS)
		dlist:SetSize(10, 250)
		dlist:SetMultiSelect(false)
		function dlist:OnRowSelected(_, line)
			if bit.band(type:GetInt(), line:GetValue(3)) ~= 0 then
				line:SetValue(2, GetText("false"))
				type:SetInt(type:GetInt()-line:GetValue(3))
			else
				line:SetValue(2, GetText("true"))
				type:SetInt(type:GetInt()+line:GetValue(3))
			end
		end
		panel:AddItem(dlist)
	end

	function TOOL:LeftClick(tr)
		local ent = tr.Entity
		if IsValid(ent) and SERVER then
			local dmg = DamageInfo()
			dmg:SetDamage(self:GetClientNumber("value"))
			dmg:SetDamageType(self:GetClientNumber("type"))
			dmg:SetAttacker(self:GetOwner())
			dmg:SetInflictor(self:GetOwner():GetActiveWeapon())
			dmg:SetDamageForce(tr.Normal*self:GetClientNumber("value"))
			dmg:SetDamagePosition(tr.HitPos)
			dmg:SetReportedPosition(tr.HitPos)
			ent:DispatchTraceAttack(dmg, tr)
		end
		return true
	end

	function TOOL:Reload()
		local owner = self:GetOwner()
		return self:LeftClick({
			Normal = -owner:EyeAngles():Forward(),
			Entity = owner, HitPos = owner:GetPos()
		})
	end
end)