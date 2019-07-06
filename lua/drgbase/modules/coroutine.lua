
local id = 0
local coroutines = {}
hook.Add("Think", "DrGBaseCoroutines", function()
  for id, todo in pairs(coroutines) do
    local status = coroutine.status(todo.cor)
    if status == "suspended" then
			local ok, args = coroutine.resume(todo.cor)
      if coroutine.status(todo.cor) == "dead" then
        if isfunction(todo.call) then todo.call(ok, args) end
      end
		elseif status == "dead" then
			coroutine.DrG_Remove(id)
		end
  end
end)

function coroutine.DrG_Create(todo, call)
  local cor = coroutine.create(todo)
  local curr = id
  id = id+1
  coroutines[curr] = {
    cor = cor, call = call
  }
  return cor, curr
end
function coroutine.DrG_Remove(id)
  coroutines[id] = nil
end
