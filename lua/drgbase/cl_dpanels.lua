function DrGBase.DListView(columns, options)
  if not istable(options) then options = {} end
  local dlist = vgui.Create("DListView")
  for _, column in ipairs(columns) do dlist:AddColumn(column) end
  if isstring(options.convar) then
    local convar = GetConVar(options.convar)
    if convar then
      local AddLine = dlist.AddLine
      local Clear = dlist.Clear
      cvars.AddChangeCallback(options.convar, function(_, old, new)
        if old == new then return end
        new = util.JSONToTable(new)
        Clear(dlist)
        for _, line in ipairs(new) do
          AddLine(dlist, unpack(line))
        end
      end)
      function dlist:AddLine(...)
        local tbl = util.JSONToTable(convar:GetString())
        table.insert(tbl, {...})
        convar:SetString(util.TableToJSON(tbl))
      end
      function dlist:RemoveLine(id)
        local tbl = util.JSONToTable(convar:GetString())
        table.remove(tbl, id)
        convar:SetString(util.TableToJSON(tbl))
      end
      function dlist:Clear()
        convar:SetString("[]")
      end
    end
  end
  return dlist
end