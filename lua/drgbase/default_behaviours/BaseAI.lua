
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
      ["description"] = "Idle",
      ["run"] = ":OnIdle"
    }
  }
}
