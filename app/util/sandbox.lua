return function (untrustedFile, env, ...)
  env = env or {}
  local untrustedCode = love.filesystem.read(untrustedFile) or ""
  local untrustedFn, msg = load(untrustedCode, nil, "t", env)
  if not untrustedFn then return nil end
  local success, data = pcall(untrustedFn)
  if not success
  or not (type(data) == "table" or type(data) == "string") then return nil end
  return data
end
