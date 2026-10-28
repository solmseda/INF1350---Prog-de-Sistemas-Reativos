local machine = {}
local current = "WAITING"
-- Strings substituem as tabelas aninhadas de estados e transicoes.
local transitions = {
    WAITING = "|SCANNING|",
    SCANNING = "|PROCESSING|ERROR|",
    PROCESSING = "|WAITING|ERROR|",
    ERROR = "|WAITING|"
}

function machine.set_state(next_state)
    if type(next_state) ~= "string" or
       not string.find(transitions[current], "|" .. next_state .. "|", 1, true) then
        print("[STATE] Transicao invalida:", tostring(next_state))
        return false
    end
    print("[STATE] " .. current .. " -> " .. next_state)
    current = next_state
    return true
end

function machine.get_state() return current end
function machine.is(value) return current == value end
return machine
