
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
