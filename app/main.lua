local rgb                     = require "app.util.color.rgb"
local try_delegate            = require "app.util.try.delegate"
local Global                  = require "app.Global"
local main = {}

local background = love.graphics.newImage("res/background.png")
--background:setWrap("repeat", "repeat")

local current_scene

function setScene(scene, ...)
  if current_scene then
    try_delegate(current_scene, "on_exit")
  end
  current_scene = scene and (require ("app.scene."..scene))
  if current_scene then
    try_delegate(current_scene, "on_enter", ...)
  end
end

setScene("title")

function main.update(dt)
  try_delegate(current_scene, "update", dt)
end

function love.keypressed(key, scancode, isrepeat)
  try_delegate(current_scene, "keypressed", key, scancode, isrepeat)
end

function love.mousereleased(mx, my, button, isTouch)
  mx = mx - Global.OFFSET_X
  my = my - Global.OFFSET_Y
  try_delegate(current_scene, "mousereleased", mx, my, button, isTouch)
end

function love.mousepressed(mx, my, button, isTouch)
  mx = mx - Global.OFFSET_X
  my = my - Global.OFFSET_Y
  try_delegate(current_scene, "mousepressed", mx, my, button, isTouch)
end

do
  local _getMousePosition = love.mouse.getPosition

  function love.mouse.getPosition()
    print("here")
    local mx, my = _getMousePosition()
    mx = mx - Global.OFFSET_X
    my = my - Global.OFFSET_Y
    return mx, my
  end
end

function love.mousemoved(mx, my, dx, dy)
  mx = mx - Global.OFFSET_X
  my = my - Global.OFFSET_Y
  try_delegate(current_scene, "mousemoved", mx, my, dx, dy)
end

function main.draw()
  local scale = Global.SCALE
  love.graphics.push()
  love.graphics.translate(Global.OFFSET_X, Global.OFFSET_Y)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(background, -126*scale, -76*scale, 0, scale, scale)
  try_delegate(current_scene, "draw")
  love.graphics.pop()
end

return main
