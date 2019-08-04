
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
            type = "Selector",
            children = {
              {
                type = "Sequence",
                children = {
                  {
                    type = "Leaf",
                    name = "IsEnemyTooClose?",
                    run = function(self, nextbot)
                      local enemy = nextbot:GetEnemy()
                      return nextbot:IsInRange(enemy, nextbot.AvoidAfraidOfRange)
                    end
                  },
                  {
                    type = "Leaf",
                    name = "AvoidEnemy",
                    run = function(self, nextbot)
                      local enemy = nextbot:GetEnemy()
                      local res = nextbot:OnAvoidAfraidOf(enemy)
                      if res ~= nil then return res end
                      local away = nextbot:GetPos()*2 - enemy:GetPos()
                      return nextbot:FollowPath(away) ~= "unreachable"
                    end
                  }
                }
              },
              {
                type = "Leaf",
                name = "WatchEnemy",
                run = function(self, nextbot)
                  local enemy = nextbot:GetEnemy()
                  local res = nextbot:OnWatchAfraidOf(enemy)
                  if res ~= nil then return res end
                  nextbot:FaceEnemy()
                  return true
                end
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

function BT:OnEvent(nextbot, event, old, new)
  if event == "EnemyChange" then
    return nextbot:GetRelationship(new) == D_FR
  end
end
