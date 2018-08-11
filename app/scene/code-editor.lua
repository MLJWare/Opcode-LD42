local Board                   = require "app.Board"
local Robot                   = require "app.Robot"
local Opcode                  = require "app.Opcode"
local Map                     = require "app.Map"
local Direction               = require "app.Direction"
local Images                  = require "app.Images"
local Global                  = require "app.Global"

local contains_mouse          = require "app.util.contains_mouse"
local rgb                     = require "app.util.color.rgb"
local rgba                    = require "app.util.color.rgba"
local vec3                    = require "app.util.color.vec3"
local vec4                    = require "app.util.color.vec4"

local TILE_SIZE      =  16
local CODE_FIELD_X   =  18
local CODE_FIELD_Y   =   3
local CODE_PALETTE_X = 153
local CODE_PALETTE_Y =   3

local function r2l(x) return x/(TILE_SIZE*Global.SCALE) end
local function l2r(x) return math.floor(x*(TILE_SIZE*Global.SCALE)) end
local function r2t(x) return math.floor(x/(TILE_SIZE*Global.SCALE)) end

local code_editor = {}

local _opcode_moving = nil
local _opcode_moving_dx = 0
local _opcode_moving_dy = 0
local _opcode_moving_can_place = true
local _opcode_moving_tile_x = 0
local _opcode_moving_tile_y = 0

local map, robot

local function draw_image_direct(image_path, x, y, angle, ox, oy, scale)
  scale, ox, oy = scale or 1, ox or 0, oy or 0
  local img = Images.get(image_path)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(img, x, y, angle or 0, scale, scale, ox, oy)
end

local function draw_image_tiled(image_path, x, y, angle, scale)
  draw_image_direct(image_path, l2r(x-.5), l2r(y-.5), angle, 8, 8, Global.SCALE)
end

local function draw_OPCODE (self)
  local scale = Global.SCALE

  local x, y
  if _opcode_moving == self then
    local mx, my = love.mouse.getPosition()
    x = mx - _opcode_moving_dx
    y = my - _opcode_moving_dy
  else
    x = l2r(self.x) + CODE_PALETTE_X*scale
    y = l2r(self.y) + CODE_PALETTE_Y*scale
  end
  draw_image_direct("code-editor/"..self.id, x, y, 0, 0, 0, scale)
end

local function make_OPCODE (self)
  return Opcode {
    id = self.id;
  }
end

local function OpcodeTemplate(opcode)
  local image = Images.get("code-editor/"..opcode.id)

  local img_w, img_h = image:getDimensions()
  opcode.width    = img_w
  opcode.height   = img_h
  opcode.tiles_x  = r2t(img_w*Global.SCALE)
  opcode.tiles_y  = r2t(img_h*Global.SCALE)
  opcode.image    = image
  opcode.draw     = draw_OPCODE
  opcode.contains = contains_mouse
  opcode.make     = make_OPCODE
  return opcode
end

local OPCODES = {
  OpcodeTemplate { id = "UP"      ; x = 0; y = 0; };
  OpcodeTemplate { id = "RIGHT"   ; x = 2; y = 0; };
  OpcodeTemplate { id = "DOWN"    ; x = 0; y = 1; };
  OpcodeTemplate { id = "LEFT"    ; x = 2; y = 1; };
  OpcodeTemplate { id = "JUMP"    ; x = 0; y = 2; };
  OpcodeTemplate { id = "JUMP_LEQ"; x = 1; y = 2; };
  OpcodeTemplate { id = "INSPECT" ; x = 3; y = 2; };
  OpcodeTemplate { id = "ADD"     ; x = 0; y = 3; };
  OpcodeTemplate { id = "SUB"     ; x = 2; y = 3; };
  OpcodeTemplate { id = "MUL"     ; x = 0; y = 4; };
  OpcodeTemplate { id = "DIV"     ; x = 2; y = 4; };
}

function code_editor.on_enter(level)
  GLOB_level = level -- DEBUG HACK TODO remove
  map = Map.load_png(level)
  robot = Robot {
    x = map.start_x[1];
    y = map.start_y[1];
  }
  board = Board {
    tiles_x = map.tiles_x;
    tiles_y = map.tiles_y;
  }
end

if GLOB_level then code_editor.on_enter(GLOB_level) end -- DEBUG HACK TODO remove

function code_editor.update(dt)
  robot:update(map, dt)
end

function code_editor.mousepressed(mx, my, button, isTouch)
  _opcode_moving = nil

  local scale = Global.SCALE
  local code_palette_x = CODE_PALETTE_X*scale
  local code_palette_y = CODE_PALETTE_Y*scale

  if mx < code_palette_x or my < code_palette_y then return end

  local mx2 = mx - code_palette_x
  local my2 = my - code_palette_y

  for _, OPCODE in ipairs(OPCODES) do
    local dx = mx2 - l2r(OPCODE.x)
    local dy = my2 - l2r(OPCODE.y)
    if OPCODE:contains(dx, dy) then
      _opcode_moving = OPCODE
      _opcode_moving_dx = dx
      _opcode_moving_dy = dy
      return
    end
  end
end

function code_editor.mousereleased(mx, my, button, isTouch)
  local to_place = _opcode_moving; _opcode_moving = nil
  if not (to_place and _opcode_moving_can_place) then return end

  board:place(to_place, _opcode_moving_tile_x, _opcode_moving_tile_y)
end

function code_editor.keypressed(key, scancode, isrepeat)
  if key == "escape" then
    setScene("level-select")
    return
  end

  if robot.idle and key == "return" then
    robot:execute (board:compile())
  end
end

function code_editor.draw()
  local scale = Global.SCALE

  love.graphics.push()
  love.graphics.setColor(1,1,1)
  love.graphics.draw(Images.get("code-editor/Board"), 0, 0, 0, scale, scale)

  love.graphics.translate(scale*CODE_FIELD_X, scale*CODE_FIELD_Y)
  code_editor.draw_tiles()
  code_editor.draw_start_tiles()
  code_editor.draw_robot()
  love.graphics.pop()

  if _opcode_moving then
    code_editor.draw_opcode_placement_indicator()
  end

  for _, OPCODE in ipairs(OPCODES) do
    OPCODE:draw()
  end
end

function code_editor.draw_start_tiles()
  local half_scaled_tile_size = (TILE_SIZE*Global.SCALE)/2
  love.graphics.setColor(vec3(0.07, 0.68, 0.0))
  love.graphics.setLineWidth(4)
  for i = 1, #map.start_x do
    local x = map.start_x[i]
    local y = map.start_y[i]

    local render_x = l2r(x-0.75)
    local render_y = l2r(y-0.75)
    love.graphics.rectangle("line", render_x, render_y, half_scaled_tile_size, half_scaled_tile_size)
  end
  love.graphics.setLineWidth(1)
end


function code_editor.draw_tiles()
  local scale = Global.SCALE
  local render_tile_size = TILE_SIZE*scale
  for y = 1, map.tiles_y do
    for x = 1, map.tiles_x do
      code_editor.try_draw_tile(x, y)
      code_editor.try_draw_item(x, y)

      local opcode, x2, y2 = board:try_locate(x, y)
      if opcode then
        love.graphics.setColor(1, 1, 1)
        opcode:draw(l2r(x2-1), l2r(y2-1), scale)
      end
    end
  end
end

function code_editor.try_draw_tile(x, y)
  local tile = map:get_tile_at(x, y) if not tile then return end
  if tile == "WALL" then
    local render_tile_size = TILE_SIZE*Global.SCALE
    love.graphics.setColor(vec3(0.31, 0.31, 0.31))
    love.graphics.rectangle("fill", l2r(x-1), l2r(y-1), render_tile_size, render_tile_size)
  end
end

function code_editor.try_draw_item(x, y)
  local item = map:get_item_at(x, y) if not item then return end

  if item == "FLOPPY" then
    draw_image_tiled("game/floppy", x, y)
  elseif item == "GOAL" then
    draw_image_tiled("game/goal", x, y)
  end
end

function code_editor.draw_robot()
  draw_image_tiled("game/robot", robot.x, robot.y, Direction.angle(robot.dir))
end

function code_editor.draw_opcode_placement_indicator()
  local scale = Global.SCALE
  local code_field_x = CODE_FIELD_X*scale
  local code_field_y = CODE_FIELD_Y*scale
  local mx, my = love.mouse.getPosition()
  local tile_dx = r2t((mx - _opcode_moving_dx) - code_field_x)
  local tile_dy = r2t((my - _opcode_moving_dy) - code_field_y)
  local tiles_x = _opcode_moving.tiles_x
  local tiles_y = _opcode_moving.tiles_y

  local render_tile_size = TILE_SIZE*scale

  _opcode_moving_can_place = true
  _opcode_moving_tile_x = 1 + tile_dx
  _opcode_moving_tile_y = 1 + tile_dy

  for yi = 1, tiles_y do
    local y = yi + tile_dy
    for xi = 1, tiles_x do
      local x = xi + tile_dx
      local render_x = l2r(x-1) + code_field_x
      local render_y = l2r(y-1) + code_field_y

      local valid = board:empty_at(x, y)
                and not map:get_item_at(x, y)
                and not map:get_tile_at(x, y)
                and not map:is_start(x, y)

      _opcode_moving_can_place = _opcode_moving_can_place and valid

      local color = valid and vec4(0.15, 0.8, 0.23, 0.7)
                           or vec4(0.69, 0.18, 0.17, 0.7)

      love.graphics.setColor(color)
      love.graphics.rectangle("fill", render_x, render_y, render_tile_size, render_tile_size)
    end
  end
end

return code_editor
