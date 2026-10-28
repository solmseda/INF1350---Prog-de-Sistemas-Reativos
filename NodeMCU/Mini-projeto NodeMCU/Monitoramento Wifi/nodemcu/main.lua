
local config = require("config")
local wifi_manager = require("wifi_manager")
local scanner = require("scanner")
local scheduler = require("scheduler")
local network_store = require("network_store")
local http_server = require("http_server")

local main = {}

local initialized = false

local function execute_scan()
    local started = scanner.start(function(success, received, missing)
        if success then
            print("[MAIN] Redes disponiveis: " ..
                  network_store.get_count())
        elseif received and received > 0 then
            print("[MAIN] Varredura parcial")
            print("[MAIN] Canais com resposta:", received)
            print("[MAIN] Canais sem resposta:", missing)
            print("[MAIN] Canais nao tentados:",
                  config.SCAN_LAST_CHANNEL - received - missing)
            print("[MAIN] Redes:", network_store.get_count())
        else
            print("[MAIN] Falha na varredura")
        end

        scheduler.next()
    end)

    if not started then
        print("[MAIN] Nao foi possivel iniciar scanner")
        scheduler.next()
    end
end

local function on_wifi_connected(ip)
    print("[MAIN] Wi-Fi disponivel")
    print("[MAIN] Endereco IP: " .. ip)

    if initialized then
        return
    end

    initialized = true

    -- Inicia o servidor HTTP
    http_server.start()

    -- Ativa o scheduler antes do scan; a conclusao agenda a proxima rodada.
    scheduler.start(execute_scan, true)
end

function main.start()
    print("========================")
    print("       WIFI MONITOR")
    print("========================")

    print("[MAIN] Dispositivo: " ..
          config.DEVICE_NAME)

    wifi_manager.start(on_wifi_connected)
end

return main
