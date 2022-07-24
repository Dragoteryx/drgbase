if not DrGBase then return end -- return if DrGBase isn't installed
ENT.Base = "drgbase_nextbot" -- DO NOT TOUCH (obviously)

-- Misc --
ENT.PrintName = "Zombie"
ENT.Category = "DrGBase"
ENT.Models = {"models/Zombie/Classic.mdl"}
ENT.BloodColor = BLOOD_COLOR_GREEN

-- Sounds --
ENT.OnDamageSounds = {"Zombie.Pain"}
ENT.OnDeathSounds = {"Zombie.Die"}

-- Stats --
ENT.SpawnHealth = 100

-- AI --
ENT.RangeAttackRange = 0
ENT.MeleeAttackRange = 30
ENT.ReachEnemyRange = 30
ENT.AvoidEnemyRange = 0

-- Relationships --
ENT.Factions = {FACTION_ZOMBIES}

-- Movements/animations --
ENT.UseWalkframes = true
ENT.RunAnimation = ACT_WALK

-- Detection --
ENT.EyeBone = "ValveBiped.Bip01_Spine4"
ENT.EyeOffset = Vector(7.5, 0, 5)

-- Possession --
ENT.PossessionEnabled = true
ENT.PossessionMovement = POSSESSION_MOVE_8DIR
ENT.PossessionViews = {
	{
		offset = Vector(0, 30, 20),
		distance = 100
	},
	{
		offset = Vector(7.5, 0, 0),
		distance = 0,
		eyepos = true
	}
}
ENT.PossessionBinds = {
	[IN_ATTACK] = {{
		coroutine = true,
		onkeydown = function(self)
			self:EmitSound("Zombie.Attack")
			self:PlayActivityAndMove(ACT_MELEE_ATTACK1, 1, self.PossessionFaceForward)
		end
	}}
}

if SERVER then

	-- Init/Think --

	function ENT:CustomInitialize()
		self:SetDefaultRelationship(D_HT)
		self:SetBodygroup(1, 1)
	end

	-- AI --

	function ENT:OnMeleeAttack(enemy)
		self:EmitSound("Zombie.Attack")
		self:PlayActivityAndMove(ACT_MELEE_ATTACK1, 1, self.FaceEnemy)
	end

	function ENT:OnReachedPatrol()
		self:Wait(math.random(3, 7))
	end
	function ENT:OnIdle()
		self:AddPatrolPos(self:RandomPos(1500))
	end

	-- Damage --

	function ENT:OnDeath(dmg, delay, hitgroup)
		if hitgroup ~= HITGROUP_HEAD then
			self:SetBodygroup(1, 0)
			local headcrab = ents.Create("npc_drg_headcrab")
			if not IsValid(headcrab) then return end
			headcrab:SetPos(self:EyePos())
			headcrab:SetAngles(self:GetAngles())
			headcrab:Spawn()
			if IsValid(self:GetCreator()) then
				self:GetCreator():DrG_AddUndo(headcrab, "NPC", "Undone Headcrab")
			end
		end
	end

	-- Animations/Sounds --

	function ENT:OnNewEnemy()
		self:EmitSound("Zombie.Alert")
	end

	function ENT:OnAnimEvent()
		if self:IsAttacking() and self:GetCycle() > 0.3 then
			self:Attack({
				damage = 10,
				type = DMG_SLASH,
				viewpunch = Angle(20, math.random(-10, 10), 0)
			}, function(self, hit)
				if #hit > 0 then
					self:EmitSound("Zombie.AttackHit")
				else self:EmitSound("Zombie.AttackMiss") end
			end)
		elseif math.random(2) == 1 then
			self:EmitSound("Zombie.FootstepLeft")
		else self:EmitSound("Zombie.FootstepRight") end
	end

end

-- DO NOT TOUCH --
AddCSLuaFile()
DrGBase.AddNextbot(ENT)
