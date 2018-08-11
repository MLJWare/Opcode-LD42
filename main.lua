local swapper = require "swapper"

swapper.install()

local main = require "app.main"

function love.load(arg)
  pcall(main.load, arg)
end

function love.update(dt)
  swapper.update(dt)
  local status, msg = pcall(main.update, dt)
  if not status then
    print(msg)
    love.timer.sleep(1)
  end
end

function love.draw()
  pcall(main.draw)
end
