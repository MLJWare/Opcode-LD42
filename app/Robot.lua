local Direction               = require "app.Direction"
local Program                 = require "app.Program"
local action_for              = require "app.robot_actions"

local Robot = {}
Robot.__index = Robot

function Robot:execute(commands)
  self.program = Program(commands)
end

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
    robot.dir = Direction.UP;
    robot.idle = true
    robot.move_speed = 2
    robot.vars = {}
    robot.inventory = {}
    return robot
  end
})
