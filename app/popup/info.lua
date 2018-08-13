local Global                  = require "app.Global"
local Button                  = require "app.Button"
local popup_text              = require "app.popup_text"
local Images                  = require "app.Images"

local MB_LEFT   = 1
local MB_RIGHT  = 2
local MB_MIDDLE = 3

local text_popup = {}

local OFFSET_X, OFFSET_Y
local SIZE_X, SIZE_Y

local back_image = love.graphics.newImage("res/popup/info/back.png")
do
  SIZE_X, SIZE_Y = back_image:getDimensions()
  origin_x = math.floor(SIZE_X/2)
  origin_y = math.floor(SIZE_Y/2)
  local center_x = Global.CENTER_X
  local center_y = Global.CENTER_Y

  OFFSET_X = center_x - origin_x - 28
  OFFSET_Y = center_y - origin_y - 18
end

local TEXT_DX =  4
local TEXT_DY = 33

local TEXT_X = OFFSET_X + TEXT_DX
local TEXT_Y = OFFSET_Y + TEXT_DY

local BUTTON_X = 57 + OFFSET_X
local BUTTON_Y = 74 + OFFSET_Y

local function _goto_next()
  setPopup(nil)
  if text_popup.on_click then
    text_popup.on_click()
  end
end

local next_button = Button{
  id       = "Next";
  x        = BUTTON_X;
  y        = BUTTON_Y;
  on_click = _goto_next;
}

function text_popup.on_enter(text, on_click)
  text_popup.on_click = on_click
  text = tostring(text or "")
  local _, stop, icon = text:find("^!([^\n]*)")
  if icon then
    text = text:sub(stop+2)
    icon = Images.get(icon)
    text_popup.icon = icon
    text_popup.icon_x = -8 + SIZE_X + TEXT_X - icon:getWidth() - 2*TEXT_DX
    text_popup.icon_y =  8 + TEXT_Y
  end
  text_popup.text = text
end

function text_popup.keypressed(key, scancode, isrepeat)
  if isrepeat then return end
  if key == "space" or key == "return" or key == "escape" then
    _goto_next()
  end
end

function text_popup.mousepressed(mx, my, button, isTouch)
  next_button:mousepressed(mx, my, button, isTouch)
end

function text_popup.draw()
  local scale = Global.SCALE
  love.graphics.setColor(1,1,1)
  love.graphics.draw(back_image, OFFSET_X*scale, OFFSET_Y*scale, 0, scale, scale)
  popup_text(text_popup.text or "", TEXT_X, TEXT_Y)
  next_button:draw(scale)
  local icon = text_popup.icon
  if icon then
    local icon_x = text_popup.icon_x
    local icon_y = text_popup.icon_y
    love.graphics.draw(icon, icon_x*scale, icon_y*scale, 0, scale, scale)
  end
end

return text_popup
