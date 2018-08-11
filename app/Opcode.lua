local Direction               = require "app.Direction"
local Program                 = require "app.Program"
local Images                  = require "app.Images"

local Opcode = {}
Opcode.__index = Opcode


local Red_1x1 = {}
Red_1x1.__index = Red_1x1
setmetatable(Red_1x1, {__index = Opcode})
do
  --
  function Red_1x1:draw(x, y, scale)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.image, x, y, 0, scale)
  end
end
local function make_Red_1x1(self)
  setmetatable(self, Red_1x1)
  self.image = Images.get("code-editor/"..self.id)
  return self
end

local Red_2x1 = {}
Red_2x1.__index = Red_2x1
setmetatable(Red_2x1, {__index = Opcode})
do
  --
  function Red_2x1:draw(x, y, scale)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.image, x, y, 0, scale)
  end
end
local function make_Red_2x1(self)
  setmetatable(self, Red_2x1)
  self.image = Images.get("code-editor/"..self.id)
  self.count = 1
  return self
end

local Yellow_2x1 = {}
Yellow_2x1.__index = Yellow_2x1
setmetatable(Yellow_2x1, {__index = Opcode})
do
  --
  function Yellow_2x1:draw(x, y, scale)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.image, x, y, 0, scale)
  end
end
local function make_Yellow_2x1(self)
  setmetatable(self, Yellow_2x1)
  self.image = Images.get("code-editor/"..self.id)
  self.var = "A"
  self.val = "A"
  return self
end

local Green_2x1 = {}
Green_2x1.__index = Green_2x1
setmetatable(Green_2x1, {__index = Opcode})
do
  --
  function Green_2x1:draw(x, y, scale)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.image, x, y, 0, scale)
  end
end
local function make_Green_2x1(self)
  setmetatable(self, Green_2x1)
  self.image = Images.get("code-editor/"..self.id)
  self.var = "A"
  self.val = "A"
  return self
end

local Blue_1x1 = {}
Blue_1x1.__index = Blue_1x1
setmetatable(Blue_1x1, {__index = Opcode})
do
  --
  function Blue_1x1:draw(x, y, scale)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.image, x, y, 0, scale)
  end
end
local function make_Blue_1x1(self)
  setmetatable(self, Blue_1x1)
  self.image = Images.get("code-editor/"..self.id)
  self.line = "A"
  return self
end

local Blue_2x1 = {}
Blue_2x1.__index = Blue_2x1
setmetatable(Blue_2x1, {__index = Opcode})
do
  --
  function Blue_2x1:draw(x, y, scale)
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.image, x, y, 0, scale)
  end
end
local function make_Blue_2x1(self)
  setmetatable(self, Blue_2x1)
  self.image = Images.get("code-editor/"..self.id)
  self.var  = "A"
  self.line = "A"
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
    local id = assert(opcode.id, "Missing 'id' property.")
    local maker = assert(make_opcode[id], "Invalid opcode: "..id)
    maker(opcode)
    return opcode
  end
})
