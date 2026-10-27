
local wifi_manager = {}

local config = require("config")

local connected = false
local current_ip = nil

-- Consulta o estado da conexão
function wifi_manager.is_connected()
    return connected
end

-- Retorna o endereço IP atual
function wifi_manager.get_ip()
    return current_ip
end

-- Inicializa a conexão Wi-Fi
function wifi_manager.start(on_connected)

    print("[WIFI] Iniciando conexao...")

    connected = false
    current_ip = nil

    wifi.setmode(wifi.STATION)

    wifi.sta.config({
        ssid = config.WIFI_SSID,
        pwd = config.WIFI_PASSWORD,
        save = false,

        got_ip_cb = function(info)
            connected = true
            current_ip = info.IP

            print("[WIFI] Conectado!")
            print("[WIFI] IP: " .. current_ip)

            if on_connected then
                on_connected(current_ip)
            end
        end
    })
end

return wifi_manager
