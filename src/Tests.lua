function RandomPoint(Lat, Lon, Data, Disp)
  Lat = Lat + math.random(0, Disp*2) - Disp
  Lon = Lon + math.random(0, Disp*2) - Disp
  --print("Point= "..tostring(Lat)..", "..tostring(Lon))
  return POINT:New(Lat, Lon, Data)
end

function QuadtreeFill(Quadtree, Size)
  for i=1, Size do
    local Data = "UNIT#"..tostring(i)
    Quadtree:Insert(POINT:New(math.random(1,9999), math.random(1,9999), Data))
  end
end

function ArrayFill(Array, Size)
  for i=1, Size do
    local Data = "UNIT#"..tostring(i)
    table.insert(Array, RandomPoint(math.random(1,9999), math.random(1,9999), Data, 0))
  end
end

----------------------------------------------------------------------------
-- Quadtree Tests
----------------------------------------------------------------------------
function QuadtreeTestInsert(Quadtree, Size, InsertNumber)
  local AccTime = 0
  QuadtreeFill(Quadtree, Size)
  

  InsertNumber = InsertNumber + Size
  Size = Size + 1

  for i=Size, InsertNumber do
    local Data = "SpecialUnit#"..tostring(i-Size)
    local Time = os.clock()
    Quadtree:Insert(RandomPoint(math.random(1,9999), math.random(1,9999), Data, 0))
    AccTime = AccTime + os.clock() - Time
  end
  print(string.format("%.3f", AccTime))
end


function QuadtreeTestRemove(Quadtree, Size, RemoveNumber, Disp)
  local AccTime = 0
  local lat
  local lon
  QuadtreeFill(Quadtree, Size)
  
  RemoveNumber = RemoveNumber + Size
  Size = Size + 1
  
  if type(Disp) == "string" then
    for i=Size, RemoveNumber do
      Disp = 0
      Quadtree:Insert(RandomPoint(math.random(1,9999), math.random(1,9999), "SpecialUnit", 0))
      lat = math.random(1,9999)
      lon = math.random(1,9999)
      
      local Time = os.clock()
      Quadtree:Remove(RandomPoint(lat, lon, "SpecialUnit", Disp))
      AccTime = AccTime + os.clock() - Time
    end
  else
    for i=Size, RemoveNumber do
      lat = math.random(1+Disp,9999-Disp)
      lon = math.random(1+Disp,9999-Disp)
      Quadtree:Insert(RandomPoint(lat, lon, "SpecialUnit", 0))
    
      local Time = os.clock()
      Quadtree:Remove(RandomPoint(lat, lon, "SpecialUnit", Disp))
      AccTime = AccTime + os.clock() - Time
    end
  end
  print(string.format("%.3f", AccTime))
end 


function QuadtreeTestUpdate(Quadtree, Size, RemoveNumber, Disp)
  local AccTime = 0
  local lat
  local lon
  QuadtreeFill(Quadtree, Size)
  
  RemoveNumber = RemoveNumber + Size
  Size = Size + 1
  
  if type(Disp) == "string" then
    for i=Size, RemoveNumber do
      Disp = 0
      Quadtree:Insert(RandomPoint(math.random(1,9999), math.random(1,9999), "SpecialUnit", 0))
      lat = math.random(1,9999)
      lon = math.random(1,9999)
      
      local Time = os.clock()
      Quadtree:Update(RandomPoint(lat, lon, "SpecialUnit", Disp))
      AccTime = AccTime + os.clock() - Time
      Quadtree:Remove(RandomPoint(lat, lon, "SpecialUnit", 0))
    end
  else
    for i=Size, RemoveNumber do
      lat = math.random(1+Disp,9999-Disp)
      lon = math.random(1+Disp,9999-Disp)
      Quadtree:Insert(RandomPoint(lat, lon, "SpecialUnit", 0))
      
      local Time = os.clock()
      Quadtree:Update(RandomPoint(lat, lon, "SpecialUnit", Disp))
      AccTime = AccTime + os.clock() - Time
      Quadtree:Remove(RandomPoint(lat, lon, "SpecialUnit", 0))
    end  
  end
  print(string.format("%.3f", AccTime))
end 


function QuadtreeTestFind(Quadtree, Size, FindNumber, Disp)
  local AccTime = 0
  local lat
  local lon
  QuadtreeFill(Quadtree, Size)
  
  FindNumber = FindNumber + Size
  Size = Size + 1
  
  if type(Disp) == "string" then
    for i=Size, FindNumber do
      Disp = 0
      Quadtree:Insert(RandomPoint(math.random(1,9999), math.random(1,9999), "SpecialUnit", 0))
      
      lat = math.random(1,9999)
      lon = math.random(1,9999)
      local Time = os.clock()
      Quadtree:Find(RandomPoint(lat, lon, "SpecialUnit", Disp))
      AccTime = AccTime + os.clock() - Time
      Quadtree:Remove(RandomPoint(lat, lon, "SpecialUnit", Disp))
    end
  else
    for i=Size, FindNumber do
      lat = math.random(1+Disp,9999-Disp)
      lon = math.random(1+Disp,9999-Disp)
      Quadtree:Insert(RandomPoint(lat, lon, "SpecialUnit", 0))
      
      local Time = os.clock()
      Quadtree:Find(RandomPoint(lat, lon, "SpecialUnit", Disp))
      AccTime = AccTime + os.clock() - Time
      Quadtree:Remove(RandomPoint(lat, lon, "SpecialUnit", Disp))
    end
  end
  print(string.format("%.3f", AccTime))
end 


function QuadtreeTestInZone(Quadtree, Size, SearchNumber, Radius)
  local AccTime = 0
  local lat
  local lon
  
  QuadtreeFill(Quadtree, Size)
  
  if type(Radius) == "string" then
    for i=1, SearchNumber do
      Radius = math.random(1,2000)
      lat = math.random(1+Radius,9999-Radius)
      lon = math.random(1+Radius,9999-Radius)
    
      local Time = os.clock()
      Quadtree:NodesInCircle(RandomPoint(lat, lon, "", 0), Radius)
      AccTime = AccTime + os.clock() - Time
    end
  else
    for i=1, SearchNumber do
      lat = math.random(1+Radius,9999-Radius)
      lon = math.random(1+Radius,9999-Radius)
    
      local Time = os.clock()
      Quadtree:NodesInCircle(RandomPoint(lat, lon, "", 0), Radius)
      AccTime = AccTime + os.clock() - Time
    end
  end
  print(string.format("%.3f", AccTime))
end 


-----------------------------------------------------------------------------
-- Array Tests
-----------------------------------------------------------------------------
function ArrayTestInsert(Array, Size, InsertNumber)
  local AccTime = 0
  ArrayFill(Array, Size)
  
  InsertNumber = InsertNumber + Size
  Size = Size + 1
  
  for i=Size, InsertNumber do
    local Data = "SpecialUnit#"..tostring(i-Size)
    local Time = os.clock()
    table.insert(Array, RandomPoint(math.random(1,9999), math.random(1,9999), Data, 0))
    AccTime = AccTime + os.clock() - Time
  end
  
  print(string.format("%.3f", AccTime))
end



function ArrayTestRemove(Array, Size, RemoveNumber)
  local AccTime = 0
  ArrayFill(Array, Size)
  
  RemoveNumber = RemoveNumber + Size
  Size = Size + 1
  
  for i=Size, RemoveNumber do
    local lat = math.random(1,9999)
    local lon = math.random(1,9999)
    local Data = "SpecialUnit"
    local Place = math.random(1,Size)
    table.insert(Array, Place, POINT:New(lat, lon, Data))
    local Time = os.clock()
    for i=1, Size-1 do
      if Array[i].Data == "SpecialUnit" then
        table.remove(Array, i )
        break
      end
    end
    AccTime = AccTime + os.clock() - Time
  end
  print(string.format("%.3f", AccTime))
end


function ArrayTestUpdate(Array, Size, UpdateNumber)
  local AccTime = 0
  ArrayFill(Array, Size)
  
  UpdateNumber = UpdateNumber + Size
  Size = Size + 1
  
  for i=Size, UpdateNumber do
    local lat = math.random(1,9999)
    local lon = math.random(1,9999)
    local Data = "SpecialUnit"
    local Place = math.random(1,Size)
    table.insert(Array, Place, POINT:New(lat, lon, Data))
    local Time = os.clock()
    for i=1, Size-1 do
      if Array[i].Data == "SpecialUnit" then
        local TempPoint = Array[i]
        table.remove(Array, i )
        table.insert(Array,TempPoint)
        break
      end
    end
    AccTime = AccTime + os.clock() - Time
    for i=1, Size-1 do
      if Array[i].Data == "SpecialUnit" then
        table.remove(Array, i )
        break
      end
    end
  end
  print(string.format("%.3f", AccTime))
end


function ArrayTestSearch(Array, Size, SearchNumber)
  local AccTime = 0
  ArrayFill(Array, Size)
  
  SearchNumber = SearchNumber + Size
  Size = Size + 1
  
  for i=Size, SearchNumber do
    local lat = math.random(1,9999)
    local lon = math.random(1,9999)
    local Data = "SpecialUnit"
    local Place = math.random(1,Size)
    table.insert(Array, Place, POINT:New(lat, lon, Data))
    local Time = os.clock()
    for i=1, Size-1 do
      if Array[i].Data == "SpecialUnit" then
        break
      end
    end
    for i=1, Size-1 do
      if Array[i].Data == "SpecialUnit" then
        table.remove(Array, i )
        break
      end
    end
    AccTime = AccTime + os.clock() - Time
  end
  print(string.format("%.3f", AccTime))
end


function ArrayTestInZone(Array, Size, SearchNumber, Radius)
  local AccTime = 0
  ArrayFill(Array, Size)
  
  if type(Radius) == "string" then
    for i=1, SearchNumber do
      Radius = math.random(1,2000)
      lat = math.random(1+Radius,9999-Radius)
      lon = math.random(1+Radius,9999-Radius)
    
      local Time = os.clock()
      local ComputedSize = table.getn(Array)
      local SearchPoint = POINT:New(lat, lon, "")
      local SearchResults = {}
      for i = 1, ComputedSize do
        if Array[i]:Distance(SearchPoint) < Radius then
          table.insert(SearchResults, Array[i])
        end
      end 
      AccTime = AccTime + os.clock() - Time
    end
  else
    for i=1, SearchNumber do
      lat = math.random(1+Radius,9999-Radius)
      lon = math.random(1+Radius,9999-Radius)
    
      local Time = os.clock()
      local ComputedSize = table.getn(Array)
      local SearchPoint = POINT:New(lat, lon, "")
      local SearchResults = {}
      for i = 1, ComputedSize do
        if SearchPoint:Distance(Array[i]) < Radius then
          table.insert(SearchResults, Array[i])
        end
      end 
      AccTime = AccTime + os.clock() - Time
      SearchResults = {}
    end
  end
  print(string.format("%.3f", AccTime))
end