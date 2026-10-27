
local state_machine = {}

local states = {
    WAITING = "WAITING",
    SCANNING = "SCANNING",
    PROCESSING = "PROCESSING",
    ERROR = "ERROR"
}

local current_state = states.WAITING

local transitions = {
    WAITING = {
        SCANNING = true
    },
    SCANNING = {
        PROCESSING = true,
        ERROR = true
    },
    PROCESSING = {
        WAITING = true,
        ERROR = true
    },
    ERROR = {
        WAITING = true
    }
}

function state_machine.get_state()
    return current_state
end

function state_machine.set_state(new_state)
    local allowed = transitions[current_state]

    if not allowed or not allowed[new_state] then
        print("[STATE] Transicao invalida: " ..
            current_state .. " -> " .. tostring(new_state))
        return false
    end

    print("[STATE] " .. current_state ..
          " -> " .. new_state)

    current_state = new_state
    return true
end

function state_machine.is(state)
    return current_state == state
end

return state_machine