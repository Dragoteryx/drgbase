
local Callback = BT.Args["call"]

local function ReachedPosition(nextbot, data)
  return nextbot:GetHullRangeSquaredTo(data.pos) < 20^2
end

BT.Tree = {
  ["type"] = "Sequence",
  ["children"] = {
    {
      ["type"] = "Leaf",
      ["description"] = "Valid position?",
      ["run"] = function(nextbot, data)
        return isvector(data.pos)
      end
    },
    {
      ["type"] = "RepeatUntil",
      ["child"] = {
        ["type"] = "Sequence",
        ["children"] = {
          {
            ["type"] = "Inverter",
            ["child"] = {
              ["type"] = "Leaf",
              ["description"] = "Has reached position?",
              ["run"] = ReachedPosition
            }
          },
          {
            ["type"] = "Leaf",
            ["description"] = "Move towards the position",
            ["run"] = function(nextbot, data)
              local res
              if isfunction(Callback) then res = Callback(nextbot, data) end
              if res == nil then
                return nextbot:MoveCloserTo(data.pos) ~= "unreachable"
              else return res end
            end
          }
        }
      }
    },
    {
      ["type"] = "Leaf",
      ["description"] = "Has reached position?",
      ["run"] = ReachedPosition
    }
  }
}
