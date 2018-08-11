local Global                  = require "app.Global"
return function (self, mx, my)
  local scale = Global.SCALE
  local x, y, w, h = self.x*scale, self.y*scale, self.width*scale, self.height*scale
  return x <= mx and y <= my and mx < x + w and my < y + h
end
