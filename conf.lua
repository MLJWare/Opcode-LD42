SCALE = 4

function love.conf(t)
  t.identity      = "robot-game"
  t.window.title  = "Robot Game"
  t.window.width  = 216*SCALE
  t.window.height = 134*SCALE
  t.window.x      = 1400
  t.window.y      = 0
  t.window.display = 2
end
