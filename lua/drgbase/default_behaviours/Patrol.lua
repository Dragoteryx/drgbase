
BT.Tree = {
  ["type"] = "Sequence",
  ["children"] = {
    {
      ["type"] = "Leaf",
      ["description"] = "Has patrol positions?",
      ["run"] = function(nextbot, data)
        return isvector(nextbot:GetPatrolPos(1))
      end
    },
    {
      ["type"] = "RepeatUntil",
      ["child"] = {
        ["type"] = "Sequence",
        ["children"] = {
          {
            ["type"] = "Leaf",
            ["description"] = "Fetch next patrol pos",
            ["run"] = function(nextbot, data)
              data.pos = nextbot:GetPatrolPos(1)
              return isvector(data.pos)
            end
          },
          {
            ["type"] = "Leaf",
            ["description"] = "Is patrolling",
            ["run"] = function(nextbot, data)
              nextbot:SetNW2Bool("DrGBasePatrol", true)
              return true
            end
          },
          {
            ["type"] = "Selector",
            ["children"] = {
              {
                ["type"] = "Sequence",
                ["children"] = {
                  {
                    ["type"] = "Tree",
                    ["name"] = "MoveToPosition",
                    ["args"] = {
                      ["call"] = function(nextbot, data)
                        return nextbot:WhilePatrolling(data.pos)
                      end
                    }
                  },
                  {
                    ["type"] = "Leaf",
                    ["description"] = "Reached patrol pos",
                    ["run"] = function(nextbot, data)
                      nextbot:RemovePatrolPos(1)
                      nextbot:OnReachedPatrol(data.pos)
                      return true
                    end
                  }
                }
              },
              {
                ["type"] = "Leaf",
                ["description"] = "Patrol pos unreachable",
                ["run"] = function(nextbot, data)
                  nextbot:RemovePatrolPos(1)
                  nextbot:OnPatrolUnreachable(data.pos)
                  return true
                end
              }
            }
          }
        }
      }
    },
    {
      ["type"] = "Leaf",
      ["description"] = "Is not patrolling",
      ["run"] = function(nextbot, data)
        nextbot:SetNW2Bool("DrGBasePatrol", false)
        return true
      end
    }
  }
}
