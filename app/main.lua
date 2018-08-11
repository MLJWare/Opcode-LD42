local rgb                     = require "app.util.color.rgb"
local rgba                    = require "app.util.color.rgba"
local vec3                    = require "app.util.color.vec3"
local vec4                    = require "app.util.color.vec4"
local try_delegate            = require "app.util.try.delegate"
local main = {}

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
  try_delegate(current_scene, "mousereleased", mx, my, button, isTouch)
end

function love.mousepressed(mx, my, button, isTouch)
  try_delegate(current_scene, "mousepressed", mx, my, button, isTouch)
end

function love.mousemoved(mx, my, dx, dy)
  try_delegate(current_scene, "mousemoved", mx, my, dx, dy)
end

function main.draw()
  try_delegate(current_scene, "draw")
end

return main
