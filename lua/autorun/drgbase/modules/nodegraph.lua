nodegraph = nodegraph or {}

local Draw = CreateConVar("drgbase_nodegraph_draw", "0")

local NUM_HULLS = 10

local nodes = {}
local links = {}

local Node = {}
Node.__index = Node
function Node:_New(node)
  setmetatable(node, Node)
  return node
end
function Node:GetID()
  return self._id
end
function Node:GetPos()
  return self._pos
end
function Node:ToNavmesh()
  if CLIENT then return end
  return self:GetNearestNavArea():GetClosestPointOnArea(self:GetPos())
end
function Node:GetType()
  return self._type
end
function Node:GetLink(node)
  return nodegraph.DrG_GetLink(self, node)
end
function Node:Link(node, move)
  return nodegraph.DrG_Link(self, node, move)
end
function Node:Unlink(node)
  return nodegraph.DrG_Unlink(self, node)
end
function Node:LinkedTo(node)
  if node == nil then
    local tab = {}
    for i, link in ipairs(self._links) do
      local node1, node2 = link:GetNodes()
      if node1:GetID() == self:GetID() then
        table.insert(tab, node2)
      else table.insert(tab, node1) end
    end
    return tab
  else
    for i, link in ipairs(self._links) do
      local node1, node2 = link:GetNodes()
      if node1:GetID() == node:GetID() or
      node2:GetID() == node:GetID() then
        return true
      end
    end
    return false
  end
end
function Node:GetNearestNavArea()
  if CLIENT then return end
  return navmesh.GetNearestNavArea(self:GetPos())
end
function Node:Distance(pos)
  if type(pos) ~= "Vector" then pos = pos:GetPos() end
  return self:GetPos():Distance(pos)
end
function Node:DistToSqr(pos)
  if type(pos) ~= "Vector" then pos = pos:GetPos() end
  return self:GetPos():DistToSqr(pos)
end
setmetatable(Node, {__call = Node._New})

function nodegraph.DrG_Clear()
  nodes = {}
  links = {}
  if SERVER then nodegraph.DrG_BroadcastNodegraph() end
end
function nodegraph.DrG_GetNode(id)
  return nodes[id]
end
function nodegraph.DrG_GetNodes(callback)
  if callback == nil then callback = function() return true end end
  local tab = {}
  for i, node in ipairs(nodes) do
    if callback(node) then table.insert(tab, node) end
  end
  return tab
end
function nodegraph.DrG_GetNodesByType(type)
  return nodegraph.DrG_GetNodes(function(node)
    return node:GetType() == type
  end)
end
function nodegraph.DrG_GetNodesNearPos(pos, radius, type)
  radius = math.pow(radius, 2)
  return nodegraph.DrG_GetNodes(function(node)
    if type ~= nil and node:GetType() ~= type then return false end
    return node:DistToSqr(pos) <= radius
  end)
end
function nodegraph.DrG_GetNodesWithinNavArea(area, type)
  if CLIENT then return {} end
  if type(area) == "Vector" then area = navmesh.GetNearestNavArea(area) end
  return nodegraph.DrG_GetNodes(function(node)
    if type ~= nil and node:GetType() ~= type then return false end
    return node:GetNearestNavArea():GetID() == area:GetID()
  end)
end
function nodegraph.DrG_GetClosestNode(pos, type)
  local closest = nil
  local distsqr = math.huge
  local nodes = nodes
  if type ~= nil then nodes = nodegraph.DrG_GetNodesByType(type) end
  for i, node in ipairs(nodes) do
    local distsqr2 = pos:DistToSqr(node:GetPos())
    if distsqr2 < distsqr then
      closest = node
      distsqr = distsqr2
    end
  end
  if closest ~= nil then return closest, pos:Distance(closest:GetPos()) end
end
function nodegraph.DrG_RandomNode(pos, maxradius, minradius)
  minradius = minradius or 0
  minradius = math.pow(minradius, 2)
  maxradius = math.pow(maxradius, 2)
  local nodes = nodegraph.DrG_GetNodes()
  table.sort(nodes, function() return math.random(2) == 2 end)
  for i, node in ipairs(nodes) do
    local distsqr = pos:DistToSqr(node:GetPos())
    if distsqr >= minradius and distsqr <= maxradius then
      return node
    end
  end
end

local Link = {}
Link.__index = Link
function Link:_New(node1, node2, move)
  if move == nil then
    move = {}
    for i = 1, NUM_HULLS do
      move[i] = 1
    end
  end
  local link = {
    _node1 = node1:GetID(),
    _node2 = node2:GetID(),
    _move = move
  }
  setmetatable(link, Link)
  return link
end
function Link:GetNodes()
  return nodegraph.DrG_GetNode(self._node1), nodegraph.DrG_GetNode(self._node2)
end
function Link:GetMove()
  return self._move
end
function Link:Remove()
  local node1, node2 = self:GetNodes()
  node1:Unlink(node2)
end
setmetatable(Link, {__call = Link._New})

function nodegraph.DrG_Link(node1, node2, move)
  if node1:LinkedTo(node2) then return end
  local link = Link(node1, node2, move)
  table.insert(node1._links, link)
  table.insert(node2._links, link)
  table.insert(links, link)
  return link
end
function nodegraph.DrG_Unlink(node1, node2)
  if not node1:LinkedTo(node2) then return false end
  local link = node1:GetLink(node2)
  table.RemoveByValue(node1._links, link)
  table.RemoveByValue(node2._links, link)
  table.RemoveByValue(links, link)
  return true
end
function nodegraph.DrG_GetLinks()
  local tab = {}
  for i, link in ipairs(links) do
    table.insert(tab, link)
  end
  return tab
end
function nodegraph.DrG_GetLink(node1, node2)
  for i, link in ipairs(links) do
    local lnode1, lnode2 = link:GetNodes()
    if (node1:GetID() == lnode1:GetID() and node2:GetID() == lnode2:GetID()) or
    (node1:GetID() == lnode2:GetID() and node2:GetID() == lnode1:GetID()) then
      return link
    end
  end
end

if SERVER then
  util.AddNetworkString("NodegraphRequest")
  util.AddNetworkString("NodegraphParsed")

  -- parse ain file (based on nodegraph editor addon, thx!)
  local SIZEOF_INT = 4
  local SIZEOF_SHORT = 2
  local AINET_VERSION_NUMBER = 37
  local function toUShort(b)
  	local i = {string.byte(b,1,SIZEOF_SHORT)}
  	return i[1]+i[2]*256
  end
  local function toInt(b)
  	local i = {string.byte(b,1,SIZEOF_INT)}
  	i = i[1]+i[2]*256+i[3]*65536+i[4]*16777216
  	if i > 2147483647 then return i-4294967296 end
  	return i
  end
  local function ReadInt(f) return toInt(f:Read(SIZEOF_INT)) end
  local function ReadUShort(f) return toUShort(f:Read(SIZEOF_SHORT)) end
  function nodegraph.DrG_ParseNodegraph()
    f = file.Open("maps/graphs/"..game.GetMap()..".ain", "rb", "GAME")
    if not f then return end
    nodes = {}
    links = {}
    local ainet_ver = ReadInt(f)
    if ainet_ver ~= AINET_VERSION_NUMBER then return end
    local map_ver = ReadInt(f)
    local nbnodes = ReadInt(f)
    if nbnodes <= 0 then return end
    for i = 1, nbnodes do
    	local pos = Vector(f:ReadFloat(), f:ReadFloat(), f:ReadFloat())
    	local yaw = f:ReadFloat()
    	local flOffsets = {}
    	for h = 1, NUM_HULLS do
    		flOffsets[h] = f:ReadFloat()
    	end
    	local nodetype = f:ReadByte()
    	local nodeinfo = ReadUShort(f)
    	local zone = f:ReadShort()
    	table.insert(nodes, Node({
        _id = i,
    		_pos = pos,
    		_yaw = yaw,
    		_offset = flOffsets,
    		_type = nodetype,
    		_info = nodeinfo,
    		_zone = zone,
    		_links = {}
    	}))
    end
    local numLinks = ReadInt(f)
		for i = 1, numLinks do
			local srcID = f:ReadShort()
			local destID = f:ReadShort()
			local nodesrc = nodes[srcID+1]
			local nodedest = nodes[destID+1]
      local move = {}
			for i = 1, NUM_HULLS do
				move[i] = f:ReadByte()
			end
			if nodesrc and nodedest then
        nodesrc:Link(nodedest, move)
			end
		end
    f:Close()
    nodegraph.DrG_BroadcastNodegraph()
  end

  function nodegraph.DrG_SendNodegraph(ply)
    net.Start("NodegraphParsed")
    net.Send(ply)
  end

  function nodegraph.DrG_BroadcastNodegraph()
    net.Start("NodegraphParsed")
    net.Broadcast()
  end

  -- parse nodegraph
  local parsed = false
  hook.Add("Think", "NodegraphParse", function()
    if parsed then return end
    parsed = true
    nodegraph.DrG_ParseNodegraph()
  end)

  -- send nodes
  DrGBase.Net.DefineCallback("NodegraphRequest", function()
    return {nodes = nodes, links = links}
  end)

  -- send parsed nodegraph to connecting players
  hook.Add("PlayerInitialSpawn", "NodegraphPlayerInitialSpawn", function(ply)
    if not parsed then return end
    nodegraph.DrG_SendNodegraph(ply)
  end)

else

  local DrawGround = CreateClientConVar("drgbase_nodegraph_draw_ground", "1")
  local DrawAir = CreateClientConVar("drgbase_nodegraph_draw_air", "0")
  local DrawClimb = CreateClientConVar("drgbase_nodegraph_draw_climb", "1")
  local DrawWater = CreateClientConVar("drgbase_nodegraph_draw_water", "0")
  local DrawDistance = CreateClientConVar("drgbase_nodegraph_draw_distance", "1500")
  local Transparent = CreateClientConVar("drgbase_nodegraph_draw_transparent", "0")
  local HitWorld = CreateClientConVar("drgbase_nodegraph_draw_hitworld", "1")

  -- request nodegraph from server
  function nodegraph.DrG_FetchNodegraph()
    DrGBase.Net.UseCallback("NodegraphRequest", nil, function(data)
      local links = {}
      nodes = {}
      links = {}
      for i, node in ipairs(data.nodes) do
        for h, link in ipairs(node._links) do
          table.insert(links, link)
        end
        node._links = {}
        table.insert(nodes, Node(node))
      end
      for i, link in ipairs(links) do
        nodegraph.DrG_GetNode(link._node1):Link(nodegraph.DrG_GetNode(link._node2), link._move)
      end
    end)
  end

  -- fetch nodes on parse
  net.Receive("NodegraphParsed", function()
    nodegraph.DrG_FetchNodegraph()
  end)

  local function ShouldDrawNode(node)
    if node:GetType() == NODE_TYPE_GROUND and DrawGround:GetBool() then return true end
    if node:GetType() == NODE_TYPE_AIR and DrawAir:GetBool() then return true end
    if node:GetType() == NODE_TYPE_CLIMB and DrawClimb:GetBool() then return true end
    if node:GetType() == NODE_TYPE_WATER and DrawWater:GetBool() then return true end
    return false
  end

  -- draw nodegraph
  hook.Add("PostDrawOpaqueRenderables", "NodegraphDraw", function()
    if not Draw:GetBool() then return end
    local tr = LocalPlayer():GetEyeTrace()
    local dist = DrawDistance:GetFloat()
    local closest = nodegraph.DrG_GetClosestNode(tr.HitPos)
    for i, node in ipairs(nodes) do
      if ShouldDrawNode(node) and node:DistToSqr(tr.HitPos) < math.pow(dist, 2) then
        local color = DrGBase.Colors.White
        if node:GetType() == NODE_TYPE_AIR then color = DrGBase.Colors.Cyan
        elseif node:GetType() == NODE_TYPE_CLIMB then color = DrGBase.Colors.Purple
        elseif node:GetType() == NODE_TYPE_WATER then color = DrGBase.Colors.Blue end
        render.DrawWireframeBox(node:GetPos(), Angle(0, 0, 0), Vector(15, 15, 8), Vector(-15, -15, 0), color, not Transparent:GetBool())
        if node:GetID() == closest:GetID() then
          render.DrawWireframeSphere(node:GetPos(), 2, 4, 4, color, not Transparent:GetBool())
        end
        for h, node2 in ipairs(node:LinkedTo()) do
          if ShouldDrawNode(node2) and node2:DistToSqr(tr.HitPos) < math.pow(dist, 2) then
            local linecolor = DrGBase.Colors.Green
            if HitWorld:GetBool() and util.TraceLine({
              start = node:GetPos()+Vector(0, 0, 1),
              endpos = node2:GetPos()+Vector(0, 0, 1),
              collisiongroup = COLLISION_GROUP_IN_VEHICLE
            }).HitWorld then linecolor = DrGBase.Colors.Red end
            if node:GetType() == NODE_TYPE_CLIMB and node2:GetType() == NODE_TYPE_CLIMB then linecolor = DrGBase.Colors.Purple end
            render.DrawLine(node:GetPos(), node2:GetPos(), linecolor, not Transparent:GetBool())
          end
        end
      end
    end
  end)

end
