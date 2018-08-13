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

local current_popup

function setPopup(popup, ...)
  if current_popup then
    try_delegate(current_popup, "on_exit")
  end
  current_popup = popup and (require ("app.popup."..popup))
  if current_popup then
    try_delegate(current_popup, "on_enter", ...)
  end
end

setScene("title")

function main.delegate(event, a, b, c, d, e, f, g)
  if current_popup then
    try_delegate(current_popup, event, a, b, c, d, e, f, g)
  else
    try_delegate(current_scene, event, a, b, c, d, e, f, g)
  end
end

function main.update(dt)
  main.delegate("update", dt)
end

function love.keypressed(key, scancode, isrepeat)
    main.delegate("keypressed", key, scancode, isrepeat)
end

function love.mousereleased(mx, my, button, isTouch)
  mx = mx - Global.OFFSET_X
  my = my - Global.OFFSET_Y
  main.delegate("mousereleased", mx, my, button, isTouch)
end

function love.mousepressed(mx, my, button, isTouch)
  mx = mx - Global.OFFSET_X
  my = my - Global.OFFSET_Y
  main.delegate("mousepressed", mx, my, button, isTouch)
end

do
  local _getMousePosition = love.mouse.getPosition

  function love.mouse.getPosition()
    local mx, my = _getMousePosition()
    mx = mx - Global.OFFSET_X
    my = my - Global.OFFSET_Y
    return mx, my
  end
end

function love.mousemoved(mx, my, dx, dy)
  mx = mx - Global.OFFSET_X
  my = my - Global.OFFSET_Y
  main.delegate("mousemoved", mx, my, dx, dy)
end

function main.draw()
  local scale = Global.SCALE
  love.graphics.push()
  love.graphics.translate(Global.OFFSET_X, Global.OFFSET_Y)
  love.graphics.setColor(1,1,1)
  love.graphics.draw(background, -126*scale, -76*scale, 0, scale, scale)
  try_delegate(current_scene, "draw")
  try_delegate(current_popup, "draw")
  love.graphics.pop()
end

return main
