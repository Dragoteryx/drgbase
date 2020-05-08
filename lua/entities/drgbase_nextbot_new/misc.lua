if SERVER then

  function ENT:Attack(attack, callback)
    if isfunction(callback) then
      self:Timer(isnumber(attack.delay) and attack.delay or 0, function(self)
        local hit = self:Attack(attack)
        callback(self, hit)
      end)
    else
      
    end
  end

end