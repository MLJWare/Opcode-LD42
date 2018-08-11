local Direction               = require "app.Direction"
local Program                 = require "app.Program"

local Board = {}
Board.__index = Board

function Board:compile()
  return {
    {"LEFT", 1};
    {"UP", 1};
    {"RIGHT", 1};
    {"DOWN", 1};
    {"JUMP", 1};
  };
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
      if     xi == 1 and yi == 1 then val = opcode:make()
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

return setmetatable(Board, {
  __call = function (_, board)
    local tiles_x = board.tiles_x assert(type(tiles_x)=="number")
    local tiles_y = board.tiles_y assert(type(tiles_y)=="number")
    setmetatable(board, Board)

    board.code = {}

    return board
  end
})
