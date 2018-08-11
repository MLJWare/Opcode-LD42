local HALF_PI = math.pi/2

local Direction = {
  "RIGHT", RIGHT = 1;
  "UP"   , UP    = 2;
  "LEFT" , LEFT  = 3;
  "DOWN" , DOWN  = 4;
  angle = function (dir)
    return (3-dir)*HALF_PI
  end;
}

return Direction
