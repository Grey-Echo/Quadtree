-- Stuff pulled from Moose
---------------------------------------------------------------------------------------------------------
routines = {}
routines.utils = {}
routines.utils.deepCopy = function(object)
  local lookup_table = {}
  local function _copy(object)
    if type(object) ~= "table" then
      return object
    elseif lookup_table[object] then
      return lookup_table[object]
    end
    local new_table = {}
    lookup_table[object] = new_table
    for index, value in pairs(object) do
      new_table[_copy(index)] = _copy(value)
    end
    return setmetatable(new_table, getmetatable(object))
  end
  local objectreturn = _copy(object)
  return objectreturn
end
local _ClassID = 0

BASE = {
  ClassName = "BASE",
  ClassID = 0,
  Events = {},
  States = {},
  _ = {},
}
function BASE:New()
  local self = routines.utils.deepCopy( self ) -- Create a new self instance
  local MetaTable = {}
  setmetatable( self, MetaTable )
  self.__index = self
  _ClassID = _ClassID + 1
  self.ClassID = _ClassID

  
  return self
end

function BASE:_Destructor()
  --self:E("_Destructor")

  --self:EventRemoveAll()
end


-- THIS IS WHY WE NEED LUA 5.2 ...
function BASE:_SetDestructor()

  -- TODO: Okay, this is really technical...
  -- When you set a proxy to a table to catch __gc, weak tables don't behave like weak...
  -- Therefore, I am parking this logic until I've properly discussed all this with the community.

  local proxy = newproxy(true)
  local proxyMeta = getmetatable(proxy)

  proxyMeta.__gc = function ()
    env.info("In __gc for " .. self:GetClassNameAndID() )
    if self._Destructor then
        self:_Destructor()
    end
  end

  -- keep the userdata from newproxy reachable until the object
  -- table is about to be garbage-collected - then the __gc hook
  -- will be invoked and the destructor called
  rawset( self, '__proxy', proxy )
  
end

--- This is the worker method to inherit from a parent class.
-- @param #BASE self
-- @param Child is the Child class that inherits.
-- @param #BASE Parent is the Parent class that the Child inherits from.
-- @return #BASE Child
function BASE:Inherit( Child, Parent )
  local Child = routines.utils.deepCopy( Child )
  --local Parent = routines.utils.deepCopy( Parent )
  --local Parent = Parent
  if Child ~= nil then
    setmetatable( Child, Parent )
    Child.__index = Child
    
    --Child:_SetDestructor()
  end
  --self:T( 'Inherited from ' .. Parent.ClassName ) 
  return Child
end