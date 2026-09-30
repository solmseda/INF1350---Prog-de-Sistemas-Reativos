local EventManager = {}

EventManager.listeners = {}

function EventManager.on(eventName, callback)
    if EventManager.listeners[eventName] == nil then
        EventManager.listeners[eventName] = {}
    end

    table.insert(EventManager.listeners[eventName], callback)
end

function EventManager.emit(eventName, data)
    local listeners = EventManager.listeners[eventName]

    if listeners == nil then
        return
    end

    for _, callback in ipairs(listeners) do
        callback(data)
    end
end

function EventManager.clear()
    EventManager.listeners = {}
end

return EventManager