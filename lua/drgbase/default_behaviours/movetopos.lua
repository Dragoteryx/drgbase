
local function HasReachedPosition(self, nextbot, pos)
  if navmesh.IsLoaded() then
    pos = navmesh.GetNearestNavArea(pos):GetClosestPointOnArea(pos)
  end
  return nextbot:GetHullRangeSquaredTo(pos) < 20^2
end

BT.Structure = {
  type = "Sequence",
  children = {
    {
      type = "Leaf",
      name = "IsPositionValid?",
      run = function(self, nextbot, pos)
        return isvector(pos)
      end
    },
    {
      type = "RepeatUntil",
      child = {
        type = "Sequence",
        children = {
          {
            type = "Inverter",
            child = {
              type = "Leaf",
              name = "HasReachedPosition?",
              run = HasReachedPosition
            }
          },
          {
            type = "Leaf",
            name = "Move",
            run = function(self, nextbot, pos, callback)
              if isfunction(callback) then
                local res = callback(nextbot, pos)
                if res ~= nil then return res end
              end
              return nextbot:FollowPath(pos) ~= "unreachable"
            end
          }
        }
      }
    },
    {
      type = "Leaf",
      name = "HasReachedPosition?",
      run = HasReachedPosition
    }
  }
}
