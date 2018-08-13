return function (path)
  local success, result = pcall(require, path)
  if success then return result end
end
