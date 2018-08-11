return function (element, event, ...)
  if not event then return end
  if type(element) ~= "table" then return end

  local callback = element[event]
  if not callback then return end

  return callback(...)
end
