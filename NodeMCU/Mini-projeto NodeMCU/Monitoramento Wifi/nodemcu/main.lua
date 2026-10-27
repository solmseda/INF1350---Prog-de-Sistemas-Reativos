local config = require("config")
local wifi_manager = require("wifi_manager")

local main = {}

-- Callback de conexão
local function on_wifi_connected(ip)
    print("[MAIN] Wi-Fi disponivel")
    print("[MAIN] Endereco IP: " .. ip)

    -- Futuramente:
    -- Iniciar o scanner
    -- Iniciar o servidor HTTP
end

function main.start()
    print("Iniciando!!!")

    print("[MAIN] Dispositivo: ", config.DEVICE_NAME)

    wifi_manager.start(on_wifi_connected)
end

return main