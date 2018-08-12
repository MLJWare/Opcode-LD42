local Global = require "app.Global"


local width, height, flags = love.window.getMode()

--local desktop_width, desktop_height = love.window.getDesktopDimensions(flags.display or 1)

local Images = require "app.Images"

local board_image = Images.get("code-editor/Board")

local board_w, board_h = board_image:getDimensions()

Global.SCALE = 4

love.window.setMode(board_w*Global.SCALE, board_h*Global.SCALE, {
  fullscreen = false;
  fullscreentype = "desktop";
  vsync = true;
  --msaa = 0;
  stencil = true;
  depth = 0;
  resizable = true;
  borderless = false;
  centered = true;
  display = 2;
  minwidth = board_w;
  minheight = board_h;
  --highdpi = false;
  x = nil;
  y = nil;
})


function love.resize(screen_w, screen_h)
  local scale_w = math.floor(screen_w/board_w)
  local scale_h = math.floor(screen_h/board_h)
  local scale   = math.min(scale_w, scale_h)

  Global.SCALE  = scale
  Global.OFFSET_X = math.floor((screen_w - board_w*scale)/2)
  Global.OFFSET_Y = math.floor((screen_h - board_h*scale)/2)
end
