local Direction               = require "app.Direction"
local Program                 = require "app.Program"
local Images                  = require "app.Images"

local display
do
  local image = love.graphics.newImage("res/code-editor/display-font.png")

  local quads = {}
  for i = 0, 15 do
    local x = 1 + 4*i
    local y = 1
    local w = 3
    local h = 5

    local index = (i < 10) and i or ("ABCDEF"):sub(i-9,i-9)
    quads[index] = love.graphics.newQuad(x, y, w, h, image:getDimensions())
  end

  function display(value, x, y, scale)
    local quad = quads[value]
    if not quad then return end
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(image, quad, x, y, 0, scale, scale)
  end
end

local Opcode = {}
Opcode.__index = Opcode

function Opcode:try_locate_input(local_mx, local_my)
  for _, input in ipairs(self.inputs) do
    local dx = local_mx - input.dx
    local dy = local_my - input.dy
    print(dx, dy)
    if -2 < dx and dx < 4 and -2 < dy and dy < 6 then
      return input
    end
  end
end

function Opcode:on_click(local_mx, local_my, button, isTouch)
  local input = self:try_locate_input(local_mx, local_my)
  if input and input == self.board.active_input then input:increment() end
  self.board.active_input = input
end

function Opcode:draw(x, y, scale)
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.image, x, y, 0, scale)

  local active_input = self.board.active_input
  for _, input in ipairs(self.inputs) do
    input:draw(x, y, scale, active_input)
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
      assert(input.value, "Missing 'value' property.")
      setmetatable(input, Input)
      return input
    end
  })
  function Input:draw(x, y, scale, active_input)
    if active_input == self and (love.timer.getTime()%.4<.1) then return end
    x = x + self.dx*scale
    y = y + self.dy*scale
    display(self.value, x, y, scale)
  end
  function Input:increment()
    local value = self.value
    if type(value) == "string" then
      value = 9 + (("ABCDEF"):find(value) or -9)
    end
    value = value + 1
    if value > 15    then value = 1
    elseif value > 9 then value = ("ABCDEF"):sub(value-9, value-9)
    end
    self.value = value
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
  self.image = Images.get("code-editor/"..self.id)
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
  self.image = Images.get("code-editor/"..self.id)
  self.inputs = {
    Input { id = "count"; value = 1; dx = 7; dy = 5; };
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
  self.image = Images.get("code-editor/"..self.id)
  self.inputs = {
    Input { id = "var";   value = "A"; dx =  5; dy = 5; };
    Input { id = "value"; value = "A"; dx = 24; dy = 5; };
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
  self.image = Images.get("code-editor/"..self.id)
  self.inputs = {
    Input { id = "var";   value = "A"; dx =  5; dy = 5; };
    Input { id = "value"; value = "A"; dx = 24; dy = 5; };
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
  self.image = Images.get("code-editor/"..self.id)
  self.inputs = {
    Input { id = "line"; value = "A"; dx = 9; dy = 5; };
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
  self.image = Images.get("code-editor/"..self.id)
  self.inputs = {
    Input { id = "var" ; value = "A"; dx =  4; dy = 5; };
    Input { id = "line"; value = "A"; dx = 25; dy = 5; };
  }
  return self
end

local make_opcode = {
  ["UP"      ] = make_Red_2x1;
  ["DOWN"    ] = make_Red_2x1;
  ["LEFT"    ] = make_Red_2x1;
  ["RIGHT"   ] = make_Red_2x1;

  ["JUMP"    ] = make_Blue_1x1;
  ["JUMP_LEQ"] = make_Blue_2x1;

  ["INSPECT"] = make_Red_1x1;

  ["ADD"     ] = make_Yellow_2x1;
  ["SUB"     ] = make_Yellow_2x1;
  ["MUL"     ] = make_Yellow_2x1;
  ["DIV"     ] = make_Yellow_2x1;

  ["SET"     ] = make_Green_2x1;
}

return setmetatable(Opcode, {
  __call = function (_, opcode)
    assert(type(opcode.board)=="table", "Missing 'board' property.")
    local id    = assert(opcode.id, "Missing 'id' property.")
    local maker = assert(make_opcode[id], "Invalid opcode: "..id)
    maker(opcode)
    return opcode
  end
})
