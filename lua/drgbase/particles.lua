
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
