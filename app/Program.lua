return function (commands)
  return coroutine.wrap(function ()
    local pos = 1
    while pos <= #commands do
      local arg = coroutine.yield(unpack(commands[pos]))
      pos = arg or (pos + 1)
    end
  end)
end
