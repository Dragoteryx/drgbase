
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
              return IsValid(nextbot:RefreshEnemy())
            end
          }
        }
      }
    }
  }
}
