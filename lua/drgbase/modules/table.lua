-- table utility

function table.DrG_Pack(...)
  return {...}, select("#", ...)
end

function table.DrG_Unpack(tbl, size, i)
  if not isnumber(i) then i = 1 end
  if i < size then
    return tbl[i], table.DrG_Unpack(tbl, size, i+1)
  elseif i == size then return tbl[i] end
end

-- misc

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