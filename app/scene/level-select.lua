local rgb                     = require "app.util.color.rgb"
local rgba                    = require "app.util.color.rgba"
local vec3                    = require "app.util.color.vec3"
local vec4                    = require "app.util.color.vec4"
local Global                  = require "app.Global"
local contains_mouse          = require "app.util.contains_mouse"

local level_select_scene = {}


local SLOT_SIZE

local draw_level_tile
do
  local img = love.graphics.newImage("res/level-select/tiles.png")
  img:setFilter("nearest", "nearest")
  SLOT_SIZE = math.floor(img:getWidth()/4)
  local quads = {}
  for y = 1, 4 do
    local qy = (y-1)*SLOT_SIZE
    for x = 1, 4 do
      local qx = (x-1)*SLOT_SIZE
      quads[x + (y-1)*4] = love.graphics.newQuad(qx, qy, SLOT_SIZE, SLOT_SIZE, img:getDimensions())
    end
  end
  function draw_level_tile(level_id, x, y, r)
    local quad = quads[1 + level_id]
    if not quad then return end
    love.graphics.draw(img, quad, x, y)
  end
end

local levels = {}

local _mouse_over = nil

for y = 1, 4 do
  local ry = (y-1)*(SLOT_SIZE + 4) + 8
  for x = 1, 4 do
    local rx = (x-1)*(SLOT_SIZE + 4) + 8
    local level_id = (x-1) + (y-1)*4
    levels[1 + level_id] = {
      x = rx;
      y = ry;
      width  = SLOT_SIZE;
      height = SLOT_SIZE;
      open = level_id < 3;
      id = level_id;
      contains = contains_mouse;

      draw = function (self)
        if not self.open then
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

function level_select_scene.on_enter()
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
