local popup_digit             = require "app.popup_digit"

return function (number, digit_count, x, y)
  for i = 1, digit_count do
    local digit = math.floor(number/(10^(digit_count-i)))%10
    popup_digit(digit, x + (i-1)*8, y)
  end
end
