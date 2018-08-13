local Direction               = require "app.Direction"
local Program                 = require "app.Program"

local Board = {}
Board.__index = Board

function Board:compile()
  local tiles_x = self.tiles_x
  local tiles_y = self.tiles_y
  local code   = self.code

  local program = {
    A = {};
    B = {};
    C = {};
    D = {};
    E = {};
    F = {};
    G = {};
    H = {};
  }

  for y = 1, tiles_y do
    local row_id = ("ABCDEFGH"):sub(y, y)
    local row = program[row_id]
    for x = 1, tiles_x do
      local val = code[x + (y-1)*tiles_x]
      if type(val) == "table" then
        table.insert(row, val:compile())
      else
        table.insert(row, "NOP")
      end
    end
  end

  return Program(program)
end

local REFER_LEFT    = 1
local REFER_UP      = 2
local REFER_UP_LEFT = 3

function Board:empty_at(x, y)
  local tiles_x = self.tiles_x
  local tiles_y = self.tiles_y

  if x < 1 or y < 1 or x > tiles_x or y > tiles_y then return false end
  local val = self.code[x + (y-1)*tiles_x]
  return (val == nil)
end

function Board:opcode_at(x, y)
  local tiles_x = self.tiles_x
  local tiles_y = self.tiles_y

  if x < 1 or y < 1 or x > tiles_x or y > tiles_y then return false end
  local val = self.code[x + (y-1)*tiles_x]
  return type(val) == "table" and val or nil
end

function Board:place(opcode, tile_x, tile_y)
  local board_code     = self.code
  local board_tiles_x  = self.tiles_x

  local opcode_tiles_x = opcode.tiles_x
  local opcode_tiles_y = opcode.tiles_y

  for yi = 1, opcode_tiles_y do
    local y = tile_y + yi - 1
    for xi = 1, opcode_tiles_x do
      local x = tile_x + xi - 1
      local val
      if     xi == 1 and yi == 1 then val = not opcode.make and opcode or opcode:make()
      elseif xi  > 1 and yi == 1 then val = REFER_LEFT
      elseif xi == 1 and yi  > 1 then val = REFER_UP
      else                            val = REFER_UP_LEFT
      end
      board_code[x + (y-1)*board_tiles_x] = val
    end
  end

  return
end

function Board:try_locate(x, y)
  local tiles_x = self.tiles_x
  local tiles_y = self.tiles_y
  local code    = self.code

  if x > tiles_x or y > tiles_y then return end

  while true do
    if x < 1 or y < 1 then return end

    local val = code[x + (y-1)*tiles_x]
    if not val then return
    elseif val == REFER_UP      then y = y - 1
    elseif val == REFER_LEFT    then x = x - 1
    elseif val == REFER_UP_LEFT then x, y = x - 1, y - 1
    else
      return val, x, y
    end
  end
end

function Board:remove(x, y)
  local opcode, opcode_x, opcode_y = self:try_locate(x,y)
  if not opcode then return end

  local opcode_tiles_x = opcode.tiles_x
  local opcode_tiles_y = opcode.tiles_y
  local board_code     = self.code
  local board_tiles_x  = self.tiles_x

  for yi = 1, opcode_tiles_y do
    local y = opcode_y + yi - 1
    for xi = 1, opcode_tiles_x do
      local x = opcode_x + xi - 1
      board_code[x + (y-1)*board_tiles_x] = nil
    end
  end
end

function Board:keypressed(key, scancode, isrepeat)
  local input = self.active_input
  if not input then return end
  local value = tonumber(key, 18)
  if not value or value < input.min or value > input.max then return end
  input.value = value
end

return setmetatable(Board, {
  __call = function (_, board)
    local tiles_x = board.tiles_x assert(type(tiles_x)=="number")
    local tiles_y = board.tiles_y assert(type(tiles_y)=="number")
    setmetatable(board, Board)

    board.code = {}
    board.active_input = nil

    return board
  end
})
