return function(ENT)

  -- Initialize --

  if isfunction(ENT.Initialize) then
    local old_Initialize = ENT.Initialize
    function ENT:Initialize(...)
      if isfunction(self._DrGBaseInitialize) then
        self:_DrGBaseInitialize(...)
      end
      local res = old_Initialize(self, ...)
      if isfunction(self._DrGBaseInitialize) then
        self._DrGBaseThinkFunctions = {}
        self._DrGBaseThinkFunctionsDelays = {}
        for name, value in pairs(self:GetTable()) do
          if not isstring(k) then continue end
          if string.StartWith(k, "_DrGBaseInit_") then
            value(self)
          elseif string.StartWith(k, "_DrGBaseThink_") then
            table.insert(self._DrGBaseThinkFunctions, name)
          end
        end
      end
      return res
    end
  end

  -- Think --

  if isfunction(ENT.Think) then
    local old_Think = ENT.Think
    function ENT:Think(...)
      local res = old_Think(self, ...)
      if isfunction(self._DrGBaseThink) then
        self:_DrGBaseThink(...)
      end
      if istable(self._DrGBaseThinkFunctions) then
        for _, name in ipairs(self._DrGBaseThinkFunctions) do
          local think = self[name]
          if not isfunction(think) then continue end
          local wait = self._DrGBaseThinkFunctionsDelays[name]
          if wait and CurTime() < wait then continue end
          local delay = think(self)
          if isnumber(delay) and delay > 0 then
            self._DrGBaseThinkFunctionsDelays[name] = CurTime() + delay
          else self._DrGBaseThinkFunctionsDelays[name] = nil end
        end
      end
      return res
    end
  end

end