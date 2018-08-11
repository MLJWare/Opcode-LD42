local rgb                     = require "app.util.color.rgb"
local rgba                    = require "app.util.color.rgba"
local vec3                    = require "app.util.color.vec3"
local vec4                    = require "app.util.color.vec4"
local Robot                   = require "app.Robot"
local Map                     = require "app.Map"
local Direction               = require "app.Direction"
local Images                  = require "app.Images"

local TILE_SIZE = 16
local SCALE = 4
local RENDER_TILE_SIZE = TILE_SIZE*SCALE

local LEFT_PAD = 18
local TOP_PAD  = 3


local OPCODES = {
  "ADD";
  "DIV";
  "DOWN";
  "INSPECT";
  "JUMP";
  "JUMP_LEQ";
  "LEFT";
  "MUL";
  "RIGHT";
  "SUB";
  "UP";
}

local function r2l(x) return x/RENDER_TILE_SIZE end
local function l2r(x) return math.floor(x*RENDER_TILE_SIZE) end
local function r2t(x) return math.floor(x/RENDER_TILE_SIZE) end

local code_editor_scene = {}

local map, robot

local function draw_image_direct(image_path, x, y, angle, ox, oy, scale)
  scale, ox, oy = scale or 1, ox or 0, oy or 0
  local img = Images.get(image_path)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(img, x, y, angle or 0, scale, scale, ox, oy)
end

local function draw_image_tiled(image_path, x, y, angle, scale)
  draw_image_direct(image_path, l2r(x-.5), l2r(y-.5), angle, 8, 8, SCALE)
end


function code_editor_scene.on_enter(level)
  map = Map.load_png(level)
  robot = Robot{
    x = map.start_x[1];
    y = map.start_y[1];
  }
end

function code_editor_scene.update(dt)
  robot:update(map, dt)
end

function code_editor_scene.keypressed(key, scancode, isrepeat)
  if key == "escape" then
    setScene("level-select")
    return
  end



  if robot.idle and key == "return" then
    robot:execute {
      {"up",    5};
      {"inspect" };
      {"right", 5};
      {"inspect" };
    }
  end
end

function code_editor_scene.draw()
  love.graphics.push()
  love.graphics.setColor(1,1,1)
  love.graphics.draw(Images.get("code-editor/Board"), 0, 0, 0, SCALE, SCALE)

  love.graphics.translate(SCALE*LEFT_PAD, SCALE*TOP_PAD)
  code_editor_scene.draw_tiles()
  code_editor_scene.draw_start_tiles()
  code_editor_scene.draw_robot()
  love.graphics.pop()

  local x, y = 10.4, 1.1

  draw_image_tiled("code-editor/UP", x, y, 0, SCALE)
  x, y = x + 2.2, y
  draw_image_tiled("code-editor/RIGHT", x, y, 0, SCALE)
  x, y = x - 2.2, y + 1.1
  draw_image_tiled("code-editor/DOWN", x, y, 0, SCALE)
  x, y = x + 2.2, y
  draw_image_tiled("code-editor/LEFT", x, y, 0, SCALE)
  x, y = x - 2.2, y + 1.1
  draw_image_tiled("code-editor/INSPECT", x, y, 0, SCALE)
  x, y = x + 1.1, y
  draw_image_tiled("code-editor/JUMP", x, y, 0, SCALE)
  x, y = x + 1.1, y
  draw_image_tiled("code-editor/JUMP_LEQ", x, y, 0, SCALE)
  x, y = x - 2.2, y + 1.1
  draw_image_tiled("code-editor/ADD", x, y, 0, SCALE)
  x, y = x, y + 1.1
  draw_image_tiled("code-editor/SUB", x, y, 0, SCALE)
  x, y = x, y + 1.1
  draw_image_tiled("code-editor/MUL", x, y, 0, SCALE)
  x, y = x, y + 1.1
  draw_image_tiled("code-editor/DIV", x, y, 0, SCALE)
end

function code_editor_scene.draw_start_tiles()
  love.graphics.setColor(vec3(0.07, 0.68, 0.0))
  love.graphics.setLineWidth(4)
  for i = 1, #map.start_x do
    local x = map.start_x[i]
    local y = map.start_y[i]

    local render_x = l2r(x-0.75)
    local render_y = l2r(y-0.75)
    love.graphics.rectangle("line", render_x, render_y, RENDER_TILE_SIZE/2, RENDER_TILE_SIZE/2)
  end
  love.graphics.setLineWidth(1)
end


function code_editor_scene.draw_tiles()
  for y = 1, map.tiles_y do
    for x = 1, map.tiles_x do
      code_editor_scene.try_draw_tile(x, y)
      code_editor_scene.try_draw_item(x, y)
    end
  end
end

function code_editor_scene.try_draw_tile(x, y)
  local tile = map:get_tile_at(x, y) if not tile then return end

  if tile == "WALL" then
    love.graphics.setColor(vec3(0.31, 0.31, 0.31))
    love.graphics.rectangle("fill", l2r(x), l2r(y), RENDER_TILE_SIZE, RENDER_TILE_SIZE)
  end
end

function code_editor_scene.try_draw_item(x, y)
  local item = map:get_item_at(x, y) if not item then return end

  if item == "FLOPPY" then
    draw_image_tiled("game/floppy", x, y)
  elseif item == "GOAL" then
    draw_image_tiled("game/goal", x, y)
  end
end

function code_editor_scene.draw_robot()
  draw_image_tiled("game/robot", robot.x, robot.y, Direction.angle(robot.dir))
end

return code_editor_scene
