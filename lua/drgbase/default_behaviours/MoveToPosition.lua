
local movingHook = BT_ARGS.hook

function BT.ValidPosition()
  return function(self, data)
    return isvector(data.pos)
  end
end

function BT.ReachedPosition()
  return function(self, data)
    return self:GetHullRangeSquaredTo(data.pos) < 20^2
  end
end

function BT.MoveTowardsPosition()
  return function(self, data)
    local res
    if isstring(movingHook) then
      local hook = self[movingHook]
      if isfunction(hook) then res = hook(self, data.pos) end
    end
    if res == nil then
      return self:MoveCloserTo(data.pos) ~= "unreachable"
    else return res end
  end
end
