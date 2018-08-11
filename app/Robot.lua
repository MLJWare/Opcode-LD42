local Direction               = require "app.Direction"
local Program                 = require "app.Program"

local Robot = {}
Robot.__index = Robot

function Robot:execute(commands)
  self.program = Program(commands)
end


local action_for = {
  ["up"] = function (self, count)
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
  ["down"] = function (self, count)
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
  ["left"] = function (self, count)
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
  ["right"] = function (self, count)
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
  ["goto"] = function (self, line)
    return function (self, map, dt)
      self:set_action(nil)
      return line
    end
  end;
  ["var"] = function (self, id, val)
    return function (self, map, dt)
      self.vars[id] = val
      self:set_action(nil)
    end
  end;
  ["dec"] = function (self, id, val)
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
  ["jmple"] = function (self, id, val, line)
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
  ["inspect"] = function (self)
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

function Robot:set_action(command, ...)
  self.action = command and action_for[command](self, ...)
end

function Robot:update(map, dt)
  local action = self.action
  if action then
    self.state = action(self, map, dt)
    return
  end

  local program = self.program
  if not program then return end
  local command, a, b, c, d = program(self.state)
  if not command then
    self.program = nil
  else
    self:set_action(command, a, b, c, d)
  end
end

return setmetatable(Robot, {
  __call = function (_, robot)
    assert(type(robot.x)=="number")
    assert(type(robot.y)=="number")
    setmetatable(robot, Robot)
    robot.dir = 1;
    robot.idle = true
    robot.move_speed = 2
    robot.vars = {}
    robot.inventory = {}
    return robot
  end
})
