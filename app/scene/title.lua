local rgb                     = require "app.util.color.rgb"
local rgba                    = require "app.util.color.rgba"
local vec3                    = require "app.util.color.vec3"
local vec4                    = require "app.util.color.vec4"

local title_scene = {}

function title_scene.on_enter()
end

function title_scene.on_exit()
end

function title_scene.update(dt)
end

function title_scene.keypressed(key, scancode, isrepeat)
  if key == "space" or key == "return" then
    setScene ("level-select")
  end
end

function title_scene.mousepressed(mx, my, button, isTouch)
  setScene ("level-select")
end

function title_scene.draw()
  local dw, dh = love.graphics.getDimensions()
  love.graphics.print("Press [space] to start", dw/2, dh/2, 0,2,2, 50)
end

return title_scene
