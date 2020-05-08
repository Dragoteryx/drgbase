function ENT:HasEnemy()
  return IsValid(self:GetEnemy())
end

function ENT:GetNemesis()
  if self:GetNW2Bool("DrGBaseNemesis") then
    return self:GetEnemy()
  else return NULL end
end
function ENT:HasNemesis()
  return IsValid(self:GetNemesis())
end

if SERVER then

  local function SetEnemy(self, enemy)
    self:SetNW2Bool("DrGBaseNemesis", false)
    self:SetNW2Entity("DrGBaseEnemy", enemy)
  end

  local function UpdateEnemy(self)
    if self:HasNemesis() then return self:GetNemesis() end

  end

  -- Getters/Setters --

  function ENT:GetEnemy()
    local enemy = self:GetNW2Entity("DrGBaseEnemy")
    if IsValid(enemy) then return enemy end
    if not self._DrGBaseHadEnemy then return NULL end
    local newEnemy = UpdateEnemy(self)
    self._DrGBaseHadEnemy = IsValid(newEnemy)
    return newEnemy
  end

  function ENT:SetNemesis(nemesis)
    if IsValid(nemesis) then
      self:SetNW2Bool("DrGBaseNemesis", true)
      self:SetNW2Entity("DrGBaseEnemy", nemesis)
    else
      self:SetNW2Bool("DrGBaseNemesis", false)
      UpdateEnemy()
    end
  end

else

  -- Getters --

  function ENT:GetEnemy()
    return self:GetNW2Entity("DrGBaseEnemy")
  end

end