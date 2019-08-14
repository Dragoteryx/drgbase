
function table.DrG_ReadOnly(tbl)
  local readOnly = {}
  setmetatable(readOnly, {
    __index = tbl,
    __newindex = function() end
  })
  return readOnly
end

local default_key = {}
local default_mt = {__index = function(tbl) return tbl[default_key] end}
function table.DrG_Default(tbl, default)
  tbl[default_key] = default
  setmetatable(tbl, default_mt)
  return tbl
end

function table.DrG_Pack(...)
  return {...}, select("#", ...)
end

function table.DrG_Unpack(tbl, size, i)
  if not isnumber(i) then i = 1 end
  if i < size then
    return tbl[i], table.DrG_Unpack(tbl, size, i+1)
  elseif i == size then return tbl[i] end
end

function table.DrG_Fetch(tbl, callback)
  local fetched = nil
  local fetchedKey = nil
  for key, val in pairs(tbl) do
    if fetched == nil or
    callback(val, fetched, key, fetchedKey) then
      fetched = val
      fetchedKey = key
    end
  end
  return fetched, fetchedKey
end

function table.DrG_Invert(tbl)
  local inverted = {}
  for key, val in pairs(tbl) do
    inverted[val] = key
  end
  return inverted
end

function table.DrG_Copy(tbl, copied)
  copied = copied or {}
  local copy = {}
  for key, val in pairs(tbl) do
    if istable(val) and not istable(getmetatable(val)) then
      copy[key] = copied[val] or table.DrG_Copy(val, copied)
      copied[val] = copy[key]
    else copy[key] = val end
  end
  return copy
end
