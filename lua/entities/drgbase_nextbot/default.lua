
--[[ENT.Name = "Default Name"
ENT.Class = "npc_default_class"
ENT.Category = "DrGBase"]]

-- Misc --
ENT.Models = {"models/Kleiner.mdl"}
ENT.Skins = {0}
ENT.ModelScale = 1
ENT.RagdollOnDeath = true
ENT.EnableBodyMoveXY = false
ENT.AmbientSounds = {}

-- Stats --
ENT.MaxHealth = 100
ENT.HealthRegen = 0
ENT.Radius = 10000
ENT.Omniscient = false
ENT.ForgetTime = 10
ENT.Flight = false
ENT.FlightMaxPitch = 45
ENT.FlightMinPitch = 45

-- Relationships --
ENT.Factions = {}
ENT.AlliedWithSelfFactions = true
ENT.KnowAlliesPosition = false
ENT.Frightening = false
ENT.EnemyReach = 250
ENT.KeepDistance = 0
ENT.AvoidRadius = 250
ENT.AllyReach = 250

-- Detection --
ENT.SightFOV = 150
ENT.SightRange = 6000
ENT.EyeBone = ""
ENT.EyeOffset = Vector(0, 0, 0)
ENT.HearingRange = 250
ENT.HearingRangeBullets = 5000

-- Possession --
ENT.PossessionEnabled = false
ENT.Possession = {
  distance = 100,
  offset = Vector(0, 0, 20),
  binds = {}
}
