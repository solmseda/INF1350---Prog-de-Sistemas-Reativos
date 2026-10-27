
local scanner = {}

-- Estado interno do scanner
local scanning = false

-- Quantidade de redes encontradas
local network_count = 0

-- Verifica se uma varredura esta em andamento
function scanner.is_scanning()
    return scanning
end

-- Retorna a quantidade da ultima varredura
function scanner.get_network_count()
    return network_count
end

-- Processa os resultados recebidos
local function on_scan_complete(networks)
    scanning = false
    network_count = 0

    print("[SCANNER] Varredura concluida!")

    if networks == nil then
        print("[SCANNER] Nenhuma rede encontrada")
        return
    end

    for bssid, info in pairs(networks) do
        network_count = network_count + 1

        print("SSID: " .. tostring(info.ssid))
        print("RSSI: " .. tostring(info.rssi) .. " dBm")
        print("Canal: " .. tostring(info.channel))
        print("BSSID: " .. tostring(bssid))
        print("Seguranca: " .. tostring(info.authmode))
    end

    print("[SCANNER] Total: " .. network_count)
end

-- Inicia uma nova varredura
function scanner.start()
    if scanning then
        return false
    end

    scanning = true

    print("[SCANNER] Iniciando varredura...")

    wifi.sta.getap({show_hidden = 1}, 1, on_scan_complete)

    return true
end

return scanner
