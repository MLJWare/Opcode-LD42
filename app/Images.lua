local _cache = {}
local Images = {}

function Images.get(path)
  local image = _cache[path]
  if not image then
    local filename = ("res/%s.png"):format(path)
    image = love.graphics.newImage( filename )
    _cache[path] = image
  end
  return image
end

return Images
