local store = {}
local networks = {}
local count = 0
local last_update = 0
local capacity = 5 -- limite fixo para a RAM disponivel no ESP8266

local function get_rssi(info)
    return tonumber(string.match(info, ",(-?%d+),%d+,%d+$"))
end

local function find_weakest()
    local weakest, weakest_rssi
    for key, value in pairs(networks) do
        local signal = get_rssi(value)
        if not weakest_rssi or signal < weakest_rssi then
            weakest, weakest_rssi = key, signal
        end
    end
    return weakest, weakest_rssi
end

function store.clear()
    networks = {}
    count = 0
end

-- Mantem as strings originais do firmware: uma unica tabela para ate 10 APs.
-- Nao cria uma tabela e varias strings de campos para cada resultado do scan.
function store.add_result(bssid, info)
    local rssi = get_rssi(info)
    if not rssi then return end
    if networks[bssid] then
        networks[bssid] = info
        return
    end
    if count < capacity then
        networks[bssid] = info
        count = count + 1
        return
    end
    local weakest, weakest_rssi = find_weakest()
    if rssi > weakest_rssi then
        networks[weakest] = nil
        networks[bssid] = info
    end
end

function store.finish()
    last_update = tmr.time()
    collectgarbage("collect")
    print("[STORE] Redes armazenadas:", count)
    print("[STORE] Heap livre:", node.heap())
end

-- Expande apenas quando um consumidor solicita os dados, nunca no scanner.
-- O chamador deve liberar a lista apos utiliza-la, sem manter um cache duplicado.
function store.get_all()
    local result = {}
    for bssid, info in pairs(networks) do
        local ssid, rssi, authmode, channel =
            string.match(info, "^(.*),(-?%d+),(%d+),(%d+)$")
        result[#result + 1] = {
            ssid = ssid, rssi = tonumber(rssi), authmode = tonumber(authmode),
            channel = tonumber(channel), bssid = bssid
        }
    end
    return result
end

function store.get_count()
    return count
end

function store.get_last_update()
    return last_update
end

return store
