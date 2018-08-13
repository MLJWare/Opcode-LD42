unlockOpcode("MOVE_1")
unlockOpcode("GOAL")
instructions {
[[
Welcome to Opcode.
Your Objective:
Program the robot to
reach the goal.]];
[[
"How?" you may ask.
Well, don't you worry,
I'm here to guide you!]];
[[
See those colored boxes
to the right? We call
those "opcodes".]];
[[
Using opcodes, you can
command the robot to do
almost anything.
]];
[[
I've helped you out a
bit by placing some
opcodes already. Try
running it to see what
it does.]];
}

return {
  dir = "RIGHT";
  {"MOVE_1", 2, 3};
  {"MOVE_1", 3, 3};
  {"MOVE_1", 4, 3};
  {"MOVE_1", 5, 3};
  {"MOVE_1", 6, 3};
  {"MOVE_1", 7, 3};
  {"MOVE_1", 8, 3};
  {"GOAL"  , 9, 3};
}
