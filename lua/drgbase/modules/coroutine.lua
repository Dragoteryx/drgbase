
local id = 0
local coroutines = {}
hook.Add("Think", "DrGBaseCoroutines", function()
  for id, co in pairs(coroutines) do
    local status = coroutine.status(co)
    if status == "suspended" then
			coroutine.resume(co)
		elseif status == "dead" then
			coroutine.DrG_Remove(id)
		end
  end
end)

function coroutine.DrG_Create(callback, ...)
  local args = table.DrG_Pack(...)
  local co = coroutine.create(function()
    callback(unpack(args))
  end)
  local curr = id
  id = id+1
  coroutines[curr] = co
  return co, curr
end
function coroutine.DrG_Remove(id)
  coroutines[id] = nil
end
