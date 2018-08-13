local rgb                     = require "app.util.color.rgb"
local rgba                    = require "app.util.color.rgba"
local vec3                    = require "app.util.color.vec3"
local vec4                    = require "app.util.color.vec4"
local Global                  = require "app.Global"
local Button                  = require "app.Button"

local MB_LEFT   = 1
local MB_RIGHT  = 2
local MB_MIDDLE = 3

local title_scene = {}

local title_image = love.graphics.newImage("res/title-scene.png")

local start_button = Button {
  id       = "Compile";
  x        = 79;
  y        = 77;
  upscale  = 3;
  on_click = function (self) setScene("level-select") end;
}

function title_scene.on_enter()
end

function title_scene.on_exit()
end

function title_scene.update(dt)
end

function title_scene.keypressed(key, scancode, isrepeat)
  if isrepeat then return end
  if key == "space" or key == "return" then
    setScene ("level-select")
  end
end

function title_scene.mousepressed(mx, my, button, isTouch)
  start_button:mousepressed(mx, my, button, isTouch)
end

function title_scene.draw()
  local dw, dh = love.graphics.getDimensions()
  local scale = Global.SCALE
  love.graphics.draw(title_image, -126*scale, -76*scale, 0, scale, scale)
  start_button:draw(scale)
end

return title_scene
