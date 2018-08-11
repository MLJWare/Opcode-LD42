local rgb                     = require "app.util.color.rgb"
local rgba                    = require "app.util.color.rgba"
local vec3                    = require "app.util.color.vec3"
local vec4                    = require "app.util.color.vec4"
local Robot                   = require "app.Robot"
local Map                     = require "app.Map"

local TILE_SIZE = 64
local function r2l(x) return x/TILE_SIZE end
local function l2r(x) return math.floor(x*TILE_SIZE) end
local function r2t(x) return math.floor(x/TILE_SIZE) end

local game_scene = {}

local map, robot

function game_scene.on_enter(level)
  map = Map.load_png(level)

 robot = Robot{
   x = map.start_x[1];
   y = map.start_y[1];
 }
end

function game_scene.update(dt)
  robot:update(map, dt)
end

function game_scene.keypressed(key, scancode, isrepeat)
  if key == "escape" then
    setScene("level-select")
    return
  end

  if robot.idle and key == "space" then
    robot:execute {
      {"up",    5};
      {"inspect" };
      {"right", 5};
      {"inspect" };
    }
  end
end

function game_scene.draw()
  game_scene.draw_tiles()
  game_scene.draw_start_tiles()
  game_scene.draw_robot()
end

function game_scene.draw_start_tiles()
  love.graphics.setColor(vec3(0.07, 0.68, 0.0))
  love.graphics.setLineWidth(4)
  for i = 1, #map.start_x do
    local x = map.start_x[i]
    local y = map.start_y[i]

    local render_x = l2r(x-0.75)
    local render_y = l2r(y-0.75)
    love.graphics.rectangle("line", render_x, render_y, TILE_SIZE/2, TILE_SIZE/2)
  end
  love.graphics.setLineWidth(1)
end

function game_scene.draw_tiles()
  for y = 1, map.tiles_y do
    local render_y = l2r(y-1)
    for x = 1, map.tiles_x do
      local render_x = l2r(x-1)
      local tile = map:get_tile_at(x, y)
      if tile == "WALL" then
        love.graphics.setColor(vec3(0.31, 0.31, 0.31))
        love.graphics.rectangle("fill", render_x, render_y, TILE_SIZE, TILE_SIZE)
      else
        love.graphics.setColor(vec3(1,1,1))
        love.graphics.rectangle("fill", render_x, render_y, TILE_SIZE, TILE_SIZE)
      end
      local item = map:get_item_at(x, y)
      if item == "FLOPPY" then
        love.graphics.setColor(vec3(0.34, 0.65, 0.86))
        love.graphics.circle("fill", l2r(x-.5), l2r(y-.5), l2r(0.4), 4)
      elseif item == "GOAL" then
        love.graphics.setColor(vec3(0.16, 0.67, 0.25))
        love.graphics.rectangle("fill", render_x, render_y, TILE_SIZE, TILE_SIZE)

      end
      love.graphics.setColor(vec3(0.0, 0.0, 0.0))
      love.graphics.rectangle("line", render_x, render_y, TILE_SIZE, TILE_SIZE)
    end
  end
end

function game_scene.draw_robot()
  love.graphics.setColor(vec3(0.14, 0.09, 0.48))
  love.graphics.circle("fill", l2r(robot.x-.5), l2r(robot.y-.5), TILE_SIZE/2)
end

return game_scene
