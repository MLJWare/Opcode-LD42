local Program = require "app.Program"

local function vec3(r, g, b) return r, g, b end
local function vec4(r, g, b, a) return r, g, b, a end

local TILE_SIZE = 64
local function r2l(x) return x/TILE_SIZE end
local function l2r(x) return math.floor(x*TILE_SIZE) end
local function r2t(x) return math.floor(x/TILE_SIZE) end

local main = {}


local map = {
  tiles_x = 8;
  tiles_y = 8;
  items = {};
  tiles = {};
}

function map:set_item_at(x, y, value)
  x, y = math.floor(x), math.floor(y)
  local tiles_x = self.tiles_x
  local tiles_y = self.tiles_y
  if x < 1 or y < 1 or x > tiles_x or y > tiles_y then return end
  local index = x + (y - 1)*tiles_x
  self.items[index] = value
end

function map:get_item_at(x, y)
  x, y = math.floor(x), math.floor(y)
  local tiles_x = self.tiles_x
  local tiles_y = self.tiles_y
  if x < 1 or y < 1 or x > tiles_x or y > tiles_y then return end
  local index = x + (y - 1)*tiles_x
  return self.items[index]
end

function map:set_tile_at(x, y, value)
  x, y = math.floor(x), math.floor(y)
  local tiles_x = self.tiles_x
  local tiles_y = self.tiles_y
  if x < 1 or y < 1 or x > tiles_x or y > tiles_y then return end
  local index = x + (y - 1)*tiles_x
  self.tiles[index] = value
end

function map:get_tile_at(x, y)
  x, y = math.floor(x), math.floor(y)
  local tiles_x = self.tiles_x
  local tiles_y = self.tiles_y
  if x < 1 or y < 1 or x > tiles_x or y > tiles_y then return end
  local index = x + (y - 1)*tiles_x
  return self.tiles[index]
end

map:set_item_at(3, 3, "RAM")
map:set_item_at(3, 6, "GOAL")

map:set_tile_at(4, 5, "WALL")
map:set_tile_at(4, 4, "WALL")

local robot = {
  x = 5;
  y = 6;
  idle = true;
  move_speed = 2;
  vars = {};
  inventory = {};
}

function robot:execute(commands)
  self.program = Program(commands)
end

local function on_tile(x) return math.abs(x - round(x)) < 0.1 end

local function round(x) return math.floor(x + 0.5) end

local action_for = {
  ["up"] = function (self, count)
    local target_y = self.y - round(count)
    return function (self, dt)
      local tile = map:get_tile_at(self.x, self.y - 1)
      if tile == "WALL" then
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
    local target_y = self.y + round(count)
    return function (self, dt)
      local tile = map:get_tile_at(self.x, self.y + 1)
      if tile == "WALL" then
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
    local target_x = self.x - round(count)
    return function (self, dt)
      local tile = map:get_tile_at(self.x - 1, self.y)
      if tile == "WALL" then
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
    local target_x = self.x + round(count)
    return function (self, dt)
      local tile = map:get_tile_at(self.x + 1, self.y)
      if tile == "WALL" then
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
    return function (self, dt)
      self:set_action(nil)
      return line
    end
  end;
  ["var"] = function (self, id, val)
    return function (self, dt)
      self.vars[id] = val
      self:set_action(nil)
    end
  end;
  ["dec"] = function (self, id, val)
    return function (self, dt)
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
    return function (self, dt)
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
    return function (self, dt)
      local item = map:get_item_at(self.x, self.y)
      if item == "GOAL" then
        love.window.showMessageBox("HURRAY", "Items: \n"..(table.concat(self.inventory, ",\n")))
      elseif item then
        table.insert(robot.inventory, item)
        map:set_item_at(self.x, self.y, nil)
      end
      self:set_action(nil)
    end
  end;
  ["wait"] = function (self, time)
    print("wait", time)
    return function (self, dt)
      time = time - dt
      if time <= 0 then
        self:set_action(nil)
      end
    end
  end
}

function robot:set_action(command, ...)
  self.action = command and action_for[command](self, ...)
end

function robot:update(dt)
  local action = self.action
  if action then
    self.state = action(self, dt)
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

local commands = {
  {"up",   2};
  {"left", 2};
  {"inspect"};
  {"down", 3};
  {"inspect"};
  --{"var", "x", 2};
  --{"jmple", "x", 0, 6};
  --{"dec", "x", 1};
  --{"up",    2};
  --{"right", 2};
  --{"down",  2};
  --{"left",  2};
  --{"goto",  2};
}

function main.load(arg)
  -- body...
end

function main.update(dt)
  robot:update(dt)
end

function love.keypressed(key, scancode, isrepeat)
  if robot.idle and key == "space" then
    robot:execute(commands)
  end
end

function main.draw()
  draw_tiles()
  draw_robot()
end

function draw_tiles()
  for y = 1, map.tiles_y do
    local render_y = l2r(y-1)
    for x = 1, map.tiles_x do
      local render_x = l2r(x-1)
      local tile = map:get_tile_at(x, y)
      if tile == "WALL" then
        love.graphics.setColor(vec3(0.31, 0.31, 0.31))
        love.graphics.rectangle("fill", render_x, render_y, TILE_SIZE, TILE_SIZE)
      else
        love.graphics.setColor(vec3(1,1,1))
        love.graphics.rectangle("fill", render_x, render_y, TILE_SIZE, TILE_SIZE)
      end
      local item = map:get_item_at(x, y)
      if item == "RAM" then
        love.graphics.setColor(vec3(0.34, 0.65, 0.86))
        love.graphics.circle("fill", l2r(x-.5), l2r(y-.5), l2r(0.4), 4)
      elseif item == "GOAL" then
        love.graphics.setColor(vec3(0.16, 0.67, 0.25))
        love.graphics.rectangle("fill", render_x, render_y, TILE_SIZE, TILE_SIZE)

      end
      love.graphics.setColor(0,0,0)
      love.graphics.rectangle("line", render_x, render_y, TILE_SIZE, TILE_SIZE)
    end
  end
end

function draw_robot()
  love.graphics.setColor(vec3(0.14, 0.09, 0.48))
  love.graphics.circle("fill", l2r(robot.x-.5), l2r(robot.y-.5), TILE_SIZE/2)
end

return main
