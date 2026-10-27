local config = {}
config.DEVICE_NAME = "wifi-monitor"
-- Rede Wi-Fi (2.4 GHz)
config.WIFI_SSID = "NOME_DA_REDE"
config.WIFI_PASSWORD = "SENHA_DA_REDE"

-- Configurações futuras
config.SCAN_INTERVAL = 10000 -- milissegundos
config.HTTP_PORT = 80

return config