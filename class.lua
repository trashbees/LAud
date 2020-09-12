local function search(key, bases)
  for _, v in ipairs(bases) do
    if type(v) ~= "nil" then return v[key] end
  end
end

return function(...)
  local class = {}
  class._bases = {...}
  class.__index = class

  -- set up type checking (instance.typeof(Class))
  class._types = {[class] = true}
  for _, base in ipairs(class._bases) do
    for cls in pairs(base._types) do
      class._types[cls] = true
    end
    class._types[base] = true
  end

  class.typeof = function(cls)
    if class._types[cls] then return true else return false end
  end

  local mt = {
    -- fallback to base index search
    __index = function(tbl, key)
      return search(key, tbl._bases)
    end,
    -- call constructor w/ classname
    __call = function(class_table, ...)
      local instance = {}
      setmetatable(instance, class)
      if instance._init then instance._init(instance, ...) end
      return instance
    end
  }
  setmetatable(class, mt)
  return class
end
