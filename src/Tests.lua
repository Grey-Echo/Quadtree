function RandomPoint(Lat, Lon, Data, Disp)
  Lat = Lat + math.random(0, Disp*2) - Disp
  Lon = Lon + math.random(0, Disp*2) - Disp
  return POINT:New(Lat, Lon, Data)
end

function QuadtreeFill(Quadtree, Size)
  for i=1, Size do
    local Data = "UNIT#"..tostring(i)
    Quadtree:Insert(RandomPoint(math.random(1,9999), math.random(1,9999), Data, 0))
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
  
  for i=Size, RemoveNumber do
    if type(Disp) == "string" then
      Disp = 0
      lat = math.random(1,9999)
      lon = math.random(1,9999)
      Quadtree:Insert(RandomPoint(lat, lon, "SpecialUnit", 0))
      lat = math.random(1,9999)
      lon = math.random(1,9999)
    else
      lat = math.random(1+Disp,9999-Disp)
      lon = math.random(1+Disp,9999-Disp)
      Quadtree:Insert(RandomPoint(lat, lon, "SpecialUnit", 0))
    end

    local Time = os.clock()
    Quadtree:Remove(RandomPoint(lat, lon, "SpecialUnit", Disp))
    AccTime = AccTime + os.clock() - Time
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
  
  for i=Size, RemoveNumber do
    if type(Disp) == "string" then
      Disp = 0
      lat = math.random(1,9999)
      lon = math.random(1,9999)
      Quadtree:Insert(RandomPoint(lat, lon, "SpecialUnit", 0))
      lat = math.random(1,9999)
      lon = math.random(1,9999)
    else
      lat = math.random(1+Disp,9999-Disp)
      lon = math.random(1+Disp,9999-Disp)
      Quadtree:Insert(RandomPoint(lat, lon, "SpecialUnit", 0))
    end

    local Time = os.clock()
    Quadtree:Update(RandomPoint(lat, lon, "SpecialUnit", Disp))
    AccTime = AccTime + os.clock() - Time
    Quadtree:Remove(RandomPoint(lat, lon, "SpecialUnit", 0))
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

--[[


function QuadtreeTestFind(Quadtree, Size, FindNumber)
  local AccTime = 0
  for i=1, Size do
    local lat = math.random(1,9999)
    local lon = math.random(1,9999)
    local Data = "UNIT#"..tostring(i)
    Quadtree:Insert(POINT:New(lat, lon, Data))
  end
  
  for i=1, FindNumber do
    local lat = math.random(101,9899)
    local lon = math.random(101,9899)
    local Data = "SpecialUnit"
    Quadtree:Insert(POINT:New(lat, lon, Data))
    
    local Time = os.clock()
    Quadtree:Find(POINT:New(lat + math.random(0, 20) - 10, lon + math.random(0, 20) - 10 , "SpecialUnit"))
    AccTime = AccTime + os.clock() - Time
  end
  print(string.format("%.3f", AccTime))
end 


function ArrayTestRemove(TestArray, ArraySize, RemoveNumber)
  local AccTime = 0
  for i=1, ArraySize do
    local lat = math.random(1,9999)
    local lon = math.random(1,9999)
    local Data = "UNIT#"..tostring(i)
    table.insert(TestArray, POINT:New(lat, lon, Data))
  end
  
  for i=ArraySize+1, ArraySize+1+RemoveNumber do
    local lat = math.random(1,9999)
    local lon = math.random(1,9999)
    local Data = "UNITAdd+"..tostring(i)
    table.insert(TestArray, POINT:New(lat, lon, Data))
    local Time = os.clock()
    for i=1, ArraySize + 1 do
      if TestArray[i].Data == Data then
        table.remove(TestArray, i )
      end
    end
    AccTime = AccTime + os.clock() - Time
  end
  print(string.format("%.3f", AccTime))
end
--]]