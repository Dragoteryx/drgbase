
function EFFECT:Init(data)
  local ent = data:GetEntity()
  if not IsValid(ent) then return end
  for i = 1, ent:GetBoneCount() do
    if not IsValid(bone) then continue end
    local pos, angles = ent:GetBonePosition(ent:TranslatePhysBoneToBone(i-1))
    ParticleEffect("blood_impact_red_01_goop", pos, angles, ent)
  end
end

function EFFECT:Think() return false end
function EFFECT:Render() end
