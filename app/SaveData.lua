local SaveData = {}

local save_data = {}

local SAVE_FILE_NAME = "save.data"

function SaveData.get_number (id)
  return tonumber(save_data[id]) or 0
end

function SaveData.set_number (id, value)
  save_data[id] = tonumber(value) or 0
end

function SaveData.inc_number (id, change)
  save_data[id] = (tonumber(save_data[id]) or 0) + change
end

function SaveData.get_bool (id)
  return save_data[id] and true or false
end

function SaveData.set_bool (id, value)
  save_data[id] = value and true or false
end

function SaveData.toggle_bool (id)
  save_data[id] = not save_data[id]
end

function SaveData.update_number (id, value)
  local value   = tonumber(value) or 0
  local current = tonumber(save_data[id]) or 0
  if current < value then
    save_data[id] = value
    return value
  end
  return current
end

function SaveData.update_level_status(map, robot)
  local id = map.id
  SaveData.update_number(id.."-FLOPPY-MAX", map.item_count["FLOPPY"] or 0)

  local robot_floppy_count = table.count(robot.inventory, "FLOPPY")
  local level_floppy_count = SaveData.get_number(id.."-FLOPPY")

  if robot_floppy_count > level_floppy_count then
    SaveData.update_number(id.."-FLOPPY", robot_floppy_count)
    SaveData.inc_number("global-FLOPPY", robot_floppy_count - level_floppy_count)
  end

  local level_floppy_count = SaveData.get_number(id.."-FLOPPY")
  local total_floppy_count = SaveData.get_number("global-FLOPPY")

  SaveData.lua2disk()
end

local stringify
do
  function stringify(v)
    if type(v) == "table" then
      local result = {"{"}
      for k, v in pairs(save_data) do
        table.insert(result, ("[%q]=%s;"):format(k, stringify(v)))
      end
      table.insert(result, "};")
      return table.concat(result,"\n")
    elseif type(v) == "string" then
      return ("%q"):format(v)
    else
      assert(type(v)~="function")
      assert(type(v)~="userdata")
      return tostring(v)
    end
  end
end

function SaveData.lua2disk()
  local data = "return "..stringify(save_data)
  love.filesystem.write(SAVE_FILE_NAME, data)
end

function SaveData.disk2lua()
  local data = love.filesystem.read(SAVE_FILE_NAME)
  if data then
    save_data = load(data)()
  end
end

SaveData.disk2lua()

return SaveData
