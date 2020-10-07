-- Coroutine extension --

DrG_Coroutines = DrG_Coroutines or {}
hook.Add("Think", "DrGBaseRunCoroutines", function()
  for thread in pairs(DrG_Coroutines) do
    local status = coroutine.status(thread)
    if status == "suspended" then
      coroutine.resume(thread)
		elseif status == "dead" then
      coroutine.DrG_Kill(thread)
    end
  end
end)

function coroutine.DrG_Create(fn)
  local thread = coroutine.create(fn)
  DrG_Coroutines[thread] = true
  return thread
end

function coroutine.DrG_Remove(thread)
  DrG_Coroutines[thread] = nil
end

-- Threads --

DrG_Threads = DrG_Threads or {}

function coroutine.DrG_RunThread(name, fn)
  if DrG_Threads[name] then coroutine.DrG_KillThread(name) end
  DrG_Threads[name] = coroutine.DrG_Create(function()
    fn(name)
  end)
end

function coroutine.DrG_KillThread(name)
  local thread = DrG_Threads[name]
  if not thread then return end
  coroutine.DrG_Remove(thread)
  DrG_Threads[name] = nil
end