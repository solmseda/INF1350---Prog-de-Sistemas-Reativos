local config = {}
config.DEVICE_NAME = "wifi-monitor"
-- Rede Wi-Fi (2.4 GHz)
config.WIFI_SSID = "Sol phone"
config.WIFI_PASSWORD = "bata1607"

-- Limites para reduzir o pico de memoria da varredura
-- Reserva inicial de seguranca; validar na placa em ambientes com muitas redes.
config.SCAN_MIN_HEAP = 12000
config.SCAN_CHANNEL_DELAY = 250 -- pausa entre canais (ms)
config.SCAN_CHANNEL_TIMEOUT = 8000 -- espera maxima pelo callback (ms)
config.SCAN_LAST_CHANNEL = 13 -- ajuste conforme os canais permitidos na regiao

-- Agendamento e servidor
config.SCAN_INTERVAL = 30000 -- milissegundos
config.HTTP_PORT = 80

return config