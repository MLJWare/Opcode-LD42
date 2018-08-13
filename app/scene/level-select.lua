local vec3                    = require "app.util.color.vec3"
local Global                  = require "app.Global"
local contains_mouse          = require "app.util.contains_mouse"
local SaveData                = require "app.SaveData"

local function is_unlocked(level_id)
  return SaveData.get_bool(level_id.."-UNLOCKED")
end

local level_select_scene = {}

local function is_gold(level_id)
  local floppy_count     = SaveData.get_number(level_id.."-FLOPPY")
  local max_floppy_count = SaveData.get_number(level_id.."-FLOPPY-MAX")
  return floppy_count >= max_floppy_count
end

local SLOT_SIZE

local draw_level_tile
do
  local img      = love.graphics.newImage("res/level-select/tiles.png")
  local img_done = love.graphics.newImage("res/level-select/tiles-done.png")
  local img_gold = love.graphics.newImage("res/level-select/tiles-gold.png")
  local img_w, img_h = img:getDimensions()
  SLOT_SIZE = math.floor(img_w/4)
  local quads      = {}
  for y = 1, 4 do
    local qy = (y-1)*SLOT_SIZE
    for x = 1, 4 do
      local qx = (x-1)*SLOT_SIZE
      local id = x + (y-1)*4
      quads[id] = love.graphics.newQuad(qx, qy, SLOT_SIZE, SLOT_SIZE, img_w, img_h)
    end
  end
  function draw_level_tile(level_id, x, y, r)
    local done  = is_unlocked(level_id + 1)
    local gold  = done and is_gold(level_id)
    local quad  = quads[1 + level_id]
    if not quad then return end
    local image = gold and img_gold
               or done and img_done
               or img
    love.graphics.draw(image, quad, x, y)
  end
end

local levels = {}

local _mouse_over = nil

local slots_x = 5
local slots_y = 3


local isFile
do
  local info = {}
  function isFile(path)
    local info = love.filesystem.getInfo(path, info)
    return info and info.type == "file"
  end
end

for y = 1, slots_y do
  local ry = (y-1)*(SLOT_SIZE + 16) + 13
  for x = 1, slots_x do
    local rx = (x-1)*(SLOT_SIZE + 16) + 14
    local level_id = (x-1) + (y-1)*slots_x
    if level_id > 9 then goto done end

    levels[1 + level_id] = {
      x = rx;
      y = ry;
      width  = SLOT_SIZE;
      height = SLOT_SIZE;
      id = level_id;
      contains = contains_mouse;

      draw = function (self)
        if not is_unlocked(self.id) then
          love.graphics.setColor(vec3(0.27, 0.23, 0.21))
        elseif self:contains(love.mouse.getPosition()) then
          if love.mouse.isDown(1,2,3) then
            _mouse_over = self
            love.graphics.setColor(vec3(0.11, 0.69, 0.11))
          else
            love.graphics.setColor(vec3(0.5, 1, 0.5))
          end
        else
          love.graphics.setColor(vec3(1,1,1))
        end
        draw_level_tile(self.id, self.x, self.y, 0)
      end;
    }
  end
end
::done::

function level_select_scene.on_enter()
  unlockLevel(0)
end

function level_select_scene.on_exit()
end

function level_select_scene.update(dt)
end

function level_select_scene.mousereleased(mx, my, button, isTouch)
  if not _mouse_over then return end
  setScene("code-editor", _mouse_over.id)
end

function level_select_scene.draw()
  _mouse_over = nil

  love.graphics.push()
  local scale = Global.SCALE
  love.graphics.scale(scale, scale)
  for _, level in ipairs(levels) do
    level:draw()
  end
  love.graphics.pop()
end

return level_select_scene
