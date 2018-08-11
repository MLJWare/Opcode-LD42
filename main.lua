love.graphics.setDefaultFilter("nearest", "nearest")

function math.round(x) return math.floor(x + 0.5) end

local swapper = require "swapper"

swapper.install()

local main = require "app.main"

local function pcall2 (where, fn, ...)
  local status, msg = pcall(fn, ...)
  if not status then
    print(where, msg)
    love.timer.sleep(1)
  end
end

function love.load(arg)
  if main.load then
    pcall2("load", main.load, arg)
  end
end

function love.update(dt)
  swapper.update(dt)
  pcall2("update", main.update, dt)
end

function love.draw()
  pcall2("draw", main.draw)
end
