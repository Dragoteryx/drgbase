
function timer.DrG_Simple(delay, callback, ...)
  local args = table.DrG_Pack(...)
  timer.Simple(delay, function()
    callback(unpack(args))
  end)
end
function timer.DrG_Loop(delay, callback, ...)
  local args = table.DrG_Pack(...)
  timer.Simple(delay, function()
    local unpacked = unpack(args)
    local res = callback(unpacked)
    if res == false then return end
    if isnumber(res) then
      timer.DrG_Loop(math.Clamp(res, 0, math.huge), callback, unpacked)
    else timer.DrG_Loop(delay, callback, unpacked) end
  end)
end
