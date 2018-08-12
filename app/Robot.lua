local Direction               = require "app.Direction"
local action_for              = require "app.robot_actions"

local Robot = {}
Robot.__index = Robot

function Robot:execute(program)
  self.program = program
end

function Robot:is_idle()
  return not self.program
end

function Robot:set_action(command, ...)
  self.action = command and action_for[command](self, ...)
end

function Robot:has_won()
  local won = self.won
  self.won = nil
  return won
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
    return true
  else
    self:set_action(command, a, b, c, d)
  end
end

return setmetatable(Robot, {
  __call = function (_, robot)
    assert(type(robot.x)=="number")
    assert(type(robot.y)=="number")
    setmetatable(robot, Robot)
    robot.dir = Direction.UP;
    robot.anim = 0;
    robot.move_speed = 2
    robot.vars = { A = 0; B = 0; C = 0; D = 0; E = 0; F = 0; G = 0; H = 0; }
    robot.inventory = {}
    return robot
  end
})
