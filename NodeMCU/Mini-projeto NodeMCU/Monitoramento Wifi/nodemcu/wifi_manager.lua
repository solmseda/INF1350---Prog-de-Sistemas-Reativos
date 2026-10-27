
local wifi_manager = {}

local config = require("config")

local connected = false
local current_ip = nil

function wifi_manager.is_connected()
    return connected
end

function wifi_manager.get_ip()
    return current_ip
end

function wifi_manager.start(on_connected)

    print("[WIFI] Iniciando conexao...")
    print("[WIFI] SSID: " .. config.WIFI_SSID)

    connected = false
    current_ip = nil

    wifi.setmode(wifi.STATION)

    -- Evento de conexao bem-sucedida
    wifi.eventmon.register(
        wifi.eventmon.STA_GOT_IP,
        function(info)
            connected = true
            current_ip = info.IP

            print("[WIFI] Conectado!")
            print("[WIFI] IP: " .. current_ip)

            if on_connected then
                on_connected(current_ip)
            end
        end
    )

    -- Evento de desconexao
    wifi.eventmon.register(
        wifi.eventmon.STA_DISCONNECTED,
        function(info)
            connected = false
            current_ip = nil

            print("[WIFI] Desconectado!")
            print("[WIFI] Motivo: " ..
                  tostring(info.reason))
        end
    )

    -- Configura a rede
    wifi.sta.config({
        ssid = config.WIFI_SSID,
        pwd = config.WIFI_PASSWORD,
        auto = true,
        save = false
    })

    -- Solicita a conexao
    wifi.sta.connect()
end

return wifi_manager
