local Global                  = require "app.Global"
return function (self, mx, my)
  local scale = Global.SCALE
  local scale2 = scale*(self.upscale or 1)
  local x, y, w, h = self.x*scale, self.y*scale, self.width*scale2, self.height*scale2
  return x <= mx and y <= my and mx < x + w and my < y + h
end
