DrGBase.Utils = DrGBase.Utils or {}

function DrGBase.Utils.RunTraces(starts, ends, data, callback)
  for i, start in ipairs(starts) do
    for h, endpos in ipairs(ends) do
      data.start = start
      data.endpos = endpos
      local tr = util.TraceLine(data)
      local res = callback(tr, data)
      if res ~= nil then return {
        data = data,
        tr = tr,
        res = res,
        startKey = i,
        endposKey = h
      } end
    end
  end
  return {
    data = {},
    tr = {},
    res = nil,
    startKey = -1,
    endposKey = -1
  }
end

function DrGBase.Utils.PackTable(...)
  return {n = select("#", ...); ...}
end

function DrGBase.Utils.RandomPos(pos, maxradius, minradius, nodegraph)
  minradius = minradius or 0
  if nodegraph or CLIENT then
    local node = DrGBase.Nodegraph.RandomNode(pos, maxradius, minradius)
    if node ~= nil then return node:GetPos() end
  elseif navmesh.IsLoaded() then
    local point = nil
    while point == nil do
      local x = math.random(minradius, maxradius)
      local y = math.random(minradius, maxradius)
      if math.random(2) == 2 then x = x*-1 end
      if math.random(2) == 2 then y = y*-1 end
      local area = navmesh.GetNearestNavArea(pos + Vector(x, y, 0))
      if area ~= nil then point = area:GetRandomPoint() end
    end
    return point
  end
end

local realisticSounds = {}
hook.Add("Think", "DrGBaseRealisticSoundsThink", function()
  for i, co in ipairs(realisticSounds) do
    if coroutine.status(co) == "dead" then
      table.RemoveByValue(realisticSounds, co)
    else coroutine.resume(co) end
  end
end)

function DrGBase.Utils.EmitSound(soundname, pos, options, callback)
  if soundname == nil or pos == nil then return end
  options = options or {}
  if options.radius == nil then options.radius = 999999999 end
  if options.volume == nil then options.volume = 1 end
  if options.pitch == nil then options.pitch = 100 end
  if options.channel == nil then options.channel = CHAN_AUTO end
  if pos.EmitSound ~= nil then
    pos:EmitSound(soundname, 75, options.pitch, 0, options.channel)
    pos = pos:GetPos()
  end
  if callback == nil then callback = function() end end
  local co = coroutine.create(function()
    local now = CurTime()
    local reached = {}
    local soundDistance = 0
    while soundDistance <= options.radius do
      local players = {}
      if SERVER then entities = ents.GetAll()
      else entities = {LocalPlayer()} end
      soundDistance = (340/0.01905)*(CurTime()-now)
      local soundDistsqr = math.pow(soundDistance, 2)
      for i, ent in ipairs(entities) do
        if reached[ent:EntIndex()] then continue end
        local distsqr = ent:GetPos():DistToSqr(pos)
        if soundDistsqr >= distsqr then
          local distance = math.sqrt(distsqr)
          reached[ent:EntIndex()] = true
          local res = callback(ent, distance, CurTime()-now)
          if (res == nil or res) and ent:IsPlayer() then
            if SERVER then
              net.Start("DrGBaseUtilsEmitSound")
              net.WriteString(soundname)
              net.WriteFloat(options.volume*-(distance/options.radius)+1)
              net.WriteFloat(options.pitch)
              net.Send(ent)
            else sound.Play(soundname, LocalPlayer():GetPos(), 75, options.pitch, options.volume) end
          end
        end
      end
      coroutine.yield()
    end
  end)
  table.insert(realisticSounds, co)
end

if SERVER then
  util.AddNetworkString("DrGBaseUtilsEmitSound")

  function DrGBase.Utils.Explosion(pos, options)
    if options == nil then options = {} end
    if type(options) == "number" then options = {magnitude = options} end
    options.damage = options.damage or 0
    local explosion = ents.Create("env_explosion")
  	if options.owner ~= nil then explosion:SetOwner(options.owner) end
    explosion:SetPos(pos)
  	explosion:Spawn()
    explosion:SetKeyValue("iMagnitude", options.damage)
  	if options.radius ~= nil then explosion:SetKeyValue("iRadiusOverride", options.radius) end
  	explosion:Fire("Explode", 0, 0)
  end

else

  net.Receive("DrGBaseUtilsEmitSound", function()
    local soundname = net.ReadString()
    local volume = net.ReadFloat()
    local pitch = net.ReadFloat()
    sound.Play(soundname, LocalPlayer():GetPos(), 75, pitch, volume)
  end)

end
