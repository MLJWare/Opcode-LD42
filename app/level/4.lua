unlockOpcode("JUMP")
instructions {
[[
Told you it was cool!
See if you're able to
get all the floppy
disks in each level.]];
[[
Anyways, here's another
opcode for you. This
one allows you to jump
to a different position
in the code.]];
[[
A number from 0 to 9
makes the program jump
to that column, and a
letter from A to H will
jump to that row.]];
isAndroid and [[
You can change the
value of the opcode by
tapping on the input
field.]] or [[
You can change the
value of the opcode by
clicking on the input
field.]];
unpack({[[
The left mouse button
is used to increment,
and the right button
is used to decrement.]];
[[
Once you've clicked on
the field, you can also
simply type the value
you want the input to
have with you keyboard.]];
[[
Also note that once the
program gets to the end
of a row, it continues
from the start of the
next one.]];
}, isAndroid and 3 or 1)
}

return "RIGHT";
