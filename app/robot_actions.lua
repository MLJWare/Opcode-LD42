local Direction               = require "app.Direction"

local actions = {}

actions["MOVE"] = function (self, count)
  if type(count) == "string" then
    count = self.vars[count] or 0
  end
  count = math.max(0, math.round(count))

  local dx, dy = Direction.delta(self.dir)

  local target_x = self.x + dx*count
  local target_y = self.y + dy*count

  return function (self, map, dt)
    local old_x = (dx > 0 and math.floor or math.ceil)(self.x)
    local old_y = (dy > 0 and math.floor or math.ceil)(self.y)
    local tile = map:get_tile_at(old_x + dx, old_y + dy)
    if tile == "WALL" then
      self.x = old_x
      self.y = old_y
      local time = math.abs(old_x - target_x) + math.abs(old_y - target_y)
      self:set_action("wait", time)
      return
    end
    self.anim = self.anim + dt*self.move_speed
    self.x = self.x + dx*dt*self.move_speed
    self.y = self.y + dy*dt*self.move_speed

    if dx > 0 and self.x >= target_x then self.x, dx = target_x, 0 end
    if dx < 0 and self.x <= target_x then self.x, dx = target_x, 0 end
    if dy > 0 and self.y >= target_y then self.y, dy = target_y, 0 end
    if dy < 0 and self.y <= target_y then self.y, dy = target_y, 0 end

    if dx == 0 and dy == 0 then
      self:set_action(nil)
    end
  end
end
actions["MOVE_1"] = function (self)
  return actions["MOVE"](self, 1)
end

actions["TURN_LEFT"] = function (self)
  return function (self)
    self.dir = Direction.turn_left(self.dir)
    self:set_action(nil)
  end
end
actions["TURN_RIGHT"] = function (self)
  return function (self)
    self.dir = Direction.turn_right(self.dir)
    self:set_action(nil)
  end
end
actions["TURN_AROUND"] = function (self)
  return function (self)
    self.dir = Direction.turn_right(Direction.turn_right(self.dir))
    self:set_action(nil)
  end
end

actions["INSPECT"] = function (self)
  return function (self, map, dt)
    local dx, dy = Direction.delta(self.dir)
    local item = map:get_item_at(self.x + dx, self.y + dy)
    if item then
      table.insert(self.inventory, item)
      map:set_item_at(self.x + dx, self.y + dy, nil)
    end
    self:set_action(nil)
  end
end

actions["GOAL"] = function (self)
  return function (self, map, dt)
    local tile = map:get_tile_at(self.x, self.y)
    if tile == "GOAL" then
      self.program = nil
      self.won     = true
    end
    self:set_action(nil)
  end
end

actions["UP"] = function (self, count)
  if type(count) == "string" then
    count = self.vars[count] or 0
  end

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
    self.anim = self.anim + dt*self.move_speed
    self.y = self.y - dt*self.move_speed
    if self.y <= target_y then
      self.y = target_y
      self:set_action(nil)
    end
  end
end
actions["DOWN"] = function (self, count)
  if type(count) == "string" then
    count = self.vars[count] or 0
  end

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
    self.anim = self.anim + dt*self.move_speed
    self.y = self.y + dt*self.move_speed
    if self.y >= target_y then
      self.y = target_y
      self:set_action(nil)
    end
  end
end
actions["LEFT"] = function (self, count)
  if type(count) == "string" then
    count = self.vars[count] or 0
  end

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
    self.anim = self.anim + dt*self.move_speed
    self.x = self.x - dt*self.move_speed
    if self.x <= target_x then
      self.x = target_x
      self:set_action(nil)
    end
  end
end
actions["RIGHT"] = function (self, count)
  if type(count) == "string" then
    count = self.vars[count] or 0
  end

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
    self.anim = self.anim + dt*self.move_speed
    self.x = self.x + dt*self.move_speed
    if self.x >= target_x then
      self.x = target_x
      self:set_action(nil)
    end
  end
end

actions["SUB"] = function (self, id, val)
  return function (self, map, dt)
    if type(val) == "string" then
      val = self.vars[val] or 0
    end
    local var = self.vars[id] or 0
    self.vars[id] = var - val
    self:set_action(nil)
  end
end
actions["ADD"] = function (self, id, val)
  return function (self, map, dt)
    if type(val) == "string" then
      val = self.vars[val] or 0
    end
    local var = self.vars[id] or 0
    self.vars[id] = var + val
    self:set_action(nil)
  end
end
actions["MUL"] = function (self, id, val)
  return function (self, map, dt)
    if type(val) == "string" then
      val = self.vars[val] or 0
    end
    local var = self.vars[id] or 0
    self.vars[id] = var * val
    self:set_action(nil)
  end
end
actions["DIV"] = function (self, id, val)
  return function (self, map, dt)
    if type(val) == "string" then
      val = self.vars[val] or 0
    end
    local var = self.vars[id] or 0
    self.vars[id] = math.trunc(var / val)
    self:set_action(nil)
  end
end


actions["JUMP"] = function (self, line)
  return function (self, map, dt)
    self:set_action(nil)
    return line
  end
end
actions["JUMP_LEQ"] = function (self, id, line)
  return function (self, map, dt)
    local var = self.vars[id] or 0
    self:set_action(nil)
    if var <= 0 then
      return line
    end
  end
end

actions["SET"] = function (self, id, val)
  return function (self, map, dt)
    if type(val) == "string" then
      val = self.vars[val] or 0
    end
    self.vars[id] = val
    self:set_action(nil)
  end
end

actions["wait"] = function (self, time)
  return function (self, map, dt)
    self.anim = self.anim + dt*self.move_speed
    time = time - dt
    if time <= 0 then
      self:set_action(nil)
    end
  end
end

return actions
