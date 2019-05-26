
function BT.HasPatrolPos()
  return function(self, data)
    return isvector(self:GetPatrolPos(1))
  end
end

function BT.FetchPatrolPos()
  return function(self, data)
    data.pos = self:GetPatrolPos(1)
    return isvector(data.pos)
  end
end

function BT.ReachedPatrolPos()
  return function(self, data)
    self:RemovePatrolPos(1)
    return true
  end
end

function BT.PatrolPosUnreachable()
  return function(self, data)
    return true
  end
end
