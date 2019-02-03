
local coroutines = {}
hook.Add("Think", "DrGBaseCoroutines", function()
  for i, co in ipairs(coroutines) do
    local status = coroutine.status(co)
    if status == "suspended" then
			coroutine.resume(co)
		elseif status == "dead" then
			table.RemoveByValue(coroutines, co)
		end
  end
end)

function coroutine.DrG_Create(callback)
  local co = coroutine.create(callback)
  table.insert(coroutines, co)
end
