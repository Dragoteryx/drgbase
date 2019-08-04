
BT.Structure = {
  type = "Sequence",
  children = {
    {
      type = "Leaf",
      name = "HasEnemy?",
      run = function(self, nextbot)
        return nextbot:HasEnemy()
      end
    },
    {
      type = "RepeatUntil",
      child = {
        type = "Sequence",
        children = {
          {
            type = "Selector",
            children = {
              {
                type = "Sequence",
                children = {
                  {
                    type = "Leaf",
                    name = "IsEnemy?",
                    run = function(self, nextbot)
                      return nextbot:IsEnemy(nextbot:GetEnemy())
                    end
                  },
                  {
                    type = "Tree",
                    name = "ChaseEnemy"
                  }
                }
              },
              {
                type = "Sequence",
                children = {
                  {
                    type = "Leaf",
                    name = "IsAfraidOf?",
                    run = function(self, nextbot)
                      return nextbot:IsAfraidOf(nextbot:GetEnemy())
                    end
                  },
                  {
                    type = "Tree",
                    name = "FleeEnemy"
                  }
                }
              }
            }
          },
          {
            type = "Leaf",
            name = "HasEnemy?",
            run = function(self, nextbot)
              return IsValid(nextbot:UpdateEnemy())
            end
          }
        }
      }
    }
  }
}

function BT:OnInit()
  self:IgnoreEvent("LastEnemy", true)
end
