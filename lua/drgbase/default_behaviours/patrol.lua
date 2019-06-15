
local function HasPatrolPositions(self, nextbot)
  return isvector(nextbot:GetPatrolPos(1))
end

BT.Structure = {
  ["type"] = "Sequence",
  ["children"] = {
    {
      ["type"] = "Leaf",
      ["name"] = "HasPatrolPositions?",
      ["run"] = HasPatrolPositions
    },
    {
      ["type"] = "RepeatUntil",
      ["child"] = {
        ["type"] = "Sequence",
        ["children"] = {
          {
            ["type"] = "Selector",
            ["children"] = {
              {
                ["type"] = "Sequence",
                ["children"] = {
                  {
                    ["type"] = "Tree",
                    ["name"] = "MoveToPos",
                    ["args"] = function(self, nextbot)
                      return nextbot:GetPatrolPos(1),
                      nextbot.WhilePatrolling
                    end
                  },
                  {
                    ["type"] = "Leaf",
                    ["name"] = "OnReachedPatrol",
                    ["run"] = function(self, nextbot)
                      nextbot:OnReachedPatrol(nextbot:GetPatrolPos(1))
                      self:IgnoreEvent("RemovedPatrolPos", true)
                      nextbot:RemovePatrolPos(1)
                      self:IgnoreEvent("RemovedPatrolPos", false)
                      return true
                    end
                  }
                }
              },
              {
                ["type"] = "Leaf",
                ["name"] = "OnPatrolUnreachable",
                ["run"] = function(self, nextbot)
                  nextbot:OnPatrolUnreachable(nextbot:GetPatrolPos(1))
                  self:IgnoreEvent("RemovedPatrolPos", true)
                  nextbot:RemovePatrolPos(1)
                  self:IgnoreEvent("RemovedPatrolPos", false)
                  return true
                end
              }
            }
          },
          {
            ["type"] = "Leaf",
            ["name"] = "HasPatrolPositions?",
            ["run"] = HasPatrolPositions
          }
        }
      }
    }
  }
}
