local _cache = {}

return function (r, g, b, a)
  a = a or 1
  local id = ("#%02X%02X%02X%02X"):format(r, g, b, a*255)
  local col = _cache[id]
  if not col then
    col = {r/255, g/255, b/255, a}
    _cache[id] = col
  end
  return col
end
