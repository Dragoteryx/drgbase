local INCR_ID = 0
local COROUTINES = {}
hook.Add("Think", "DrGBaseCoroutines", function()
  for id, todo in pairs(COROUTINES) do
    local status = coroutine.status(todo.co)
    if status == "suspended" then
			local ok, args = coroutine.resume(todo.co)
      if coroutine.status(todo.co) == "dead" and
      isfunction(todo.call) then
        todo.call(ok, args)
      end
		elseif status == "dead" then
			coroutine.DrG_Remove(id)
		end
  end
end)

function coroutine.DrG_Create(todo, call)
  local co = coroutine.create(todo)
  local id = INCR_ID
  INCR_ID = INCR_ID+1
  COROUTINES[id] = {
    co = co, call = call
  }
  return co, id
end
function coroutine.DrG_Remove(id)
  COROUTINES[id] = nil
end