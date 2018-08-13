local rgb                     = require "app.util.color.rgb"
local rgba                    = require "app.util.color.rgba"
local vec3                    = require "app.util.color.vec3"
local vec4                    = require "app.util.color.vec4"
local Global                  = require "app.Global"
local Button                  = require "app.Button"
local Images                  = require "app.Images"
local popup_digits            = require "app.popup_digits"

local MB_LEFT   = 1
local MB_RIGHT  = 2
local MB_MIDDLE = 3

local won_popup = {}

local OFFSET_X, OFFSET_Y
local back_image = love.graphics.newImage("res/popup/win/back.png")
do
  local img_x, img_y = back_image:getDimensions()
  local origin_x = math.floor(img_x/2)
  local origin_y = math.floor(img_y/2)
  local center_x = Global.CENTER_X
  local center_y = Global.CENTER_Y

  OFFSET_X = center_x - origin_x
  OFFSET_Y = center_y - origin_y
end

local LEFT_BUTTON_X  = 11 + OFFSET_X
local RIGHT_BUTTON_X = 51 + OFFSET_X
local BUTTON_Y       = 56 + OFFSET_Y

local buttons = {
  Button{
    id       = "Next";
    x        = LEFT_BUTTON_X;
    y        = BUTTON_Y;
    on_click = function (self)
      setPopup(nil)
      setScene("level-select")
    end;
  };
  Button{
    id       = "Redo";
    x        = RIGHT_BUTTON_X;
    y        = BUTTON_Y;
    on_click = function (self)
      setPopup(nil)
    end;
  }
}

local actual_floppy_count, max_floppy_count
function won_popup.on_enter(scene, robot, map)
  actual_floppy_count = table.count(robot.inventory, "FLOPPY")
  max_floppy_count    = map.item_count["FLOPPY"] or 0
end

function won_popup.on_exit()
end

function won_popup.update(dt)
end

function won_popup.keypressed(key, scancode, isrepeat)
  if key == "space" or key == "return" then
    setPopup (nil)
  end
end

function won_popup.mousepressed(mx, my, button, isTouch)
  if button == MB_LEFT then
    for _, btn in ipairs(buttons) do
      btn.held = btn:contains(mx, my)
    end
  end
end

function won_popup.draw()
  local scale = Global.SCALE
  love.graphics.draw(back_image, OFFSET_X*scale, OFFSET_Y*scale, 0, scale, scale)
  popup_digits(actual_floppy_count, 2, OFFSET_X+39, OFFSET_Y+39)
  popup_digits(max_floppy_count   , 2, OFFSET_X+63, OFFSET_Y+39)
  won_popup.draw_buttons()
end

function won_popup.draw_buttons()
  local scale = Global.SCALE
  for _, button in ipairs(buttons) do
    button:draw(scale)
  end
end

return won_popup
