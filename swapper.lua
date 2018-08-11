local getLastModified
do
  local info = {}
  getLastModified = function (filepath)
    love.filesystem.getInfo(filepath, info)
    return info.modtime
  end
end
local prevModified     = {}

local _lua_getmetatable = getmetatable
local _lua_setmetatable = setmetatable
local _lua_require      = require
local _lua_ipairs       = ipairs
local _lua_pairs        = pairs
local _lua_pcall        = pcall
local _lua_type         = type
local _lua_table_insert = table.insert
local _lua_table_remove = table.remove

local hotSwaps = {}
local hotStuff = {}
local hotFiles = {}

local hotListen = {}

local hotMeta  = {}
local __metatable = {}

local NIL = {}

local _unswaps = {}

local function unswap(t)
  return hotStuff[_unswaps[t] or NIL] or t
end

local function metafunct(name, key)
  return function (...)
    return __metatable[name][key](...)
  end
end

local function unloadAll()
  for name, swapper in pairs(hotStuff) do
    package.loaded[name] = false
  end
end

local function Swapper(name)
  hotStuff[name] = _lua_require(name)
  hotFiles[name] = (name:gsub("%.", "/")..".lua")

  if _lua_type(hotStuff[name]) == "function" then
    hotSwaps[name] = function (...) return hotStuff[name](...) end
  elseif _lua_type(hotStuff[name]) == "table" then
    __metatable[name] = _lua_getmetatable(hotStuff[name])
    hotMeta[name] = {
      __index    = function (t, k) return unswap(t)[k] end;
      __newindex = function (t, k, v) unswap(t)[k] = v end;

      __metatable = __metatable[name];

      __len      = function (t) return #unswap(t) end;
      __call     = metafunct(name, "__call");
      __tostring = metafunct(name, "__tostring");
      __unm      = metafunct(name, "__unm");
      __add      = metafunct(name, "__add");
      __sub      = metafunct(name, "__sub");
      __mul      = metafunct(name, "__mul");
      __div      = metafunct(name, "__div");
      __idiv     = metafunct(name, "__idiv");
      __mod      = metafunct(name, "__mod");
      __pow      = metafunct(name, "__pow");
      __concat   = metafunct(name, "__concat");
      __eq       = metafunct(name, "__eq");
      __lt       = metafunct(name, "__lt");
      __le       = metafunct(name, "__le");
    }
    local swapper = _lua_setmetatable({}, hotMeta[name])
    _unswaps[swapper] = name
    hotSwaps[name] = swapper
  end

  package.loaded[name] = hotSwaps[name]
  prevModified[name] = getLastModified(hotFiles[name])
  return hotSwaps[name]
end

local function requireAsSwapper(name)
  local swap = hotSwaps[name]
  if not swap then
    swap = Swapper(name)
  end
  return swap
end

local function makeHotListen(name, callback)
  hotListen[name] = callback
  return name
end

local function  pairsWithSwapper(t)
  return _lua_pairs(unswap(t))
end
local function ipairsWithSwapper(t)
  return _lua_ipairs(unswap(t))
end

local function lenWithSwapper(t)
  return #(unswap(t))
end

local function hotswap()
  local changed
  for name, file in _lua_pairs(hotFiles) do
    local lastModified = getLastModified(file)
    if prevModified[name] ~= lastModified then
      local swapper = package.loaded[name]
      package.loaded[name] = false

      local status, msgOrData = _lua_pcall(_lua_require, name)

      if status then
        hotStuff[name] = msgOrData

        if _lua_type(swapper) == "table" then
          local meta = hotMeta[name]
          __metatable[name] = _lua_getmetatable(hotStuff[name])
          meta.__metatable = __metatable[name]
        end

        changed = changed or {}
        changed[name] = true
      end
      print("Swapper", msgOrData)

      package.loaded[name] = swapper
      prevModified[name] = lastModified
    end
  end
  for file, callback in _lua_pairs(hotListen) do
    local lastModified = getLastModified(file)
    if prevModified[file] ~= lastModified then
      local success, magOrData = pcall(callback, file)
      if success then
        changed = changed or {}
        changed[file] = true
      end
      print("Swapper", msgOrData or "Reloaded: "..file)
      prevModified[file] = lastModified
    end
  end
  return changed
end

local function insertWithSwapper(t,a,b)
  if b then
    return _lua_table_insert(unswap(t),a,b)
  else
    return _lua_table_insert(unswap(t),a)
  end
end

local function removeWithSwapper(t,a)
  return _lua_table_remove(unswap(t),a)
end

local lib_swapper = {
  update    = assert(hotswap);
  unloadAll = assert(unloadAll);
  require   = assert(requireAsSwapper);
  hot       = assert(makeHotListen);
  pairs     = assert(pairsWithSwapper);
  ipairs    = assert(ipairsWithSwapper);
  len       = assert(lenWithSwapper);
  insert    = assert(insertWithSwapper);
  remove    = assert(removeWithSwapper);
}

function lib_swapper.install()
  require      = lib_swapper.require
  lua_require  = _lua_require
  pairs        = lib_swapper.pairs
  lua_pairs    = _lua_pairs
  ipairs       = lib_swapper.ipairs
  lua_ipairs   = _lua_ipairs
  len          = lib_swapper.len
  table.insert = lib_swapper.insert
  table.remove = lib_swapper.remove
end

return lib_swapper
