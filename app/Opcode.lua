local Direction               = require "app.Direction"
local Program                 = require "app.Program"
local Images                  = require "app.Images"
local Global                  = require "app.Global"

local MB_LEFT   = 1
local MB_RIGHT  = 2
local MB_MIDDLE = 3

local DISPLAY_MAX = 0x11

local display
do
  local image = love.graphics.newImage("res/code-editor/display-font.png")

  local quads = {}
  for i = 0, DISPLAY_MAX do
    local x = 1 + 4*i
    local y = 1
    local w = 3
    local h = 5
    quads[i] = love.graphics.newQuad(x, y, w, h, image:getDimensions())
  end

  function display(value, x, y)
    local quad = quads[value]
    if not quad then return end
    local scale = Global.SCALE
    love.graphics.draw(image, quad, x, y, 0, scale, scale)
  end
end

local Opcode = {}
Opcode.__index = Opcode

function Opcode:try_locate_input(local_mx, local_my)
  for _, input in ipairs(self.inputs) do
    local dx = local_mx - input.dx
    local dy = local_my - input.dy
    if -3 < dx and dx < 5 and -3 < dy and dy < 7 then
      return input
    end
  end
end

function Opcode:compile()
  local result = {self.id}
  for _, input in ipairs(self.inputs) do
    table.insert(result, input:get_value())
  end
  return result
end

function Opcode:on_click(local_mx, local_my, button, isTouch)
  local input = self:try_locate_input(local_mx, local_my)
  if input and input == self.board.active_input then
    if button == MB_RIGHT then input:decrement() else input:increment() end
  end
  self.board.active_input = input

  return not input
end

function Opcode:draw(x, y)
  love.graphics.draw(self.image, x, y, 0, Global.SCALE)

  local active_input = self.board.active_input
  for _, input in ipairs(self.inputs) do
    input:draw(x, y, active_input)
  end
end

local Input = {}
do
  Input.__index = Input
  setmetatable(Input, {
    __call = function (_, input)
      assert(type(input.id) == "string", "Missing 'id' text property.")
      assert(type(input.dx) == "number", "Missing numeric 'dx' property.")
      assert(type(input.dy) == "number", "Missing numeric 'dy' property.")
      assert(type(input.value) == "number", "Missing numeric 'value' property.")
      setmetatable(input, Input)

      if not input.min then input.min = 0           end
      if not input.max then input.max = DISPLAY_MAX end
      input:ensure_range()

      return input
    end
  })
  function Input:ensure_range()
    if self.value < self.min then self.value = self.max end
    if self.value > self.max then self.value = self.min end
  end

  function Input:draw(x, y, active_input)
    if active_input == self and (love.timer.getTime()%.4<.1) then return end
    local scale = Global.SCALE
    x = x + self.dx*scale
    y = y + self.dy*scale
    display(self.value, x, y)
  end
  function Input:increment()
    self.value = self.value + 1
    self:ensure_range()
  end
  function Input:decrement()
    self.value = self.value - 1
    self:ensure_range()
  end
  function Input:is_var()
    return (self.value > 9)
  end
  function Input:get_value()
    local value = self.value
    if value > 9 then
      value = (value - 9)
      return ("ABCDEFGH"):sub(value, value)
    end
    return value
  end
end

local Red_1x1 = {}
Red_1x1.__index = Red_1x1
setmetatable(Red_1x1, {__index = Opcode})
do
  --
end
local function make_Red_1x1(self)
  setmetatable(self, Red_1x1)
  self.image = Images.get("code-editor/opcode/"..self.id)
  self.inputs = {}
  return self
end

local Red_2x1 = {}
Red_2x1.__index = Red_2x1
setmetatable(Red_2x1, {__index = Opcode})
do
  --
end
local function make_Red_2x1(self)
  setmetatable(self, Red_2x1)
  self.image = Images.get("code-editor/opcode/"..self.id)
  self.inputs = {
    Input { id = "count"; min = 1; value = 1; dx = 7; dy = 5; };
  }
  return self
end

local Yellow_2x1 = {}
Yellow_2x1.__index = Yellow_2x1
setmetatable(Yellow_2x1, {__index = Opcode})
do
  --
end
local function make_Yellow_2x1(self)
  setmetatable(self, Yellow_2x1)
  self.image = Images.get("code-editor/opcode/"..self.id)
  self.inputs = {
    Input { id = "var"; min = 0xA; value = 0xA; dx =  5; dy = 5; };
    Input { id = "value"; value = 1; dx = 24; dy = 5; };
  }
  return self
end

local Green_2x1 = {}
Green_2x1.__index = Green_2x1
setmetatable(Green_2x1, {__index = Opcode})
do
  --
end
local function make_Green_2x1(self)
  setmetatable(self, Green_2x1)
  self.image = Images.get("code-editor/opcode/"..self.id)
  self.inputs = {
    Input { id = "var"; min = 0xA; value = 0xA; dx =  5; dy = 5; };
    Input { id = "value"; value = 1; dx = 24; dy = 5; };
  }
  return self
end

local Blue_1x1 = {}
Blue_1x1.__index = Blue_1x1
setmetatable(Blue_1x1, {__index = Opcode})
do
  --
end
local function make_Blue_1x1(self)
  setmetatable(self, Blue_1x1)
  self.image = Images.get("code-editor/opcode/"..self.id)
  self.inputs = {
    Input { id = "line"; value = 1; dx = 9; dy = 5; };
  }
  return self
end

local Blue_2x1 = {}
Blue_2x1.__index = Blue_2x1
setmetatable(Blue_2x1, {__index = Opcode})
do
  --
end
local function make_Blue_2x1(self)
  setmetatable(self, Blue_2x1)
  self.image = Images.get("code-editor/opcode/"..self.id)
  self.inputs = {
    Input { id = "var" ; min = 0; value = 0xA; dx =  4; dy = 5; };
    Input { id = "line"; min = 0; value = 0xA; dx = 25; dy = 5; };
  }
  return self
end

local make_opcode = {
  ["UP"         ] = make_Red_2x1;
  ["DOWN"       ] = make_Red_2x1;
  ["LEFT"       ] = make_Red_2x1;
  ["RIGHT"      ] = make_Red_2x1;
  ["MOVE"       ] = make_Red_2x1;

  ["MOVE_1"     ] = make_Red_1x1;
  ["TURN_LEFT"  ] = make_Red_1x1;
  ["TURN_RIGHT" ] = make_Red_1x1;
  ["TURN_AROUND"] = make_Red_1x1;
  ["INSPECT"    ] = make_Red_1x1;
  ["GOAL"       ] = make_Red_1x1;

  ["ADD"        ] = make_Yellow_2x1;
  ["SUB"        ] = make_Yellow_2x1;
  ["MUL"        ] = make_Yellow_2x1;
  ["DIV"        ] = make_Yellow_2x1;

  ["JUMP"       ] = make_Blue_1x1;
  ["JUMP_LEQ"   ] = make_Blue_2x1;

  ["SET"        ] = make_Green_2x1;
}

return setmetatable(Opcode, {
  __call = function (_, opcode)
    assert(type(opcode.board)=="table", "Missing 'board' property.")
    assert(type(opcode.tiles_x) == "number", "Missing numeric 'tiles_x' property.")
    assert(type(opcode.tiles_y) == "number", "Missing numeric 'tiles_y' property.")
    local id    = assert(opcode.id, "Missing 'id' property.")
    local maker = assert(make_opcode[id], "Invalid opcode: "..id)
    maker(opcode)
    return opcode
  end
})
