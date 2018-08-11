local rgba = require "app.util.color.rgba"

return function (r, g, b)
  r = math.floor(r*255)
  g = math.floor(g*255)
  b = math.floor(b*255)
  return rgba(r, g, b, 1)
end
