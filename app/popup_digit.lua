local Global                  = require "app.Global"

local quads = {}
local image = love.graphics.newImage("res/popup/digits.png")
for i = 0, 9 do
  quads[i] = love.graphics.newQuad(1 + i*7, 1, 6, 10, image:getDimensions())
end

return function (number, x, y)
  local scale = Global.SCALE
  local quad = quads[number]
  if not quad then return end
  love.graphics.draw(image, quad, x*scale, y*scale, 0, scale, scale)
end
