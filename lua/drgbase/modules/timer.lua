
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
    if callback(unpacked) == false then return end
    timer.DrG_Loop(delay, callback, unpacked)
  end)
end
