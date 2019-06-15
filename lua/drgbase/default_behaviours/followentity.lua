
local function IsEntityValid(self, nextbot, ent)
  return IsValid(ent)
end

BT.Structure = {
  ["type"] = "Sequence",
  ["children"] = {
    {
      ["type"] = "Leaf",
      ["name"] = "IsEntityValid?",
      ["run"] = IsEntityValid
    },
    {
      ["type"] = "RepeatUntil",
      ["child"] = {
        ["type"] = "Sequence",
        ["children"] = {
          {
            ["type"] = "Conditional",
            ["name"] = "HasReachedEntity?",
            ["run"] = function(self, nextbot, ent, dist)
              return nextbot:IsInRange(ent, dist) and nextbot:Visible(ent)
            end,
            ["success"] = {
              ["type"] = "Leaf",
              ["name"] = "ReachedEntity",
              ["run"] = function(self, nextbot, ent, dist, toofar, reached)
                if isfunction(reached) then reached(nextbot, ent) end
                return true
              end
            },
            ["failure"] = {
              ["type"] = "Leaf",
              ["name"] = "EntityTooFar",
              ["run"] = function(self, nextbot, ent, dist, toofar, reached)
                if isfunction(toofar) and toofar(nextbot, ent) then return true end
                nextbot:MoveCloserTo(ent)
                return true
              end
            }
          },
          {
            ["type"] = "Leaf",
            ["name"] = "IsEntityValid?",
            ["run"] = IsEntityValid
          }
        }
      }
    }
  }
}
