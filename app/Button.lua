local Global                  = require "app.Global"
local Images                  = require "app.Images"
local contains_mouse          = require "app.util.contains_mouse"

local MB_LEFT   = 1
local MB_RIGHT  = 2
local MB_MIDDLE = 3

local Button = {}
Button.__index = Button

function Button:draw()
  local scale = Global.SCALE
  local scale2 = scale*self.upscale
  local x = self.x * scale
  local y = self.y * scale

  local down = love.mouse.isDown(1)
  local held = self.held
  local over = self:contains(love.mouse.getPosition())
  local image = (held and over) and self.image_down or self.image
  love.graphics.setColor(1,1,1)
  love.graphics.draw(image, x, y, 0, scale2, scale2)

  if held and not down then
    self.held = nil
    if over then self:on_click() end
  end
end

function Button:mousepressed(mx, my, button, isTouch)
  if button ~= MB_LEFT then return end
  self.held = self:contains(mx, my)
end

Button.contains = contains_mouse

return setmetatable(Button, {
  __call = function (_, button)
    assert(type(button.x)=="number", "Missing numeric 'x' property.")
    assert(type(button.y)=="number", "Missing numeric 'y' property.")
    assert(type(button.on_click)=="function", "Missing 'on_click' callback.")
    local id = button.id assert(type(id)=="string", "Missing 'id' text property.")
    setmetatable(button, Button)

    button.upscale = tonumber(button.upscale) or 1

    local image      = Images.get("code-editor/button/"..id)
    local image_down = Images.get("code-editor/button/"..id.."_down")
    local img_w, img_h = image:getDimensions()

    button.image      = image
    button.image_down = image_down
    button.width      = img_w
    button.height     = img_h

    return button
  end
})
