love.graphics.setDefaultFilter("nearest", "nearest")
function math.round(x) return math.floor(x + 0.5) end
function math.trunc(x) return (x > 0) and math.floor(x) or math.ceil(x) end

function table.count(t, v) local c=0 for i=1,#t do c=c+(t[i]==v and 1 or 0) end return c end

local swapper = require "swapper"
swapper.install()

require "setup_display"

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
