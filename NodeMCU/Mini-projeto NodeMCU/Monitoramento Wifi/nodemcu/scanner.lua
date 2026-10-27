
local scanner = {}

local state_machine = require("state_machine")
local network_store = require("network_store")

local scanning = false

function scanner.is_scanning()
    return scanning
end

function scanner.get_network_count()
    return network_store.get_count()
end

function scanner.start(on_complete)
    if scanning or not state_machine.is("WAITING") then
        print("[SCANNER] Scanner ocupado")
        return false
    end

    if not state_machine.set_state("SCANNING") then
        return false
    end

    scanning = true
    print("[SCANNER] Iniciando varredura...")

    local function finish(success)
        scanning = false

        if success then
            state_machine.set_state("PROCESSING")
            state_machine.set_state("WAITING")
        else
            state_machine.set_state("ERROR")
            state_machine.set_state("WAITING")
        end

        if on_complete then
            on_complete(success)
        end
    end

    wifi.sta.getap({
        show_hidden = 1
    }, 1, function(results)

        if results == nil then
            print("[SCANNER] Falha na varredura")
            finish(false)
            return
        end

        local parsed = {}

        for bssid, info in pairs(results) do
            local ssid, rssi, authmode, channel =
                string.match(
                    info,
                    "^([^,]*),([^,]*),([^,]*),([^,]*)$"
                )

            if ssid then
                parsed[bssid] = {
                    ssid = ssid,
                    rssi = tonumber(rssi),
                    authmode = tonumber(authmode),
                    channel = tonumber(channel),
                    bssid = bssid
                }
            end
        end

        network_store.update(parsed)

        print("[SCANNER] Varredura concluida!")
        print("[SCANNER] Total: " ..
              network_store.get_count())

        finish(true)
    end)

    return true
end

return scanner