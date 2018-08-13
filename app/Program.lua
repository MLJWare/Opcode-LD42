local function next_row(row)
  local i = ("ABCDEFGH"):find(row) + 1
  return ("ABCDEFGH"):sub(i, i), 0
end

return function (program)
  return coroutine.wrap(function ()
    local row = "A"
    local pos = 0
    while true do
      local code   = program[row] if not code   then break end
      local opcode = code[pos + 1]

      if not opcode then
        row, pos = next_row(row)
        goto continue
      end

      if opcode ~= "NOP" then
        local jump = coroutine.yield(unpack(opcode))
        if type(jump) == "string" then
          row = jump
          goto continue
        elseif type(jump) == "number" then
          pos = jump
          goto continue
        end
      end
      pos = pos + 1
      ::continue::
    end
    -- QUESTION yield "END-OF-PROGRAM"?
  end)
end
