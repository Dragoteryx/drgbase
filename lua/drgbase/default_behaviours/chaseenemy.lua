
local function HasEnemyOrRefresh(nextbot, data)
  if nextbot:HasEnemy() then return true end
  return IsValid(nextbot:RefreshEnemy())
end

BT.Tree = {
  ["type"] = "Sequence",
  ["children"] = {
    {
      ["type"] = "Leaf",
      ["description"] = "Has enemy?",
      ["run"] = function(nextbot, data)
        return nextbot:HasEnemy()
      end
    },
    {
      ["type"] = "RepeatUntil",
      ["child"] = {
        ["type"] = "Sequence",
        ["children"] = {
          {
            ["type"] = "Leaf",
            ["description"] = "Has enemy?",
            ["run"] = HasEnemyOrRefresh
          },
          {
            ["type"] = "Succeeder",
            ["child"] = {
              ["type"] = "Selector",
              ["children"] = {
                {
                  ["type"] = "Sequence",
                  ["children"] = {
                    {
                      ["type"] = "Leaf",
                      ["description"] = "Enemy too far or not visible?",
                      ["run"] = function(nextbot, data)
                        local enemy = nextbot:GetEnemy()
                        return not nextbot:IsInRange(enemy, nextbot.EnemyTooFar) or not nextbot:VisibleVec(enemy:WorldSpaceCenter())
                      end
                    },
                    {
                      ["type"] = "Leaf",
                      ["description"] = "Move closer to enemy",
                      ["run"] = function(nextbot, data)
                        local res = nextbot:OnChaseEnemy(nextbot:GetEnemy())
                        if res == nil then
                          return nextbot:MoveCloserTo(nextbot:GetEnemy()) ~= "unreachable"
                        else return res end
                      end
                    }
                  }
                },
                {
                  ["type"] = "Sequence",
                  ["children"] = {
                    {
                      ["type"] = "Leaf",
                      ["description"] = "Enemy too close?",
                      ["run"] = function(nextbot, data)
                        return nextbot:IsInRange(nextbot:GetEnemy(), nextbot.EnemyTooClose)
                      end
                    },
                    {
                      ["type"] = "Leaf",
                      ["description"] = "Move away from enemy",
                      ["run"] = function(nextbot, data)
                        local res = nextbot:OnAvoidEnemy(nextbot:GetEnemy())
                        if res == nil then
                          nextbot:MoveAwayFrom(nextbot:GetEnemy(), true)
                          return true
                        else return res end
                      end
                    }
                  }
                }
              }
            }
          },
          {
            ["type"] = "Leaf",
            ["description"] = "Has enemy?",
            ["run"] = HasEnemyOrRefresh
          },
          {
            ["type"] = "Conditional",
            ["description"] = "Is enemy in attack range?",
            ["run"] = function(nextbot, data)
              local enemy = nextbot:GetEnemy()
              return nextbot:IsInRange(enemy, nextbot.AttackRange) and nextbot:VisibleVec(enemy:WorldSpaceCenter())
            end,
            ["success"] = {
              ["type"] = "Leaf",
              ["description"] = "Enemy in attack range",
              ["run"] = function(nextbot, data)
                nextbot:OnAttack(nextbot:GetEnemy())
                return true
              end
            }
          }
        }
      }
    }
  }
}
