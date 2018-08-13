unlockOpcode("TURN_LEFT")
unlockOpcode("TURN_RIGHT")
unlockOpcode("TURN_AROUND")
instructions {
[[
Wasn't that just fun?!
]];
[[
No...?
Well, ok then, let's
spice things up a bit,
shall we?
]];
[[
Here are some new
opcodes for rotating
the robot left, right
and half way around.]];
[[
Also, I forgot to say:
The opcode with the
flag causes the robot
to check whether it's
on top of the goal.]];
[[
You'll need to use it
to finish the level.
Good luck; I'll be
waiting for you in the
next level.]];
}

return {
  dir = "RIGHT";
  {"MOVE_1", 2, 3};
  {"MOVE_1", 4, 3};
  {"MOVE_1", 5, 3};
  {"MOVE_1", 8, 3};
  {"GOAL"  , 9, 3};
}
