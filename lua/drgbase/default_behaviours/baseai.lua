
BT.Structure = {
  type = "Selector",
  children = {
    {
      type = "Tree",
      name = "HandleEnemy"
    },
    --[[{
      type = "Tree",
      name = "FollowEntity",
      args = function(self, nextbot)
        local ent, dist = nextbot:GetFollowing()
        return ent, dist, nextbot.OnFollowEntity, nextbot.OnReachedEntity
      end
    },]]
    {
      type = "Tree",
      name = "Patrol"
    },
    {
      type = "Leaf",
      name = "OnIdle",
      run = function(self, nextbot)
        nextbot:OnIdle()
        return true
      end
    }
  }
}
