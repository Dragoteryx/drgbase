
local coroutines = {}
hook.Add("Think", "DrGBaseCoroutines", function()
  for name, co in pairs(coroutines) do
    if co == nil then continue end
    local status = coroutine.status(co)
    if status == "suspended" then
			coroutine.resume(co)
		elseif status == "dead" then
			coroutine.DrG_Remove(name)
		end
  end
end)

function coroutine.DrG_Create(name, callback)
  local co = coroutine.create(callback)
  coroutines[name] = co
  return co
end
function coroutine.DrG_Remove(name)
  coroutines[name] = nil
end
