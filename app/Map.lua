local rgb  = require "app.util.color.rgb"
local vec4 = require "app.util.color.vec4"

local Map = {}
Map.__index = Map

setmetatable(Map, {
  __call = function (_, map)
    assert(type(map.start_x)=="table", "Missing 'start_x' property")
    assert(type(map.start_y)=="table", "Missing 'start_y' property")
    assert(#map.start_x == #map.start_y, "Problem with start positions, unpaired coords.")
    assert(#map.start_x == 1, "Map must have exactly one starting point.")
    assert(type(map.tiles_x)=="number", "Missing numeric 'tiles_x' property")
    assert(type(map.tiles_y)=="number", "Missing numeric 'tiles_y' property")
    setmetatable(map, Map)

    map.tiles = map.tiles or {}
    map.items = map.items or {}

    return map
  end
})

function Map:set_item_at(x, y, value)
  x, y = math.floor(x), math.floor(y)
  local tiles_x = self.tiles_x
  local tiles_y = self.tiles_y
  if x < 1 or y < 1 or x > tiles_x or y > tiles_y then return end
  local index = x + (y - 1)*tiles_x
  self.items[index] = value
end

function Map:get_item_at(x, y)
  x, y = math.floor(x), math.floor(y)
  local tiles_x = self.tiles_x
  local tiles_y = self.tiles_y
  if x < 1 or y < 1 or x > tiles_x or y > tiles_y then return end
  local index = x + (y - 1)*tiles_x
  return self.items[index]
end

function Map:set_tile_at(x, y, value)
  x, y = math.floor(x), math.floor(y)
  local tiles_x = self.tiles_x
  local tiles_y = self.tiles_y
  if x < 1 or y < 1 or x > tiles_x or y > tiles_y then return end
  local index = x + (y - 1)*tiles_x
  self.tiles[index] = value
end

function Map:get_tile_at(x, y)
  x, y = math.floor(x), math.floor(y)
  local tiles_x = self.tiles_x
  local tiles_y = self.tiles_y
  if x < 1 or y < 1 or x > tiles_x or y > tiles_y then return "WALL" end
  local index = x + (y - 1)*tiles_x
  return self.tiles[index]
end

function Map:is_start(x, y)
  x, y = math.floor(x), math.floor(y)
  local start_x, start_y = self.start_x, self.start_y
  for i = 1, #start_x do
    if start_x[i] == x and start_y[i] == y then return true end
  end
  return false
end

do
  local function _load_image_data(path)
    local success, result = pcall(love.image.newImageData, path)
    if not success then
      -- handle error
      love.window.showMessageBox("ERROR", "Error loading level.\nClosing game")
      love.event.quit(-1)
      return love.image.newImageData(1,1)
    end
    return result
  end

  local is_start = {
    [rgb(0, 127, 0)] = true
  }

  local tile_of = {
    [rgb(127, 127, 127)] = "WALL";
  }
  local item_of = {
    [rgb(0, 255, 255)] = "FLOPPY";
    [rgb(0, 255, 0)  ] = "GOAL";
  }

  function Map.load_png(level)
    local data = _load_image_data(("app/level/%s.png"):format(level) )

    local tiles_x, tiles_y = data:getDimensions()

    local start_x = {}
    local start_y = {}
    local items   = {}
    local tiles   = {}

    local result = {
      tiles_x = tiles_x;
      tiles_y = tiles_y;
      start_x = start_x;
      start_y = start_y;
      items   = items;
      tiles   = tiles;
    }

    for y = 1, tiles_y do
      local py = y - 1
      for x = 1, tiles_x do
        local px = x - 1
        local color = vec4(data:getPixel(px, py))

        if is_start[color] then
          table.insert(start_x, x)
          table.insert(start_y, y)
        end

        local tile = tile_of[color]
        if tile then
          Map.set_tile_at(result, x, y, tile)
        end

        local item = item_of[color]
        if item then
          Map.set_item_at(result, x, y, item)
        end
      end
    end
    return Map(result)
  end
end

function Map.load_lua (level)
  local fn = loadfile ( ("app/level/%s.lua"):format(level) )
  local status, result = pcall(fn)
  if not status then
    print("Error loading level", result)
    result = {
      start_x = {4};
      start_y = {4};
      tiles_x = 4;
      tiles_y = 4;
      items = {"GOAL"}
    }
  end
  return Map(result)
end

return Map
