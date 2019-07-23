
-- Registry --

function DrGBase.AddParticles(pcf, particles)
  if not isstring(pcf) then return end
  game.AddParticles("particles/"..pcf)
  if not istable(particles) then particles = {particles} end
  for i, particle in ipairs(particles) do
    if not isstring(particle) then continue end
    PrecacheParticleSystem(particle)
  end
end

-- Premade particles --

DrGBase.AddParticles("drgbase.pcf", {
  "drg_plasma_ball",
  "drg_smokescreen"
})

-- Vanilla particles --

PrecacheParticleSystem("blood_impact_red_01_goop")
PrecacheParticleSystem("blood_impact_yellow_01")
PrecacheParticleSystem("blood_impact_green_01")
PrecacheParticleSystem("blood_impact_antlion_01")
PrecacheParticleSystem("blood_impact_zombie_01")
PrecacheParticleSystem("blood_impact_antlion_worker_01")
