
BT.Tree = {
  ["type"] = "Selector",
  ["children"] = {
    {
      ["type"] = "Tree",
      ["name"] = "ChaseEnemy"
    },
    {
      ["type"] = "Tree",
      ["name"] = "Patrol"
    },
    {
      ["type"] = "Leaf",
      ["description"] = "On idle",
      ["run"] = function(nextbot, data)
        nextbot:OnIdle()
        return true
      end
    }
  }
}
