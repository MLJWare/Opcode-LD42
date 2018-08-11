local rgb                     = require "app.util.color.rgb"
local rgba                    = require "app.util.color.rgba"
local vec3                    = require "app.util.color.vec3"
local vec4                    = require "app.util.color.vec4"

local SCALE = 3

local level_select_scene = {}

local draw_level_tile
do
  local img = love.graphics.newImage("res/level-select/tiles.png")
  img:setFilter("nearest", "nearest")
  local quads = {}
  for y = 1, 2 do
    local qy = (y-1)*32
    for x = 1, 8 do
      local qx = (x-1)*32
      quads[x + (y-1)*8] = love.graphics.newQuad(qx, qy, 32, 32, img:getDimensions())
    end
  end
  function draw_level_tile(level_id, x, y, r)
    local quad = quads[level_id]
    if not quad then return end
    love.graphics.draw(img, quad, x, y)
  end
end

local levels = {}

local _mouse_over = nil

local SLOT_SIZE = 32

for y = 1, 4 do
  local ry = (y-1)*(SLOT_SIZE + 4) + 8
  for x = 1, 4 do
    local rx = (x-1)*(SLOT_SIZE + 4) + 8
    local level_id = x + (y-1)*4
    levels[level_id] = {
      x = rx;
      y = ry;
      open = level_id < 3;
      id = level_id;
      contains = function (self, mx, my)
        local x, y, size = self.x*SCALE, self.y*SCALE, SLOT_SIZE*SCALE
        return x <= mx and y <= my and mx < x + size and my < y + size
      end;

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
  love.graphics.scale(SCALE, SCALE)
  for _, level in ipairs(levels) do
    level:draw()
  end
  love.graphics.pop()
end

return level_select_scene
