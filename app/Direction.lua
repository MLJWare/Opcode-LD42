local HALF_PI = math.pi/2

local DIR = {
  LEFT  = 0;
  DOWN  = 1;
  RIGHT = 2;
  UP    = 3;
}

local Direction = {
  [DIR.LEFT ] = "LEFT" , LEFT  = DIR.LEFT;
  [DIR.DOWN ] = "DOWN" , DOWN  = DIR.DOWN;
  [DIR.RIGHT] = "RIGHT", RIGHT = DIR.RIGHT;
  [DIR.UP   ] = "UP"   , UP    = DIR.UP;
  angle = function (dir)
    return (3-dir)*HALF_PI
  end;
  from = function (str)
    return DIR[str] or DIR.LEFT
  end;
  turn_left = function (dir)
    return (dir+1)%4
  end;
  turn_right = function (dir)
    return (dir-1)%4
  end;
  delta = function (dir)
    if dir == DIR.DOWN  then return  0,  1 end
    if dir == DIR.RIGHT then return  1,  0 end
    if dir == DIR.UP    then return  0, -1 end
    if dir == DIR.LEFT  then return -1,  0 end
    return 0, 0
  end;
}

return Direction
