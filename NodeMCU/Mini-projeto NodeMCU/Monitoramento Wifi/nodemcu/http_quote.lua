-- Escape JSON sem alocar o encoder nativo sjson.
return function(value)
    return '"' .. string.gsub(value, '[%z\1-\31\\"]', function(c)
        return string.format('\\u%04x', string.byte(c))
    end) .. '"'
end
