
local network_store = {}

local networks = {}
local count = 0
local last_update = 0

function network_store.update(new_networks)
    networks = new_networks or {}

    count = 0
    for _ in pairs(networks) do
        count = count + 1
    end

    last_update = tmr.time()

    print("[STORE] Redes armazenadas: " .. count)
end

function network_store.get_all()
    return networks
end

function network_store.get_count()
    return count
end

function network_store.get_last_update()
    return last_update
end

return network_store
