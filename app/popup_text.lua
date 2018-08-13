local Global                  = require "app.Global"

local quads = {}
local image = love.graphics.newImage("res/popup/text-font.png")

local STR=[[ABCDEFGHIJKLMNOPQRSTUVWXYZ.,:;0123456789!?+-*/"'()]]
for i = 1, #STR do
  local index = i-1
  local x = 1 + (index%10)*6
  local y = 1 + math.floor(index/10)*8

  local c = STR:sub(i,i)
  quads[c] = love.graphics.newQuad(x, y, 5, 8, image:getDimensions())
end

return function (text, x, y)
  local scale = Global.SCALE
  local text = tostring(text or ""):upper()
  local dx, dy = 0, 0
  for i = 1, #text do
    local c = text:sub(i,i)
    local quad = quads[c]
    if quad then
      love.graphics.draw(image, quad, (x+dx)*scale, (y+dy)*scale, 0, scale, scale)
    end
    dx = dx + 6
    if c == "\n" then dx, dy = 0, dy + 8 end
  end
end
