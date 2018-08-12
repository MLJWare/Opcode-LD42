return function (program)
  return coroutine.wrap(function ()
    local row = "A"
    local pos = 1
    while true do
      local code   = program[row] if not code   then break end
      local opcode = code[pos]    if not opcode then break end

      local new_row = coroutine.yield(unpack(opcode))
      if new_row then
        row, pos = new_row, 0
      end
      pos = pos + 1
    end
    -- QUESTION yield "END-OF-PROGRAM"?
  end)
end
