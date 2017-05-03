require "MooseStuff"
require "PepperFish"

--- @type POINT
POINT = {}

-- Instantiate a new POINT, which is a Data (probably going to be a UNIT) embeded into a structure, with its coordinates
function POINT:New(X, Y, Data)
  local self = BASE:Inherit( self, BASE:New() )
  self.X = X
  self.Y = Y
  self.Data = Data
  --print("New Point : "..self.X..", "..self.Y..", "..self.Data)
  return self
end

-- Calculate the distance from the point to an other point
function POINT:Distance(Point)
  -- This is not cool for the programer, but very optimized... sorry :)
  -- dont use math.pow it is slow af !
  return math.sqrt((self.X - Point.X) * (self.X - Point.X) + (self.Y - Point.Y) * (self.Y - Point.Y)) 
end

--- @type BOUNDING_BOX
BOUNDING_BOX = {}

-- Instantiate a new BoundingBox. X, Y are the coordinates at the bottom left, and H, W are the width and the Hieght
function BOUNDING_BOX:New(X, Y, W, H)
  local self = BASE:Inherit( self, BASE:New() )
  self.X = X
  self.Y = Y
  self.W = W
  self.H = H
  -- We store the half width and the half height, so we don't have to calculate them later
  self.HalfW = W/2
  self.HalfH = H/2
  return self
end

function BOUNDING_BOX:ContainPoint(Point)
  -- This makes use of lua's lazy operator. The order is important !
  return Point.X > self.X and Point.Y > self.Y and Point.X <= self.W + self.X and Point.Y <= self.H + self.Y
end

-- Check if a circle intercept with the bounding box. The center of the circle must be a POINT
-- can be easily changed to take X and Y instead
function BOUNDING_BOX:Intersect(CircleCenter, CircleRadius)
  -- This is not cool for the programer, but very optimized... sorry :)

  local cx = math.abs(CircleCenter.X - self.X - self.HalfW)
  local xDist = self.HalfW + CircleRadius 
  if (cx > xDist) then return false end
  
  local cy = math.abs(CircleCenter.Y - self.Y - self.HalfH)
  local yDist = self.HalfH + CircleRadius
  if (cy > yDist) then return false end
  
  if (cx <= self.HalfW or cy <= self.HalfH) then return true end
  
  local xCornerDist = cx - self.HalfW
  local yCornerDist = cy - self.HalfH
  local xCornerDistSq = xCornerDist * xCornerDist
  local yCornerDistSq = yCornerDist * yCornerDist
  local maxCornerDistSq = CircleRadius * CircleRadius
  return xCornerDistSq + yCornerDistSq <= maxCornerDistSq
end

--- @type NODE
NODE = {}

function NODE:New(BoundingBox, Node_Previous)
  local self = BASE:Inherit( self, BASE:New() )
  self.BoundingBox = BoundingBox
  self.Node_Previous = Node_Previous
  --print("New NODE ! Bounding Box : X="..self.BoundingBox.X.." Y="..self.BoundingBox.Y.." Width = "..self.BoundingBox.W.." Height = "..self.BoundingBox.H)
  return self
end

-- Adds its children to a Node
function NODE:_Subdivide()
  -- Sorry... less CPU cycles this way

  self.Node_SE = NODE:New(BOUNDING_BOX:New(self.BoundingBox.X, self.BoundingBox.Y, self.BoundingBox.HalfW, self.BoundingBox.HalfH), self)
  self.Node_NE = NODE:New(BOUNDING_BOX:New(self.BoundingBox.X, self.BoundingBox.Y + self.BoundingBox.HalfH, self.BoundingBox.HalfW, self.BoundingBox.HalfH), self)
  self.Node_NW = NODE:New(BOUNDING_BOX:New(self.BoundingBox.X + self.BoundingBox.HalfW, self.BoundingBox.Y + self.BoundingBox.HalfH, self.BoundingBox.HalfW, self.BoundingBox.HalfH), self)
  self.Node_SW = NODE:New(BOUNDING_BOX:New(self.BoundingBox.X + self.BoundingBox.HalfW, self.BoundingBox.Y, self.BoundingBox.HalfW, self.BoundingBox.HalfH), self)
  return self
end

--- @type QUADTREE
QUADTREE = {
  DataStored  = 0
}

function QUADTREE:New(BoundingBox)
  local self = BASE:Inherit( self, NODE:New(BoundingBox) )
  self.Node_Previous = nil
  return self
end


function QUADTREE:Insert(Point)
  self.DataStored = self.DataStored + 1
  local CurrentNode = self
  
  while true do
  
    if CurrentNode.Point == nil then
      --print("Point "..Point.Data.." added to this Quadtree")
      CurrentNode.Point = Point
      return true
    end
  
    --print("There is already a POINT here, need to subdivide !")
    if CurrentNode.Node_SE == nil then
      CurrentNode:_Subdivide()
    end
  
    if CurrentNode.Node_SE.BoundingBox:ContainPoint(Point) then CurrentNode = CurrentNode.Node_SE
    elseif CurrentNode.Node_NE.BoundingBox:ContainPoint(Point) then CurrentNode = CurrentNode.Node_NE
    elseif CurrentNode.Node_NW.BoundingBox:ContainPoint(Point) then CurrentNode = CurrentNode.Node_NW
    elseif CurrentNode.Node_SW.BoundingBox:ContainPoint(Point) then CurrentNode = CurrentNode.Node_SW end
    --print("The POINT didn't fit in any of the subdivisions")
  end
end

-- I need to rework this one. But it is only usefull for debug
function QUADTREE:Print()
  local Queue = {self}
  
  while table.maxn(Queue) > 0 do
    local LevelNodes = table.maxn(Queue)
    while LevelNodes > 0 do
      if Queue[1].Node_SE then
        io.write(" "..Queue[1].Point.Data)
        table.insert(Queue, Queue[1].Node_SE)
        table.insert(Queue, Queue[1].Node_NE)
        table.insert(Queue, Queue[1].Node_NW)
        table.insert(Queue, Queue[1].Node_SW)
      end
      table.remove(Queue, 1)
      LevelNodes = LevelNodes - 1
    end
    io.write("\n")
  end
      
end



function QUADTREE:Find(Point)
  --print("Searching")
  local CurrentNode = self
  local i = 0
  while true do
  
    if CurrentNode.Point then
      if CurrentNode.Point.Data == Point.Data then
        -- print("Unit found. Search Depth : "..i)
        -- print("0")
        return CurrentNode
      end
    end 
    
    if not CurrentNode.Node_SE then
      -- print("Unit not found. Search Depth : "..i)
      break
    end
    
    i = i+1
    
    if CurrentNode.Node_SE.BoundingBox:ContainPoint(Point) then
      CurrentNode = CurrentNode.Node_SE
      --print("Taking SE route !")
    elseif CurrentNode.Node_NE.BoundingBox:ContainPoint(Point) then
      CurrentNode = CurrentNode.Node_NE
      --print("Taking NE route !")
    elseif CurrentNode.Node_NW.BoundingBox:ContainPoint(Point) then
      CurrentNode = CurrentNode.Node_NW
      --print("Taking NW route !")
    elseif CurrentNode.Node_SW.BoundingBox:ContainPoint(Point) then
      CurrentNode = CurrentNode.Node_SW
      --print("Taking SW route !")
    end
  end
    
  -- This would be good enough if the UNIT stayed in its square since last update. But it may not be the case
  -- so we need to walk back the tree, comparing the Point to any Point found in the Tree.
  -- This should be still efficient, as Units usually don't move too much too fast
  -- This will be very inefficient if the UNIT is an OVNI, moving at light speed
  -- print("Unit moved, searching around...")
  
  local PotentialUnits = {}
  local PotentialUnitsSize
  local PreviousSize
  -- A lot of science has gone into that !
  -- The idea is that the more data is stored, the smaller the radius is increased at each step
  local RadiusStep = math.abs(math.ceil((1/(self.DataStored + 800)) * 1E6))
  local Radius = RadiusStep
  
  while not CurrentNode.Point do
    CurrentNode = CurrentNode.Node_Previous
  end
  local j = 0
  while true do
    j = j+1
    -- print("Search radius : "..tostring(Radius))
    
    PotentialUnits = self:NodesInCircle(CurrentNode.Point, Radius)
    PreviousSize = PotentialUnitsSize 
    PotentialUnitsSize = table.getn(PotentialUnits)
    
    if self.DataStored == PotentialUnitsSize then return nil end
    
    if PotentialUnitsSize > 0 and PreviousSize ~= PotentialUnitsSize then      
  
      for i=1, PotentialUnitsSize do        
        if PotentialUnits[i].Point.Data == Point.Data then
          -- print("Unit Found ! Radius : "..tostring(Radius))
          print(j)
          return PotentialUnits[i]
        end
      end 
    end
    
    Radius = Radius + RadiusStep    
  end
end

function QUADTREE:Remove(Point)
  self.DataStored = self.DataStored-1
  --print("Removing")
  -- print("Remove Point : "..tostring(Point.Data))
  local Node = self:Find(Point)
  
  Node.Point = nil
end

function QUADTREE:Update(Point)
  -- print("Update Point : "..tostring(Point.Data))
  local Node = self:Find(Point)
  
  if Node.BoundingBox:ContainPoint(Point) then
    Node.Point = Point
  else
    Node.Point = nil
    self:Insert(Point)
  end
end

-- I should totally find a way to merge this one with ExistingPointNearestNeighbour...
-- The difference is that in this function, if the neirest neighboun is an existing point, the function stops and returns this point
-- In ExistingPointNearestNeighbour, the function woul keep searching for the closest Unit.
function QUADTREE:NearestNeighbour(Point)
  local Stack = {self}
  local CurrentNode
  local CurrentDist
  local CurrentRadius = 1E12
  local NearestNeighbour
  local NNDist = 1E12
  local i = 0
  
  while true do
    i = i + 1
    print("Step : "..tostring(i))
    
    CurrentNode = Stack[table.maxn(Stack)]
    table.remove(Stack)
    
    if not CurrentNode then break end
    
    if CurrentNode.Node_SE then
    
      if CurrentNode.Node_SE.BoundingBox:Intersect(Point, CurrentRadius) then
        table.insert(Stack, CurrentNode.Node_SE)
        if CurrentNode.Node_SE.Point then
        CurrentDist = Point:Distance(CurrentNode.Node_SE.Point)
          if CurrentDist < CurrentRadius then
            NearestNeighbour = CurrentNode.Node_SE.Point
            CurrentRadius = CurrentDist
          end 
        end
      end
      
      if CurrentNode.Node_NE.BoundingBox:Intersect(Point, CurrentRadius) then
        table.insert(Stack, CurrentNode.Node_NE)
        if CurrentNode.Node_NE.Point then
          CurrentDist = Point:Distance(CurrentNode.Node_NE.Point)
          if CurrentDist < CurrentRadius then
            NearestNeighbour = CurrentNode.Node_NE.Point
            CurrentRadius = CurrentDist
          end
        end
      end
      if CurrentNode.Node_NW.BoundingBox:Intersect(Point, CurrentRadius) then
        table.insert(Stack, CurrentNode.Node_NW) 
        if CurrentNode.Node_NW.Point then
          CurrentDist = Point:Distance(CurrentNode.Node_NW.Point)
          if CurrentDist < CurrentRadius then
            NearestNeighbour = CurrentNode.Node_NW.Point
            CurrentRadius = CurrentDist
          end
        end
      end
      if CurrentNode.Node_SW.BoundingBox:Intersect(Point, CurrentRadius) then
        table.insert(Stack, CurrentNode.Node_SW)
        if CurrentNode.Node_SW.Point then
          CurrentDist = Point:Distance(CurrentNode.Node_SW.Point)
          if CurrentDist < CurrentRadius then
            NearestNeighbour = CurrentNode.Node_SW.Point
            CurrentRadius = CurrentDist
          end
        end
      end
    end
    
    if Point.X == NearestNeighbour.X then
      if Point.Y == NearestNeighbour.Y then
        print("Point Already Exists !")
        break
      end
    end
    
  end 
  return NearestNeighbour
end

function QUADTREE:ExistingPointNearestNeighbour(Point)
  local Stack = {self}
  local CurrentNode
  local CurrentDist
  local CurrentRadius = 1E12
  local NearestNeighbour
  local NNDist = 1E12
  local i = 0

  
  while true do
    i = i + 1
    print("Step : "..tostring(i))
    
    CurrentNode = Stack[table.maxn(Stack)]
    table.remove(Stack)
    
    if not CurrentNode then break end
    
    if CurrentNode.Node_SE then
    
      if CurrentNode.Node_SE.BoundingBox:Intersect(Point, CurrentRadius) then
        table.insert(Stack, CurrentNode.Node_SE)
        if CurrentNode.Node_SE.Point then
          if CurrentNode.Node_SE.Point.Data ~= Point.Data then
          CurrentDist = Point:Distance(CurrentNode.Node_SE.Point)
            if CurrentDist < CurrentRadius then
              NearestNeighbour = CurrentNode.Node_SE.Point
              CurrentRadius = CurrentDist
            end
          end 
        end
      end
      
      if CurrentNode.Node_NE.BoundingBox:Intersect(Point, CurrentRadius) then
        table.insert(Stack, CurrentNode.Node_NE)
        if CurrentNode.Node_NE.Point then
          if CurrentNode.Node_NE.Point.Data ~= Point.Data then
            CurrentDist = Point:Distance(CurrentNode.Node_NE.Point)
            if CurrentDist < CurrentRadius then
              NearestNeighbour = CurrentNode.Node_NE.Point
              CurrentRadius = CurrentDist
            end
          end
        end
      end
      if CurrentNode.Node_NW.BoundingBox:Intersect(Point, CurrentRadius) then
        table.insert(Stack, CurrentNode.Node_NW) 
        if CurrentNode.Node_NW.Point then
          if CurrentNode.Node_NW.Point.Data ~= Point.Data then
            CurrentDist = Point:Distance(CurrentNode.Node_NW.Point)
            if CurrentDist < CurrentRadius then
              NearestNeighbour = CurrentNode.Node_NW.Point
              CurrentRadius = CurrentDist
            end
          end
        end
      end
      if CurrentNode.Node_SW.BoundingBox:Intersect(Point, CurrentRadius) then
        table.insert(Stack, CurrentNode.Node_SW)
        if CurrentNode.Node_SW.Point then
          if CurrentNode.Node_SW.Point.Data ~= Point.Data then
            CurrentDist = Point:Distance(CurrentNode.Node_SW.Point)
            if CurrentDist < CurrentRadius then
              NearestNeighbour = CurrentNode.Node_SW.Point
              CurrentRadius = CurrentDist
            end
          end
        end
      end
    end
    
  end 
  return NearestNeighbour
end

function QUADTREE:NodesInCircle(Center, Radius)
  local Stack = {self}
  local CurrentNode
  local NodesInCircle = {}
  local i = 0
  
  while true do
    i = i + 1
    -- print("Step : "..tostring(i))
    
    CurrentNode = Stack[table.maxn(Stack)]
    table.remove(Stack)
    
    if not CurrentNode then break end
    
    if CurrentNode.Node_SE then
    
      if CurrentNode.Node_SE.BoundingBox:Intersect(Center, Radius) then
        table.insert(Stack, CurrentNode.Node_SE)
        if CurrentNode.Node_SE.Point then
          if Center:Distance(CurrentNode.Node_SE.Point) < Radius then
            table.insert(NodesInCircle, CurrentNode.Node_SE)
          end 
        end
      end
   
      if CurrentNode.Node_NE.BoundingBox:Intersect(Center, Radius) then
        table.insert(Stack, CurrentNode.Node_NE)
        if CurrentNode.Node_NE.Point then
          if Center:Distance(CurrentNode.Node_NE.Point) < Radius then
            table.insert(NodesInCircle, CurrentNode.Node_NE)
          end 
        end
      end
      
      if CurrentNode.Node_NW.BoundingBox:Intersect(Center, Radius) then
        table.insert(Stack, CurrentNode.Node_NW)
        if CurrentNode.Node_NW.Point then
          if Center:Distance(CurrentNode.Node_NW.Point) < Radius then
            table.insert(NodesInCircle, CurrentNode.Node_NW)
          end 
        end
      end
      
      if CurrentNode.Node_SW.BoundingBox:Intersect(Center, Radius) then
        table.insert(Stack, CurrentNode.Node_SW)
        if CurrentNode.Node_SW.Point then
          if Center:Distance(CurrentNode.Node_SW.Point) < Radius then
            table.insert(NodesInCircle, CurrentNode.Node_SW)
          end 
        end
      end
    end
    
  end 
  return NodesInCircle
end


-- Main
-------------------------------------------------------------------------------------
require "Tests"
math.randomseed(os.time())
--[[
-- Uncomment to start the profiler
profiler = newProfiler()
profiler:start()
--]]
---[[
-- Quadtree tests
for i=1, 1 do
  local MyQuadtree = QUADTREE:New(BOUNDING_BOX:New(0, 0, 10000, 10000))
  
  -- QuadtreeTestInZone(MyQuadtree, 200, 50, "random")
  QuadtreeTestFind(MyQuadtree, 10, 1000, 200)
  -- QuadtreeTestUpdate(MyQuadtree, 100000, 1, "random")
  -- QuadtreeTestRemove(MyQuadtree, 100000, 1, "random")
  -- QuadtreeTestInsert(MyQuadtree, 10000, 1000)

  collectgarbage(collect)
end
--]]
--[[
-- Array tests
for i=1, 20 do
  local Array = {}
  -- ArrayTestInsert(Array, 10000, 1000)
  -- ArrayTestRemove(Array, 100000, 1000)
  -- ArrayTestUpdate(Array, 100000, 1000)
  -- ArrayTestSearch(Array, 100000, 1000)
  ArrayTestInZone(Array, 200, 50, "random")
end
--]]
--[[
-- Uncomment to stop the profiler
profiler:stop()
local outfile = io.open( "profile.txt", "w+" )
profiler:report( outfile )
outfile:close()
--]]