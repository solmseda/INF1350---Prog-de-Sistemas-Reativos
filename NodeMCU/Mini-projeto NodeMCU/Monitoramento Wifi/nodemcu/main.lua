
local config = require("config")
local wifi_manager = require("wifi_manager")
local scanner = require("scanner")
local scheduler = require("scheduler")
local network_store = require("network_store")

local main = {}

local initialized = false

local function execute_scan()
    local started = scanner.start(function(success)
        if success then
            print("[MAIN] Redes disponiveis: " ..
                  network_store.get_count())
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

    -- Primeira varredura imediata
    execute_scan()

    -- Inicia o agendamento das proximas
    scheduler.start(execute_scan)
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
