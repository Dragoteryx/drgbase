
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
            type = "Tree",
            name = "ChaseEnemy"
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
  self:IgnoreEvent("EnemyChange", true)
  self:IgnoreEvent("LastEnemy", true)
end
