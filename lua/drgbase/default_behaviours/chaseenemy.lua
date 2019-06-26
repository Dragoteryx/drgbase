
local function HasEnemy(self, nextbot)
  return nextbot:HasEnemy()
end

BT.Structure = {
  type = "Sequence",
  children = {
    {
      type = "Leaf",
      name = "HasEnemy?",
      run = HasEnemy
    },
    {
      type = "RepeatUntil",
      child = {
        type = "Sequence",
        children = {
          {
            type = "Leaf",
            name = "HasEnemy?",
            run = HasEnemy
          },
          {
            type = "Succeeder",
            child = {
              type = "Selector",
              children = {
                {
                  type = "Conditional",
                  name = "IsEnemyTooFar?",
                  run = function(self, nextbot)
                    local enemy = nextbot:GetEnemy()
                    return not nextbot:IsInRange(enemy, nextbot.ReachEnemyRange) or not nextbot:Visible(enemy)
                  end,
                  success = {
                    type = "Leaf",
                    name = "MoveTowardsEnemy",
                    run = function(self, nextbot)
                      local enemy = nextbot:GetEnemy()
                      local res = nextbot:OnChaseEnemy(enemy)
                      if res ~= nil then return res end
                      nextbot:FollowPath(enemy)
                      return true
                    end
                  }
                },
                {
                  type = "Sequence",
                  children = {
                    {
                      type = "Leaf",
                      name = "IsEnemyTooClose?",
                      run = function(self, nextbot)
                        local enemy = nextbot:GetEnemy()
                        return nextbot:IsInRange(enemy, nextbot.AvoidEnemyRange) and nextbot:Visible(enemy)
                      end
                    },
                    {
                      type = "Leaf",
                      name = "EnemyNotInMeleeRange?",
                      run = function(self, nextbot)
                        return not nextbot:IsInRange(nextbot:GetEnemy(), nextbot.MeleeAttackRange)
                      end
                    },
                    {
                      type = "Leaf",
                      name = "AvoidEnemy",
                      run = function(self, nextbot)
                        local enemy = nextbot:GetEnemy()
                        local res = nextbot:OnAvoidEnemy(enemy)
                        if res ~= nil then return res end
                        local away = nextbot:GetPos()*2 - enemy:GetPos()
                        nextbot:FollowPath(away)
                        return true
                      end
                    }
                  }
                }
              }
            }
          },
          {
            type = "Leaf",
            name = "HasEnemy?",
            run = HasEnemy
          },
          {
            type = "Succeeder",
            child = {
              type = "Selector",
              children = {
                {
                  type = "Conditional",
                  name = "IsEnemyInMeleeRange?",
                  run = function(self, nextbot)
                    local enemy = nextbot:GetEnemy()
                    return nextbot:IsInRange(enemy, nextbot.MeleeAttackRange) and nextbot:Visible(enemy)
                  end,
                  success = {
                    type = "Leaf",
                    name = "MeleeAttack",
                    run = function(self, nextbot)
                      local enemy = nextbot:GetEnemy()
                      if nextbot:OnMeleeAttack(enemy) == false then return false
                      else return true end
                    end
                  }
                },
                {
                  type = "Conditional",
                  name = "IsEnemyInRangeAttackRange?",
                  run = function(self, nextbot)
                    local enemy = nextbot:GetEnemy()
                    return nextbot:IsInRange(enemy, nextbot.RangeAttackRange) and nextbot:Visible(enemy)
                  end,
                  success = {
                    type = "Leaf",
                    name = "RangeAttack",
                    run = function(self, nextbot)
                      local enemy = nextbot:GetEnemy()
                      nextbot:OnRangeAttack(enemy)
                      return true
                    end
                  }
                }
              }
            }
          },
          {
            type = "Leaf",
            name = "HasEnemy?",
            run = HasEnemy
          }
        }
      }
    }
  }
}

function BT:OnInit()
  self:IgnoreEvent("EnemyChange", true)
  self:IgnoreEvent("LastEnemy", true)
end
