local Direction               = require "app.Direction"

return {
  ["UP"] = function (self, count)
    local target_y = self.y - math.round(count)
    return function (self, map, dt)
      self.dir = Direction.UP
      local old_y = math.ceil(self.y)
      local tile = map:get_tile_at(self.x, old_y - 1)
      if tile == "WALL" then
        self.y = old_y
        self:set_action("wait", self.y - target_y)
        return
      end
      self.y = self.y - dt*self.move_speed
      if self.y <= target_y then
        self.y = target_y
        self:set_action(nil)
      end
    end
  end;
  ["DOWN"] = function (self, count)
    local target_y = self.y + math.round(count)
    return function (self, map, dt)
      self.dir = Direction.DOWN
      local old_y = math.floor(self.y)
      local tile = map:get_tile_at(self.x, old_y + 1)
      if tile == "WALL" then
        self.y = old_y
        self:set_action("wait", target_y - self.y)
        return
      end
      self.y = self.y + dt*self.move_speed
      if self.y >= target_y then
        self.y = target_y
        self:set_action(nil)
      end
    end
  end;
  ["LEFT"] = function (self, count)
    local target_x = self.x - math.round(count)
    return function (self, map, dt)
      self.dir = Direction.LEFT
      local old_x = math.ceil(self.x)
      local tile = map:get_tile_at(old_x - 1, self.y)
      if tile == "WALL" then
        self.x = old_x
        self:set_action("wait", self.x - target_x)
        return
      end
      self.x = self.x - dt*self.move_speed
      if self.x <= target_x then
        self.x = target_x
        self:set_action(nil)
      end
    end
  end;
  ["RIGHT"] = function (self, count)
    local target_x = self.x + math.round(count)
    return function (self, map, dt)
      self.dir = Direction.RIGHT
      local old_x = math.floor(self.x)
      local tile = map:get_tile_at(old_x + 1, self.y)
      if tile == "WALL" then
        self.x = old_x
        self:set_action("wait", target_x - self.x)
        return
      end
      self.x = self.x + dt*self.move_speed
      if self.x >= target_x then
        self.x = target_x
        self:set_action(nil)
      end
    end
  end;
  ["JUMP"] = function (self, line)
    return function (self, map, dt)
      self:set_action(nil)
      return line
    end
  end;
  ["SET"] = function (self, id, val)
    return function (self, map, dt)
      self.vars[id] = val
      self:set_action(nil)
    end
  end;
  ["SUB"] = function (self, id, val)
    return function (self, map, dt)
      local var = self.vars[id]
      if not var then
        love.window.showMessageBox("Compiler Error", "Undefined variable "..id)
      else
        self.vars[id] = var - val
      end
      self:set_action(nil)
    end
  end;
  ["JUMP_LEQ"] = function (self, id, val, line)
    return function (self, map, dt)
      local var = self.vars[id]
      if not var then
        love.window.showMessageBox("Compiler Error", "Undefined variable "..id)
      elseif var <= val then
        return line
      end
      self:set_action(nil)
    end
  end;
  ["INSPECT"] = function (self)
    return function (self, map, dt)
      local item = map:get_item_at(self.x, self.y)
      if item == "GOAL" then
        love.window.showMessageBox("HURRAY", "Items: \n"..(table.concat(self.inventory, ",\n")))
      elseif item then
        table.insert(self.inventory, item)
        map:set_item_at(self.x, self.y, nil)
      end
      self:set_action(nil)
    end
  end;
  ["wait"] = function (self, time)
    print("wait", time)
    return function (self, map, dt)
      time = time - dt
      if time <= 0 then
        self:set_action(nil)
      end
    end
  end;
}
