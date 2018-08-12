local HALF_PI = math.pi/2

local LEFT  = 0
local DOWN  = 1
local RIGHT = 2
local UP    = 3

local Direction = {
  "DOWN" , DOWN  = DOWN;
  "RIGHT", RIGHT = RIGHT;
  "UP"   , UP    = UP;
  "LEFT" , LEFT  = LEFT;
  angle = function (dir)
    return (3-dir)*HALF_PI
  end;
  turn_left = function (dir)
    return (dir+1)%4
  end;
  turn_right = function (dir)
    return (dir-1)%4
  end;
  delta = function (dir)
    if dir == DOWN  then return  0,  1 end
    if dir == RIGHT then return  1,  0 end
    if dir == UP    then return  0, -1 end
    if dir == LEFT  then return -1,  0 end
    return 0, 0
  end;
}

return Direction
